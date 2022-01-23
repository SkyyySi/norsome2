#!/usr/bin/env lua5.3
local awful   = require("awful")
local wibox   = require("wibox")
local gears   = require("gears")
local naughty = require("naughty")

-- Define the base module
local pulseaudio = {
	-- Create a new instance
	new = function(self, selected_cli)
		local object = {
			-- There are multiple pulseaudio clis available, see below.
			selected_cli = selected_cli or "pamixer"
		}
		setmetatable(object, self)
		self.__index = self
		return object
	end
}

-- Signals used by this module:
-- >	"pulseaudio::get_volume": used for widgets to be notified when
-- | 	the volume was changed by another part of the code.

-- Commands used to call the specific cli tools used to mamange pulseaudio.
-- By default, this is configured for pamixer, but on Debian, you may want to
-- override this with pulsemixer.
pulseaudio.pamixer = {}
pulseaudio.pulsemixer = {}

--------------------------------------------------
---                 Get volume                 ---
--------------------------------------------------
-- Get the current playback volume. Callback must be nil or a function accepting
-- a number value (the volume in percent). Note that this function is not
-- intended to be called directly. Use the "pulseaudio::get_volume"-signal instead.
function pulseaudio.pamixer.get_volume(callback)
	awful.spawn.easy_async({"pamixer", "--get-volume"}, function(volume)
		volume = tonumber(volume)

		if callback then
			callback(volume)
		end

		awesome.emit_signal("pulseaudio::get_volume", volume)
	end)
end

-- Run it automatically in a loop.
pulseaudio.pamixer.volume_updater = gears.timer {
	timeout = 0.3,
	call_now = true,
	autostart = true,
	callback = function()
		pulseaudio.pamixer.get_volume()
	end,
}

-- Signal that the timer is alreay running.
awesome.emit_signal("pulseaudio::volume_updater_running", true)

-- Prevent multiple instances to needlessly run at the same time.
awesome.connect_signal("pulseaudio::volume_updater_running", function(status)
	if status then
		notify("Stopped already running update timer!")
		pulseaudio.pamixer.volume_updater:stop()
	end
end)

--------------------------------------------------
---                 Set volume                 ---
--------------------------------------------------
-- Set the current playback volume.
function pulseaudio.pamixer.set_volume(volume)
	awful.spawn({"pamixer", "--set-volume", tostring(volume)})
end

-- Connect it to a signal.
awesome.connect_signal("pulseaudio::set_volume", function(volume)
	pulseaudio.pamixer.set_volume(volume)
end)

--------------------------------------------------
---              Increment volume              ---
--------------------------------------------------
-- Increment the volume by n or 1
function pulseaudio.pamixer.increase_volume(volume)
	if not volume then volume = 1 end
	awful.spawn({"pamixer", "--increase", tostring(volume)})
end

-- Connect it to a signal.
awesome.connect_signal("pulseaudio::increase_volume", function(volume)
	pulseaudio.pamixer.increase_volume(volume)
end)

--------------------------------------------------
---              Decrement volume              ---
--------------------------------------------------
-- Decrement the volume by n or 1
function pulseaudio.pamixer.decrease_volume(volume)
	if not volume then volume = 1 end
	awful.spawn({"pamixer", "--decrease", tostring(volume)})
end

-- Connect it to a signal.
awesome.connect_signal("pulseaudio::decrease_volume", function(volume)
	pulseaudio.pamixer.decrease_volume(volume)
end)

--------------------------------------------------
---                 Mute status                ---
--------------------------------------------------
-- Get the current mute status. true = muted, false = unmuted.
-- Callback must be nil or a function accepting a boolean value.
-- Note that this function is not intended to be called directly.
-- Use the "pulseaudio::get_mute"-signal instead.
function pulseaudio.pamixer.get_mute(callback)
	awful.spawn.easy_async({"pamixer", "--get-mute"}, function(status)
		-- cli commands always return a string and lua does not have a
		-- `tobool()`-builtin.
		if status == "true" then
			status = true
		else
			status = false
		end

		if callback then
			callback(tonumber(status))
		end

		awesome.emit_signal("pulseaudio::get_mute", status)
	end)
end

--------------------------------------------------
---                    Mute                    ---
--------------------------------------------------
-- Mute the volume
function pulseaudio.pamixer.mute()
	awful.spawn({"pamixer", "--mute"})
end

-- Connect it to a signal.
awesome.connect_signal("pulseaudio::mute", function()
	pulseaudio.pamixer.mute()
end)

--------------------------------------------------
---                   Unmute                   ---
--------------------------------------------------
-- Unmute the volume
function pulseaudio.pamixer.unmute()
	awful.spawn({"pamixer", "--mute"})
