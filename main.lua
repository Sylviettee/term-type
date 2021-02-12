math.randomseed(os.time())

local box = require 'luabox'
local screen = require 'luabox.screen'
local Logic = require './logic'
local func = require './findRandomFunction'()

local util = box.util
local cursor = box.cursor
local event = box.event

local stdin, stdout = util.getHandles()

local console = box.Console.new(stdin, stdout)

console:setMode(1)

---@type Game
local logic = Logic.new(console)

logic:setup(func)

logic:draw()

console.onData = function(data)
   local first
   local rest = {}

   for char in data:gmatch('.') do
      if not first then
         first = char
      else
         table.insert(rest, char)
      end
   end

   local iter = util.StringIterator(table.concat(rest))

   local keyData = event.parse(first, iter)

   if keyData.key == 'ctrl' and keyData.char == 'c' then
      console:setMode(0)
      console:write(
         cursor.show ..
         screen.toMain
      )

      os.exit()
   else
      logic:input(keyData)
   end
end

console.run()
