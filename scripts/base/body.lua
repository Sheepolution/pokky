local Body = Entity:extend()

function Body:new(world, x, y, img, w, h)
	Body.super.new(self, x, y, img, w, h)
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self:setShape("rectangle", self.width, self.height)
	self:setMass(1)
end


function Body:update(dt)
	Body.super.update(self, dt)
end


function Body:draw()
	self.x = self.body:getX()
	self.y = self.body:getY()
	Body.super.draw(self)
end


function Body:setShape(mode, w, h)
	if mode == "rectangle" then
		self.shape = love.physics.newRectangleShape(w or self.width, h or self.height)
	elseif mode == "circle" then
		self.shape = love.physics.newCircleShape(w or self.width)
	end
end


function Body:setMass(m)
	love.physics.newFixture(self.body, self.shape, m)
end


function Body:__tostring()
	return "Body"
end

return Body