end

-- Connect it to a signal.
awesome.connect_signal("pulseaudio::unmute", function()
	pulseaudio.pamixer.mute()
end)

--------------------------------------------------
---                Toggle mute                 ---
--------------------------------------------------
-- Unmute the volume
function pulseaudio.pamixer.unmute()
	awful.spawn({"pamixer", "--toggle-mute"})
end

-- Connect it to a signal.
awesome.connect_signal("pulseaudio::toggle_mute", function()
	pulseaudio.pamixer.mute()
end)

--------------------------------------------------
---                   Widgets                  ---
--------------------------------------------------
-- A few basic widgets for managing volume. Can be used as templates for
-- creating your own, more advanced (or nicer looking) ones.
pulseaudio.widget = {}

--------------------------------------------------
---                   Slider                   ---
--------------------------------------------------
-- A basic volume slider based on wibox.widget.slider
-- The first argument must be arguments for wibox.widget.slider
-- as a table or nil.
function pulseaudio.widget.volume_slider(args) --> table
	-- Set a few basic default options if none are given.
	if not args then
		args = {
			minimum = 0,
			value = 50,
			maximum = 100,
			forced_width = 200,
		}
	end

	-- Create a new slider widget.
	local slider = wibox.widget.slider(args)

	-- Connect the widget to the volume signal.
	awesome.connect_signal("pulseaudio::get_volume", function(volume)
		slider:set_value(volume)
	end)

	-- Allow to set the volume using the mouse wheel.
	slider:connect_signal("button::press", function(_,_,_,button)
		if button == 4 then
			awesome.emit_signal("pulseaudio::increase_volume", 5)
		elseif button == 5 then
			awesome.emit_signal("pulseaudio::decrease_volume", 5)
		end
	end)

	-- Change the system volume when the slider value changes.
	slider:connect_signal("property::value", function()
		awesome.emit_signal("pulseaudio::set_volume", slider.value)
	end)

	return slider
end

--------------------------------------------------
---                 Text label                 ---
--------------------------------------------------
function pulseaudio.widget.volume_label(args) --> table
	-- Create a new slider widget.
	local label = wibox.widget.textbox(args)

	-- Connect the widget to the volume signal.
	awesome.connect_signal("pulseaudio::get_volume", function(volume)
		label:set_text(volume)
	end)

	-- Allow to (un-)mute by left clicking the label and to
	-- set the volume using the mouse wheel.
	label:connect_signal("button::press", function(_,_,_,button)
		if button == 1 then
			awesome.emit_signal("pulseaudio::toggle_mute")
		elseif button == 4 then
			awesome.emit_signal("pulseaudio::increase_volume", 5)
		elseif button == 5 then
			awesome.emit_signal("pulseaudio::decrease_volume", 5)
		end
	end)

	return label
end

--------------------------------------------------
---            Status notifications            ---
--------------------------------------------------
pulseaudio.notification = {
	volume = { enabled = false },
	mute = { enabled = false },
}

function pulseaudio.notification.volume:enable()
	self.enabled = true
	awesome.connect_signal("pulseaudio::get_volume", function(volume)
		naughty.notification {
			title = "Volume change",
			message = "Current volume: " .. tostring(volume),
			category = "pulseaudio.volume",
			app_name = "pulseaudio_cli_awesome_bindings",
			timeout = 1,
		}
	end)
end

function pulseaudio.notification.volume:disable()
	self.enabled = false
	awesome.disconnect_signal("pulseaudio::get_volume")
end

function pulseaudio.notification.volume:toggle()
	if self.enabled then
		self:disable()
	else
		self:enable()
	end
end

function pulseaudio.notification.mute:enable()
	self.enabled = true
	awesome.connect_signal("pulseaudio::get_mute", function(muted)
		local title = "Unmuted"
		local text = "System unmuted"

		if muted then
			title = "Muted"
			text = "System muted"
		end

		naughty.notification {
			title = title,
			message = text,
			category = "pulseaudio.mute",
			app_name = "pulseaudio_cli_awesome_bindings",
			timeout = 1,
		}
	end)
end

function pulseaudio.notification.mute:disable()
	self.enabled = false
	awesome.disconnect_signal("pulseaudio::get_mute")
end

function pulseaudio.notification.mute:toggle()
	if self.enabled then
		self:disable()
	else
		self:enable()
	end
end

-- Select the correct cli tool.
if pulseaudio.current_cli == "pamixer" then
	pulseaudio.cli = pulseaudio.pamixer
elseif pulseaudio.current_cli == "pulsemixer" then
	pulseaudio.cli = pulseaudio.pulsemixer
end

return pulseaudio:new()
