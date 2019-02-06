local Once = Object:extend()

function Once:new(obj)
	self._obj = obj
	self._used = {}
end


function Once:call(f, ...)
	if not self._used[f] then
		self._used[f] = true
		return self._obj[f](self._obj, ...)
	end
end


function Once:back(f, bf, ...)
	if self._used[f] then
		self._used[f] = nil
		return self._obj[bf](self._obj, ...)
	end
end

return Once