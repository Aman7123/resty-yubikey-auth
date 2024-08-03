-- Main Checkpoints
--  To reduce the amount of logic in the main function, we have broken these functions out
-- 

local _M = {}

local ngx = require "ngx"
local env = require "yubikey-otp-authentication.env"
local cookies = require "yubikey-otp-authentication.cookie_management"
local yubi_auth = require "yubikey-otp-authentication.authentication"

-- This function helps break up so much logic in the main function.
-- Function is called after the login page is displayed and a POST request is made
function _M.handle_post_request(args)
    local otp = args.otp
    if otp then
        local ok, err_code, err_msg = yubi_auth.get_and_verify_otp(otp)
        if ok then
            -- Cookie generate new expiration and domain to setup
            local expires = ngx.cookie_time(ngx.time() + env.cookie_ttl)
            local domain = ngx.var.host
            -- Generate our cookie json structure with new hash
            local cookie_value = cookies.generate_cookie(otp, domain, expires)
            -- Build the http string for our cookie
            local http_cookie = cookies.build_http_cookie(cookie_value, domain, expires)
            -- success
            return http_cookie, ngx.HTTP_OK, nil
        else
            return nil, err_code, err_msg
        end
    else
        return nil, ngx.HTTP_BAD_REQUEST, "No OTP provided"
    end
end

-- This function helps break up so much logic in the main function.
-- Function serves to authenticate each request coming through the gateway
function _M.handle_existing_cookie(auth_cookie)
    -- Existing cookie validation
    local valid, cookie_raw_json = cookies.validate_cookie(auth_cookie)
    if valid then
        -- Cookie generate new expiration
        local expires = ngx.cookie_time(ngx.time() + env.cookie_ttl)
        -- Generate our cookie json structure with new hash
        local cookie_value = cookies.generate_cookie(cookie_raw_json.otp, cookie_raw_json.domain, expires)
        -- Build the http string for our cookie
        local http_cookie = cookies.build_http_cookie(cookie_value, cookie_raw_json.domain, expires)
        -- success
        return http_cookie, ngx.HTTP_OK, nil
    else
        return nil, ngx.HTTP_BAD_REQUEST, string.format("Invalid cookie: %s", cookie_raw_json)
    end
end

return _M