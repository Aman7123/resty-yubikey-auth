-- Main Checkpoints
-- To reduce the amount of logic in the main function, we have broken these functions out
--

local _M = {}

local ngx = require "ngx"
local env = require "resty-yubikey-auth.env"
local cookie = require "resty-yubikey-auth.cookie_management"
local auth = require "resty-yubikey-auth.authentication"

-- This function helps break up so much logic in the main function.
-- Function is called after the login page is displayed and a POST request is made
function _M.handle_post_request(args)
    local input = args[env.key]
    if input then
        local ok, err_code, err_msg = auth.verify(input)
        if ok then
            -- Build the http string for the cookie
            local http_cookie = cookie.build_http_cookie(input)
            -- success
            return http_cookie, ngx.HTTP_OK, nil
        else
            return nil, err_code, err_msg
        end
    else
        local err_msg = string.format("No %s provided", env.key:upper())
        return nil, ngx.HTTP_BAD_REQUEST, err_msg
    end
end

-- This function helps break up so much logic in the main function.
-- Function serves to authenticate each request coming through the gateway
function _M.handle_existing_cookie(auth_cookie)
    -- Existing cookie validation
    local valid, res_data = cookie.validate_cookie(auth_cookie)
    if valid then
        -- Build the http string for our cookie
        local http_cookie = cookie.build_http_cookie(res_data[env.key])
        -- success
        return http_cookie, ngx.HTTP_OK, nil
    else
        return nil, ngx.HTTP_BAD_REQUEST, string.format("Invalid cookie: %s", res_data)
    end
end

return _M