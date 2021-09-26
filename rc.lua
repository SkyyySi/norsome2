-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, 'luarocks.loader')

-- Standard awesome library
local gears         = require('gears')
local awful         = require('awful')
require('awful.autofocus')
local wibox         = require('wibox') -- Widget and layout library
beautiful           = require('beautiful') -- Theme handling library
local naughty       = require('naughty') -- Notification library
-- Declarative object management
local ruled         = require('ruled')
local menubar       = require('menubar')
local hotkeys_popup = require('awful.hotkeys_popup')
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require('awful.hotkeys_popup.keys')
-- Other libraries
local base          = require('modules.libraries.backend.base')
local easing        = require('modules.libraries.backend.easing')
local animate       = require('modules.libraries.backend.animate')
local buttonify     = require('modules.libraries.end-user.buttonify')
local smart_run_cmd = require('modules.libraries.backend.smart_run_cmd')
local xresources    = require('beautiful.xresources')
local dpi           = xresources.apply_dpi

awful.spawn.with_shell('echo "" > /tmp/awt.txt')
awful.spawn.with_shell('echo "'..type(gears)..'" >> /tmp/awt.txt')
awful.spawn.with_shell('echo "'..type(awful)..'" >> /tmp/awt.txt')
awful.spawn.with_shell('echo "'..type(wibox)..'" >> /tmp/awt.txt')
awful.spawn.with_shell('echo "'..type(naughty)..'" >> /tmp/awt.txt')
awful.spawn.with_shell('echo "'..type(ruled)..'" >> /tmp/awt.txt')
awful.spawn.with_shell('echo "'..tostring(package.path)..'" >> /tmp/awt.txt')

-- Shortcut for sending notifications (primarily for debugging,
-- you should still use the full syntax for actual use).
function notify(message)
	naughty.notification { message = tostring(message) }
end

-- {{{ Error handling
-- This function will show a popup containing an error message.
function raise_error(arg)
	-- Default arguments
	local argv = {
		message = arg.message,
		title   = arg.title or 'Oops, an error happened!',
	}

	naughty.notification {
		urgency = 'critical',
		message = argv.message,
		title   = argv.title,
	}
end

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal('request::display_error', function(message, startup)
	raise_error {
		title   = 'Oops, an error happened'..(startup and ' during startup!' or '!'),
		message = message
	}
end)
-- }}}

-- {{{ Variable definitions
-- This is used later as the default terminal and editor to run.
config_dir  = gears.filesystem.get_configuration_dir()
terminal    = 'alacritty'
editor      = 'code' -- os.getenv('EDITOR') or 'nano'
filemanager = 'pcmanfm-qt'
webbrowser  = 'firefox'
editor_cmd  = editor .. ' ' .. config_dir --terminal .. ' -e ' .. editor
theme       = 'nord'

-- Themes define colours, icons, font and wallpapers.
theme_dir = config_dir .. 'themes/' .. theme .. '/'
theme_file = theme_dir .. 'theme.lua'
beautiful.init(theme_file)

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = 'Mod4'
-- }}}

-- {{{ Autostart
smart_run_cmd {
	command    = 'xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu > ' .. config_dir .. '/modules/external/archmenu/init.lua',
	with_shell = true,
}

local autostart = require('modules.libraries.end-user.autostart')

local autostart_commands = {
    { 'timidity', '-iA' },
    { 'picom', '--config', config_dir..'config/picom/picom.conf' },
    { 'pasystray' },
    { 'xscreensaver', '-no-splash' },
    { 'unclutter', '-b' },
    { 'nm-applet' },
    { 'blueman-applet' },
    { 'lxqt-session', '-w', 'awesome', '--de=awesome' },
    --{ 'ulauncher', '--hide-window' },
    { 'playerctld' },
    { 'kdeconnect-indicator' },
}

autostart {
	commands = autostart_commands,
	rerun   = true,
	timeout = 5,
}
-- }}}

