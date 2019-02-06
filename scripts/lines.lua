Lines = Level:extend()

function Lines:new()
	self.mode = "Lines"
	Lines.super.new(self)
	self.data = Util.createData(DATA.Settings.size, DATA.Settings.colors)
	local i = DATA.Settings.size-3
	self.field = self:addScenery(_G[DATA.Settings.mode](self.data, 570 - (85 * i), 130  - (70 * i)))
	repeat self.field:shuffleData()
	until not self:winCondition() and self:noLines()
end


function Lines:winCondition()
	local goal = true
	for i=1,DATA.Settings.size do
		local a = self.field.data[i][1] 
		for j=1,DATA.Settings.size do
			if self.field.data[i][j] ~= a then
				goal = false
				break
			end
		end
		if not goal then break end
	end

	if goal then return true end
	
	local goal = true
	for i=1,DATA.Settings.size do
		local a = self.field.data[1][i] 
		for j=1,DATA.Settings.size do
			if self.field.data[j][i] ~= a then
				goal = false
				break
			end
		end
		if not goal then break end
	end
	if goal then return true end
end


function Lines:noLines()
	local goal = true
	for i=1,DATA.Settings.size do
		local a = self.field.data[i][1] 
		for j=1,DATA.Settings.size do
			if self.field.data[i][j] ~= a then
				goal = false
				break
			end
		end
		if goal then return false end
	end

	local goal = true
	for i=1,DATA.Settings.size do
		local a = self.field.data[1][i] 
		for j=1,DATA.Settings.size do
			if self.field.data[j][i] ~= a then
				goal = false
				break
			end
		end
		if goal then return false end
	end

	return true
end


function Lines:__tostring()
	return lume.tostring(self, "Lines")
end