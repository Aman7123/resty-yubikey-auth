-- Environment
-- This modules loads from os
-- 

local _M = {}
local os = require "os"
local errors = require "yubikey-otp-authentication.error_handling"

_M.yubikey_request_id = os.getenv("YUBIKEY_REQUEST_ID")
_M.yubikeys_authorized_keys = os.getenv("YUBIKEYS_AUTHORIZED_KEYS")
_M.yubikey_cookie_secret = os.getenv("YUBIKEY_COOKIE_SECRET")
_M.yubikey_cookie_name = os.getenv("YUBIKEY_COOKIE_NAME") or "OTP"
_M.yubikey_cookie_secure = os.getenv("YUBIKEY_COOKIE_SECURITY") or "Secure"
_M.yubikey_cookie_samesite = os.getenv("YUBIKEY_COOKIE_SAMESITE") or "Strict"
_M.yubikey_cookie_ttl = os.getenv("YUBIKEY_COOKIE_TTL") or 1800

-- Check to ensure all yubikey environment variables are set]
if not _M.yubikey_request_id then
    errors.log("YUBIKEY_REQUEST_ID environment variable not set")
elseif not _M.yubikey_cookie_secret then
    errors.log("YUBIKEY_COOKIE_SECRET environment variable not set")
elseif not _M.yubikeys_authorized_keys then
    errors.log("YUBIKEYS_AUTHORIZED_KEYS environment variable not set")
end

return _M