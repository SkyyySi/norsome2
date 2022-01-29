#!/usr/bin/env lua5.3
local awful         = require("awful")
local wibox         = require("wibox")
local gears         = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")

local main_menu = require("modules.widgets.awesome_menu")
local buttonify = require("modules.libraries.end-user.buttonify")

local main_menu_launcher = wibox.widget {
	{
		{
			image  = beautiful.awesome_icon,
			widget = wibox.widget.imagebox,
		},
		margins = 12,
		widget  = wibox.container.margin,
	},
	widget = wibox.container.background,
}

buttonify {
	widget = main_menu_launcher,
	button_callback_release = function()
		main_menu:toggle()
	end
}

-- Create a new wibar on the left of the screen.
-- s = the scrren (from `screen.connect_signal...`)
local function sideways_wibar(s)
	local swwb = {}

	if mylauncher then
		swwb.main_menu_launcher = mylauncher
	elseif main_menu_launcher then
		swwb.main_menu_launcher = main_menu_launcher
	else
		swwb.main_menu_content = {
			{ "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
			{ "manual", terminal .. " -e man awesome" },
			{ "edit config", editor_cmd .. " " .. awesome.conffile },
			{ "restart", awesome.restart },
			{ "quit", function() awesome.quit() end },
		}

		swwb.main_menu = awful.menu {
			items = {
				{ "awesome", swwb.main_menu, beautiful.awesome_icon },
				{ "open terminal", terminal or "xterm" }
			}
		}

		swwb.main_menu_launcher = awful.widget.launcher {
			image = beautiful.awesome_icon,
			menu = swwb.main_menu,
		}
	end

	function swwb.taglist(args)
		if not args then args = {} end
		args = {
			screen = args.screen or s or nil,
		}

		local widget = awful.widget.taglist {
			screen  = args.screen,
			filter  = awful.widget.taglist.filter.all,
			layout  = {
				layout  = wibox.layout.fixed.vertical
			},
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

		return widget
	end

	function swwb.layoutbox(args)
		if not args then args = {} end
		args = {
			screen = args.screen or s or nil,
		}

		local widget = awful.widget.layoutbox {
			screen  = args.screen,
			buttons = {
				awful.button({ }, 1, function () awful.layout.inc( 1) end),
				awful.button({ }, 3, function () awful.layout.inc(-1) end),
				awful.button({ }, 4, function () awful.layout.inc(-1) end),
				awful.button({ }, 5, function () awful.layout.inc( 1) end),
			}
		}

		return widget
	end

	function swwb.tasklist(args)
		if not args then args = {} end
		args = {
			--
		}

		local widget = awful.widget.tasklist {
			screen = s,
			filter = awful.widget.tasklist.filter.currenttags,
			layout = {
				layout  = wibox.layout.fixed.vertical
			},
			widget_template = {
				{
					{
						id     = "icon_role",
						widget = wibox.widget.imagebox,
					},
					margins = 6,
					widget  = wibox.container.margin,
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

		return widget
	end

	function swwb.clock(args)
		if not args then args = {} end
		args = {
			--
		}

		local widget = wibox.widget {
			nil,
			{
				format = "<b>%H:%M</b>",
				widget = wibox.widget.textclock,
			},
			nil,
			expand = "outside",
			layout = wibox.layout.align.horizontal,
		}

		return widget
	end

	function swwb.systray(args)
		if not args then args = {} end
		args = {
			border_width = args.border_width or 1,
		}

		local widget = wibox.widget {
			{
				{
					{
						horizontal = false,
						widget     = wibox.widget.systray,
					},
					top    = args.border_width + 16,
					bottom = args.border_width + 16,
					left   = args.border_width + 1,
					right  = args.border_width + 1,
					widget = wibox.container.margin,
				},
				bg                 = beautiful.bg_systray or "#000000",
				shape              = function(cr,w,h) gears.shape.rounded_bar(cr,w,h) end,
				shape_border_color = beautiful.nord4 or "#FFFFFF",
				shape_border_width = args.border_width,
				widget             = wibox.widget.background,
			},
			margins = 4,
			widget  = wibox.container.margin,
		}

		return widget
	end

	function swwb.wibar(args)
		if not args then args = {} end
		args = {
			--
		}

		local widget = awful.wibar {
			position = "left",
			screen = s,
			width = 42,
			widget = {
				{ -- Top
					swwb.main_menu_launcher,
					swwb.taglist(),
					layout = wibox.layout.fixed.vertical,
				},
				{ -- Center
					swwb.tasklist(),
					layout = wibox.layout.fixed.vertical,
				},
				{ -- Bottom
					swwb.systray(),
					swwb.clock(),
					swwb.layoutbox(),
					layout = wibox.layout.fixed.vertical,
				},
				--expand = "outside",
				layout = wibox.layout.align.vertical,
			}
		}

		return widget
	end

	return swwb.wibar()
end

return sideways_wibar
