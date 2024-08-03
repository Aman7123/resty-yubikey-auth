-- Cookie Management Module
-- Functions related to cookie generation and parsing.
-- 

local _M = {}

local ngx = require "ngx"
local cjson = require "cjson"
local resty_sha256 = require "resty.sha256"
local resty_str = require "resty.string"
local env = require "yubikey-otp-authentication.env"

-- Create a cookie string
function _M.build_http_cookie(cookie_value, domain, expires)
    local set_cookie = string.format("%s=%s; Path=/; Expires=%s; HttpOnly; Domain %s; SameSite=%s; %s", env.cookie_name, cookie_value, expires, domain, env.cookie_samesite, env.cookie_secure)
    return set_cookie
end

-- uses sha256 lib to gen a base64 encoded string of a json token
function _M.generate_cookie(otp, domain, expires)
    local cookie_raw_json = {
        otp = otp,
        hash = _M.generate_cookie_hash(otp, domain, expires),
        domain = domain,
        expires = expires
    }
    local cookie_string = cjson.encode(cookie_raw_json)
    return ngx.encode_base64(cookie_string)
end

function _M.generate_cookie_hash(otp, domain, expires)
    local sha256 = resty_sha256:new()
    sha256:update(otp)
    sha256:update(env.request_id)
    sha256:update(domain)
    sha256:update(expires)
    sha256:update(env.cookie_secret)
    local digest = sha256:final()
    return resty_str.to_hex(digest)
end


-- decodes the base64 cookie and validates the hash based on provided and known info
function _M.validate_cookie(cookie)
    local b64_status, cookie_value = pcall(ngx.decode_base64, cookie)
    if not b64_status then
        return false, "Failed to decode base64"
    end
    local json_status, cookie_raw_json = pcall(cjson.decode, cookie_value)
    if not json_status then
        return false, "Failed to decode JSON"
    end
    if ngx.time() > ngx.parse_http_time(cookie_raw_json.expires) then
        return false, "Cookie expired"
    end
    local cookie_hash = _M.generate_cookie_hash(cookie_raw_json.otp, cookie_raw_json.domain, cookie_raw_json.expires)
    return cookie_hash == cookie_raw_json.hash, cookie_raw_json
end


return _M