-- Nicer titlebars
package.path = package.path .. ';' .. awful.util.getdir('config') .. 'modules/external/?.lua'
package.path = package.path .. ';' .. awful.util.getdir('config') .. 'modules/external/?/init.lua'
local nice = require('nice')
nice {
	titlebar_font   = 'Source Sans Pro bold 12',
	titlebar_color  = beautiful.titlebar_bg_normal,
	titlebar_height = beautiful.titlebar_size,
	close_color     = beautiful.nord11,
	minimize_color  = beautiful.nord13,
	maximize_color  = beautiful.nord14,
	floating_color  = beautiful.nord7,
	ontop_color     = beautiful.nord8,
	sticky_color    = beautiful.nord9,
}

-- Load bling for extra stuff
local bling = require('bling')
bling.signal.playerctl.enable()

function music_widget(arg)
	if not arg then arg = {} end
	local argv = {
		bg      = arg.bg      or beautiful.widget_bg or beautiful.bg_normal or beautiful.nord0 or '#2E3440',
		shape   = arg.shape   or function(cr, w, h) gears.shape.partially_rounded_rect(cr, w, h, false, false, false, true, 16) end,
		width   = arg.width   or dpi(250),
		height  = arg.height  or dpi(400),
		ontop   = arg.ontop   or true,
		visible = arg.visible or true,
		type    = arg.type    or 'desktop',
	}

	music_wibox = {}
	music_wibox.wibox = wibox {
		bg      = gears.color.transparent,
		width   = argv.width,
		height  = argv.height,
		ontop   = argv.ontop,
		visible = argv.visible,
		type    = argv.type,
		shape   = argv.shape,
	}

	music_wibox.widget_coverart = wibox.widget {
		resize = true,
		widget = wibox.widget.imagebox,
	}

	music_wibox.widget_title = wibox.widget {
		font   = beautiful.font_bold,
		text   = 'title',
		align  = 'center',
		widget = wibox.widget.textbox,
	}

	music_wibox.widget_artist = wibox.widget {
		text   = 'artist',
		align  = 'center',
		widget = wibox.widget.textbox,
	}

	music_wibox.widget_progess = wibox.widget {
		bar_height          = dpi(4),
		bar_shape           = gears.shape.rounded_rect,
		bar_color           = beautiful.widget_slider_bar_color        or beautiful.nord10 or '#5E81AC',
		bar_border_color    = beautiful.widget_slider_bar_border_color or beautiful.nord4  or '#D8DEE9',
		bar_border_width    = dpi(1),
		handle_shape        = gears.shape.circle,
		handle_color        = beautiful.widget_slider_handle_color or beautiful.nord7  or '#8FBCBB',
		handle_border_color = beautiful.widget_slider_handle_border_color or beautiful.nord4  or '#D8DEE9',
		handle_border_width = dpi(1),
		minimum             = 0,
		maximum             = 100,
		value               = 0,
		forced_height       = dpi(30),
		widget              = wibox.widget.slider,
	}

	function music_wibox.widget_progess_update(length, position)
		music_wibox.widget_progess:set_maximum(length)
		music_wibox.widget_progess:set_value(position)
	end

	music_wibox.widget_progess_update_timer = gears.timer {
		timeout   = 0.5,
		autostart = true,
		call_now  = true,
		callback  = function()
			awful.spawn.easy_async({ 'playerctl', 'metadata', 'mpris:length' }, function(stdout, stderr, reason, exit_code)
				if not out then return end
				out = stdout:gsub('\n', '')
				music_wibox.widget_progess:set_maximum(tonumber(out))
			end)
			awful.spawn.easy_async({ 'playerctl', 'metadata', '--format', '{{ position }}' }, function(stdout, stderr, reason, exit_code)
				if not out then return end
				out = stdout:gsub('\n', '')
				music_wibox.widget_progess:set_value(tonumber(out))
			end)
		end
	}

	music_wibox.widget_separator = wibox.widget {
		orientation   = 'horizontal',
		span_ratio    = 0.75,
		thickness     = dpi(2),
		forced_height = dpi(24),
		widget        = wibox.widget.separator,
	}

	music_wibox.wibox.widget = wibox.widget.base.make_widget(wibox.widget {
		{
			{
				nil,
				{
					nil,
					{
						nil,
						music_wibox.widget_coverart,
						nil,
						layout = wibox.layout.align.horizontal,
					},
					nil,
					layout = wibox.layout.align.horizontal,
				},
				{
					music_wibox.widget_separator,
					--{
						music_wibox.widget_title,
					--	fps           = 60,
					--	layout        = wibox.container.scroll.horizontal,
					--	step_function = wibox.container.scroll.linear_increase,
					--	speed         = 25,
					--},
					music_wibox.widget_artist,
					music_wibox.widget_separator,
					music_wibox.widget_progess,
					layout = wibox.layout.fixed.vertical,
				},
				layout = wibox.layout.align.vertical,
			},
			margins = dpi(10),
			widget  = wibox.container.margin,
		},
		bg      = argv.bg,
		shape   = argv.shape,
		widget  = wibox.container.background,
	})

	awesome.connect_signal('bling::playerctl::title_artist_album', function(title, artist, cover, player)
		music_wibox.widget_title:set_text(title)
		music_wibox.widget_artist:set_text(artist)

		local time = os.time(os.date("!*t"))
		local username = os.getenv('USER')
		local filepath = ('/tmp/awesome_' .. username .. '/')
		awful.spawn.with_shell('mkdir "/tmp/awesome_"' .. username)
		local filename = (filepath .. 'media_cover_' .. time .. '.jpg')

		music_wibox.widget_coverart:set_image(beautiful.icon.note or beautiful.awesome_icon)
		awful.spawn.with_shell('rm -f ' .. filepath .. '*.jpg')
		awful.spawn.easy_async_with_shell('ffmpeg -i ' .. cover .. [[ -vf "crop=w='min(min(iw\,ih)\,600)':h='min(min(iw\,ih)\,600)',scale=600:600,setsar=1" -vframes 1 ]] .. filename .. ' > /dev/null; echo now', function()
			music_wibox.widget_coverart:set_image(filename)
		end)
	end)

	return music_wibox.wibox
