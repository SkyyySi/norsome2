#!/usr/bin/env lua
local awful      = require('awful')
local wibox      = require('wibox')
local base       = require('modules.libraries.backend.base')
local xresources = require('beautiful.xresources')
local dpi        = xresources.apply_dpi

local function make_panel_widget(widget)
	local widget_base = wibox.widget.base.make_widget()

	widget_base.widget = wibox.widget {
		{
			{
				{
					widget = widget,
				},
				top    = dpi(4),
				bottom = dpi(4),
				left   = dpi(8),
				right  = dpi(8),
				widget = wibox.container.margin,
			},
			bg                 = beautiful.qrwidget_panel_bg,
			shape              = beautiful.qrwidget_shape,
			shape_border_color = beautiful.qrwidget_shape_border_color,
			shape_border_width = beautiful.qrwidget_shape_border_width,
			widget             = wibox.container.background,
		},
		margins = dpi(4),
		widget  = wibox.container.margin,
	}

	return widget_base
end

return make_panel_widget
