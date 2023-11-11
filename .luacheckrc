-- Configuration file for LuaCheck
-- see: https://luacheck.readthedocs.io/en/stable/
--
-- To run do: `luacheck .` from the repo

std             = "ngx_lua"

ignore = {
    "6.", -- ignore whitespace warnings
}

include_files = {
    "**/*.lua",
    "*.rockspec",
    ".busted",
    ".luacheckrc",
}

exclude_files = {
    --"invalid-module.lua",
    --"old/invalid-module.lua",
}