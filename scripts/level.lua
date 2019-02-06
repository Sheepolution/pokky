Level = Area:extend()

function Level:new()
	LEVEL = self
	Level.super.new(self)
	self.data = Util.createData(DATA.Settings.size, DATA.Settings.colors)
	-- Level.super.update(self, dt)

	self.textTimer = Text(95, 990, "0.00", Options.fonts.normal)
	self.textTimer.color = {0, 0, 0}

	self.textOldTimer = Text(1600, 990, "", Options.fonts.normal)
	self.textOldTimer.color = {0, 0, 0}

	self.textEscape = Text(430, 990, "ESC to go back       R to restart", Options.fonts.normal)
	self.textEscape.color = {0, 0, 0}
	self.textEscape.visible = false

	local ot = DATA.Times[self.mode][DATA.Settings.mode][DATA.Settings.size][DATA.Settings.colors]
	self.textOldTimer:write(ot < 0 and "-" or lume.round(ot, 0.01))
	self.oldTimer = ot

	self:addScenery(self.textTimer, self.textOldTimer, self.textEscape)

	self.timer = 0

	self.start = false

	self.gameWon = false
end


function Level:update(dt)
	Level.super.update(self, dt)
	if self:winCondition() then
		if not self.gameWon then
			self.field.tileObjects:circelize()
			if self.oldTimer < 0 then self.oldTimer = self.timer end
			DATA.Times[self.mode][DATA.Settings.mode][DATA.Settings.size][DATA.Settings.colors] = self.timer < self.oldTimer and self.timer or self.oldTimer
			love.filesystem.write("data", lume.serialize(DATA))
		end
		self.gameWon = true
		self.field.inControl = false
		self.field.tileObjects:set("selected", true)
		self.textEscape.visible = true
	else
		if not self.start then return end
		self.timer = self.timer + dt
		local t = lume.round(self.timer, 0.01)
		self.textTimer:write(t)
		if t % 1 == 0 then
			self.textTimer:append(".00")
		elseif t % 0.1 == 0 then
			self.textTimer:append("0")
		end
		if self.oldTimer == -1 then
			self.textTimer.color = {0, 200, 0}
		elseif self.timer < self.oldTimer - 5 then
			self.textTimer.color = {0, 200, 0}
		elseif self.timer < self.oldTimer then
			self.textTimer.color = {235, 142, 12}
		else
			self.textTimer.color = {255, 0, 0}
		end
	end
end


function Level:draw()
	Level.super.draw(self)
end


function Level:winCondition()
end


function Level:__tostring()
	return lume.tostring(self, "Level")
end