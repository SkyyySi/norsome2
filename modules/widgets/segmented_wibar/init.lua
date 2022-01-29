#!/usr/bin/env lua5.3
local awful         = require("awful")
local wibox         = require("wibox")
local gears         = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")

local function segmented_wibar(s)
	local default_wibar_segment = {
		layout = wibox.layout.fixed.horizontal,
	}

	local wibar_segments = {
		left   = default_wibar_segment,
		center = default_wibar_segment,
		right  = default_wibar_segment,
	}

	if mylauncher then
		wibar_segments.left.main_menu_launcher = mylauncher
	elseif main_menu_launcher then
		wibar_segments.left.main_menu_launcher = main_menu_launcher
	else
		wibar_segments.left.main_menu_content = {
			{ "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
			{ "manual", terminal .. " -e man awesome" },
			{ "edit config", editor_cmd .. " " .. awesome.conffile },
			{ "restart", awesome.restart },
			{ "quit", function() awesome.quit() end },
		}

		wibar_segments.left.main_menu = awful.menu {
			items = {
				{ "awesome", wibar_segments.left.main_menu, beautiful.awesome_icon },
				{ "open terminal", terminal or "xterm" }
			}
		}

		wibar_segments.left.main_menu_launcher = awful.widget.launcher {
			image = beautiful.awesome_icon,
			menu = wibar_segments.left.main_menu,
		}
	end

	wibar_segments.left.taglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		widget_template = {
			{
				{
					nil,
					{
						id     = "text_role",
						align  = "center",
						valign = "center",
						widget = wibox.widget.textbox,
					},
					nil,
					layout = wibox.layout.align.horizontal,
				},
				margins = 5,
				widget = wibox.container.margin,
			},
			id     = "background_role",
			widget = wibox.container.background,
		},
		buttons = {
			awful.button({ }, 1, function(t) t:view_only() end),
			awful.button({ modkey }, 1, function(t)
				if client.focus then
					client.focus:move_to_tag(t)
				end
			end),
			awful.button({ }, 3, awful.tag.viewtoggle),
			awful.button({ modkey }, 3, function(t)
				if client.focus then
					client.focus:toggle_tag(t)
				end
			end),
			awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
			awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
		}
	}

	wibar_segments.center.tasklist = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		layout = {
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				id     = "icon_role",
				widget = wibox.widget.imagebox,
			},
			id     = "background_role",
			widget = wibox.container.background,
		},
		buttons = {
			awful.button({ }, 1, function (c)
				c:activate { context = "tasklist", action = "toggle_minimization" }
			end),
			awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
			awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
			awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
		}
	}

	wibar_segments.right.keyboard_layout = wibox.widget {
		widget = awful.widget.keyboardlayout
	}

	wibar_segments.right.systray = wibox.widget {
		widget = wibox.widget.systray,
	}

	wibar_segments.right.clock = wibox.widget {
		{
			format = "<b>%m/%d/%Y - %H:%M</b>",
			widget = wibox.widget.textclock,
		},
		expand = "outside",
		layout = wibox.layout.align.horizontal,
	}

	wibar_segments.right.layoutbox = awful.widget.layoutbox {
		screen  = s,
		buttons = {
			awful.button({ }, 1, function () awful.layout.inc( 1) end),
			awful.button({ }, 3, function () awful.layout.inc(-1) end),
			awful.button({ }, 4, function () awful.layout.inc(-1) end),
			awful.button({ }, 5, function () awful.layout.inc( 1) end),
		}
	}

	local function add_side_margin_to_wibar_item(item)
		local widget = {
			{
				widget = item,
			},
			margins = {
				top    = 0,
				bottom = 0,
				left   = 8,
				right  = 8,
			},
			widget = wibox.container.margin,
		}

		return widget
	end

	local function wrap_wibar_segment(segment)
		local widget = wibox.widget {
			{
				{
					{
						{
							widget = wibox.widget(segment),
						},
						margins = {
							top    = 0,
							bottom = 0,
							left   = 0,
							right  = 0,
						},
						widget = wibox.container.margin,
					},
					bg = gears.color {
						type  = "linear",
						from  = { 0, 0  },
						to    = { 0, 36 },
						stops = {
							{ 0, "#12005e" },
							{ 1, "#000034" },
						},
					},
					shape              = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,4) end,
					shape_border_width = 1,
					shape_border_color = "#fafafa",
					widget             = wibox.container.background,
				},
				margins = {
					top    = 4,
					bottom = 4,
					left   = 4,
					right  = 4,
				},
				widget = wibox.container.margin,
			},
			layout = wibox.layout.fixed.horizontal,
		}

		return widget
	end

	local wibar = awful.wibar {
		position = "top",
		screen   = s,
		height   = 44,
		bg       = "#00000000",
		type     = "desktop",
		widget   = {
			{
				wrap_wibar_segment{
					add_side_margin_to_wibar_item(wibar_segments.left.main_menu_launcher),
					add_side_margin_to_wibar_item(wibar_segments.left.taglist),
					layout = wibox.layout.fixed.horizontal,
				},
				nil,
				nil,
				expand = "outside",
				layout = wibox.layout.align.horizontal,
			},
			{
				nil,
				wrap_wibar_segment {
					add_side_margin_to_wibar_item(wibar_segments.center.tasklist),
					layout = wibox.layout.fixed.horizontal,
				},
				nil,
				layout = wibox.layout.align.horizontal,
			},
			{
				nil,
				nil,
				wrap_wibar_segment {
					add_side_margin_to_wibar_item(wibar_segments.right.keyboard_layout),
					add_side_margin_to_wibar_item(wibar_segments.right.systray),
					add_side_margin_to_wibar_item(wibar_segments.right.clock),
					add_side_margin_to_wibar_item(wibar_segments.right.layoutbox),
					layout = wibox.layout.fixed.horizontal,
				},
				layout = wibox.layout.align.horizontal,
			},
			expand = "outside",
			layout = wibox.layout.align.horizontal,
		},
	}

	return wibar
end

return segmented_wibar
