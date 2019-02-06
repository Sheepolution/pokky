Block = Rect:extend()

function Block:new(x, y, size)
	Block.super.new(self, x, y)
	self.oSize = size
	self.size = self.oSize
	self.highlightFactor = 1.5


	self.flux = flux.group()
	self.once = Once(self)

	self.isButton = false
	self.isCircle = false

	self.highlighted = true

	self.radius = 0
end


function Block:update(dt)
	-- Block.super.update(self, dt)
	self.width = self.size
	self.height = self.size
	self.flux:update(dt)
end


function Block:draw()
	local r, g, b = unpack(self.color)
	love.graphics.setColor(r, g, b, self.alpha * 255)
	love.graphics.push()
	love.graphics.translate(self.oSize/2,self.oSize/2)
	-- local style = self.selected and "fill" or "line"
	love.graphics.setLineWidth(10)
	if self.isCircle then
		love.graphics.circle("fill", self.x, self.y, self.size/2, 100)
	else
		love.graphics.rectangle("fill", self.x - self.size/2, self.y - self.size/2, self.size, self.size, self.size*0.1 + self.radius , self.size*0.1 + self.radius)
	end
	love.graphics.setColor(255, 255, 255, 255)
	if DATA.Configs.colorblind and not self.isButton then
		love.graphics.setFont(Options.fonts.big)
		love.graphics.print(self.id, self.x - self.oSize/4 + 5, self.y - self.oSize/4 - 15)
	end
	love.graphics.pop()

end


function Block:highlight()
	self.highlighted = true
	self.once:call("doHighlight")
end


function Block:doHighlight()
	self.flux:to(self, 0.1, {size = self.oSize * self.highlightFactor, alpha = 1})
end

function Block:stopHighlight()
	self.highlighted = false
	self.once:back("doHighlight", "toOriginalSize")
end

function Block:toOriginalSize()
	self.flux:to(self, 0.1, {size = self.oSize})
end


function Block:circelize()
	self.flux:to(self, 0.5, {radius = self.oSize/2}):oncomplete(function () self.isCircle = true end)
end


function Block:moveTo(x, y)
	if INSTANT_MOVEMENT then
		self.x = x
		self.y = y
	elseif not self.tween then
		MOVING = true
		self.tween = self.flux:to(self, 0.1, {x = x , y = y})
		:oncomplete(function () self.tween = nil MOVING = false end)
	end
end


function Block:scaleTo(size)
	self.tween = self.flux:to(self, 0.3, {size = size})
	:oncomplete(function () self.tween = nil end)
end



function Block:__tostring()
	return lume.tostring(self, "Block")
end