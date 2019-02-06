local Hitbox = Rect:extend()

Hitbox.propTypes = {
	all = {solid = true, weakness = true, damaging = true},
	solidweak = {solid = true, weakness = true, damaging = false},
	soliddamage = {solid = true, weakness = false, damaging = true},
	weakdamage = {solid = false, weakness = true, damaging = true},
	solid = {solid = true, weakness = false, damaging = false},
	weak = {solid = false, weakness = true, damaging = false},
	damage = {solid = false, weakness = false, damaging = true},
	none = {solid = false, weakness = false, damaging = false},
}

function Hitbox:new(p, name, x, y, width, height, proptype)
	self.parent = p
	self.name = name

	if not x then
		x, y = 0, 0
		width, height = self.parent.width, self.parent.height
	elseif type(width) ~= "number" then
		if width ~= nil then
			proptype = width
		end
		width, height = x, y
		x, y = 0, 0
	end

	Hitbox.super.new(self, x, y, width, height)
	self.last = Rect()
	self.last:clone(self)
	self.flipRelative = {x = true, y = true}


	if proptype then
		for k,v in pairs(Hitbox.propTypes[proptype]) do
			self[k] = v
		end
	else
		self.solid = true
		self.weakness = false
		self.damaging = false
	end

	-- if self.width % 2 ~= 0 or self.height % 2 ~= 0 then
	-- 	warning("The hitbox of ", self.parent," has an odd width (" .. self.width .. ") or height (" .. self.height .. ")")
	-- end
end


function Hitbox:update()
	self.last:clone(self)
end


function Hitbox:draw()
	love.graphics.setColor(0, 100, 200, 200)
	love.graphics.setLineWidth(0.5)
	love.graphics.rectangle("line", self:getBB())
	love.graphics.setColor(255, 255, 255)
end


function Hitbox:overlaps(h, last)
	local x1, y1, w1, h1 = self:getBB(last)
					--Unpack because else it doesn't return all for because of and or
	local x2, y2, w2, h2 = unpack(h:is(Hitbox) and {h:getBB(last)} or {h:get()})
	return 	x1 + w1 > x2 and
			x1 < x2 + w2 and
			y1 + h1 > y2 and
			y1 < y2 + h2

end


function Hitbox:overlapsX(h, last)
	local x1, y1, w1, h1 = self:getBB(last)
	local x2, y2, w2, h2 = h:getBB(last)
	printif(self.parent:is(Player), x1, x2, x1 + w1, x2 + w2)
	return  x1 + w1 > x2 and
			x1 < x2 + w2
end


function Hitbox:overlapsY(h, last)
	local x1, y1, w1, h1 = self:getBB(last)
	local x2, y2, w2, h2 = h:getBB(last)
	return  y1 + h1 > y2 and
			y1 < y2 + h2
end


function Hitbox:getBB(last)
	if last then
		return  self.parent.last.x + self.parent.last.width/2 + (self.flipRelative.x and (self.parent.flip.x and -self.last.x or self.last.x) or self.last.x) - self.last.width/2,
				self.parent.last.y + self.parent.last.height/2 + (self.flipRelative.y and (self.parent.flip.y and -self.last.y or self.last.y) or self.last.y) - self.last.height/2,
				self.last.width or 0, self.last.height or 0
	else
		return  self.parent.x + self.parent.width/2 + (self.flipRelative.x and (self.parent.flip.x and -self.x or self.x) or self.x) - self.width/2,
				self.parent.y + self.parent.height/2 + (self.flipRelative.y and (self.parent.flip.y and -self.y or self.y) or self.y) - self.height/2,
				self.width or 0, self.height or 0
	end
end


function Hitbox:getX(last)
	if last then
		return self.parent.last.x + self.parent.last.width/2 + (self.flipRelative.x and (self.parent.flip.x and -self.last.x or self.last.x) or self.last.x) - self.last.width/2
	else
		return self.parent.x + self.parent.width/2 + (self.flipRelative.x and (self.parent.flip.x and -self.x or self.x) or self.x) - self.width/2
	end
end


function Hitbox:getY(last)
	if last then
		return self.parent.last.y + self.parent.last.height/2 + (self.flipRelative.y and (self.parent.flip.y and -self.last.y or self.last.y) or self.last.y) - self.last.height/2
	else
		return self.parent.y + self.parent.height/2 + (self.flipRelative.y and (self.parent.flip.y and -self.y or self.y) or self.y) - self.height/2
	end
end


Hitbox.left = Hitbox.getX

Hitbox.top = Hitbox.getY

function Hitbox:right(last)
	if last then
		return self.parent.last.x + self.parent.last.width/2 + (self.flipRelative.x and (self.parent.flip.x and -self.last.x or self.last.x) or self.last.x) + self.last.width/2
	else
		return self.parent.x + self.parent.width/2 + (self.flipRelative.x and (self.parent.flip.x and -self.x or self.x) or self.x) + self.width/2
	end
end


function Hitbox:bottom(last)
	if last then
		return self.parent.last.y + self.parent.last.height/2 + (self.flipRelative.y and (self.parent.flip.y and -self.last.y or self.last.y) or self.last.y) + self.last.height/2
	else
		return self.parent.y + self.parent.height/2 + (self.flipRelative.y and (self.parent.flip.y and -self.y or self.y) or self.y) + self.height/2
	end
end


function Hitbox:centerX(last)
	if last then
		return self.parent.last.x + (self.flipRelative.x and (self.parent.flip.x and -self.last.x or self.last.x) or self.last.x)
	else
		return self.parent.x + (self.flipRelative.x and (self.parent.flip.x and -self.x or self.x) or self.x)
	end
end


function Hitbox:centerY(last)
	if last then
		return self.parent.last.y + (self.flipRelative.y and (self.parent.flip.y and -self.last.y or self.last.y) or self.last.y)
	else
		return self.parent.y + (self.flipRelative.y and (self.parent.flip.y and -self.y or self.y) or self.y)
	end
end


--CLEANUP: Unused, remove?
function Hitbox:_getlocalx()
	return self.flipRelative.x and (self.parent.flip.x and -self.x or self.x) or self.x
end


function Hitbox:_getlocaly()
	return self.flipRelative.x and (self.parent.flip.x and -self.x or self.x) or self.x
end


function Hitbox:kill()
end


function Hitbox:__tostring()
	return lume.tostring(self, "Hitbox")
end

return Hitbox