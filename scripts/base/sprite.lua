local Sprite = Rect:extend()

Sprite._quadCache = {}
Sprite._borderShader = Shader.new("border")

function Sprite:new(x, y, img, w, h)
	Sprite.super.new(self, x, y)
	self.anim = Animation()
	self.offset = Point(0, 0)
	self.scale = Point(1, 1)
	self.origin = Point(0, 0)
	self.shear = Point(0, 0)
	self.border = Point(0, 0)
	self.border.color = {255, 255, 255}
	self.border.auto = true
	self.alpha = 1
	self.color = {255,255,255}
	self.angle = 0
	self.angleOffset = 0
	self.rotate = 0
	self.flip = {x = false, y = false}
	self.visible = true
	self.mirror = false
	self.parent = nil

	self.shader = nil
	self._shaders = {
		border = Sprite._borderShader
	}

	self._frames = {}
	if img then self:setImage(img, w, h) end
end


function Sprite:update(dt)
	self.anim:update(dt)
	self.angle = self.angle + self.rotate * dt
	if self.angle < -math.pi then self.angle = self.angle + math.pi * 2 end
	if self.angle > math.pi then self.angle = self.angle - math.pi * 2 end
	
	if self.shader then
		for i,v in ipairs(self._shaders[self.shader].names) do
			if Shader.has(v, "rnd") then
				self:send(v .. "_rnd", math.random())
			end
		end
	end
end


function Sprite:draw(img, x, y, r, sx, sy, ox, oy, kx, ky)
	if self.visible and self.alpha > 0 then
		love.graphics.push("all")
		love.graphics.translate(
			x or self.x + self.origin.x + self.offset.x + (self.anim.offset[1] * (self.flip.x and -1 or 1)), 
			y or self.y + self.origin.y + self.offset.y + self.anim.offset[2])
		
		love.graphics.rotate(self.angle + self.angleOffset)
		love.graphics.scale(
			self.flip.x and -(sx or self.scale.x) or (sx or self.scale.x),
			self.flip.y and -(sy or self.scale.y) or (sy or self.scale.y))

		if self.border.auto then
			self:drawBorder(img, x, y, r, sx, sy, ox, oy, kx, ky)
		end

		love.graphics.setColor(self.color[1],self.color[2],self.color[3], self.alpha * 255)
		if self.blend then love.graphics.setBlendMode(self.blend) end
		if self.shader then love.graphics.setShader(self._shaders[self.shader].shader) end

		self:drawImage(img, x, y, r, sx, sy, ox, oy, kx, ky)
		
		love.graphics.pop()
	end

	love.graphics.setColor(255,255,255,255)
end


