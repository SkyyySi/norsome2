#!/usr/bin/env lua5.3
local awful   = require("awful")
local wibox   = require("wibox")
local gears   = require("gears")
local naughty = require("naughty")
--local hotkeys_popup = require("awful.hotkeys_popup")

local function create_sidebar(s)
	-- The main table holding everything
	local sidebar = {}

	-- Contain the widgets (to keep things tidy)
	sidebar.widgets = {
		top_header    = {},
		notifications = {},
		calendar      = {},
	}

	function sidebar.widgets.notifications.dismiss_all_button()
		local widget = wibox.widget {
			{
				markup = "<b>Dismiss all</b>",
				align  = "center",
				valign = "center",
				widget = wibox.widget.textbox
			},
			buttons = {
				awful.button({}, 1, function() naughty.destroy_all_notifications() end),
				awful.button({}, 3, function() naughty.notification { message = "test", timeout = 0, } end),
			},
			bg                 = "#202020",
			forced_height      = 50,
			shape              = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, 10)
			end,
			shape_border_width = 1,
			shape_border_color = beautiful.bg_highlight,
			widget             = wibox.container.background
		}

		local old_cursor, old_wibox
		widget:connect_signal("mouse::enter", function(d)
			d:set_bg("#404040")
			local wb = mouse.current_wibox
			old_cursor, old_wibox = wb.cursor, wb
			wb.cursor = "hand1"
		end)

		widget:connect_signal("mouse::leave", function(d)
			d:set_bg("#202020")
			if old_wibox then
				old_wibox.cursor = old_cursor
				old_wibox = nil
			end
		end)

		widget:connect_signal("button::press", function(d)
			d:set_bg("#606060")
		end)

		widget:connect_signal("button::release", function(d)
			d:set_bg("#404040")
		end)

		return widget
	end

	sidebar.widgets.notifications.container = wibox.widget {
		nil,
		{
			base_layout = wibox.widget {
				spacing_widget = wibox.widget {
					orientation = "vertical",
					span_ratio  = 0.5,
					widget      = wibox.widget.separator,
				},
				forced_height = 30,
				spacing       = 3,
				layout        = wibox.layout.fixed.vertical
			},
			widget_template = {
				{
					{
						naughty.widget.icon,
						{
							naughty.widget.title,
							naughty.widget.message,
							{
								naughty.list.widgets,
								layout = wibox.layout.fixed.horizontal
							},
							layout = wibox.layout.align.vertical
						},
						spacing = 10,
						fill_space = true,
						layout  = wibox.layout.fixed.horizontal
					},
					margins = 5,
					widget  = wibox.container.margin
				},

				widget = wibox.container.background,
			},
			widget = naughty.list.notifications,
		},
		{
			sidebar.widgets.notifications.dismiss_all_button(),
			top    = 0,
			bottom = 0,
			left   = 0,
			right  = 0,
			widget = wibox.container.margin,
		},
		layout = wibox.layout.align.vertical,
	}


	function sidebar.double_border_wrapper(args)
		args = args or {}
		args = {
			widget             = args.widget,
			shape              = args.shape              or gears.shape.rectangle,
			shape_inner        = args.shape_inner        or gears.shape.rectangle,
			shape_outer        = args.shape_outer        or gears.shape.rectangle,
			bg                 = args.bg                 or gears.color.transparent,
			border_width       = args.border_width       or beautiful.border_width       or 1, -- width of EACH border!
			border_color_inner = args.border_color_inner or beautiful.border_color_inner or beautiful.border_color or "#FFFFFF",
			border_color_outer = args.border_color_outer or beautiful.border_color_outer or "#000000",
		}

		return wibox.widget {
			{
				{
					{
						args.widget,
						margins = args.border_width * 2,
						widget  = wibox.container.margin,
					},
					bg                 = args.bg,
					shape              = args.shape_inner,
					shape_border_width = args.border_width,
					shape_border_color = args.border_color_inner,
					widget             = wibox.container.background,
				},
				margins = args.border_width,
				widget  = wibox.container.margin,
			},
			shape              = args.shape_outer,
			shape_border_width = args.border_width,
			shape_border_color = args.border_color_outer,
			widget             = wibox.container.background,
		}
	end


	sidebar.container_wibox = awful.wibar {
		bg       = gears.color.transparent,
		screen   = s,
		type     = "desktop",
		position = "right",
		width    = 400,
		visible  = false,
		widget   = {
				sidebar.double_border_wrapper {
					widget = {
						{
							sidebar.widgets.notifications.container,
							widget = wibox.layout.flex.vertical
						},
						top    = 24,
						bottom = 24,
						left   = 24,
						right  = 8,
						widget = wibox.container.margin,
					},
					--bg = beautiful.bg_normal,
					bg = gears.color {
						type  = "linear",
						from  = { 0, 0 },
						to    = { 0, 1040 },
						stops = {
							{ 0, beautiful.nord3 },
							{ 1, beautiful.nord0 },
						}
					},
					shape_inner = function(cr, w, h)
						gears.shape.partially_rounded_rect(cr, w, h, true, false, false, true, 48)
					end,
					shape_outer = function(cr, w, h)
						gears.shape.partially_rounded_rect(cr, w, h, true, false, false, true, 48)
					end,
					border_width       = 1,
					border_color_inner = beautiful.nord4,
					border_color_outer = beautiful.nord0,
				},
			top    = beautiful.useless_gap or 16,
			bottom = beautiful.useless_gap or 16,
			left   = beautiful.useless_gap or 16,
			right  = 0,
			widget = wibox.container.margin,
		},
	}


	-- This is a function to keep local variables out of scope (keeping things tidy)
	function sidebar.toggle_button(args)
		-- Make sure the args table exists, as code along the lines of
		-- `args.proptery or "default"` only works if `args` is a table
		-- (it does not need to hold any items, however)
		args = args or {}

		local toggle_button = {
			sidebar_is_expanded = false,

			text = {
				sidebar_expanded  = args.sidebar_expanded  or ">",
				sidebar_collapsed = args.sidebar_collapsed or "<",
			},

			colors = {
				-- var   = 'simple name' or 'awesome-style name' or 'default value',
				bg       = args.bg       or args.bg_normal or "#202020",
				bg_hover = args.bg_hover or args.bg_enter  or "#404040",
				bg_click = args.bg_click or args.bg_press  or "#606060",
			}
		}

		toggle_button.textbox = wibox.widget {
			text   = toggle_button.text.sidebar_collapsed,
			widget = wibox.widget.textbox,
		}

		local widget = wibox.widget {
			{
				toggle_button.textbox,
				left   = 12,
				right  = 12,
				widget = wibox.container.margin,
			},
			bg     = "#202020",
			widget = wibox.container.background,
		}

		local old_cursor, old_wibox
		widget:connect_signal("mouse::enter", function(d)
			d:set_bg("#404040")
			local wb = mouse.current_wibox
			old_cursor, old_wibox = wb.cursor, wb
			wb.cursor = "hand1"
		end)

		widget:connect_signal("mouse::leave", function(d)
			d:set_bg("#202020")
			if old_wibox then
				old_wibox.cursor = old_cursor
				old_wibox = nil
			end
		end)

		widget:connect_signal("button::press", function(d)
			d:set_bg("#606060")
		end)

		widget:connect_signal("button::release", function(d)
			d:set_bg("#404040")

			toggle_button.sidebar_is_expanded = not toggle_button.sidebar_is_expanded

			if toggle_button.sidebar_is_expanded then
				toggle_button.textbox:set_text(toggle_button.text.sidebar_expanded)
			else
				toggle_button.textbox:set_text(toggle_button.text.sidebar_collapsed)
			end

			sidebar.container_wibox.visible = not sidebar.container_wibox.visible
		end)

		return widget
	end

	return sidebar.toggle_button()
end

return create_sidebar
