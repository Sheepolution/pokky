local Entity = Sprite:extend()
local HitboxGroup = require "base.hitboxgroup"

function Entity:new(x, y, img, w, h)
	Entity.super.new(self, x, y, img, w, h)

	self.z = 0
	
	self.velocity = Point(0, 0)
	self.maxVelocity = Point(9999999, 9999999)
	self.accel = Point(0, 0)
	self.drag = Point(0, 0)

	self.angularVelocity = 0
	
	self.last = Rect(x, y, w, h)
	self.dead = false
	self.active = true
	self.solid = true
	self.bounce = Point(0, 0)
	self.immovable = false
	self.moves = true

	self.autoFlip = {x = true, y = false}

	self.coil = coil.group()
	self.flux = flux.group()
	self.tick = tick.group()

	self.separatePriority = Point(0,0)
	self._sp = Point(0,0)

	self.inControl = true

	self.HC = false
	self.hitboxes = {}
end


function Entity:postNew()
	self.last:clone(self)
	self._sp:clone(self.separatePriority)
	if self.width > 0 and self:countHitboxes() == 0 then
		self.hitbox = self:addHitbox("solid", self.width, self.height, self.hitboxType or "solid")
	end
end


function Entity:update(dt)
	Entity.super.update(self, dt)

	for k,v in pairs(self.hitboxes) do
		v:update(dt)
	end
	
	self._sp:clone(self.separatePriority)
	if self.moves then
		self:move(dt)
	end

	self.coil:update(dt)
	self.flux:update(dt)
	self.tick:update(dt)
end


function Entity:draw()
	self:setFlip()
	Entity.super.draw(self)
end


function Entity:drawDebug()
	Entity.super.drawDebug(self)
	for k,v in pairs(self.hitboxes) do
		for i,hb in ipairs(v.list) do
			Data.add("drawcalls", -1)
			hb:draw()
			-- love.graphics.circle("fill", hb:getX(), hb:bottom(), 1, 20)
		end
	end
end


function Entity:setFlip()
	if self.autoFlip.x then
		self.flip.x = self.velocity.x == 0 and self.flip.x or self.velocity.x < 0 and true or false
	end
	if self.autoFlip.y then
		self.flip.y = self.velocity.y == 0 and self.flip.y or self.velocity.y < 0 and true or false
	end
end


function Entity:move(dt)
	self.last:clone(self)

	if self.angularVelocity ~= 0 then
		local cos, sin = math.cos(self.angle), math.sin(self.angle)
		self.x = self.x + cos * self.angularVelocity * dt
		self.y = self.y + sin * self.angularVelocity * dt
	else
		for i,v in ipairs({"x", "y"}) do
			self.velocity[v] = self.velocity[v] + self.accel[v] * dt;
			if math.abs(self.velocity[v]) > self.maxVelocity[v] then
				self.velocity[v] = self.maxVelocity[v] * (self.velocity[v] > 0 and 1 or -1);
			end

			self[v] = self[v] + self.velocity[v] * dt;
		end
		self:applyDrag(dt)
	end
end


function Entity:applyDrag(dt)
	for i,v in ipairs({"x", "y"}) do
		if self.accel[v] == 0 and self.velocity[v] ~= 0 and self.drag[v] ~= 0 then
			if (self.drag[v] * dt > math.abs(self.velocity[v])) then
				self.velocity[v] = 0;
			else
				self.velocity[v] = self.velocity[v] + self.drag[v] * dt * (self.velocity[v] > 0 and -1 or 1);
			end
		end
	end
end


function Entity:moveToAngle(speed, angle)
	self.velocity.x = math.cos(angle or self.angle) * speed
	self.velocity.y = math.sin(angle or self.angle) * speed
end


function Entity:teleport(x, y)
	self.x = x or self.x
	self.y = y or self.y
	self.last:clone(self)
end

function Entity:kill()
	self.dead = true
	self.active = false
end


function Entity:silence()
	self.active = false
end


--Set relative velocity
function Entity:setRelVel(x, y)
	if x then
		self.velocity.x = self.flip.x and x or -x
	end
	if y then
		self.velocity.y = self.flip.y and -y or y
	end

end


function Entity:addHitbox(name, x, y, width, height, proptype)
	if not self.hitboxes[name] then
		self.hitboxes[name] = HitboxGroup(self, name, self.HC)
	end

	return self.hitboxes[name]:add(x, y, width, height, proptype or self.hitboxType)
end


function Entity:removeHitbox(name)
	if self.hitboxes[name] then
		self.hitboxes[name]:kill()
		self.hitboxes[name] = nil
	end
end


function Entity:clearHitboxes()
	for k,v in pairs(self.hitboxes) do
		v:kill()
	end
	self.hitboxes = {}
