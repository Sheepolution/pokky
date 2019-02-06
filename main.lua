RELEASE = arg[2] == nil
DEBUG = not RELEASE
PERF_TEST_UPDATE = arg[2] == "perf_test_update"
PERF_TEST_DRAW = arg[2] == "perf_test_draw"

local paths  = love.filesystem.getRequirePath()
love.filesystem.setRequirePath(paths .. ";scripts/?.lua;scripts/?/init.lua;")

local libs = require "libs"
local base = require "base"

local sum, amt, tm = 0, 0, 0

local old_color = love.graphics.setColor

love.graphics.setColor = function (r, g, b, a) old_color(r/255, g/255, b/255, a and a/255 or nil) end

function love.load()
	require "game"
	require "play"

	for i,v in ipairs(require "require") do
		local succes, msg = pcall(require, v)
		if not succes then
			if msg:match("not found:") then
				requireDir("scripts/" .. v)
			else
				error(msg)
			end
		end 
	end

	game = Game()

	love.graphics.setBackgroundColor(255, 255, 255)

	-- gifcat.init()
end

local timer = 0

function love.update(t)
	if pause then return end 
	if PERF_TEST_UPDATE then
		tm = love.timer.getTime()
		amt = amt + 1
	end

	local dt = math.min(t, 0.08333333333)
	
	libs.update(dt)
	base.beginstep(dt)

	if Key:isPressed("f4") then
		love.window.setFullscreen(not love.window.getFullscreen())
	end

	if DEBUG then
		if Key:isPressed("q") then
			love.event.quit()
		end

		if Key:isPressed("f5") then
			love.load()
		end

		if Key:isDown("pause") then
			dt = 0
		end

		if Key:isDown("tab") then
			if Key:isDown("1") then
				dt = dt / 2
			elseif Key:isDown("2") then
				dt = dt * 2
			elseif Key:isDown("3") then
				dt = dt * 4
			end
		end
	end

	game:update(dt)
	base.endstep(dt)

	if PERF_TEST_UPDATE then
		sum = sum + (love.timer.getTime() - tm)
		print("update avg: " .. sum/amt)
	end
end


function love.draw()
	love.graphics.scale(SCALE)
	if PERF_TEST_DRAW then
		tm = love.timer.getTime()
		amt = amt + 1
	end
	love.graphics.setColor(255, 255, 255)
	game:draw()
	if PERF_TEST_DRAW then
		sum = sum + (love.timer.getTime() - tm)
		print("draw avg: " .. sum/amt)
	end
	love.graphics.origin()

	if DEBUG and Key:isDown("tab") then
		Data.add("drawcalls", love.graphics.getStats().drawcalls)
		Data.add("fps", love.timer.getFPS())
		Data.draw()
	end
	-- if curgif then
	--   -- Save a frame to our gif.
	--   curgif:frame(love.graphics.newScreenshot())

	--   -- Show a little recording icon in the upper right hand corner. This will
	--   --   not get shown in the gif because it is displayed after the call to
	--   --   newScreenshot()
	--   love.graphics.setColor(255,0,0)
	--   love.graphics.circle("fill",love.graphics.getWidth()-10,10,10)
	-- end
end


function love.keypressed(key)
	if key == "pause" then
		pause = not pause
	end
	base.keypressed(key)

	-- if key == "g" then
	-- 	if isrepeat then
	-- 		return
	-- 	end

-- 	curgif = gifcat.newGif(os.time()..".gif")

	-- 	-- Optional method to just print out the progress of the gif
	-- 	curgif:onUpdate(function(gif,curframes,totalframes)
	-- 		print(string.format("Progress: %.2f%% (%d/%d)",gif:progress()*10,curframes,totalframes))
	-- 		end)
	-- 	curgif:onFinish(function(gif,totalframes)
	-- 		print(totalframes.." frames written")
	-- 		end)
	-- end
end


function love.keyreleased(key)
	base.keyreleased(key)
	-- if key == "o" then
	-- 	curgif:close()
	-- 	curgif = nil
	-- end
end


function love.mousepressed(x, y, button)
	base.mousepressed(x, y, button)
end


function love.mousereleased(x, y, button)
	base.mousereleased(x, y, button)
end


function love.wheelmoved(x, y)
	base.wheelmoved(x, y)
end

function love.quit()
	love.filesystem.write("data", lume.serialize(DATA))
	-- gifcat.close()
end