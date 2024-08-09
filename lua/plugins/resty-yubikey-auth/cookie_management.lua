-- Cookie Management Module
-- Functions related to cookie generation and parsing.
--

local _M = {}

local ngx = require "ngx"
local cjson = require "cjson"
local resty_sha256 = require "resty.sha256"
local resty_str = require "resty.string"
local env = require "resty-yubikey-auth.env"

local function generate_cookie_hash(i, domain, expires)
    local sha256 = resty_sha256:new()
    sha256:update(i)
    sha256:update(domain)
    sha256:update(expires)
    sha256:update(env.cookie_secret)
    local digest = sha256:final()
    return resty_str.to_hex(digest)
end

-- uses sha256 lib to gen a base64 encoded string of a json token
local function generate_cookie(i, domain, expires)
    local cookie_raw_json = {
        [env.key] = i,
        domain = domain,
        expires = expires,
        hash = generate_cookie_hash(i, domain, expires),
    }
    local cookie_string = cjson.encode(cookie_raw_json)
    return ngx.encode_base64(cookie_string)
end

-- Create a cookie string
function _M.build_http_cookie(i)
    -- Cookie generate new expiration and domain to setup
    local expires = ngx.cookie_time(ngx.time() + env.cookie_ttl)
    local domain = ngx.var.host
    -- Generate our cookie json structure with new hash
    local cookie_value = generate_cookie(i, domain, expires)

    local cookie_string = table.concat({
        env.cookie_name .. "=" .. cookie_value,
        "Path=/",
        "Expires=" .. expires,
        "HttpOnly",
        "Domain=" .. domain,
        "SameSite=" .. env.cookie_samesite,
        env.cookie_secure
    }, "; ")

    return cookie_string
end

-- decodes the base64 cookie and validates the hash based on provided and known info
function _M.validate_cookie(i)
    local b64_status, cookie_value = pcall(ngx.decode_base64, i)
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
    local cookie_hash = generate_cookie_hash(cookie_raw_json[env.key], cookie_raw_json.domain, cookie_raw_json.expires)
    if cookie_hash ~= cookie_raw_json.hash then
        return false, "Cookie signature mismatch"
    end
    return true, cookie_raw_json
end

return _M