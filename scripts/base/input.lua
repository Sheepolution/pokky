local Input = Object:extend()

function Input:new()
	self._pressed = {}
	self._released = {}
	self._custom = {}
end


function Input:reset()
	self._pressed = {}
	self._released = {}
end


function Input:isPressed(...)
	return lume.any({...}, function (a) return self._custom[a] and lume.any(self._custom[a], function (b) return lume.find(self._pressed, b) end) end)
end


function Input:isReleased(...)
	return lume.any({...}, function (a) return self._custom[a] and lume.any(self._custom[a], function (b) return lume.find(self._released, b) end) end)
end


function Input:isDown(...)
	return lume.any({...}, function (a) return self._custom[a] and lume.any(self._custom[a], function (b) return love.keyboard.isDown(b) end) end)
end


function Input:set(name, t)
	self._custom[name] = t
end


function Input:inputpressed(input)
	table.insert(self._pressed, input)
	if not self._custom[input] then
		self._custom[input] = {input}
	end
end


function Input:inputreleased(input)
	table.insert(self._released, input)
end


function Input:_str()
	return "pressed: " .. (unpack(self._pressed) or " ") .. ", released: " .. (unpack(self._released) or " ")
end


function Input:__tostring()
	return lume.tostring(self, "Input")
end

return Input