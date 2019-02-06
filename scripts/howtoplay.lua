Howtoplay = Area:extend()

function Howtoplay:new()
	Howtoplay.super.new(self)
	self.x = 0
	self.y = 0

	self.text = Text(0, 10, "Move the cursor(s) with the Arrow Keys\nMove the blocks with WASD", Options.fonts.normal)
	self.text.color = {0, 0, 0}
	self.text.align.x = "center"
	self.text.limit = WIDTH
	self:addScenery(self.text)

	self.data = Util.createData(5, 5)
	self.field = Shifter(self.data, 400, 80)
	self:addScenery(self.field)

	self.flux = flux.group()
end


function Howtoplay:update(dt)
	Howtoplay.super.update(self, dt)

	if Key:isPressed("escape") and not self.tween then
		self.tween = self.flux:to(self, .5, {x = WIDTH})
		:oncomplete(function () game:toState(self.menu) end)
		self.menu = Menu(true)
	end

	self.flux:update(dt)
end


function Howtoplay:draw()
	love.graphics.push()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	Howtoplay.super.draw(self)
	love.graphics.pop()
	if self.menu then
		love.graphics.translate(self.x - WIDTH, 0)
		self.menu:draw()
	end
	love.graphics.pop()
end


function Howtoplay:__tostring()
	return lume.tostring(self, "Howtoplay")
end