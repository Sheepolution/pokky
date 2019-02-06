local Data = {}
Data.info = {}

function Data.add(k, v)
	v = v or 1
	local c = Data.info[k]
	Data.info[k] = c and c + v or v
end


function Data.reset()
	Data.info = {}
end


function Data.draw(x, y)
	love.graphics.setColor(0, 0, 0, 255 * .75)
	love.graphics.rectangle("fill", 5, 12, 110, lume.count(Data.info) * 15 + 3, 3)
	
	love.graphics.setColor(255, 255, 255)
	local i = 0
	for k,v in pairs(Data.info) do
		i = i + 1
		love.graphics.print(k .. ": " .. v, 10, 15 * i)
	end
end

return Data