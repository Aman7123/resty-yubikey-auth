-- General Utils
-- A tool set for this plugin
-- 

local _M = {}
local ngx = require "ngx"
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

function _M.get_current_year()
    -- Get the current local time as a string
    local local_time = ngx.localtime()
    -- Extract the year part (first 4 characters)
    local year = local_time:sub(1, 4)
    return year
end

return _M