lume = require "libs.lume"
oldprint = print
print = DEBUG and lume.trace or function () end
assert = lume.assert

-- autobatch = require "libs.autobatch"
lurker = require "libs.lurker"
Object = require "libs.classic"
lovebird = require "libs.lovebird"
flux = require "libs.flux"
tick = require "libs.tick"
coil = require "libs.coil"
json = require "libs.json"
HC = require "libs.HC"
-- require "imgui"
-- gifcat = require "libs.gifcat"
--Guess I have this one going for me
buddies = require "libs.buddies"

local libs = {}

libs.lovebird = arg[2] == "lovebird"

function libs.update(dt)
	tick.update(dt)
	flux.update(dt)
	coil.update(dt)
	lurker.update(dt)
	if libs.lovebird then lovebird.update(dt) end
end

return libs