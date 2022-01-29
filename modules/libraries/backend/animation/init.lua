#!/usr/bin/env lua5.3
local awful   = require("awful")
local wibox   = require("wibox")
local gears   = require("gears")
local easing  = require("modules.libraries.backend.easing")
local naughty = require("naughty")

local animation = {
	mt = {},
}

local function create_animation(args)
	if type(args) ~= "table" then
		raise_error("Type of 'args' must be table!")
	end

	args = args or {}
	args = {
		fps      = args.fps    or 60,
		start    = args.start  or 0,
		stop     = args.stop   or 100,
		step     = args.step   or 1,
		loop     = args.loop   or false,
		easing   = args.easing or easing.easeInOutCubic,
		callback = args.callback, -- Needs to be defined, because it's just a resource waste otherwise.
	}

	local current_step = 0
	local current_step_invert = 1
	local timer
	local timer_callback

	if args.loop == true or args.loop == "forward" or args.loop == "f" then
		timer_callback = function()
			current_step = current_step + args.step

			if current_step >= args.stop then
				current_step = 0
			end

			local current_step_eased = args.easing(current_step / args.stop) * args.stop

			args.callback(current_step_eased)
		end
	elseif args.loop == "forward-backward" or args.loop == "fb" then
		timer_callback = function()
			if current_step <= args.start then
				current_step_invert = 1
			elseif current_step >= args.stop then
				current_step_invert = -1
			end

			current_step = current_step + (args.step * current_step_invert)

			local current_step_eased = args.easing(current_step / args.stop) * args.stop

			args.callback(current_step_eased)
		end
	else
		timer_callback = function()
			current_step = current_step + args.step

			if current_step >= args.stop then
				current_step = 0
				timer:stop()
			end

			local current_step_eased = args.easing(current_step / args.stop) * args.stop

			args.callback(current_step_eased)
		end
	end

	timer = gears.timer {
		timeout   = 1 / args.fps,
		autostart = true,
		callback  = timer_callback
	}
end

local function new(args)
	create_animation(args)

	local new_instance = setmetatable({}, animation)

	animation.__index = animation

    return new_instance
end

function animation.mt:__call(...)
    return new(...)
end

return setmetatable(animation, animation.mt)