end

--[[ local music_wibox = music_widget()

awful.placement.top_right(music_wibox, { margins = { top = 32 } })
music_wibox.visible = false
awesome.connect_signal('bling::playerctl::status', function(status)
	music_wibox.visible = status
	--notify(tostring(status))
end) ]]

-- }}}

-- {{{ Menu
local main_menu = require('modules.widgets.awesome_menu')

local main_menu_launcher = wibox.widget {
	{
		{
			image  = beautiful.awesome_icon,
			widget = wibox.widget.imagebox,
		},
		top    = dpi(6),
		bottom = dpi(6),
		left   = dpi(12),
		right  = dpi(12),
		widget = wibox.container.margin,
	},
	widget = wibox.container.background,
}

buttonify {
	widget = main_menu_launcher,
	button_callback_release = function()
		main_menu:toggle()
	end
}
--}}}



--[[
local menu_test = wibox.widget {
	widget = wibox.widget.base.make_widget,
}

awful.spawn.with_shell( 'echo "' .. base.untable(wibox.widget) .. '" > /tmp/awesome_launcher.txt' )
--]]
--[[
local test_wibox_1 = wibox {
	width   = 150,
	height  = 150,
	ontop   = true,
	visible = true,
	screen  = 'primary',
}

test_wibox_1.widget = wibox.widget.base.make_widget(
	--[[ wibox.widget {
		{
			{
				{
					{
						{
							draw = function(_,_,cr,w,h)
								cr:set_source(gears.color(beautiful.nord11))
								cr:move_to(0, 0)
								gears.shape.rounded_bar(cr,w,h)
								cr:fill()
							end,
							widget = wibox.widget.base.make_widget,
						},
						forced_width  = dpi(42),
						forced_height = dpi(8),
						widget        = wibox.container.constraint,
					},
					layout = wibox.layout.fixed.vertical,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			top    = 8,
			widget = wibox.container.margin,
		},
		{
			{
				{
					{
						draw = function(_,_,cr,w,h)
							cr:set_source(gears.color(beautiful.nord12))
							cr:move_to(0, 0)
							gears.shape.circle(cr,w,h)
							cr:fill()
						end,
						widget = wibox.widget.base.make_widget,
					},
					forced_width  = dpi(24),
					forced_height = dpi(24),
					widget        = wibox.container.constraint,
				},
				layout = wibox.layout.fixed.vertical,
			},
			layout = wibox.layout.fixed.horizontal,
		},
		layout = wibox.layout.stack,
	} --] ]
	wibox.widget {
		{
			{
				--{
				--	{
						min_value     = 0,
						max_value     = 1,
						value         = 1,
						forced_width  = dpi(42),
						forced_height = dpi(24),
						paddings      = 1,
						border_width  = 1,
						bar_shape     = gears.shape.circle,
						background_color = gears.color.transparent,
						widget        = wibox.widget.progressbar,
				--	},
				--},
				--forced_width  = dpi(42),
				--forced_height = dpi(24),
				--widget        = wibox.container.constraint,
			},
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.fixed.horizontal,
	}
) ]]

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Tag
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal('request::default_layouts', function()
	awful.layout.append_default_layouts({
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.floating,
		--[[
		awful.layout.suit.floating,
		awful.layout.suit.tile,
		awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.tile.top,
		awful.layout.suit.fair,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.spiral,
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.max,
		awful.layout.suit.max.fullscreen,
		awful.layout.suit.magnifier,
		awful.layout.suit.corner.nw,
		--]]
	})
end)
-- }}}

