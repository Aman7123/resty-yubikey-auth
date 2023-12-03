-- Login Display
-- THe login code and prompt engine
-- 

local _M = {}

local ngx = require "ngx"
local favicon = require "yubikey-otp-authentication.favicon"

local script_block = [[
    document.getElementById('login-form').addEventListener('submit', function(event) {
        var otpInput = document.getElementById('otp').value;
        if (otpInput.length !== 44) {
            document.getElementById('error-alert').classList.remove('d-none');
            document.getElementById('error-alert').innerText = 'OTP must be exactly 44 characters long.';
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
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
        <link rel="icon" type="image/svg+xml" href="data:image/svg+xml;base64,%s">
    </head>
    <body class="bg-light">
        <div class="container">
            <div class="row justify-content-center align-items-center min-vh-100">
                <div class="col-12 col-sm-10 col-md-8 col-lg-6 col-xl-5">
                    <!-- Error Message Alert -->
                    <div id="error-alert" class="alert alert-danger d-none" role="alert">%s</div>
                    <!-- Main Login Card -->
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <form action="/" method="post" class="p-4" id="login-form">
                                <h2 class="text-center mb-4">OTP Login</h2>
                                <div class="form-group">
                                    <input type="text" id="otp" name="otp" class="form-control" placeholder="Enter OTP" required autofocus>
                                </div>
                                <button class="btn btn-lg btn-primary btn-block" type="submit">Submit</button>
                            </form>
                        </div>
                        <div class="card-footer text-muted text-center">
                            Copyright AAR &copy; 2023<br>
                            Your IP: %s
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- JavaScript for OTP Validation -->
        <script>%s</script>
    </body>
    </html>
]]

function _M.display_login_portal(err)
    local ip = ngx.var.remote_addr
    local modified_html = string.format(html_body, favicon.getImage(), err, ip, script_block)
    
    -- Correctly assign the result of gsub back to modified_html
    if err and err ~= "" then
        modified_html = modified_html:gsub('id="error%-alert" class="alert alert%-danger d%-none"', 'id="error-alert" class="alert alert-danger"')
    end
    
    ngx.header.content_type = "text/html"
    ngx.say(modified_html)
    ngx.exit(ngx.HTTP_OK)    
end

return _M