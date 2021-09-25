#!/usr/bin/env lua
local beautiful = require('beautiful')
beautiful.init(theme_file)

--[[ A small helper module that adds hover and click effects
to a widget, to make it "feel" more like a button. --]]
local function buttonify(arg)
	local argv = {
		widget                  = arg.widget,
		button_color_enter      = arg.button_color_enter      or beautiful.button_enter,
		button_color_leave      = arg.button_color_leave      or beautiful.button_normal,
		button_color_press      = arg.button_color_press      or beautiful.button_press,
		button_color_release    = arg.button_color_release    or beautiful.button_release,
		-- Callbacks are functions that will be executed whenever the corresponding action is performed.
		button_callback_enter   = arg.button_callback_enter   or nil,
		button_callback_leave   = arg.button_callback_normal  or nil,
		button_callback_press   = arg.button_callback_press   or nil,
		button_callback_release = arg.button_callback_release or nil,
	}

	local old_cursor, old_wibox
	argv.widget:connect_signal('mouse::enter', function(c)
		c:set_bg(argv.button_color_enter)
		local wb = mouse.current_wibox
		old_cursor, old_wibox = wb.cursor, wb
		wb.cursor = 'hand1'

		if type(argv.button_callback_enter) == 'function' then
			argv.button_callback_enter()
		end
	end)

	argv.widget:connect_signal('mouse::leave', function(c)
		c:set_bg(argv.button_color_leave)
		if old_wibox then
			old_wibox.cursor = old_cursor
			old_wibox = nil
		end

		if type(argv.button_callback_leave) == 'function' then
			argv.button_callback_leave()
		end
	end)

	argv.widget:connect_signal('button::press', function(c)
		c:set_bg(argv.button_color_press)

		if type(argv.button_callback_press) == 'function' then
			argv.button_callback_press()
		end
	end)

	argv.widget:connect_signal('button::release', function(c)
		c:set_bg(argv.button_color_release)

		if type(argv.button_callback_release) == 'function' then
			argv.button_callback_release()
		end
	end)
end

return buttonify