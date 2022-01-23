#!/usr/bin/env lua5.3
local awful   = require("awful")
local wibox   = require("wibox")
local gears   = require("gears")
local naughty = require("naughty")
local base    = require("modules.libraries.backend.base")
local class   = require("modules.libraries.backend.class")
local playercontrol = class:new {
	cli = {},
	unparsed_output = "",
	time_remaining_human_readable = "",
	widget = {},
	metadata = {
		playerName = "",
		position = 0,
		status = "",
		volume = "",
		album = "",
		artist = "",
		["xesam:albumArtist"] = "", -- From my testing, this doesn't seem to work with only "albumArtist"
		title = "",
	},
}


function playercontrol.cli.get_metadata()
	for _,v in pairs({ "playerName", "status", "volume", "album", "title" }) do
		awful.spawn.easy_async({ "playerctl", "metadata", "--format", "{{ "..v.." }}" }, function(stdout)
			playercontrol.metadata[v] = stdout:gsub("\n", "")
			awesome.emit_signal("playerctl::metadata::"..v, playercontrol.metadata[v])
		end)
	end

	-- This is special behaviour for metadata formmated for jellyfin.
	for _,v in pairs({ "artist", "xesam:albumArtist" }) do
		awful.spawn.easy_async({ "playerctl", "metadata", "--format", "{{ "..v.." }}" }, function(stdout)
			local artists_no_linebreak = stdout:gsub("\n", "")
			playercontrol.metadata[v] = ""
			local artists_table = {}
			local artists_string = ""
			local artists_no_feat = string.gsub(artists_no_linebreak, "feat.", ";")
			local artists_split = string.gmatch(artists_no_feat, "([^\\;]+)")
			for a in artists_split do table.insert(artists_table, a) end
			for index, value in pairs(artists_table) do
				if #artists_table == 1 then
					playercontrol.metadata[v] = value
					break
				end

				if index == #artists_table then
					playercontrol.metadata[v] = playercontrol.metadata[v] .. " & " .. value
				elseif index ~= 1 then
					playercontrol.metadata[v] = playercontrol.metadata[v] .. ", " .. value
				else
					playercontrol.metadata[v] = value
				end
			end

			playercontrol.metadata[v] = playercontrol.metadata[v] .. artists_string

			awesome.emit_signal("playerctl::metadata::"..v, stdout)
		end)
	end

	awful.spawn.easy_async({"playerctl", "metadata", "--format", "{{ position / ( mpris:length / 100 ) }}"}, function(stdout)
		local position = tonumber(stdout)
		if position == nil or position < 0 or position > 100 then return end
		playercontrol.metadata.position = position
		awesome.emit_signal("playerctl::metadata::position", position)
	end)

	awesome.emit_signal("playerctl::metadata::all", playercontrol.metadata)
end


-- Run it automatically in a loop.
playercontrol.cli.metadata_updater = gears.timer {
	timeout = 0.5,
	call_now = true,
	autostart = true,
	callback = function()
		playercontrol.cli.get_metadata()
	end,
}

-- Signal that the timer is alreay running.
awesome.emit_signal("playerctl::metadata_updater_running", true)

-- Prevent multiple instances to needlessly run at the same time.
awesome.connect_signal("playerctl::metadata_updater_running", function(status)
	if status then
		playercontrol.cli.metadata_updater:stop()
	end
end)

function playercontrol.cli.get_time_remaining_human_readable()
	awful.spawn.easy_async({ "playerctl", "metadata", "--format", "{{ duration(mpris:length - position) }}" }, function(stdout)
		playercontrol.time_remaining_human_readable = stdout
	end)
end


function playercontrol.widget.title_label(args)
	-- Create a new slider widget.
	local label = wibox.widget.textbox(args)

	-- Connect the widget to the song title signal.
	awesome.connect_signal("playerctl::metadata::title", function(title)
		label:set_text(base.clamp_string_length(title, 153))
	end)

	-- Allow to (un-)pause by left clicking the label.
	label:connect_signal("button::press", function(_,_,_,button)
		if button == 1 then
			awful.spawn({"playerctl", "play-pause"})
		end
	end)

	return label
end


function playercontrol.widget.title_artist_label(args)
	-- Create a new slider widget.
	local label = wibox.widget.textbox(args)

	-- Connect the widget to the song title signal.
	awesome.connect_signal("playerctl::metadata::all", function(metadata)
		label:set_text(base.clamp_string_length(metadata.artist, 75) .. " - " ..base.clamp_string_length(metadata.title, 75))

		if label.text == " - " then
			label:set_text("")
			label:set_visible(false)
		else
			label:set_visible(true)
		end
	end)

	-- Allow to (un-)pause by left clicking the label.
	label:connect_signal("button::press", function(_,_,_,button)
		if button == 1 then
			awful.spawn({"playerctl", "play-pause"})
		end
	end)

	return label
end


return playercontrol:new()
