Game = Object:extend()
local Intro = require "base.intro"


Sounds = {
	pok = Asset.audio("pok", true),
	pik = Asset.audio("pik", true),
	pek = Asset.audio("pek", true),
	pak = Asset.audio("pak", true),
}

MOVING = false

function Game:new(a)
	GameManager = self
	love.audio.setVolume(0.6)

	if love.filesystem.exists("data") then
		DATA = lume.deserialize(love.filesystem.read("data"))
	end


	if not DEBUG and not a then
		self.state = Intro()
	else
		self.state = Menu()
	end
end


function Game:update(dt)
	self.state:update(dt)
end


function Game:draw()
	self.state:draw()
end


function Game:endIntro()
	self.state = Menu()
end


function Game:toState(state)
	self.state = state
end


function PlaySound(name)
	if not MOVING and DATA.Configs.sound then
		Sounds[name]:stop()
		Sounds[name]:play()
	end
end

return Game