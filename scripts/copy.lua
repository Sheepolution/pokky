Copy = Level:extend()

function Copy:new()
	self.mode = "Copy"
	Copy.super.new(self)
	local i = DATA.Settings.size-3
	self.field = self:addScenery(_G[DATA.Settings.mode](self.data, 80 - (70 * i), 130  - (70 * i)))
	self.copy = self:addScenery(Field(Util.copyData(self.data), 1000 - (70 * i), 130   - (70 * i)))
	repeat self.field:shuffleData()
	until not self:winCondition() and self:countMatching() <= (DATA.Settings.colors < 4 and (DATA.Settings.size + DATA.Settings.size - 3) or 3) 
end


function Copy:update(dt)
	for i=1,DATA.Settings.size do
		for j=1,DATA.Settings.size do
			if self.field.data[i][j] == self.copy.data[i][j] then
				self.copy.tileData[i][j]:highlight()
			else
				self.copy.tileData[i][j]:stopHighlight()
			end
		end
	end
	Copy.super.update(self, dt)
end


function Copy:draw()
	Copy.super.draw(self)
	love.graphics.setColor(12, 12, 12, 100)
	love.graphics.line(WIDTH/2, 100, WIDTH/2, HEIGHT - 100)
	love.graphics.setColor(255, 255, 255)
end


function Copy:winCondition()
	for i=1,DATA.Settings.size do
		for j=1,DATA.Settings.size do
			if self.field.data[i][j] ~= self.copy.data[i][j] then
				return
			end
		end
	end
	return true
end


function Copy:countMatching()
	local n = 0
	for i=1,DATA.Settings.size do
		for j=1,DATA.Settings.size do
			if self.field.data[i][j] == self.copy.data[i][j] then
				n = n + 1
			end
		end
	end
	return n
end


function Copy:__tostring()
	return lume.tostring(self, "Copy")
end