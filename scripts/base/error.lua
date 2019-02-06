function love.errhand(msg)
	msg = tostring(msg)
 
	oldprint((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
	if DEBUG then return end
 	
	if not love.window or not love.graphics or not love.event then
		return
	end
 
	if not love.graphics.isCreated() or not love.window.isCreated() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end
 
	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local font = love.graphics.setNewFont(math.floor(love.window.toPixels(18)))
 
	local sRGB = select(3, love.window.getMode()).srgb
	if sRGB and love.math then
		love.graphics.setBackgroundColor(love.math.gammaToLinear(89, 157, 220))
	else
		love.graphics.setBackgroundColor(12, 12, 12)
end
 
	love.graphics.setColor(255, 255, 255, 255)
 
	local trace = debug.traceback()
 
	love.graphics.clear()
	love.graphics.origin()
 
	local err = {}
 
	table.insert(err, msg.."\n\n\n")
 
	-- for l in string.gmatch(trace, "(.-)\n") do
	-- 	if not string.match(l, "boot.lua") then
	-- 		l = string.gsub(l, "stack traceback:", "Traceback\n")
	-- 		table.insert(err, l)
	-- 	end
	-- end
 
	local p = table.concat(err, "\n")
 
	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")
 
	love.graphics.setLineWidth(3)
	local function draw()
		local pos = love.window.toPixels(70)
		love.graphics.clear()
		love.graphics.setColor(150,60,50)
		love.graphics.rectangle("fill",0,pos+50,1000,110)
		love.graphics.setColor(255,255,255)
		love.graphics.printf("Oh no :(\nWould you kindly tell Sheepolution the following message", pos, pos-50, love.graphics.getWidth() - pos)
		love.graphics.line(0,pos+50,1000,pos+50)
		love.graphics.setColor(255,255,255)
		love.graphics.line(0,pos+160,1000,pos+160)
		love.graphics.printf(p, pos, pos+60, love.graphics.getWidth() - pos)
		love.graphics.printf("Thanks :)", pos, pos+180, love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	while true do
		love.event.pump()
 
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			end
			if e == "keypressed" and a == "escape" then
				return
			end
		end
 
		draw()
 
		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end