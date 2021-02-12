local colors = require 'luabox.colors'
local lexer = require './lexer'

local function highlight(code)
   local out = ''

   for t, v in lexer.lua(code, {}, {}) do
      if t == 'comment' then
         out = out .. colors.fg(colors.green)
      elseif t == 'keyword' then
         out = out .. colors.fg(colors.magenta)
      elseif t == 'string' then
         out = out .. colors.fg(colors.cyan)
      elseif t == 'number' then
         out = out .. colors.fg(colors.yellow)
      elseif t == 'iden' and _G[v] then
         out = out .. colors.fg(colors.lightBlue)
      end

      out = out .. v .. colors.resetFg
   end

   return out
end

return highlight