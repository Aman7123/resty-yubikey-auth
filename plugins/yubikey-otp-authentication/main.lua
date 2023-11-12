-- Core
-- Run these file to execute the plugin
-- 

local ngx = require "ngx"
local string = require "string"
local env = require "yubikey-otp-authentication.env"
local login = require "yubikey-otp-authentication.login_page"
local process = require "yubikey-otp-authentication.request_processes"
local utils = require "yubikey-otp-authentication.utils"

local function run()
    -- Grab cookie in all requests, 
    local auth_cookie = ngx.var["cookie_" .. env.yubikey_cookie_name]
    
    local request
    -- In this if statement we check the POST with the uri to ensure 
    if ngx.req.get_method() == "POST" and ngx.var.uri == "/" then
        ngx.req.read_body() 
        local err
        request, err = ngx.req.get_post_args()
        if not request then
            local display_err = string.format("Failed: %s", err)
            ngx.log(ngx.ERR, display_err)
            login.display_login_portal(display_err)
        end
    end
   
    -- When a POST occurs with an otp value, we need to validate it and generate a cookie
    if request and request["otp"] then
        -- Generate our cookie using custom algorithms
        local build_cookie, post_err_code, post_err = process.handle_post_request(request)
        if not build_cookie then
            local display_err = post_err_code .. " - " .. post_err
            ngx.log(ngx.ERR, display_err)
            login.display_login_portal(display_err)
        end
        -- Return back just cookie and redirect to the original request
        ngx.header["Location"] = utils.location_header_build()
        ngx.header["Set-Cookie"] = build_cookie
        local status = ngx.HTTP_MOVED_TEMPORARILY
        ngx.status = status
        ngx.exit(status)
    else
        -- Ensure the request contains the login cookie or return for login
        if auth_cookie then
            -- Validate and refresh our cookie
            local handle_cookie, cook_err_code, cook_err = process.handle_existing_cookie(auth_cookie)
            if not handle_cookie then
                local display_err = cook_err_code .. " - " .. cook_err
                ngx.log(ngx.ERR, display_err)
                login.display_login_portal(display_err)
            end
            -- Append our new cookie into the request so the client can use it
            ngx.header["Set-Cookie"] = handle_cookie
            -- Request is allowed to continue to our system as normal from this point on
        else
            login.display_login_portal()
        end
    end
end

-- Execute
run()