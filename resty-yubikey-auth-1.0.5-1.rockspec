local name = "resty-yubikey-auth"
local app_version = "1.0.5"
local rockspec_revision = "1"

local developer = "Aman7123"
local repo = developer .. "/" .. name

local code_path = "lua/plugins"
local full_code_path = "lua/plugins/"..name

package = name
version = app_version .. "-" .. rockspec_revision
source = {
    url = "git+https://github.com/" .. repo .. ".git"
}
description = {
    summary = "Yubikey OTP Authentication plugin for OpenResty",
    detailed = "A Lua plugin for OpenResty to authenticate users using Yubikey OTP.",
    homepage = "https://github.com/" .. repo
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
        [name..".main"] = full_code_path.."/main.lua",
        [name..".request_processes"] = full_code_path.."/request_processes.lua",
        [name..".cookie_management"] = full_code_path.."/cookie_management.lua",
        [name..".authentication"] = full_code_path.."/authentication.lua",
        [name..".env"] = full_code_path.."/env.lua",
        [name..".error_handling"] = full_code_path.."/error_handling.lua",
        [name..".login_page"] = full_code_path.."/login_page.lua",
        [name..".favicon"] = full_code_path.."/favicon.lua",
        [name..".utils"] = full_code_path.."/utils.lua",
        [name..".yubikey"] = full_code_path.."/yubikey.lua"
    }
}