-- Login Display
-- THe login code and prompt engine
-- 

local _M = {}

local ngx = require "ngx"
local favicon = require "yubikey-otp-authentication.favicon"

local style_block = [[
    * {
        box-sizing: border-box;
    }
    body {
        background-color: #1f4037;
        font-family: Arial, sans-serif;
        color: white;
        display: flex;
        justify-content: center;
        align-items: flex-start;
        height: 100vh;
        margin: 0;
        padding: 0;
        padding-top: 50px;
    }
    form {
        background: white;
        max-width: 90%%;
        width: 375px;
        padding: 25px;
        padding-bottom: 0px;
        border-radius: 10px;
        color: black;
        box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
        position: relative;
    }
    h1, h2 {
        text-align: center;
        font-size: 200%%;
    }
    input[type="text"] {
        width: 100%%;
        padding: 12.5px;
        margin: 12.5px 0;
        border-radius: 5px;
        border: 1px solid #ccc;
    }
    input[type="submit"] {
        background-color: #4CAF50;
        color: white;
        padding: 12.5px 25px;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        display: block;
        margin: 0 auto;
        transition: background-color 0.3s ease;
    }
    input[type="submit"]:hover {
        background-color: #45a049;
    }
    .error-message {
        display: %s; /* automated in code */
        color: red;
        margin: 10px 0;
        padding: 10px;
        border: 1px solid red;
        border-radius: 5px;
        white-space: nowrap;
        overflow: auto;
    }
    .footer {
        bottom: 0;
        display: flex;
        justify-content: space-between;
        margin-top: 50px;
        padding-bottom: 18.75px;
        width: 100%%;
        font-size: 0.8em;
        color: #ccc;
    }
]]

local script_block = [[
    window.onload = function() {
        var form = document.querySelector('form');
        var input = document.querySelector('input[name="otp"]');
        var errorMessage = document.querySelector('.error-message');
        // Validate OTP length
        form.addEventListener('submit', function(event) {
            if (input.value.length !== 44) {
                event.preventDefault();
                errorMessage.textContent = 'Must be 44 characters long';
                errorMessage.style.display = 'block';
            }
        });
    };
]]

-- TODO: add a way to display errors to the user
-- TODO: add validation to web form
local html_body = [[
    <html>
        <head>
            <title>OTP Gateway Authentication</title>
            <link rel="icon" type="image/svg+xml" href="data:image/svg+xml;base64,%s">
            <style>%s</style>
            <script>%s</script>
        </head>
        <body>
            <form method="post" action="/">
                <h1>OTP Login</h1>
                <div class="error-message">%s</div>
                <label>OTP </label>
                <input name="otp" type="text" maxlength="44" value="" autofocus />  
                <input type="submit" name="submit"/>
                <div class="footer">
                    <div>Copyright AAR &copy; 2023</div>
                    <div>IP: %s</div>
                </div>
            </form>
        </body>
    </html>
]]

local function build_style(err)
    local err_display = err and "block" or "none"
    local style = string.format(style_block, err_display)
    return style

end

function _M.display_login_portal(err)
    local ip = ngx.var.remote_addr
    local stylesheets = build_style(err)
    local html = string.format(html_body, favicon.getImage(), stylesheets, script_block, err, ip)
    ngx.header.content_type = "text/html"
    ngx.say(html)
    ngx.exit(ngx.HTTP_OK)
end

return _M