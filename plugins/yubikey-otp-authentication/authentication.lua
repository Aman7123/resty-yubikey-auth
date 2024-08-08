-- Authentication Module
-- This would contain all the logic necessary for authentication and authorization processes.
--

local _M = {}

local yubikey = require "yubikey-otp-authentication.yubikey"

function _M.verify(i)
    local ok, err_code, err_msg = yubikey.verify(i)
    return ok, err_code, err_msg
end

return _M