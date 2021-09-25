#!/usr/bin/env lua
local easing = require('modules.libraries.backend.easing')
local gears  = require('gears')

local animate = {
	range = 0,
	running = false,
}

function animate.move(arg)
	local argv = {
		fps      = arg.fps    or 60,
		--start    = arg.start or 0,
		stop     = arg.stop   or 1080,
		speed    = arg.speed  or 10,
		easing   = arg.easing or easing.easeInOutCubic,
		callback = arg.callback, -- Needs to be defined, because it's just a resource waste otherwise.
	}

	if animate.range >= 1 then
		notify('stopped')
		animate:stop()
	end

	local delta = argv.stop / argv.speed

	animate.range = animate.range + 1 / delta

	arg.callback(argv.easing(animate.range) * delta * argv.speed)
end

function animate.animate(arg)
	local argv = {
		fps      = arg.fps    or 60,
		--start    = arg.start or 0,
		stop     = arg.stop   or 1080,
		speed    = arg.speed  or 10,
		easing   = arg.easing or easing.easeInOutCubic,
		callback = arg.callback, -- Needs to be defined, because it's just a resource waste otherwise.
	}

	local delta_time_speed = argv.speed * (60 / argv.fps) -- At 60 FPS, the speed will be taken as is.

	animate.timer = gears.timer {
		timeout = (1 / argv.fps),
		--autostart = true,
		callback = function()
			animate.move {
				stop     = argv.stop,
				speed    = delta_time_speed,
				easing   = argv.easing,
				callback = argv.callback,
			}
		end
	}
end

function animate:start()
	self.timer:start()
	self.running = true
end

function animate:stop()
	self.timer:stop()
	self.running = false
end

function animate:reset()
	self.range = 0
end

return animate