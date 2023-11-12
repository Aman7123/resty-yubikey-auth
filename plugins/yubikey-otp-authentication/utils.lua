-- General Utils
-- A tool set for this plugin
-- 

local _M = {}
local math = require "math"

-- Function to generate a random nonce
function _M.generate_nonce()
    local charset = {}  -- an array to store the indices of allowable characters
    for c = 48, 57  do table.insert(charset, string.char(c)) end  -- digits
    for c = 65, 90  do table.insert(charset, string.char(c)) end  -- uppercase letters
    for c = 97, 122 do table.insert(charset, string.char(c)) end  -- lowercase letters

    local function random_char()
        return charset[math.random(1, #charset)]
    end

    local length = math.random(16, 40)
    local nonce = ""
    for i = 1, length do
        nonce = nonce .. random_char()
    end
    return nonce
end

function _M.location_header_build(scheme, host, uri, query_string)
    scheme = scheme or ngx.var.scheme
    host = host or ngx.var.host
    uri = uri or ngx.var.uri
    local location_header = scheme .. "://" .. host .. uri
    if query_string then
        location_header = location_header .. "?" .. query_string
    end
    return location_header
end

return _M