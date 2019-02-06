Play = Area:extend()

function Play:new(lines)
	Play.super.new(self)
	PlayManager = self

	self.lines = lines
	self.level = self.lines and Lines() or Copy()
	self:addScenery(self.level)
	-- INSTANT_MOVEMENT = true
	self.flux = flux.group()
	self.y = 0

	self.soundIcon = Sprite(0, 0, "sound", 126, 123)
	self.soundIcon.anim:add("off", 1)
	self.soundIcon.anim:add("on", 2)
	self.soundIcon.scale:set(0.7)
	self.soundIcon.alpha = 0.6
	self.soundText = Text(120, 20, "M", Options.fonts.normal)
	self.soundText.color = {0, 0, 0}
	self.soundText.alpha = 0.6
	self:addScenery(self.soundIcon, self.soundText)

	if DATA.Configs.sound then
		self.soundIcon.anim:set("on")
		self.soundText.alpha = 0.6
		self.soundIcon.alpha = 0.6
	else
		self.soundIcon.anim:set("off")
		self.soundText.alpha = 0.3
		self.soundIcon.alpha = 0.3
	end
end


function Play:update(dt)
	Play.super.update(self, dt)

	if Key:isPressed("escape") and not self.tween then
		self.tween = self.flux:to(self, 0.5, {y = HEIGHT})
		:oncomplete(function () game:toState(self.options) end)
		self.options = Options(self.lines)
	elseif Key:isPressed("r") then
		game:toState(Play(self.lines))
	end

	if Key:isPressed("m") then
		DATA.Configs.sound = not DATA.Configs.sound
		if DATA.Configs.sound then
			self.soundIcon.anim:set("on")
			self.soundText.alpha = 0.6
			self.soundIcon.alpha = 0.6
		else
			self.soundIcon.anim:set("off")
			self.soundText.alpha = 0.3
			self.soundIcon.alpha = 0.3
		end
	end

	self.flux:update(dt)
end


function Play:draw()
	love.graphics.push()
		if self.options then
		love.graphics.push()
			love.graphics.translate(0, -HEIGHT + self.y)
			self.options:draw()
		love.graphics.pop()
		end
		love.graphics.translate(0, self.y)
		Play.super.draw(self)
	love.graphics.pop()
	
end


function Play:__tostring()
	return "Play"
end