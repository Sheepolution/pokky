local Text = Rect:extend()

for k,v in pairs(string) do
	Text[k] = function (self, ...)
		return string[k](self:read(), ...)
	end
end


function Text:new(x, y, text, font, size, force)
	Text.super.new(self, x, y)
	self.origin = Point(0, 0)
	self.offset = Point(0, 0)
	self.scale = Point(1, 1)
	self.shear = Point(0, 0)
	self.shadow = Point(0, 0)
	self.shadow.alpha = 1
	self.shadow.color = {0, 0, 0}

	self.border = Point(0,0)
	self.border.alpha = 1
	self.border.color = {0,0,0}

	self.alpha = 1
	self.color = {255,255,255}
	self.angle = 0

	self.visible = true
	self.blend = "alpha"
	---------------
	self:write(text or "")
	self.align = {x = "left", y = "top"} 
	self.limit = 999999

	if type(font) == "number" then
		size = font
		font = "sheepixel"
	elseif not font then
		font = "sheepixel"
	end

	if type(font) == "string" then
		self.font = Asset.font(font, (size or 12) * SCALE, force)
	else
		self.font = font
	end

	self.size = size or 12
	-- self.contentObject = love.graphics.newText(self.font)
	-- self.contentObjectString = ""
end


function Text:draw(s)
	if not self.visible or self.alpha == 0 then return end
	love.graphics.setFont(self.font)
	local factor = 1

	if self.shadow.x ~= 0 or self.shadow.y ~= 0 then
		love.graphics.setColor(self.shadow.color[1],self.shadow.color[2],self.shadow.color[3], self.shadow.alpha * 255)
		love.graphics.push()
		love.graphics.translate((self.shadow.x/SCALE) * factor, (self.shadow.y/SCALE) * factor)
		self:print(s)
		love.graphics.pop()
	end

	if self.border.x ~= 0 or self.border.y ~= 0 then
		love.graphics.setColor(self.border.color[1],self.border.color[2],self.border.color[3], self.border.alpha * 255)
		for i=-self.border.x,self.border.x do
			for j=-self.border.y,self.border.y do
				love.graphics.translate((i/SCALE) * factor, (j/SCALE) * factor)
				self:print(s)
				love.graphics.translate(-i/SCALE * factor, -j/SCALE * factor)
			end
		end
	end

	love.graphics.setColor(self.color[1],self.color[2],self.color[3],self.alpha * 255)
	if self.blend then love.graphics.setBlendMode(self.blend) end
	self:print(s)

	love.graphics.setColor(255,255,255,255)
	if self.blend then love.graphics.setBlendMode("alpha") end
end


function Text:print(s)

	love.graphics.push()

	if self.align.y ~= "top" then
		local width, lines = self:getWrap()
		local height = self:getTrueHeight() * #lines * 2
		height = height - (((self:getLineHeight()-1) * self:getHeight()) * 2)
		if self.align.y == "center" then
			love.graphics.translate(0, -height/2)
		elseif self.align.y == "bottom" then
			love.graphics.translate(0, -height)
		else
			error("Invalid vertical alignment!")
		end
	end

	love.graphics.scale(1/SCALE, 1/SCALE)
	love.graphics.printf(s or self.content,
	(self.x + self.offset.x + self.origin.x)*SCALE,
	(self.y + self.offset.y + self.origin.y)*SCALE, 
	self.limit*SCALE, self.align.x,
	self.angle, self.scale.x, self.scale.y, 
	self.origin.x*SCALE, self.origin.y*SCALE, self.shear.x, self.shear.y)
	love.graphics.pop()
end


function Text:write(text, color)
	self.content = {color or self.color, text}
end


function Text:append(text, color)
	table.insert(self.content, color or self.color)
	table.insert(self.content, text)
	return self.content
end


function Text:read()
	local str = ""
	for i,v in ipairs(self.content) do
		if type(v) == "string" then
			str = str .. v
		end
	end
	return str
end


function Text:readReal()
	return self.content
end


function Text:getHeight()
	return self.font:getHeight() / SCALE
end


function Text:getTrueHeight()
	return self:getHeight() * self:getLineHeight()
end


function Text:getLineHeight()
	return self.font:getLineHeight()
end


function Text:getLength(s)
	return self.font:getWidth(s or self:read())/SCALE
end


function Text:getWrap(s)
	local width, lines = self.font:getWrap(s or self.content, self.limit*SCALE)
	return width/SCALE, lines
end


function Text:setFont(font, size, force)
	self.font = Asset.font(font, (size or 12) * SCALE, force)
end


function Text:_str()
	return "x: " .. self.x .. ", y: " .. self.y .. ", text: " .. self.content
end


function Text:__tostring()
	return lume.tostring(self, "Text")
end

return Text