local Intro = Object:extend()

--1: normal, 2: hd, 3: hdplus, 4:pixel, 5:pixelhd
Intro.SHEEP = 3

local lovesplash = require "libs.o-ten-one"

function Intro:new()
	self.splash = lovesplash.new({background={0,0,0}})

	self.logoSheep = Sprite(0,0,"logos/sheepolution_".. ({"normal", "hd", "hdplus", "pixel", "pixelhd"})[Intro.SHEEP])
	self.logoSheep:setFilter(Intro.SHEEP < 4 and "linear" or "nearest")
	self.logoSheep:centerX(WIDTH/2)
	self.logoSheep:centerY(HEIGHT/2)
	self.logoSheep.scale:set(math.min(WIDTH/ self.logoSheep.width, HEIGHT / self.logoSheep.height))

	self.rect = Rect(0, 0, WIDTH, HEIGHT)
	self.rect.color = {0, 0, 0}

	self.state = "sheep"

	self.flux = flux.group()
	self.flux:to(self.rect, 0.5, {alpha = 0}):delay(0.1)
	:after(0.5, {alpha = 1}):delay(1.2):oncomplete(function() self.state = "love" end)
	:after(0.5, {alpha = 0})
	self.splash.onDone = function () self.flux:to(self.rect, 0.5, {alpha = 1}):oncomplete(function () GameManager:endIntro() end)  end

end


function Intro:update(dt)
	self.flux:update(dt)
	if Key:isPressed("escape") or Key:isPressed("return") then
		GameManager:endIntro()
	end
	if self.state == "love" then
		self.splash:update(dt)
	end
end


function Intro:draw()
	self.logoSheep:draw()
	if self.state == "love" then
		love.graphics.push()
		love.graphics.origin()
		self.splash:draw(dt)
		love.graphics.pop()
	end
	self.rect:draw()
end

return Intro