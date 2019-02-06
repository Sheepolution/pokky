local Area = Object:extend()

function Area:new()
	self.entities = buddies.new()
	self.scenery = buddies.new()
	self.particles = buddies.new()
	self.everything = buddies.new(true, self.entities, self.scenery, self.particles)

	self.scale = 1

	self._cache = {}
end


function Area:update(dt)
	self.everything:update(dt)
	self.entities:others(function (a, b) a:resolveCollision(b)  end)
	self.everything:removeIf(function (a) return a.dead end)
end


function Area:draw()
	love.graphics.push()
	love.graphics.scale(self.scale)
	local t = self.everything:clone()
	t:sort("z")
	t:draw()
	if DEBUG and Key:isDown("tab") then
		t:drawDebug()
	end
	love.graphics.pop()
end


function Area:addEntity(a)
	self:finishObject(a)
	self.entities:add(a)
	return a
end


function Area:addScenery(...)
	local a = ({...})[1]
	for i,v in ipairs({...}) do
		self:finishObject(v)
		self.scenery:add(v)
	end
	return a
end


function Area:addSceneries(t)
	for i,v in ipairs(t) do
		self:finishObject(v)
		self.scenery:add(v)
	end
end


function Area:finishObject(a)
	a.world = self
	a:done()
end


function Area:addParticle(name, ...)
	local p = type(name) == "table" and name or Particles[name](...)
	p.world = self
	self.particles:add(p)
end


function Area:findEntity(f)
	return self.entities:find(f)[1]
end


function Area:findEntities(f)
	return self.entities:find(f)
end


function Area:findEntitiesOfType(a, f)
	local t
	if f then
		t = self.entities:find(function (x) return x:is(a) and f(x) end)
	else
		t = self.entities:find(function (x) return x:is(a) end)
	end
	return t
end


function Area:findEntityOfType(a, f)
	return self:findEntitiesOfType(a, f)[1]
end


function Area:__tostring()
	return lume.tostring(self, "Area")
end

return Area