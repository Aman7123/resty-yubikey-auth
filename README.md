## Openresty Yubikey OTP Auth

This is a plugin for OpenResty Nginx that 2FA with a YubiKey OTP. The plugin is designed to run within an Nginx block from a single call, providing a seamless and efficient authentication process.

### Prerequisites

- YubiKey
- An existing Nginx deployment which is running from a docker compose
- Setup a custom `Dockerfile` to build your Docker environment into Lua ENV variables
  - Check my `entrypoint.sh` as an example to creating the environment directives on OpenResty startup

### Installation
This process will guide you through installing the plugin into the OpenResty Lua Path.

1. Clone or download the repository.
2. Add `lua_package_path` to the core Nginx configuration.
  - Make sure that persistent volume in Nginx is configured to a location like `./lua:/usr/local/openresty/nginx/lua:ro`.
  - In `nginx.conf` setup `lua_package_path '/usr/local/openresty/nginx/lua/plugins/?.lua;;';`.
3. Place the `plugins/` folder for this repo into that `lua/` directory for the docker compose.

### Usage

Once installed, you can use the `access_by_lua_file` in your Nginx configuration. Here's an example:

```nginx
server {
    listen 443 ssl;
    server_name example.com;

    error_log /usr/local/openresty/nginx/logs/error.log;
    access_log /usr/local/openresty/nginx/logs/otp-access.log main;

    # Configure OTP auth
    access_by_lua_file /usr/local/openresty/nginx/lua/plugins/yubikey-otp-authentication/main.lua;

    location / {
        proxy_pass http://localhost:8080$request_uri;
    }
}
```

### Environment Variable Configuration

The plugin stores the the environment in code within `env.lua`. You can set the following environment variables:

| Environment Variable | Default | Description |
| --- | --- | --- |
| `YUBIKEY_REQUEST_ID` | REQUIRED | A unique ID which identifies you the requestor |
| `YUBIKEY_AUTHORIZED_KEYS` | REQUIRED | Accepts a CSV of authorized [YubiKey IDs](https://developers.yubico.com/OTP/OTPs_Explained.html) |
| `YUBIKEY_COOKIE_SECRET` | REQUIRED | A secret used to encrypt the cookie |
| `YUBIKEY_COOKIE_NAME` | `OTP` | The name of the cookie |
| `YUBIKEY_COOKIE_SAMESITE` | `Strict` | [Mozilla Cookie SameSite](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#samesitesamesite-value) |
| `YUBIKEY_COOKIE_SECURITY` | `Secure` | Set env to `""` to disable [Mozilla Cookie Secure](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#secure) |
| `YUBIKEY_COOKIE_TTL` | `1800` | The time to live for the cookie in seconds |

### Verification Backend
This plugin utilizes the [Yubico WSAPI](https://developers.yubico.com/wsapi/2.0/otp/verify-otp.html) to verify the OTP.

After verification from Yubico the `YUBIKEY_AUTHORIZED_KEYS` from the environment is used to authorize the "user".

### OTP Input Form

The plugin features an OTP input form that is displayed when authentication is required. The form is customizable to fit your application's look and feel. Checkout `login_page.lua` to review this feature.