-- {{{ Wibar

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = wibox.widget.textclock()

screen.connect_signal('request::wallpaper', function(s)
	-- Wallpaper
	awful.spawn { 'nitrogen', '--restore', '--force-setter=xinerama' }
	--[[
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == 'function' then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
	--]]
end)

screen.connect_signal('request::desktop_decoration', function(s)
	-- Each screen has its own tag table.
	awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox {
		screen  = s,
		buttons = {
			awful.button({ }, 1, function () awful.layout.inc( 1) end),
			awful.button({ }, 3, function () awful.layout.inc(-1) end),
			awful.button({ }, 4, function () awful.layout.inc(-1) end),
			awful.button({ }, 5, function () awful.layout.inc( 1) end),
		}
	}

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
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

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist {
		screen  = s,
		filter  = awful.widget.tasklist.filter.currenttags,
		buttons = {
			awful.button({ }, 1, function (c)
				c:activate { context = 'tasklist', action = 'toggle_minimization' }
			end),
			awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
			awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
			awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
		}
	}

	-- Create the wibox
	s.mywibox = awful.wibar({ position = 'top', screen = s })

	-- Add widgets to the wibox
	s.mywibox.widget = {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			main_menu_launcher,
			s.mytaglist,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			mykeyboardlayout,
			wibox.widget.systray(),
			mytextclock,
			s.mylayoutbox,
		},
	}
end)
-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
	awful.button({ }, 3, function () main_menu:toggle() end),
	awful.button({ }, 4, awful.tag.viewprev),
	awful.button({ }, 5, awful.tag.viewnext),
})
-- }}}


local buttonify = require('modules.libraries.end-user.buttonify')

local exit_popup = {}

function exit_popup.button(arg)
	if not arg then arg = {} end
	local argv = {
		text     = arg.text     or 'Button',
		image    = arg.image    or beautiful.awesome_icon,
		image_bg = arg.image_bg or beautiful.button_normal or '#3B4252',
		bg       = arg.bg       or beautiful.bg_normal     or '#2E3440',
		callback = arg.callback or nil
	}

	local imagebox = wibox.widget {
		{
			{
				image                 = argv.image,
				resize                = true,
				halign                = 'center',
				valign                = 'center',
				forced_width          = 100,
				horizontal_fit_policy = 'filter',
				vertical_fit_policy   = 'filter',
				widget                = wibox.widget.imagebox,
			},
			margins = 10,
			widget  = wibox.container.margin,
		},
		bg     = argv.image_bg,
		shape  = gears.shape.rounded_rect,
		widget = wibox.container.background,
	}

	buttonify {
		widget                  = imagebox,
		button_callback_release = argv.callback
	}

	local widget = wibox.widget {
			{
				{
					{
						widget = imagebox
					},
					{
						font   = 'Source Code Pro Bold 14',
						text   = argv.text,
						align  = 'center',
						widget = wibox.widget.textbox
					},
					layout = wibox.layout.fixed.vertical,
				},
				bg     = argv.bg,
				shape  = gears.shape.rounded_rect,
				shape_border_width = 2,
				shape_border_color = beautiful.nord4,
				widget = wibox.container.background,
			},
			widget        = wibox.container.constraint,
			forced_height = dpi(150),
	}

	return widget
end

