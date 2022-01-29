#!/usr/bin/env lua5.3
local lgi        = require("lgi")
local cairo      = require("lgi").cairo
local awful      = require("awful")
local wibox      = require("wibox")
local gears      = require("gears")
local naughty    = require("naughty")
local base       = require("modules.libraries.backend.base")
local class      = require("modules.libraries.backend.class")
local buttonify  = require("modules.libraries.end-user.buttonify")
local xresources = require('beautiful.xresources')
local dpi        = xresources.apply_dpi
local cache_dir  = gears.filesystem.get_cache_dir()
local def_icon   = beautiful.awesome_icon

local playercontrol = class:new {
	cli = {},
	unparsed_output = "",
	time_remaining_human_readable = "",
	widget = {},
	metadata = {
		playerName = "",
		position = 0,
		playing = "",
		volume = "",
		album = "",
		title = "",
		coverart = cache_dir.."playerctl_coverart.png", -- This is not actually a metadata key, but rather a workaround,
		-- because awesome's imagebox does not support urls, only file paths.
		["mpris:artUrl"] = "", -- From my testing, this doesn't seem to work with only "artUrl"
		["xesam:albumArtist"] = "",
		artist = "",
	},
	new_metadata = {},
}

function playercontrol.cli.get_metadata()
	for _,v in pairs({ "playerName", "volume", "album", "title" }) do
		awful.spawn.easy_async({ "playerctl", "metadata", "--format", "{{ "..v.." }}" }, function(stdout)
			playercontrol.metadata[v] = stdout:gsub("\n", "")
			awesome.emit_signal("playerctl::metadata::"..v, playercontrol.metadata[v])
		end)
	end

	-- This is special behaviour for metadata formated for jellyfin.
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

	awful.spawn.easy_async({ "playerctl", "metadata", "--format", "{{ position / ( mpris:length / 100 ) }}" }, function(stdout)
		local position = tonumber(stdout)
		if position == nil or position < 0 or position > 100 then return end
		playercontrol.metadata.position = position
		awesome.emit_signal("playerctl::metadata::position", position)
	end)

	awful.spawn.easy_async({ "playerctl", "status" }, function(stdout)
		local playing = false
		stdout = stdout:gsub("\n", "")
		if stdout == "Playing" then
			playing = true
		end

		awesome.emit_signal("playerctl::metadata::playing", playing)
	end)

	awesome.emit_signal("playerctl::metadata::all", playercontrol.metadata)

	-- Only download a new coverart image when the metadata has changed.
	awful.spawn.easy_async({ "playerctl", "metadata", "mpris:artUrl" }, function(stdout)
		playercontrol.metadata["mpris:artUrl"] = stdout:gsub("\n", "")
		awesome.emit_signal("playerctl::metadata::mpris:artUrl", playercontrol.metadata["mpris:artUrl"])
		if playercontrol.new_metadata["mpris:artUrl"] ~= playercontrol.metadata["mpris:artUrl"] then
			awful.spawn.easy_async_with_shell("curl -sSLo '"..cache_dir.."playerctl_coverart_temp' '"..playercontrol.metadata["mpris:artUrl"].."'; ffmpeg -y -i '"..cache_dir..[[playerctl_coverart_temp' -vf "crop=w='min(min(iw\,ih)\,600)':h='min(min(iw\,ih)\,600)',scale=600:600,setsar=1" -vframes 1 ']]..playercontrol.metadata.coverart.."'", function()
				local surface = cairo.ImageSurface.create('ARGB32', 50, 50)
				local cr      = cairo.Context(surface)
				local img     = cairo.ImageSurface.create_from_png(playercontrol.metadata.coverart)
				cr:paint()

				awesome.emit_signal("playerctl::metadata::coverart", img)
			end)
		end
	end)
	playercontrol.new_metadata["mpris:artUrl"] = playercontrol.metadata["mpris:artUrl"]
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
	local widget = wibox.widget.textbox(args)

	-- Connect the widget to the song title signal.
	awesome.connect_signal("playerctl::metadata::title", function(title)
		widget:set_text(base.clamp_string_length(title, 153))
	end)

	return widget
end


