Particle = Entity:extend()

function Particle:new(x, y, flags)
	Particle.super.new(self, x, y)
	self.timer = 0
	if flags then
		for k,v in pairs(flags) do
			self[k] = v
		end
	end
	if self.maxSpeed then
		local speed = lume.random(self.minSpeed or 0, self.maxSpeed)
		if self.circleSpread then
			self.angle = math.random(TAU)
			self:moveToAngle(speed)
		end
	end
end


function Particle:update(dt)
	self:onUpdate(dt)
end


function Particle:onUpdate(dt)
	Particle.super.update(self, dt)
	self.timer = self.timer + dt

	if self.lifespan then
		self.lifespan = self.lifespan - dt
		if self.lifespan <= 0 then
			self:kill()
		end
	end

	if self.alphaSpeed then
		self.alpha = self.alpha - self.alphaSpeed * dt
		if self.alpha <= 0 then
			self.alpha = 0
			self:kill()
		end
	end

	if self.scaleSpeed then
		self.scale.x = self.scale.x + self.scaleSpeed * dt
		self.scale.y = self.scale.y + self.scaleSpeed * dt
		if self.scale.x <= 0 then
			self.scale.x = 0
			self:kill()
		end
	end
end


function Particle:__tostring()
	return lume.tostring(self, "Particle")
end

-----------------------
Particles = {}

Particles.explosion_small = function (x, y)
	local self = Particle(x, y)
	self:setImage("explosion_small", 18, 18)
	self.anim:add("_", {1,2,3,4}, {16,16,24,24}, "once")
		:onComplete(function () self.dead = true end)
	self:centerX(x)
	self:centerY(y)
	return self
end


Particles.dirt = function (x, y, vx, vy)
	local self = Particle(x, y)
	self.width = 1
	self.height = 1
	self.velocity.x = vx or 0
	self.velocity.y = vy or 0
	self:centerX(x)
	self:centerY(y)
	self.timer = 0.05 + math.random()/10
	return self
end


Particles.splash = function (x, y, vx, vy)
	local self = Particle(x, y)
	self.width = 1
	self.height = 1
	self.velocity.x = vx or math.random(-40, 40)
	self.velocity.y = vy or -math.random(50, 60)
	self.velocity.y = self.velocity.y*lume.random(0.5, 1)
	self.accel.y = 300
	self:centerX(x)
	self:centerY(y)
	self.border:set(0)
	self.startY = self.y
	function self:update(dt)
		if self.y > self.startY then
			self:kill()
		end
		self:onUpdate(dt)
	end
	return self
end


Particles.bubble = function (x, y)
	local self = Particle(x, y)
	self.width = 1
	self.height = 1
	self.velocity.x = vx or math.random(-40, 40)
	self.velocity.y = -10

	self:centerX(x)
	self:centerY(y)
	self.startY = self.y

	self.cosValue = 0

	self.autoFlip = false

	function self:update(dt)
		self.cosValue = self.cosValue + dt * 4
		self.velocity.x = math.cos(self.cosValue) * 10
		local t = self.world.tiles:find(function (ent) return ent:is(Liquid) and ent:overlaps(self) end) 
		if #t == 0 then
			self:kill()
		end
		self:onUpdate(dt)
	end
	self:postNew()
	return self
end


Particles.cloud = function (x, y, vx, vy)
	local self = Particle(x, y)
	self:toCircle()
	self.radius = 2
	self.thickness = 0.5
	self.mode = "line"
	self.velocity.x = vx or 0
	self.velocity.y = vy or 0
	self:centerX(x)
	self:centerY(y)
	self.alphaSpeed = 4
	self.timer = 0.05 + math.random()/10
	return self
end


Particles.leaf = function (x, y, planet)
	local self = Particle(x, y)
	self.angleOffset = PI/2
	-- self:setPlanet(planet)
	-- self:centerX(x)
	-- self:centerY(y)
	self.planet = planet
	self:setImage("leaf")
	self.accel.y = 0
	self.cosValue = 0
	-- self.alphaSpeed = 0.2
	self.border:set(0,0)
	-- self.velocity.x = 10
	self.velocity.y = 10
	function self:update(dt)
		self.cosValue = self.cosValue + dt * 4
		self.velocity.x = math.cos(self.cosValue) * 10
		self:onUpdate(dt)
	end
	return self
end


Particles.chimney_smoke = function (x, y, circle)
	local self = Particle(x, y)
	self.layer = 1
	self.angleOffset = PI/2
	self:toCircle()
	self.radius = 4
	self.mode = "fill"
	-- self:setPlanet(planet)
	-- self:centerX(x)
	-- self:centerY(y)
	self.accel.y = 0
	self.cosValue = 0
	-- self.alphaSpeed = 0.2
	-- self.border:set(0,0)
	-- self.accel.x = -10
	self.velocity.y = -12
	function self:update(dt)
		self:onUpdate(dt)
		self.radius = self.radius - dt
		if self.radius <= 0 then
			self:kill()
		end
	end
	return self
end