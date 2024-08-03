-- Authentication Module
-- This would contain all the logic necessary for authentication and authorization processes.
--

local _M = {}
local ngx = require "ngx"
local string = require "string"
local utils = require "yubikey-otp-authentication.utils"
local env = require "yubikey-otp-authentication.env"
local yubi_http = require "yubikey-otp-authentication.yubikey_http"

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
    if string.len(otp) ~= 44 then
        return false
    end
    return true
end

-- Function to check if the OTP is valid
local function is_valid_otp(res_body, otp, nonce)

    -- Ensure the otp var and res_body.otp are 44 characters long
    if not is_valid_otp_length(otp) or not is_valid_otp_length(res_body:match("otp=(%w+)")) then
        local msg = "OTP length mismatch"
        return false, msg
    end

    -- Ensure nonce in res_body and the passed in var match
    if string.match(res_body, "nonce=" .. nonce) == nil then
        local msg = "Nonce mismatch"
        return false, msg
    end

    -- TODO: possibly add timestamp validation here

    -- Ensure the otp response was accepted
    if not string.match(res_body, "status=OK") then
        local status_info = res_body:match("status=([%w_]+)")
        local msg = string.format("OTP not accepted: %s", status_info)
        return false, msg
    end
    
    -- Check if the OTP matches in the response body
    if string.match(res_body, "otp=" .. otp) == nil then
        local msg = "OTP mismatch"
        return false, msg
    end

    return true, nil
end

-- Function to verify OTP with Yubico API
-- TODO: migrate this to local validation using public key, private key, and secret
function _M.get_and_verify_otp(otp)
    local nonce = utils.generate_nonce()

    -- Send HTTP request to Yubico API
    local status, res, code, err = yubi_http.yubico_verification_server(otp, env.request_id, nonce)
    if not status then
        return false, code, err
    end

    -- Run validation checks
    local valid, validity_err = is_valid_otp(res, otp, nonce)
    if not valid then
        return false, ngx.HTTP_BAD_REQUEST, validity_err
    end
    
    -- Check if the YubiKey is authorized
    if not is_authorized_yubikey(otp) then
        return false, ngx.HTTP_FORBIDDEN, "Unauthorized YubiKey"
    end

    -- Return true if all checks passed
    return true
end

return _M