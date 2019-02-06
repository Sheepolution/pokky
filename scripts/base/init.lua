love.graphics.setDefaultFilter("nearest", "nearest")

local oldrandomseed = math.randomseed
local currentrandomseed = 0

function math.randomseed(v)
	v = v or os.time()
	currentrandomseed = v
	oldrandomseed(v)
end


function math.getrandomseed()
	return currentrandomseed
end

math.randomseed()

GLOBAL = _G
PI = math.pi
TAU = PI * 2
SCREEN_WIDTH = love.graphics.getWidth()
SCREEN_HEIGHT = love.graphics.getHeight()
WIDTH = love.graphics.getWidth()/SCALE
HEIGHT = love.graphics.getHeight()/SCALE
DT = 1/60

require "base.error"

--Tools
Data = require "base.data"
Shader = require "base.shader"
Asset = require "base.asset"
Mouse = require("base.mouse")()
Key = require("base.input")()

--Classes
Point = require "base.point"
Rect = require "base.rect"
Circle = require "base.circle"
Sprite = require "base.sprite"
Animation = require "base.animation"
Text = require "base.text"
Entity = require "base.entity"
Button = require "base.button"
Once = require "base.once"
-- Tilemap = require "base.tilemap"
Camera = require "base.camera"
Area = require "base.area"

Cursors = {}
Cursors.hand = love.mouse.getSystemCursor("hand")

local base = {}

function base.beginstep(dt)
	WIDTH = love.graphics.getWidth()/SCALE
	HEIGHT = love.graphics.getHeight()/SCALE
	Mouse:update()
	Data.reset()
end


function base.endstep(dt)
	Key:reset()
	Mouse:reset()
end


function base.keypressed(key)
	Key:inputpressed(key)
end


function base.keyreleased(key)
	Key:inputreleased(key)
end


function base.mousepressed(x, y, button)
	Mouse:inputpressed(button)
end


function base.mousereleased(x, y, button)
	Mouse:inputreleased(button)
end


function base.wheelmoved(x, y)
	local a = y == 0 and x or y
	Mouse:inputpressed(a >= 0 and "wu" or "wd")
end


function warning(...)
	print("[WARNING] -", ...)
end


function printif(a, ...)
	if not a then return end
	local info = debug.getinfo(2, "Sl")
	local t = { info.short_src .. ":" .. info.currentline .. ":" }
	for i = 1, select("#", ...) do
	local x = select(i, ...)
	if type(x) == "number" then
	  x = string.format("%g", lume.round(x, .01))
	end
	t[#t + 1] = tostring(x)
	end
	oldprint(table.concat(t, " "))
end


function requireDir(dir)
	local files = love.filesystem.getDirectoryItems(dir)
	local path = dir:gsub("/",".")
	for i,v in ipairs(files) do
		local d = dir .. "/" .. v
		if love.filesystem.isDirectory(d) then
			requireDir(d)
		else
			if v:find(".lua") then
				require(path .. "." .. v:match("[^.]+"))
			end
		end
	end
end


function setScale(scale)
	if scale == SCALE then return end

	SCALE = scale
	love.window.setMode((1920/RES)*SCALE, (1080/RES)*SCALE)
end


return base