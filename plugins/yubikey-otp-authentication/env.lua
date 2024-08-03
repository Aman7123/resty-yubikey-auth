-- Environment
-- This modules loads from os
-- 

local _M = {}
local os = require "os"
local errors = require "yubikey-otp-authentication.error_handling"

-- _M.key = "otp"
-- _M.key_length = 44
_M.request_id = os.getenv("YUBIKEY_REQUEST_ID")
_M.authorized_keys = os.getenv("YUBIKEY_AUTHORIZED_KEYS")
_M.cookie_secret = os.getenv("YUBIKEY_COOKIE_SECRET")
_M.cookie_name = os.getenv("YUBIKEY_COOKIE_NAME") or "otp"
_M.cookie_secure = os.getenv("YUBIKEY_COOKIE_SECURITY") or "Secure"
_M.cookie_samesite = os.getenv("YUBIKEY_COOKIE_SAMESITE") or "Strict"
_M.cookie_ttl = os.getenv("YUBIKEY_COOKIE_TTL") or 1800

-- Check to ensure all yubikey environment variables are set]
if not _M.request_id then
    errors.log("YUBIKEY_REQUEST_ID environment variable not set")
elseif not _M.cookie_secret then
    errors.log("YUBIKEY_COOKIE_SECRET environment variable not set")
elseif not _M.authorized_keys then
    errors.log("YUBIKEYS_AUTHORIZED_KEYS environment variable not set")
end

return _M