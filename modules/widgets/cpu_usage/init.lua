#!/usr/bin/env lua5.3
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local class = require("modules.libraries.backend.class")
local cpu_usage = class:new()

cpu_usage.timer = gears.timer {
	timeout = 0.5,
	autostart = true,
	call_now = true,
	callback = function()
		awful.spawn.easy_async({"bash", "-c", [[printf '%s' "$(cat <(grep 'cpu ' /proc/stat) <(sleep 1 && grep 'cpu ' /proc/stat) | awk -v RS="" '{printf "%.2f\n", ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5)}')"]]}, function(cpu_usage)
			awesome.emit_signal("util::cpu_usage", tonumber(cpu_usage))
		end)
	end,
}

function cpu_usage.graph()
	local widget = wibox.widget {
		max_value = 100,
		color = gears.color {
			type = "linear",
			from = { 0, 0 },
			to   = { 0, 32 },
			stops = {
				{ 0,   beautiful.nord11 or "#BF616A" },
				{ 0.5, beautiful.nord13 or "#EBCB8B" },
				{ 1,   beautiful.nord14 or "#A3BE8C" },
			},
		},
		background_color = "#00000000",
		widget = wibox.widget.graph,
	}

	awesome.connect_signal("util::cpu_usage", function(usage)
		widget:add_value(usage)
	end)

	return widget
end

function cpu_usage.label()
	local widget = wibox.widget.textbox()

	awesome.connect_signal("util::cpu_usage", function(usage)
		widget:set_text(tostring(usage))
	end)

	return widget
end

return cpu_usage:new()
