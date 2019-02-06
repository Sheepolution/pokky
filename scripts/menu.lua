Menu = Area:extend()

function Menu:new(a)
	Menu.super.new(self)

	self.linesButton = self:addScenery(TileButton(500, 50, 350, 3, "menu_blocks"))
	self.copyButton = self:addScenery(TileButton(1060, 50, 350, 1, "menu_blocks2"))
	self.colorblindButton = self:addScenery(TileButton(500, 500, 350, 2, "eye"))
	self.tutorialButton = self:addScenery(TileButton(1060, 500, 350, 6, "questionmark"))

	self.buttons = buddies.new(self.colorblindButton, self.linesButton, self.copyButton, self.tutorialButton)
	self.buttons:set("autoHighlight", true)
	self.buttons:set("isButton", true)

	self.buttonLayout = 
	{{self.linesButton, self.copyButton},
	{self.colorblindButton, self.tutorialButton}}

	-- self.selectedButton = 2

	self.x = 0
	self.y = a and 0 or 1080

	self.textDescription = Text(0, 950, "Create horizontal or vertical lines of the same color", Options.fonts.normal)
	self.textDescription.limit = WIDTH
	self.textDescription.align.x = "center"
	self.textDescription.color = {0, 0, 0}
	self:addScenery(self.textDescription)

	self.texts = {
		{"Create horizontal or vertical lines of the same color", "Recreate the layout on the right"},
		{"Turn " .. (DATA.Configs.colorblind and " OFF " or " ON ") .. " Colorblind Mode", "Learn how to play the game"}
	}

	self.selector = {x=1, y=1}

	self.flux = flux.group()
	self.tick = tick.group()

	self.logo = buddies.new()
	for i,v in ipairs(require("logotable")) do
		if v == 1 then
			local t = Tile((i % 22) * 80, math.floor(i/22) * 80 - 850, 50, math.random(1, 7))
			self.logo:add(t)
		end
	end

	self.logo:set("isButton", true)
	local sounds = {"pok", "pik", "pak", "pek"}

	local t = lume.shuffle(lume.numbers(1, #self.logo))


	for i,v in ipairs(self.logo) do
		
		self.tick:delay(function () v:highlight()
			if i % 5 == 0 then
				PlaySound(sounds[i % 4 + 1])
			end
		end, t[i]/#self.logo + 1)
	end

	self.textSheep = Text(0, -200, "By Sheepolution", Options.fonts.normal)
	self.textSheep.limit = WIDTH
	self.textSheep.align.x = "center"
	self.textSheep.color = {0, 0, 0}
	self:addScenery(self.textSheep)

	self.showingLogo = not a

	self.rect = Rect(0, -HEIGHT, WIDTH, HEIGHT)
	self.rect.color = {0, 0, 0}
	self.flux:to(self.rect, 0.5, {alpha = 0})
end


function Menu:update(dt)
	Menu.super.update(self, dt)

	if not self.showingLogo then
		self.buttons:set("selected", false)
		-- print(self.selector.y,self.selector.x)
		self.buttonLayout[self.selector.y][self.selector.x].selected = true

		self.textDescription:write(self.texts[self.selector.y][self.selector.x])

		if Key:isPressed("space", "return") and not self.tween then
			if self.linesButton.selected then
				self.tween = self.flux:to(self, 0.5, {y = -HEIGHT})
				:oncomplete(function () game:toState(self.optionsMenu) end)
				self.optionsMenu = Options(true)
			elseif self.copyButton.selected then
				self.tween = self.flux:to(self, 0.5, {y = -HEIGHT})
				:oncomplete(function () game:toState(self.optionsMenu) end)
				self.optionsMenu = Options()
			elseif self.tutorialButton.selected then
				self.tween = self.flux:to(self, 0.5, {x = -WIDTH})
				:oncomplete(function () game:toState(self.howToPlay) end)
				self.howToPlay = Howtoplay()
			elseif self.colorblindButton.selected then
				DATA.Configs.colorblind = not DATA.Configs.colorblind
				self.texts[2][1] = "Turn " .. (DATA.Configs.colorblind and " OFF " or " ON ") .. " Colorblind Mode"
				self.textDescription:write(self.texts[2][1])
			end
		end

		if Key:isPressed("left") then
			self.selector.x = self.selector.x == 1 and 2 or 1
			-- self.selectedButton = self.selectedButton - 1
			-- if self.selectedButton < 1 then
				-- self.selectedButton = 3
			-- end
		elseif Key:isPressed("right") then
			self.selector.x = self.selector.x == 1 and 2 or 1
			-- self.selectedButton = self.selectedButton + 1
			-- if self.selectedButton > 3 then
				-- self.selectedButton = 1
			-- end
		elseif Key:isPressed("up") then
			self.selector.y = self.selector.y == 1 and 2 or 1
		elseif Key:isPressed("down") then
			self.selector.y = self.selector.y == 1 and 2 or 1
		elseif Key:isPressed("escape") then
			love.event.quit()
		end
	else
		if not self.tween then
			self.tick:update(dt)
		end
		self.logo:update(dt)
		if not self.tween and Key:isPressed("space", "s", "down", "return") then
			self.tween = self.flux:to(self, 0.5, {y = 0}):oncomplete(function() self.showingLogo = false self.tween = false end)
		end
	end
	self.flux:update(dt)
end


function Menu:draw()
	love.graphics.push()
		love.graphics.push()
			love.graphics.translate(self.x, self.y)
			Menu.super.draw(self)
			self.logo:draw()
			self.rect:draw()
		love.graphics.pop()
		if self.optionsMenu then
			love.graphics.translate(0, self.y + HEIGHT)
			self.optionsMenu:draw()
		end
		if self.howToPlay then
			love.graphics.translate(self.x + WIDTH, 0)
			self.howToPlay:draw()
		end
	love.graphics.pop()

end


function Menu:__tostring()
	return lume.tostring(self, "Menu")
end