exit_popup.popup = awful.popup {
	widget    = exit_popup.button {
		text     = 'Logout',
		image    = beautiful.icon.power,
		callback = function()
			exit_popup.popup.visible = false
			awesome.quit()
		end
	},
	bg        = gears.color.transparent,
	screen    = mouse.screen,
	placement = awful.placement.centered,
	shape     = gears.shape.rounded_rect,
	visible   = false,
	ontop     = true,
}

-- {{{ Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
	awful.key({ modkey,           }, 's',      hotkeys_popup.show_help,
			  {description='show help', group='awesome'}),
	awful.key({ modkey,           }, 'w', function () mymainmenu:show() end,
			  {description = 'show main menu', group = 'awesome'}),
	awful.key({ modkey, 'Control' }, 'r', awesome.restart,
			  {description = 'reload awesome', group = 'awesome'}),
	--awful.key({ modkey, 'Shift'   }, 'q', awesome.quit,
	--		  {description = 'quit awesome', group = 'awesome'}),
	awful.key({ modkey, 'Shift'   }, 'q', function()
		exit_popup.popup.screen  = mouse.screen
		exit_popup.popup.visible = not exit_popup.popup.visible
	end,
			  {description = 'quit awesome', group = 'awesome'}),
	awful.key({ modkey }, 'x',
			  function ()
				  awful.prompt.run {
					prompt       = 'Run Lua code: ',
					textbox      = awful.screen.focused().mypromptbox.widget,
					exe_callback = awful.util.eval,
					history_path = awful.util.get_cache_dir() .. '/history_eval'
				  }
			  end,
			  {description = 'lua execute prompt', group = 'awesome'}),
	awful.key({ modkey,           }, 'Return', function () awful.spawn(terminal) end,
			  {description = 'open a terminal', group = 'launcher'}),
	awful.key({ modkey },            'r',     function () awful.screen.focused().mypromptbox:run() end,
			  {description = 'run prompt', group = 'launcher'}),
	awful.key({ modkey }, 'p', function() menubar.show() end,
			  {description = 'show the menubar', group = 'launcher'}),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ modkey,           }, 'Left',   awful.tag.viewprev,
			  {description = 'view previous', group = 'tag'}),
	awful.key({ modkey,           }, 'Right',  awful.tag.viewnext,
			  {description = 'view next', group = 'tag'}),
	awful.key({ modkey,           }, 'Escape', awful.tag.history.restore,
			  {description = 'go back', group = 'tag'}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ modkey,           }, 'j',
		function ()
			awful.client.focus.byidx( 1)
		end,
		{description = 'focus next by index', group = 'client'}
	),
	awful.key({ modkey,           }, 'k',
		function ()
			awful.client.focus.byidx(-1)
		end,
		{description = 'focus previous by index', group = 'client'}
	),
	awful.key({ modkey,           }, 'Tab',
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		{description = 'go back', group = 'client'}),
	awful.key({ modkey, 'Control' }, 'j', function () awful.screen.focus_relative( 1) end,
			  {description = 'focus the next screen', group = 'screen'}),
	awful.key({ modkey, 'Control' }, 'k', function () awful.screen.focus_relative(-1) end,
			  {description = 'focus the previous screen', group = 'screen'}),
	awful.key({ modkey, 'Control' }, 'n',
			  function ()
				  local c = awful.client.restore()
				  -- Focus restored client
				  if c then
					c:activate { raise = true, context = 'key.unminimize' }
				  end
			  end,
			  {description = 'restore minimized', group = 'client'}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ modkey, 'Shift'   }, 'j', function () awful.client.swap.byidx(  1)    end,
			  {description = 'swap with next client by index', group = 'client'}),
	awful.key({ modkey, 'Shift'   }, 'k', function () awful.client.swap.byidx( -1)    end,
			  {description = 'swap with previous client by index', group = 'client'}),
	awful.key({ modkey,           }, 'u', awful.client.urgent.jumpto,
			  {description = 'jump to urgent client', group = 'client'}),
	awful.key({ modkey,           }, 'l',     function () awful.tag.incmwfact( 0.05)          end,
			  {description = 'increase master width factor', group = 'layout'}),
	awful.key({ modkey,           }, 'h',     function () awful.tag.incmwfact(-0.05)          end,
			  {description = 'decrease master width factor', group = 'layout'}),
	awful.key({ modkey, 'Shift'   }, 'h',     function () awful.tag.incnmaster( 1, nil, true) end,
			  {description = 'increase the number of master clients', group = 'layout'}),
	awful.key({ modkey, 'Shift'   }, 'l',     function () awful.tag.incnmaster(-1, nil, true) end,
			  {description = 'decrease the number of master clients', group = 'layout'}),
	awful.key({ modkey, 'Control' }, 'h',     function () awful.tag.incncol( 1, nil, true)    end,
			  {description = 'increase the number of columns', group = 'layout'}),
	awful.key({ modkey, 'Control' }, 'l',     function () awful.tag.incncol(-1, nil, true)    end,
			  {description = 'decrease the number of columns', group = 'layout'}),
	awful.key({ modkey,           }, 'space', function () awful.layout.inc( 1)                end,
			  {description = 'select next', group = 'layout'}),
	awful.key({ modkey, 'Shift'   }, 'space', function () awful.layout.inc(-1)                end,
			  {description = 'select previous', group = 'layout'}),
})