end


function Entity:countHitboxes()
	return lume.count(self.hitboxes)
end


function Entity:overlappable(e)
	return self ~= e
	and not self.dead and not e.dead
	and self.active and e.active
	and (not self.ignoreOverlap or not lume.any(self.ignoreOverlap, function (a) return e:is(a) end))
	and (not e.ignoreOverlap or not lume.any(e.ignoreOverlap, function (a) return self:is(a) end))
end


function Entity:overlaps(e, mine, his)
	if e == self then return false end
	
	if his then
		if not self.hitboxes[mine] or not e.hitboxes[his] then return false end
		local t = self.hitboxes[mine]:overlaps(e.hitboxes[his])
		return #t > 0 and t or false
	end

	local t = {}
	local succes = false
	local list

	if mine then
		for hisname,hisbox in pairs(e.hitboxes) do
			list = self.hitboxes[mine]:overlaps(hisbox)
			for i,v in ipairs(list) do
				table.insert(t, v)
				succes = true
			end
		end
		return succes and t or false
	end

	for myname,mybox in pairs(self.hitboxes) do
		for hisname,hisbox in pairs(e.hitboxes) do
			list = mybox:overlaps(hisbox)
			for i,v in ipairs(list) do
				table.insert(t, v)
				succes = true
			end
		end
	end

	return succes and t or false
end


function Entity:onOverlap(e, mine, his)
	if self.solid or e.solid then
		return(not self.ignoreCollision or not lume.any(self.ignoreCollision, function (a) return e:is(a) end))
			and (not e.ignoreCollision or not lume.any(e.ignoreCollision, function (a) return self:is(a) end))
	end
end


function Entity:resolveCollision(e, mine, his)
	if self:overlappable(e) then
		local t = self:overlaps(e, mine, his)
		if t then
			for i,v in ipairs(t) do
				local mine, his = v[1], v[2]
				local a = self:onOverlap(e, mine, his)
				local b = e:onOverlap(self, his, mine)
				if a and b then
					if mine.solid and his.solid then
						self:separate(e, mine, his)
					end
				end
			end
		end
	end
end


function Entity:separate(e, mine, his)
	local x, y = mine:overlapsX(his, true), mine:overlapsY(his, true)
	printif(self:is(Player), x, y)
	if not x and not y then	return end
	--If there's an y-axis overlap then separate on x-axis
	self:separateAxis(e, y and "x" or "y", mine, his);
end


function Entity:separateAxis(e, a, mine, his)
	local s = a == "x" and "width" or "height"

	if self._sp[a] >= e._sp[a] then
		local ms = (mine.flipRelative[a] and (self.flip[a] and -mine[a] or mine[a]) or mine[a])
		local hs = (his.flipRelative[a] and (e.flip[a] and -his[a] or his[a]) or his[a])

		local ms_l = (mine.flipRelative[a] and (self.flip[a] and -mine.last[a] or mine.last[a]) or mine.last[a])
		local hs_l = (his.flipRelative[a] and (e.flip[a] and -his.last[a] or his.last[a]) or his.last[a])

		if e.last[a] + e.last[s]/2 + hs_l < self.last[a] + self.last[s]/2 + ms_l then
			e[a] = self[a] + self[s]/2 + ms - mine[s]/2 - (e[s]/2 + hs + his[s]/2)
		else
			e[a] = self[a] + self[s]/2 + ms - mine[s]/2 + mine[s] - (e[s]/2 - his[s]/2 + hs)
		end
		
		e:onSeparate(self, a, mine, his)
	else
		e:separateAxis(self, a, his, mine)
	end
end


function Entity:onSeparate(e, a, mine, his)
	printif(self:is(Player), e, a, mine, his)
	self.velocity[a] = self.velocity[a] * -self.bounce[a]
	self._sp[a] = e._sp[a]
end


local function addToList(t, ...)
	if not t then t = {} end
	for i,v in ipairs({...}) do
		table.insert(t, v)		
	end
	return lume.set(t)
end


function Entity:addIgnoreOverlap(...)
	self.ignoreOverlap = addToList(self.ignoreOverlap, ...)
end


function Entity:addIgnoreCollision(...)
	self.ignoreCollision = addToList(self.ignoreCollision, ...)
end



function Entity:callWithDelay(f, t, args)
	self.tick:delay(function () self[f](self, unpack(args or {})) end, t or 1)
end


function Entity:_str()
	return Entity.super._str(self) .. ", vel x: " .. self.velocity.x .. ", vel y: "
	.. self.velocity.y .. ", dead: " .. tostring(self.dead)
	.. ", solid: " .. tostring(self.solid)
end


function Entity:__tostring()
	return lume.tostring(self, "Entity")
end

return Entity