function Sprite:drawImage(img, x, y, r, sx, sy, ox, oy, kx, ky)
	if img then
		love.graphics.draw(img, 
		x or 0, y or 0,
		r or 0,
		sx or 1, sy or 1, 
		ox or self.origin.x, oy or self.origin.y,
		kx or self.shear.x, ky or self.shear.y)
	elseif self.image then
		assert(self.anim.frame >= 1 and self.anim.frame <= #self.anim._current.frames,"Frame out of range! Frame: " .. self.anim.frame .. ", Max: " .. #self.anim._current.frames .. " Anim: " .. self.anim:get(), 3)
		love.graphics.draw(img or self.image, self._frames[self.anim._current.frames and self.anim._current.frames[self.anim.frame] or 1], 
		0, 0,
		0,
		1, 1, 
		self.origin.x, self.origin.y,
		self.shear.x, self.shear.y)
	else
		love.graphics.push()
		love.graphics.translate(-self.x, -self.y)
		Sprite.super.draw(self)
		love.graphics.pop()
	end
end


function Sprite:drawBorder(img, x, y, r, sx, sy, ox, oy, kx, ky)
	if self.border.x ~= 0 or self.border.y ~= 0 then
		self._shaders.border:send("border_color", self.border.color)
		love.graphics.setShader(self._shaders.border)
		for i=-self.border.x,self.border.x,self.border.x do
			for j=-self.border.y,self.border.y,self.border.y do
				love.graphics.translate(i, j)
				self:drawImage(img, x, y, r, sx, sy, ox, oy, kx, ky)
				love.graphics.translate(-i, -j)
			end
		end
		love.graphics.setShader()
	end
end


function Sprite:drawDebug()
	love.graphics.setColor(255,0,0)
	love.graphics.setLineWidth(0.2)
	love.graphics.rectangle("line",self.x, self.y, self.width, self.height)
	love.graphics.circle("fill",self.x, self.y, 1, 10)
	-- love.graphics.circle("fill",self:centerX(), self:centerY(), 1, 10)
	love.graphics.circle("fill",self.x + self.origin.x, self.y +  self.origin.y, 1, 10)
end


function Sprite:setImage(url, width, height, margin)
	self.image = Asset.image(url)
	self._frames = {}

	margin = margin and margin or (width and 1 or 0)
	local imgWidth, imgHeight
	imgWidth = self.image:getWidth()
	imgHeight = self.image:getHeight()

	width = width or imgWidth
	height = height or imgHeight

	local hor = imgWidth/width
	local ver = imgHeight/height
	if width then
		assert(math.floor(hor) == hor, "The given width (" .. width ..") doesn't round up with the image width (" .. imgWidth ..")", 2)
		assert(math.floor(ver) == ver, "The given height (" .. height ..") doesn't round up with the image height (" .. imgHeight ..")", 2)
	end

	if Sprite._quadCache[url] then
		self._frames = Sprite._quadCache[url]
	else
		local t = {}
		for i=0,ver-1 do
			for j=0,hor-1 do
				table.insert(self._frames, love.graphics.newQuad(margin + j * (width), margin + i * (height), width-margin, height-margin, imgWidth, imgHeight) )
			end
		end
		Sprite._quadCache[url] = self._frames
	end

	self.width = width-margin*2
	self.height = height-margin*2

	self:centerOrigin()

	self.anim:_setFrames(#self._frames)
	return self
end


--TODO: Make this how you give borders to everything
-- local dirs = {{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1},	{0, 1},	{1, 1}}

-- local cache = {}
-- function Sprite:addBorder()
-- 	if cache[self.image] then return end
-- 	cache[self.image] = 1
-- 	local img_data = self.image:getData()
-- 	local new_img = love.image.newImageData(img_data:getWidth(), img_data:getHeight())

-- 	img_data:mapPixel(function (x, y, r, g, b, a)
-- 		if a > 0 and x > 0 and y > 0 and x < img_data:getWidth()-1 and y < img_data:getHeight()-1 then
-- 			for i,v in ipairs(dirs) do
-- 				new_img:setPixel(x+v[1], y+v[2], 255, 0, 0, 255)
-- 			end
-- 		end
-- 		return r, g, b, a
-- 	end)

-- 	img_data:mapPixel(function (x, y, r, g, b, a)
-- 		if a > 0 then
-- 			new_img:setPixel(x, y, r, g, b, a)
-- 		end
-- 		return r, g, b, a
-- 	end)

-- 	img_data:paste(new_img, 0, 0, 0, 0, new_img:getWidth(), new_img:getHeight())

-- 	self.image:refresh()
-- end


function Sprite:centerOrigin()
	self.origin.x = self.width/2
	self.origin.y = self.height/2
end


function Sprite:centerOffset()
	self.offset.x = -self.width/2
	self.offset.y = -self.height/2
end


function Sprite:setFilter(filter)
	self.image:setFilter(filter)
end


function Sprite:setBlend(blend)
	self.blend = blend
end


function Sprite:addShader(name, ...)
	local list = {...}
	if not ... then list = {name} end
	self._shaders[name] = {shader = Shader.new(unpack(list)), names = list}
	self.shader = name
end


function Sprite:setShader(name)
	self.shader = name
end


function Sprite:send(extern, ...)
	assert(self.shader, "You haven't set a shader!", 2)
	if not extern:find("_") then
		local names = self._shaders[self.shader].names
		if #names == 1 then
			extern = names[1] .. "_" .. extern
		else
			for i,v in ipairs(names) do
				if Shader.has(v, extern) then
					self._shaders[self.shader].shader:send(v .. "_" .. extxern, ...)
				end
			end
			return
		end
	end

	if self.shader then
		self._shaders[self.shader].shader:send(extern, ...)
	end
end


function Sprite:_str()
	return Sprite.super._str(self) .. ", angle: " .. math.floor(self.angle/2) .. ", frame: " .. self.anim.frame
end


function Sprite:__tostring()
	return lume.tostring(self, "Sprite")
end

return Sprite