awful.keyboard.append_global_keybindings({
	awful.key {
		modifiers   = { modkey },
		keygroup    = 'numrow',
		description = 'only view tag',
		group       = 'tag',
		on_press    = function (index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	},
	awful.key {
		modifiers   = { modkey, 'Control' },
		keygroup    = 'numrow',
		description = 'toggle tag',
		group       = 'tag',
		on_press    = function (index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end,
	},
	awful.key {
		modifiers = { modkey, 'Shift' },
		keygroup    = 'numrow',
		description = 'move focused client to tag',
		group       = 'tag',
		on_press    = function (index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	},
	awful.key {
		modifiers   = { modkey, 'Control', 'Shift' },
		keygroup    = 'numrow',
		description = 'toggle focused client on tag',
		group       = 'tag',
		on_press    = function (index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end,
	},
	awful.key {
		modifiers   = { modkey },
		keygroup    = 'numpad',
		description = 'select layout directly',
		group       = 'layout',
		on_press    = function (index)
			local t = awful.screen.focused().selected_tag
			if t then
				t.layout = t.layouts[index] or t.layout
			end
		end,
	}
})

client.connect_signal('request::default_mousebindings', function()
	awful.mouse.append_client_mousebindings({
		awful.button({ }, 1, function (c)
			c:activate { context = 'mouse_click' }
		end),
		awful.button({ modkey }, 1, function (c)
			c:activate { context = 'mouse_click', action = 'mouse_move'  }
		end),
		awful.button({ modkey }, 3, function (c)
			c:activate { context = 'mouse_click', action = 'mouse_resize'}
		end),
	})
end)

client.connect_signal('request::default_keybindings', function()
	awful.keyboard.append_client_keybindings({
		awful.key({ modkey,           }, 'f',
			function (c)
				c.fullscreen = not c.fullscreen
				c:raise()
			end,
			{description = 'toggle fullscreen', group = 'client'}),
		awful.key({ modkey, 'Shift'   }, 'c',      function (c) c:kill()                         end,
				{description = 'close', group = 'client'}),
		awful.key({ modkey, 'Shift' }, 'f',  awful.client.floating.toggle                     ,
				{description = 'toggle floating', group = 'client'}),
		awful.key({ modkey, 'Control' }, 'Return', function (c) c:swap(awful.client.getmaster()) end,
				{description = 'move to master', group = 'client'}),
		awful.key({ modkey,           }, 'o',      function (c) c:move_to_screen()               end,
				{description = 'move to screen', group = 'client'}),
		awful.key({ modkey,           }, 't',      function (c) c.ontop = not c.ontop            end,
				{description = 'toggle keep on top', group = 'client'}),
		awful.key({ modkey,           }, 'n',
			function (c)
				-- The client currently has the input focus, so it cannot be
				-- minimized, since minimized clients can't have the focus.
				c.minimized = true
			end ,
			{description = 'minimize', group = 'client'}),
		awful.key({ modkey,           }, 'm',
			function (c)
				c.maximized = not c.maximized
				c:raise()
			end ,
			{description = '(un)maximize', group = 'client'}),
		awful.key({ modkey, 'Control' }, 'm',
			function (c)
				c.maximized_vertical = not c.maximized_vertical
				c:raise()
			end ,
			{description = '(un)maximize vertically', group = 'client'}),
		awful.key({ modkey, 'Shift'   }, 'm',
			function (c)
				c.maximized_horizontal = not c.maximized_horizontal
				c:raise()
			end ,
			{description = '(un)maximize horizontally', group = 'client'}),
	})
end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal('request::rules', function()
	-- All clients will match this rule.
	ruled.client.append_rule {
		id         = 'global',
		rule       = { },
		properties = {
			focus     = awful.client.focus.filter,
			raise     = true,
			screen    = awful.screen.preferred,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen
		}
	}

	-- Floating clients.
	ruled.client.append_rule {
		id       = 'floating',
		rule_any = {
			instance = { 'copyq', 'pinentry' },
			class    = {
				'Arandr', 'Blueman-manager', 'Gpick', 'Kruler', 'Sxiv',
				'Tor Browser', 'Wpa_gui', 'veromix', 'xtightvncviewer'
			},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name    = {
				'Event Tester',  -- xev.
			},
			role    = {
				'AlarmWindow',    -- Thunderbird's calendar.
				'ConfigManager',  -- Thunderbird's about:config.
				'pop-up',         -- e.g. Google Chrome's (detached) Developer Tools.
			}
		},
		properties = { floating = true }
	}

	-- Launchers
	ruled.client.append_rule {
		id         = 'launcher',
		rule_any   = {
			class = {
				'ulauncher',
				'dmenu',
			}
		},
		properties = {
			floating = true,
			titlebars_enabled = false,
			border = 0,
		}
	}

	--[ [
	-- Add titlebars to normal clients and dialogs
	ruled.client.append_rule {
		id         = 'titlebars',
		rule_any   = { type = { 'normal', 'dialog' } },
		properties = { titlebars_enabled = true      }
	}
	--]]

	-- Set Firefox to always map on the tag named '2' on screen 1.
	-- ruled.client.append_rule {
	--     rule       = { class = 'Firefox'     },
	--     properties = { screen = 1, tag = '2' }
	-- }
end)

-- }}}

--[ [
-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
--[[
client.connect_signal('request::titlebars', function(c)
	-- buttons for the titlebar
	local buttons = {
		awful.button({ }, 1, function()
			c:activate { context = 'titlebar', action = 'mouse_move'  }
		end),
		awful.button({ }, 3, function()
			c:activate { context = 'titlebar', action = 'mouse_resize'}
		end),
	}

	awful.titlebar(c).widget = {
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout  = wibox.layout.fixed.horizontal
		},
		{ -- Middle
			{ -- Title
				align  = 'center',
				widget = awful.titlebar.widget.titlewidget(c)
			},
			buttons = buttons,
			layout  = wibox.layout.flex.horizontal
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton (c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton   (c),
			awful.titlebar.widget.ontopbutton    (c),
			awful.titlebar.widget.closebutton    (c),
			layout = wibox.layout.fixed.horizontal()
		},
		layout = wibox.layout.align.horizontal
	}
end)
--]]
-- }}}
--]]

