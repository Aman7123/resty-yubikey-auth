package = "resty-yubikey-auth"
version = "1.0.5-1"
source = {
    url = "."
}
description = {
    summary = "Yubikey OTP Authentication plugin for OpenResty",
    detailed = "A Lua plugin for OpenResty to authenticate users using Yubikey OTP.",
    homepage = "https://github.com/Aman7123/resty-yubikey-auth"
}
dependencies = {
    "lua >= 5.1",
    "luasec",
    "luafilesystem",
    "luasocket",
    "luacheck",
    "lua-cjson",
    "penlight",
    "lua-resty-http",
    "lua-resty-string"
}
build = {
    type = "builtin",
    modules = {
        ["resty-yubikey-auth.main"] = "lua/plugins/resty-yubikey-auth/main.lua",
        ["resty-yubikey-auth.request_processes"] = "lua/plugins/resty-yubikey-auth/request_processes.lua",
        ["resty-yubikey-auth.cookie_management"] = "lua/plugins/resty-yubikey-auth/cookie_management.lua",
        ["resty-yubikey-auth.authentication"] = "lua/plugins/resty-yubikey-auth/authentication.lua",
        ["resty-yubikey-auth.env"] = "lua/plugins/resty-yubikey-auth/env.lua",
        ["resty-yubikey-auth.error_handling"] = "lua/plugins/resty-yubikey-auth/error_handling.lua",
        ["resty-yubikey-auth.login_page"] = "lua/plugins/resty-yubikey-auth/login_page.lua",
        ["resty-yubikey-auth.favicon"] = "lua/plugins/resty-yubikey-auth/favicon.lua",
        ["resty-yubikey-auth.utils"] = "lua/plugins/resty-yubikey-auth/utils.lua",
        ["resty-yubikey-auth.yubikey"] = "lua/plugins/resty-yubikey-auth/yubikey.lua"
    }
}