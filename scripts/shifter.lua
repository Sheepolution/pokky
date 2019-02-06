Shifter = Mode:extend()

function Shifter:new(...)
	Shifter.super.new(self, ...)
	self.cursor = Cursor(1, 1, self.width, 1, self)
	self.cursor2 = Cursor(1, 1, 1, self.height, self)
	self.cursors:add(self.cursor, self.cursor2)
end


function Shifter:moveLeft()
	local t = {}
	for i=0,self.width-1 do
		local j = i == self.width-1 and -1 or i
		t[{j+1,0}] = {i,0}
	end
	self:moveTiles(self.cursor.x, self.cursor.y, t)
end


function Shifter:moveUp()
	local t = {}
	for i=0,self.height-1 do
		local j = i == self.height-1 and -1 or i
		t[{0,j+1}] = {0,i}
	end
	self:moveTiles(self.cursor2.x, self.cursor2.y, t)
end


function Shifter:moveRight()
	local t = {}
	for i=0,self.width-1 do
		local j = i == self.width-1 and -1 or i
		t[{i,0}] = {j+1,0}
	end
	self:moveTiles(self.cursor.x, self.cursor.y, t)
end


function Shifter:moveDown()
	local t = {}
	for i=0,self.height-1 do
		local j = i == self.height-1 and -1 or i
		t[{0,i}] = {0,j+1}
	end
	self:moveTiles(self.cursor2.x, self.cursor2.y, t)
end


function Shifter:__tostring()
	return lume.tostring(self, "Shifter")
end