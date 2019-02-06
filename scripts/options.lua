Options = Area:extend()

Options.fonts = {
	big = Asset.font("familiar", 120 * SCALE),
	normal = Asset.font("familiar", 70 * SCALE),
	small = Asset.font("familiar", 40 * SCALE)
}


Options.selectorPositions = {
	{x = 40, y = 50, width = 358, height = 250},
	{x = 673, y = 50, width = 500, height = 250},
	{x = 1480, y = 50, width = 300, height = 250},
}


Options.settings = {
	{"Shifter", "Rotater", "Swapper", value = 1},
	{2,3,4,5,6,7, value = 1},
	{3,4,5, value = 1}
}

Options.selectedSettings = {
	mode = "Shifter",
	colors = 2,
	size = 3
}

function Options:new(lines)
	Options.super.new(self)

	self.lines = lines

	self.flux = flux.group()

	for i,v in ipairs(Options.settings[1]) do
		if v == DATA.Settings.mode then
			Options.settings[1].value = i
		end
	end

	for i,v in ipairs(Options.settings[2]) do
		if v == DATA.Settings.colors then
			Options.settings[2].value = i
		end
	end

	for i,v in ipairs(Options.settings[3]) do
		if v == DATA.Settings.size then
			Options.settings[3].value = i
		end
	end

	Options.selectedSettings = DATA.Settings

	self.textTitleMode = Text(92, 40, "MODE", Options.fonts.big)
	if not self.lines then
		self.textTitleColor = Text(700, 40, "COLORS", Options.fonts.big)
	end
	self.textTitleSize = Text(1500, 40, "SIZE", Options.fonts.big)

	self.textMode = Text(70, 200, DATA.Settings.mode:upper(), Options.fonts.normal)
	self.textMode.align.x = "center"
	self.textMode.limit = 400
	if not self.lines then
		self.textColor = Text(940, 200, DATA.Settings.colors, Options.fonts.normal)
	end
	local size = DATA.Settings.size
	self.textSize = Text(1575, 200, size .. "x" .. size, Options.fonts.normal)

	self.textTime = Text(0, 330, "Time", Options.fonts.normal)
	local t = DATA.Times[self.lines and "Lines" or "Copy"][DATA.Settings.mode][DATA.Settings.size][DATA.Settings.colors]
	self.textTimer = Text(0, 400, t < 0 and "-" or lume.round(t, .01), Options.fonts.normal)
	self.textTimer.align.x = "center"
	self.textTime.align.x = "center"
	self.textTimer.limit = WIDTH
	self.textTime.limit = WIDTH

	self.text = buddies.new(self.textTitleMode, self.textTitleSize, self.textMode, self.textSize, self.textTimer, self.textTime, self.textTitleColor, self.textColor)
	self.text:set("color", {0, 0, 0})

	self.optionTexts = {{self.textTitleMode, self.textMode}, {self.textTitleColor, self.textColor}, {self.textTitleSize, self.textSize}}

	self.textEnter = Text(1450, 700, "Arrow Keys to select\n\nA & D to edit\n\nPress ENTER to start\n\nESC to go back", Options.fonts.small)
	self.textEnter.color = {0, 0, 0}
	self:addScenery(self.textEnter)

	self:addScenery(unpack(self.text))

	self.selected = 1

	self:highlightOption()

	self.data = Util.createData(3, 3)
	self:refreshField()

	self.settings = {}

	self.settings.colors = 3

	self.timer = 1
	self.dir = "right"
	self.x = 0
	self.y = 0
end


function Options:update(dt)
	Options.super.update(self, dt)

	self.timer = self.timer - dt
	if self.timer < 0 then
		self.timer = 0.5
		if self.dir == "right" then
			self.field:moveLeft()
			self.dir = "down"
		elseif self.dir == "down" then
			self.field:moveDown()
			self.dir = "right"
		end
	end

	if Key:isPressed("left") then
		if self.lines then
			self.selected = self.selected == 1 and 3 or 1
		else
			self.selected = (self.selected + 1) % 3 + 1
		end
		self:highlightOption()
	end

	if Key:isPressed("right") then
		if self.lines then
			self.selected = self.selected == 1 and 3 or 1
		else
			self.selected = self.selected % 3 + 1
		end
		self:highlightOption()
		-- self.flux:to(self.selector, 0.2, Options.selectorPositions[self.selected])
	end

	if Key:isPressed("d") then
		self:editSetting(1)
	elseif Key:isPressed("a") then
		self:editSetting(-1)
	end

	if Key:isPressed("space", "return") and not self.tween then
		DATA.Settings = self.selectedSettings
		self.tween = self.flux:to(self, .5, {y = -HEIGHT})
		:oncomplete(function () game:toState(self.play) end)
		self.play = Play(self.lines)
	end

	if Key:isPressed("escape") and not self.tween then
		self.tween = self.flux:to(self, .5, {y = HEIGHT})
		:oncomplete(function () game:toState(self.menu) end)
		self.menu = Menu(true)
	end

	self.flux:update(dt)
end


function Options:draw()
	love.graphics.push()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	Options.super.draw(self)
	love.graphics.pop()
	if self.play then
		love.graphics.translate(0, self.y + HEIGHT)
		self.play:draw()
	elseif self.menu then
		love.graphics.translate(0, self.y - HEIGHT)
		self.menu:draw()
	end
	love.graphics.pop()
end


function Options:highlightOption(opt)
	local opt = opt or self.selected
	for i,v in ipairs(self.optionTexts) do
		local a = i ~= opt and 0.3 or 1
		for j,w in ipairs(v) do
			self.flux:to(w, 0.1, {alpha = a})
		end
	end
end


function Options:editSetting(a)
	local t = Options.settings[self.selected]
	local content
	local old = t.value

	t.value = t.value + a
	
	if self.selected == 1 then
		if t.value > #t then
			t.value = 1
		end
		if t.value < 1 then
			t.value = #t
		end
		content = t[t.value]:upper()
	else
		t.value = lume.clamp(t.value, 1, #t)
		if t.value == old then return end
		local n = t[t.value]
		if self.selected == 3 then
			content = n .. "x" .. n
		else
			content = t[t.value]
		end
	end
	self.optionTexts[self.selected][2]:write(content)

	Options.selectedSettings.mode = Options.settings[1][Options.settings[1].value]
	Options.selectedSettings.colors = Options.settings[2][Options.settings[2].value]
	Options.selectedSettings.size = Options.settings[3][Options.settings[3].value]

	self:refreshField()
end


function Options:refreshField()
	if self.lines then
		Options.selectedSettings.colors = Options.selectedSettings.size
	end
	local data  = Util.createData(Options.selectedSettings.size, Options.selectedSettings.colors)
	if self.field then self.field.dead = true end
	self.field = _G[Options.selectedSettings.mode](data, 885 - (Options.selectedSettings.size - 3) * 67 , 520, 80)
	self.field.automated = true
	self.field.scale = 0.8

	local t = DATA.Times[self.lines and "Lines" or "Copy"][Options.selectedSettings.mode][Options.selectedSettings.size][Options.selectedSettings.colors]
	self.textTimer:write(t < 0 and "-" or lume.round(t, .01))

	self:addScenery(self.field)
end


function Options:__tostring()
	return lume.tostring(self, "Options")
end