local lib = require 'luabox'
local highlight = require './highlight'

local found

local function search(tbl)
   for _, v in pairs(tbl) do
      if type(v) == 'function' and math.random(0, 10) == 2 then
         found = v

         return true
      elseif type(v) == 'table' then
         if search(v) then
            return
         end
      end
   end

   if not found then
      search(lib)
   end
end

local function getSource(fn)
   local info = debug.getinfo(fn)

   local src = info.source:gsub('^@', '')

   local data = {}

   do
      local f = io.open(src, 'r')

      local i = 0

      for line in f:lines() do
         i = i + 1

         if i >= info.linedefined then
            table.insert(data, line)
         end

         if i >= info.lastlinedefined then
            break
         end
      end
   end

   data = table.concat(data, '\n')

   return data
end

return function()
   search(lib)

   return getSource(found)
end