local colors = require 'luabox.colors'
local cursor = require 'luabox.cursor'
local screen = require 'luabox.screen'
local clear = require 'luabox.clear'

local highlight = require './highlight'

---@param game Game
local function getReport(game)
   local words = 0

   for _ in game.text:gmatch('([^ ]+)') do
      words = words + 1
   end

   local taken = game.stop - game.start

   return string.format(
      '| WPM: %s | Time taken: %u seconds | Errors: %u',
      words / (taken / 60),
      taken,
      game.errors
   )
end

---@class Game
---@field text string
---@field term any
---@field stop number
---@field start number
---@field position number
---@field incorrect number
---@field errors number
local Game = {}

--- Create a new class
---@param term any
---@return Game
function Game.new(term)
   local self = setmetatable({}, {
      __index = Game
   })

   self.term = term

   return self
end

---@param text string
function Game:setup(text)
   self.term:write(
      screen.toAlternative ..
      cursor.hide
   )

   self.text = text
   self.typed = ''
   self.pos = 0
   self.errors = 0

   self.stop = nil
   self.start = nil
   self.incorrect = nil
end

function Game:draw()
   local written = self.text:sub(0, self.pos)
   local current = self.text:sub(self.pos + 1, self.pos + 1)
   local toGo = self.text:sub(self.pos + 2)

   if current == '\n' then
      current = '⏎\n'
   elseif current == '\t' then
      current = '➡️'
   elseif current == ' ' then
      current = colors.bg(colors.blue) .. ' ' .. colors.resetBg
   end

   if self.incorrect then
      local left = written:sub(0, self.incorrect - 1)
      local char = written:sub(self.incorrect, self.incorrect)
      local right = written:sub(self.incorrect + 1)

      written =
         highlight(left) ..
         colors.bg(colors.red) ..
         char ..
         colors.resetBg ..
         colors.fg(colors.red) ..
         right
   else
      written = highlight(written)
   end

   self.term:write(
      cursor.goTo(1, 1) ..
      clear.all ..
      colors.fg(colors.white) ..
      written ..
      colors.fg(colors.blue) ..
      current ..
      colors.fg(colors.lightBlack) ..
      toGo
   )
end

function Game:input(data)
   if data.key ~= 'char' and not data.key == 'backspace' then
      return
   end

   if self.stop then
      return
   end

   if data.key == 'backspace' then
      self.typed = self.typed:sub(0, #self.typed - 1)

      if self.incorrect == self.pos then
         self.incorrect = nil
      end

      self.pos = (self.pos <= 0 and 0 or self.pos - 1)

      self:draw()

      return
   end

   if not self.start then
      self.start = os.time()
   end

   local char = (data.char == '\r' and '\n' or data.char)

   if char == '\t' then
      local untilNext = #self.text:sub(self.pos + 1):match('( *)')

      if untilNext == 0 then
         char = '\t'
      else
         char = string.rep(' ', untilNext)
      end
   end

   self.typed = self.typed .. char

   self.pos = self.pos + #char

   if self.text:sub(self.pos - #char + 1, self.pos) ~= char then
      if not self.incorrect then
         self.incorrect = self.pos
      end

      self.errors = self.errors + 1
   end

   self:draw()

   if self.text == self.typed then
      self.stop = os.time()

      self.term:write(
         colors.resetBg ..
         colors.resetFg ..
         '\n' ..
         getReport(self)
      )
   end
end

return Game
