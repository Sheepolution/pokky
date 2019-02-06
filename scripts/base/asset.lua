local Asset = {}

-- local function stripString(base, s)
-- 	local a = s:sub(base:len()+2,s:len())
-- 	return a:sub(0, a:find("%.")-1)
-- end


-- local function loadFiles(base, dir, files, ignore)
-- 	dir = dir or base
-- 	local items = love.filesystem.getDirectoryItems(dir)
	
-- 	for i,v in ipairs(items) do
-- 		local file = dir .. "/" .. v
-- 		if love.filesystem.isFile(file) then
-- 			if not ignore or not file:find(ignore) then
-- 				files[stripString(base, file)] = file
-- 			end
-- 		else
-- 			loadFiles(base, file, files, ignore)
-- 		end
-- 	end

-- 	return files
-- end

local imgCache = {}
local fontCache = {}
local audioCache = {}
local videoCache = {}

-- local imgDirs = loadFiles("assets/images", nil, {}, "%.ase")
-- local audioDirs = loadFiles("assets/audio", nil, {})
-- local fontDirs = loadFiles("assets/fonts", nil, {})


function Asset.image(url, force)
	-- assert(imgDirs[url], 'The image "' .. url .. '" does not exist!', 2)
	local img
	if force or not imgCache[url] then
		img = love.graphics.newImage("assets/images/" .. url .. ".png")
		imgCache[url] = img
	else
		img = imgCache[url]
	end
	return img
end


function Asset.font(url, size, force)
	local font
	if force or not fontCache[url] or not fontCache[url][size] then
		font = love.graphics.newFont("assets/fonts/" .. url .. ".ttf", size)
		if not fontCache[url] then
			fontCache[url] = {}
		end
		fontCache[url][size] = font
	else
		font = fontCache[url][size]
	end
	return font
end


function Asset.audio(url, static, force)
	local aud
	if force or not audioCache[url] then
		aud = love.audio.newSource("assets/audio/" .. url .. ".ogg", "static")
		audioCache[url] = aud
	else
		aud = audioCache[url]
	end
	return aud
end


function Asset.video(url)
	local vid
	if force or not videoCache[url] then
		vid = love.graphics.newVideo("assets/videos/" .. url .. ".ogv")
		videoCache[url] = vid
	else
		vid = videoCache[url]
	end
	return vid
end

return Asset