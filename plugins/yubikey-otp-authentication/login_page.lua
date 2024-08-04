-- Login Display
-- The login code and prompt engine
-- 

local _M = {}

local ngx = require "ngx"
local env = require "yubikey-otp-authentication.env"
local utils = require "yubikey-otp-authentication.utils"
local favicon = require "yubikey-otp-authentication.favicon"

local script_block = [[
    document.getElementById('login-form').addEventListener('submit', function(event) {
        var input = document.getElementById('{{name}}').value;
        if (input.length !== {{length}}) {
            document.getElementById('error-alert').classList.remove('d-none');
            document.getElementById('error-alert').innerText = '{{NAME}} must meet length constraint.';
            event.preventDefault();
        }
    });
]]

local html_body = [[
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Login</title>
        <!-- Bootswatch Darkly Theme -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@4/dist/darkly/bootstrap.min.css">
        <link rel="icon" type="image/svg+xml" href="data:image/svg+xml;base64,{{favicon}}">
    </head>
    <body class="bg-dark text-light">
        <div class="container">
            <div class="row justify-content-center align-items-center min-vh-100">
                <div class="col-12 col-sm-10 col-md-8 col-lg-6 col-xl-5">
                    <!-- Error Message Alert -->
                    <div id="error-alert" class="alert alert-danger d-none" role="alert">{{error}}</div>
                    <!-- Main Login Card -->
                    <div class="card bg-secondary border-0 shadow">
                        <div class="card-body">
                            <form action="/" method="post" class="p-4" id="login-form">
                                <h2 class="text-center mb-4">{{NAME}} Login</h2>
                                <div class="form-group">
                                    <!-- Adjusted input style for consistency -->
                                    <input type="text" id="{{name}}" name="{{name}}" class="form-control" placeholder="Enter {{NAME}}" required autofocus style="width: 100%;">
                                </div>
                                <button class="btn btn-success btn-block" type="submit">Submit</button>
                            </form>
                        </div>
                        <div class="card-footer text-muted text-center">
                            Copyright AAR &copy; {{year}}<br>
                            Your IP: {{ip}}
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>{{script}}</script>
    </body>
    </html>
]]

local function format_body(i, error_text, script_block)
    local res = i
    -- Generic
    res = res:gsub("{{name}}", env.key)
    res = res:gsub("{{NAME}}", env.key:upper())
    res = res:gsub("{{length}}", env.key_length)
    res = res:gsub("{{favicon}}", favicon.image)
    res = res:gsub("{{ip}}", ngx.var.remote_addr)
    res = res:gsub("{{year}}", utils.get_current_year())
    -- Special
    if error_text then
        res = res:gsub("{{error}}", error_text)
    end
    if script_block then
        res = res:gsub("{{script}}", script_block)
    end
    return res
end

function _M.display_login_portal(err_code, err_msg)
    local res_status = err_code or ngx.HTTP_OK
    local ip = ngx.var.remote_addr
    local modified_script = format_body(script_block)
    local modified_html = format_body(html_body, err_msg, modified_script)
    
    -- Correctly assign the result of gsub back to modified_html
    if err_msg and err_msg ~= "" then
        modified_html = modified_html:gsub('id="error%-alert" class="alert alert%-danger d%-none"', 'id="error-alert" class="alert alert-danger"')
    end
    
    ngx.header.content_type = "text/html"
    ngx.status = res_status
    ngx.say(modified_html)
    return ngx.exit(ngx.HTTP_OK)
end

return _M