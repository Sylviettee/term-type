local lib = require 'luabox'

local function flatten(tbl, flattened)
   flattened = flattened or {}

   for _, v in pairs(tbl) do
      if type(v) == 'function' then
         table.insert(flattened, v)
      elseif type(v) == 'table' and not flattened[v] then
         flattened[v] = true
         flatten(v, flattened)
      end
   end

   return flattened
end

local function search(tbl)
   local fns = flatten(tbl)

   return fns[math.random(1, #fns)]
end

local function getSource(fn)
   local info = debug.getinfo(fn)

   local src = info.source:gsub('^@', '')

   local data = {}

   do
      local f = assert(io.open(src, 'r'))

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

   return table.concat(data, '\n')
end

return function()
   return getSource(search(lib))
end
