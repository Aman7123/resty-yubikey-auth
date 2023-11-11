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

return _M