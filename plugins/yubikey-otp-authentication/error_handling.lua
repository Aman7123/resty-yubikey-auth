-- Error
-- All error messages are handled here
-- 

local _M = {}

local ngx = require "ngx"
local cjson = require "cjson"

function _M.log(msg)
    ngx.log(ngx.ERR, msg)
end

function _M.log_json(msg)
    ngx.log(ngx.ERR, cjson.encode(msg))
end

return _M