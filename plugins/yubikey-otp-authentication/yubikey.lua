-- YubiKey Logic Module
-- This module contains all functions needed for yubikey specific functions.
--

local _M = {}
local ngx = require "ngx"
local math = require "math"
local http = require "resty.http"
local utils = require "yubikey-otp-authentication.utils"
local env = require "yubikey-otp-authentication.env"

-- Function to pull random url
local function choose_random_lb_address()
    local lb_addresses = {"api.yubico.com", "api2.yubico.com", "api3.yubico.com", "api4.yubico.com", "api5.yubico.com"}
    return lb_addresses[math.random(#lb_addresses)]
end

-- Function to check if the YubiKey is authorized
local function is_authorized_yubikey(otp)
    local key_id = string.sub(otp, 1, 12)  -- Assumes the first 12 characters are the key ID

    -- Split authorized_keys into individual keys
    for authorized_key in string.gmatch(env.authorized_keys, '([^,]+)') do
        if key_id == authorized_key then
            return true, authorized_key
        end
    end

    return false
end

-- Function to ensure a passed in otp variable is 44 characters long
local function is_valid_otp_length(otp)
    if string.len(otp) ~= env.key_length then
        return false
    end
    return true
end

-- Function to check verify the yubikey server response
-- This is all validation for the http requests to yubikey servers
local function is_valid_http_response(res_body, nonce)

    -- Ensure the otp var and res_body.otp are 44 characters long
    if not is_valid_otp_length(res_body:match("otp=(%w+)")) then
        local msg = "OTP length mismatch"
        return false, msg
    end

    -- Ensure the otp response was accepted
    if not string.match(res_body, "status=OK") then
        local status_info = res_body:match("status=([%w_]+)")
        local msg = string.format("OTP not accepted: %s", status_info)
        return false, msg
    end

    -- Ensure nonce in res_body and the passed in var match
    if string.match(res_body, "nonce=" .. nonce) == nil then
        local msg = "Nonce mismatch"
        return false, msg
    end

    return true, nil
end

-- Function to check verify the provided otp v.s. our checked one
-- Any fake yubikey manipulation from user is filtered out here
local function is_valid_otp(res_body, otp)

    -- Ensure the otp var and res_body.otp are 44 characters long
    if not is_valid_otp_length(otp) then
        local msg = "OTP length issue"
        return false, msg
    end

    -- Check if the OTP matches in the response body
    if string.match(res_body, "otp=" .. otp) == nil then
        local msg = "OTP mismatch"
        return false, msg
    end

    return true, nil
end

-- Make HTTP request to Yubico API
local function yubico_verification_server(otp, request_id, nonce)
    local httpc = http.new()
    local uri = string.format("https://%s/wsapi/2.0/verify?id=%s&otp=%s&nonce=%s",
        choose_random_lb_address(),
        request_id,
        otp,
        nonce
    )
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

-- Main function for running YubiKey checks
-- TODO: migrate this to local validation using public key, private key, and secret
function _M.verify(otp)
    local nonce = utils.generate_nonce()

    -- Send HTTP request to Yubico API
    local status, res, code, err = yubico_verification_server(otp, env.request_id, nonce)
    if not status then
        return false, code, err
    end

    -- Run validation checks against http response
    local valid_http, validity_err_http = is_valid_http_response(res, nonce)
    if not valid_http then
        return false, ngx.HTTP_INTERNAL_SERVER_ERROR, validity_err_http
    end

    -- Run validation checks against provided otp and servers
    local valid_chk, validity_err_chk = is_valid_otp(res, otp)
    if not valid_chk then
        return false, ngx.HTTP_BAD_REQUEST, validity_err_chk
    end

    -- Check if the YubiKey is authorized
    if not is_authorized_yubikey(otp) then
        return false, ngx.HTTP_FORBIDDEN, "Unauthorized YubiKey"
    end

    -- Return true if all checks passed
    return true
end

return _M