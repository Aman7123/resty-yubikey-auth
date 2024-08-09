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
        ["resty-yubikey-auth"] = "lua/plugins/resty-yubikey-auth/*.lua"
    }
}