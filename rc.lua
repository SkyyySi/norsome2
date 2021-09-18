-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, 'luarocks.loader')

-- Standard awesome library
local gears         = require('gears')
local awful         = require('awful')
require('awful.autofocus')
local wibox         = require('wibox') -- Widget and layout library
local beautiful     = require('beautiful') -- Theme handling library
local naughty       = require('naughty') -- Notification library
-- Declarative object management
local ruled         = require('ruled')
local menubar       = require('menubar')
local hotkeys_popup = require('awful.hotkeys_popup')
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require('awful.hotkeys_popup.keys')
-- Other libraries
local base     = require('modules.libraries.base')
local colorlib = require('modules.libraries.colorlib')

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
terminal = 'alacritty'
editor = os.getenv('EDITOR') or 'nano'
editor_cmd = terminal .. ' -e ' .. editor
theme = 'nord'
config_dir = gears.filesystem.get_configuration_dir()

-- Themes define colours, icons, font and wallpapers.
theme_dir = config_dir .. 'themes/' .. theme .. '/'
beautiful.init(theme_dir .. 'theme.lua')

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = 'Mod4'
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { 'hotkeys', function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { 'manual', terminal .. ' -e man awesome' },
   { 'edit config', editor_cmd .. ' ' .. awesome.conffile },
   { 'restart', awesome.restart },
   { 'quit', function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { 'awesome', myawesomemenu, beautiful.awesome_icon },
									{ 'open terminal', terminal }
								  }
						})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
									 menu = mymainmenu })

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
	awful.spawn { 'nitrogen', '--restore' }
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
			mylauncher,
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
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewprev),
	awful.button({ }, 5, awful.tag.viewnext),
})
-- }}}

-- {{{ Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
	awful.key({ modkey,           }, 's',      hotkeys_popup.show_help,
			  {description='show help', group='awesome'}),
	awful.key({ modkey,           }, 'w', function () mymainmenu:show() end,
			  {description = 'show main menu', group = 'awesome'}),
	awful.key({ modkey, 'Control' }, 'r', awesome.restart,
			  {description = 'reload awesome', group = 'awesome'}),
	awful.key({ modkey, 'Shift'   }, 'q', awesome.quit,
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

	--[[
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

-- This function will run a table with awful.spawn, but only if it is not already running.
-- Addionally, if strict is true, it will only check if the exact process
-- passed is running insead of searching for matches in a way like:
-- `echo 'this is some string i think' | grep 'some string'` <-- will return success (0).
-- You should use that option if you, for example, only want to kill sh but not bash/zsh/fish/etc.
function smart_run_cmd(arg)
	-- Provide default arguments (except for command, which has to be passed).
	local argv = {
		command       = arg.command,                -- The command you want to run.
		strict        = arg.strict        or false, -- If true, it will only be checked for the exact command (see above).
		with_shell    = arg.with_shell    or false, -- Whether to use awful.spawn.with_shell or awful.spawn.
		verbose       = arg.verbose       or false, -- If true, verbose information will be printed through notifications (useful for debugging).
		rerun         = arg.rerun         or false, -- If true, awesome will continuously check if the command is still running and re-run it if it isn't.
		rerun_timeout = arg.rerun_timeout or 5,     -- The amount of seconds awesome should wait between each check.
	}

	-- Raise an error if the type of argv.command is a missmatch with argv.with_shell
	if argv.with_shell and type(argv.command) == 'table' then
		raise_error {
			 message = '"awful.spawn.with_shell" requires a string.\nEither pass a string-formatted command or\nset "with_shell" to false to run without a shell\n(thus allowing for a table-formatted command).',
		}

		return
	end

	if (not argv.with_shell) and type(argv.command) == 'string' then
		raise_error {
			 message = '"awful.spawn" requires a table.\nEither pass a table-formatted command or\nset "with_shell" to true to run with a shell\n(thus allowing for a string-formatted command).',
		}

		return
	end

	-- Turn the command table into a string to be checked with `pgrep` below.
	local cmd_string = ''
	if type(argv.command) == 'table' then
		for i,v in pairs(argv.command) do
			if i == 1 then
				cmd_string = cmd_string .. v
			else
				cmd_string = cmd_string .. ' ' .. v
			end
		end
	else
		cmd_string = argv.command
	end

	if argv.strict then
		cmd_string = [[\<]] .. cmd_string .. [[\>]]
	end


	awful.spawn.easy_async({ 'pgrep', '-fU', os.getenv('USER'), '--', cmd_string }, function(_,_,_,exit_code)
		-- If the `pgrep`-command above returns zero as its exit code, it means that the process is already running.
		-- In that case, tell the user if verbose mode is active and return.
		if exit_code == 0 then
			if argv.verbose then
				naughty.notification { message = 'Nothing was executed because "' .. argv.command[1] .. '" appears to be already running!'}
			end

			return
		end

		if argv.with_shell then
			awful.spawn.with_shell(argv.command)
		else
			awful.spawn(argv.command)
		end

		if argv.verbose then
			naughty.notification { message = 'cmd_string:\n' .. cmd_string }
			naughty.notification { message = 'cmd (table):\n' .. base.untable(argv.command) }
			naughty.notification { message = 'Spawned "' .. argv.command[1] .. '"!'}
		end
	end)
end

smart_run_cmd {
	command    = { 'picom', '--config', config_dir..'config/picom/picom.conf' },
	strict     = false,
	with_shell = false,
	verbose    = false,
}