-- Same as above, but with music being (un-)paused by clicking
function playercontrol.widget.title_label_with_click(args)
	local widget = wibox.widget.textbox(args)

	-- Connect the widget to the song title signal.
	awesome.connect_signal("playerctl::metadata::title", function(title)
		widget:set_text(base.clamp_string_length(title, 153))
	end)

	-- Allow to (un-)pause by left clicking the label.
	widget:connect_signal("button::press", function(_,_,_,button)
		if button == 1 then
			awful.spawn({"playerctl", "play-pause"})
		end
	end)

	return widget
end


function playercontrol.widget.title_artist_label(args)
	local widget = wibox.widget.textbox(args)

	-- Connect the widget to the song title signal.
	awesome.connect_signal("playerctl::metadata::all", function(metadata)
		widget:set_text(base.clamp_string_length(metadata.artist, 75) .. " - " ..base.clamp_string_length(metadata.title, 75))

		if widget.text == " - " then
			widget:set_text("")
			widget:set_visible(false)
		else
			widget:set_visible(true)
		end
	end)

	return widget
end


-- Same as above, but with music being (un-)paused by clicking
function playercontrol.widget.title_artist_label_with_click(args)
	local widget = wibox.widget.textbox(args)

	-- Connect the widget to the song title signal.
	awesome.connect_signal("playerctl::metadata::all", function(metadata)
		widget:set_text(base.clamp_string_length(metadata.artist, 75) .. " - " ..base.clamp_string_length(metadata.title, 75))

		if widget.text == " - " then
			widget:set_text("")
			widget:set_visible(false)
		else
			widget:set_visible(true)
		end
	end)

	widget:connect_signal("button::press", function(_,_,_,button)
		if button == 1 then
			awful.spawn({"playerctl", "play-pause"})
		end
	end)

	return widget
end