-- {{{ Notifications
ruled.notification.connect_signal('request::rules', function()
	-- All notifications will match this rule.
	ruled.notification.append_rule {
		rule       = { },
		properties = {
			screen           = awful.screen.preferred,
			implicit_timeout = 5,
		}
	}
end)

naughty.connect_signal('request::display', function(n)
	naughty.layout.box { notification = n }
end)
-- }}}

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal('mouse::enter', function(c)
	c:activate { context = 'mouse_enter', raise = false }
end)

-------------------------------------------------------------------------------------

--[[
local test_box1 = {}
test_box1.wibox = wibox {
	bg      = '#202020B0',
	width   = 50,
	height  = 50,
	x       = 960,
	y       = 540,
	ontop   = true,
	visible = true,
}
--awful.placement.top(test_box1.wibox, { margins = { top = 50 } })
awful.placement.centered(test_box1.wibox)
--]]

--]]

--[[ function animate.animate:restart()
	self.anim.timer:stop()
	self.anim.timer:start()
end ]]

--[[ local bar = animate.animate {
	fps      = 30,
	stop     = 108,
	speed    = 1,
	easing   = easing.easeInOutCubic,
	callback = function(y)
		test_box2.wibox.y = y
	end,
} ]]
--[[

test_box1.wibox:connect_signal('button::press', function(_,_,_,b)
	if b == 1 then
		if animate.running then
			animate:stop()
			animate:reset()
			animate:start()
		end

		animate.animate {
			fps      = 60,
			stop     = 108,
			speed    = 1,
			easing   = easing.easeInOutCubic,
			callback = function(y)
				test_box1.wibox.y = y + 515
			end,
		}
		animate:start()
	end
end)
--]]
--[[
local wallpaper_box = {}

wallpaper_box.wibox = wibox {
	bg      = beautiful.nord2..'80',
	width   = 650,
	height  = 800,
	ontop   = true,
	visible = true,
	shape   = gears.shape.rounded_rect,
}
awful.placement.centered(wallpaper_box.wibox)

wallpaper_box.scrollbar = wibox.widget {
	{
		{
			{
				{
					bar_shape           = gears.shape.rounded_bar,
					bar_height          = 10,
					bar_color           = beautiful.nord3,
					handle_color        = beautiful.nord6,
					handle_shape        = gears.shape.circle,
					handle_border_color = beautiful.nord6,
					handle_border_width = 1,
					value               = 0,
					minimum             = 0,
					maximum             = wallpaper_box.wibox.height - 20,
					forced_height       = 32,
					forced_width        = 780,
					widget              = wibox.widget.slider,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			left = 10,
			layout = wibox.layout.margin,
		},
		direction = 'west',
		widget    = wibox.container.rotate
	},
	layout = wibox.layout.fixed.horizontal,
}

wallpaper_box.grid = wibox.widget {
	homogeneous     = false,
	spacing         = 10,
	min_cols_size   = 100,
	min_rows_size   = 100,
	forced_num_cols = 2,
	layout          = wibox.layout.grid
}

wallpaper_box.grid_widget = wibox.widget {
	{
		--{
			widget = wallpaper_box.grid,
		--},
		step_function = wibox.container.scroll.step_functions.linear_back_and_forth,
		speed         = 100,
		layout        = wibox.container.scroll.vertical,
	},
	margins = 10,
	widget  = wibox.container.margin,
}

wallpaper_box.wibox.widget = wibox.widget {
	nil,
	wallpaper_box.grid,
	wallpaper_box.scrollbar,
	layout = wibox.layout.align.horizontal,
}

function wallpaper_box.add_wallpaper(path)
	wallpaper_box.grid:add(
		{
			{
				--{
					{
						wibox.widget {
							clip_shape          = gears.shape.rounded_rect,
							resize              = true,
							image               = path,
							forced_width        = 290,
							forced_heigth       = 300,
							vertical_fit_policy = 'fit',
							valign              = 'top',
							widget              = wibox.widget.imagebox,
						},
						layout = wibox.layout.fixed.vertical,
					},
					layout = wibox.layout.fixed.horizontal,
				--},
				--widget = wibox.container.place,
			},
			bg     = '#000000',
			widget = wibox.container.background,
		}
	)
end

--wallpaper_box.add_wallpaper('/usr/share/backgrounds/wallpapers/wallpapers/charlotte_day.jpg')
--wallpaper_box.add_wallpaper('/usr/share/backgrounds/wallpapers/wallpapers/charlotte_dusk.jpg')
--wallpaper_box.add_wallpaper('/usr/share/backgrounds/wallpapers/wallpapers/charlotte_night.jpg')
--wallpaper_box.add_wallpaper('/usr/share/backgrounds/wallpapers/wallpapers/col_de_Jaman.jpg')
--wallpaper_box.add_wallpaper('/usr/share/backgrounds/wallpapers/wallpapers/default_mountains.jpg')
--wallpaper_box.add_wallpaper('/usr/share/backgrounds/wallpapers/wallpapers/lake_mountain_sky.jpg')
--wallpaper_box.add_wallpaper('/usr/share/backgrounds/wallpapers/wallpapers/madrid_tunnel.jpg')
--wallpaper_box.add_wallpaper('/usr/share/backgrounds/wallpapers/wallpapers/philadelphia.jpg')

base.list_wallpapers(function(wallpaper)
	--notify(wallpaper)
	wallpaper_box.add_wallpaper(wallpaper)
end)
--]]
