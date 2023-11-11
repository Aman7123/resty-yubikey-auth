-- Network Communication Module
-- This module would include functions related to making network requests and handling URLs.
-- 

local _M = {}
local ngx = require "ngx"
local math = require "math"
local http = require "resty.http"
local env = require "yubikey-otp-authentication.env"

-- Function to pull random url
local function choose_random_lb_address()
    local lb_addresses = {"api.yubico.com", "api2.yubico.com", "api3.yubico.com", "api4.yubico.com", "api5.yubico.com"}
    return lb_addresses[math.random(#lb_addresses)]
end

-- Make HTTP request to Yubico API
function _M.yubico_verification_server(otp, yubikey_request_id, nonce)
    local httpc = http.new()
    local uri = string.format("https://%s/wsapi/2.0/verify?id=%s&otp=%s&nonce=%s", choose_random_lb_address(), env.yubikey_request_id, otp, nonce)
    local res, err = httpc:request_uri(uri, {
        method = "GET",
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        }
    })
    if not res then
        return false, nil, ngx.HTTP_INTERNAL_SERVER_ERROR, ("HTTP request failed: " .. err)
    end

    -- Check if the HTTP response status is 200 (OK)
    if res.status ~= 200 then
        return false, nil, ngx.HTTP_INTERNAL_SERVER_ERROR, ("Invalid HTTP response: " .. res.status)
    end

    return true, res.body
end

return _M