function playercontrol.widget.info_card()
	local widget_parts = {}

	--- <Play-pause toggle button> ---
	widget_parts.play_pause_button_label = wibox.widget {
		text = "⏸",
		align = "center",
		valign = "cener",
		widget = wibox.widget.textbox,
	}

	widget_parts.play_pause_button = wibox.widget {
		widget_parts.play_pause_button_label,
		widget = wibox.container.background,
	}

	buttonify {
		widget = widget_parts.play_pause_button,
	}

	widget_parts.play_pause_button:connect_signal("button::release", function(_,_,_,button)
		if button == 1 then
			awful.spawn({"playerctl", "play-pause"})
		end
	end)

	awesome.connect_signal("playerctl::metadata::playing", function(playing)
		if playing then
			widget_parts.play_pause_button_label:set_text("⏸")
		else
			widget_parts.play_pause_button_label:set_text("▶")
		end
	end)
	--- </Play-pause toggle button> ---

	--- <Previous title button> ---
	widget_parts.previous_title_button = wibox.widget {
		{
			text = "⏮",
			align = "center",
			valign = "cener",
			widget = wibox.widget.textbox,
		},
		widget = wibox.container.background,
	}

	buttonify {
		widget = widget_parts.previous_title_button,
	}

	widget_parts.previous_title_button:connect_signal("button::release", function(_,_,_,button)
		if button == 1 then
			awful.spawn({"playerctl", "previous"})
		end
	end)
	--- </Previous title button> ---

	--- <Next title button> ---
	widget_parts.next_title_button = wibox.widget {
		{
			text = "⏭",
			align = "center",
			valign = "cener",
			widget = wibox.widget.textbox,
		},
		widget = wibox.container.background,
	}

	buttonify {
		widget = widget_parts.next_title_button,
	}

	widget_parts.next_title_button:connect_signal("button::release", function(_,_,_,button)
		if button == 1 then
			awful.spawn({"playerctl", "next"})
		end
	end)
	--- </Next title button> ---

	--- <Title label> ---
	widget_parts.title_label_textbox = wibox.widget {
		valign = "top",
		align  = "left",
		widget = wibox.widget.textbox,
	}

	awesome.connect_signal("playerctl::metadata::title", function(title)
		widget_parts.title_label_textbox:set_text(title)
	end)

	widget_parts.title_label = wibox.widget {
		widget_parts.title_label_textbox,
		left   = dpi(5),
		right  = dpi(5),
		widget = wibox.container.margin,
	}
	--- </Title label> ---

	--- <Artist label> ---
	widget_parts.artist_label_textbox = wibox.widget {
		valign = "top",
		align  = "left",
		widget = wibox.widget.textbox,
	}

	awesome.connect_signal("playerctl::metadata::artist", function(artist)
		widget_parts.artist_label_textbox:set_text(artist)
	end)

	widget_parts.artist_label = wibox.widget {
		widget_parts.artist_label_textbox,
		left   = dpi(5),
		right  = dpi(5),
		widget = wibox.container.margin,
	}
	--- </Artist label> ---

	--- <Progessbar> ---
	widget_parts.progressbar = wibox.widget {
		color            = beautiful.nord14,
		value            = 100,
		max_value        = 100,
		background_color = "#00000000",
		shape            = gears.shape.rounded_rect,
		widget = wibox.widget.progressbar,
	}

	awesome.connect_signal("playerctl::metadata::position", function(position)
		widget_parts.progressbar:set_value(position)
	end)
	--- </Progessbar> ---

	--- <Coverart> ---
	widget_parts.coverart = wibox.widget {
		image      = beautiful.awesome_icon,
		resize     = true,
		clip_shape = gears.shape.rounded_rect,
		widget     = wibox.widget.imagebox,
	}

	awesome.connect_signal("playerctl::metadata::coverart", function(coverart)
		widget_parts.coverart:set_image(coverart)
	end)
	--- </Coverart> ---

	--- <Widget background wrapper> ---
	local function wrap_widget_bg(widget, color)
		return wibox.widget {
			widget,
			bg                 = color or beautiful.button_normal,
			shape_border_width = dpi(1),
			shape_border_color = beautiful.nord4,
			shape              = gears.shape.rounded_rect,
			widget             = wibox.container.background,
		}
	end
	--- </Widget background wrapper> ---

	--- <Grid containing title, artists and control buttons> ---
	widget_parts.text_button_grid = wibox.widget {
		spacing         = dpi(5),
		expand          = true,
		forced_num_rows = 4,
		layout          = wibox.layout.grid,
	}

	widget_parts.text_button_grid:add_widget_at(wrap_widget_bg(widget_parts.title_label, beautiful.nord11), 1, 1, 1, 3)
	widget_parts.text_button_grid:add_widget_at(wrap_widget_bg(widget_parts.artist_label, beautiful.nord10), 2, 1, 1, 3)
	widget_parts.text_button_grid:add_widget_at(wrap_widget_bg(widget_parts.previous_title_button), 3, 1, 2, 1)
	widget_parts.text_button_grid:add_widget_at(wrap_widget_bg(widget_parts.play_pause_button), 3, 2, 2, 1)
	widget_parts.text_button_grid:add_widget_at(wrap_widget_bg(widget_parts.next_title_button), 3, 3, 2, 1)
	--- </Grid containing title, artists and control buttons> ---

	--- <Add the coverart to the mix> ---
	widget_parts.coverart_text_button_grid = wibox.widget {
		wrap_widget_bg(widget_parts.coverart),
		{
			{
				orientation  = "vertical",
				forced_width = dpi(5),
				color        = "#00000000",
				widget       = wibox.widget.separator,
			},
			widget_parts.text_button_grid,
			nil,
			layout = wibox.layout.align.horizontal,
		},
		layout = wibox.layout.align.horizontal,
	}
	--- </Add the coverart to the mix> ---

	--- <The widget that will be returned> ---
	local widget = wibox.widget {
		spacing = dpi(5),
		expand  = true,
		layout  = wibox.layout.grid,
	}

	--widget:add_widget_at(widget_parts.text_button_grid, 1, 3, 4, 3)
	widget:add_widget_at(widget_parts.coverart_text_button_grid, 1, 1, 4, 5)
	widget:add_widget_at(wrap_widget_bg(widget_parts.progressbar, beautiful.nord13), 5, 1, 1, 5)

	return widget
	--- </The widget that will be returned> ---
end


return playercontrol
