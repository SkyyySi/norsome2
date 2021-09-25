#!/usr/bin/env lua
local gears         = require('gears')
local awful         = require('awful')
local xdg_menu      = require('modules.external.archmenu')
local hotkeys_popup = require('awful.hotkeys_popup')

-- Generate an xdg app menu
--awful.spawn.with_shell('xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu > ' .. config_dir .. '/archmenu.lua')

-- Create a launcher widget and a main menu.
-- Entries related to awesome itself
local menu_awesome = {
	{ 'Show hotkeys', function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
	{ 'Show manual', terminal .. ' -e man awesome' },
	{ 'Edit config', editor_cmd .. ' ' .. config_dir },
	{ 'Restart awesome', awesome.restart },
	{ 'Quit awesome', function() awesome.quit() end },
}

-- Entries related to power management
local menu_power = {
	{ 'Lock session', 'loginctl lock-session' },
	{ 'Shutdown',     'sudo poweroff'         },
	{ 'Reboot',       'sudo reboot'           },
	{ 'Suspend',      'systemctl suspend'     },
	{ 'Hibernate',    'systemctl hibernate'   },
}

-- Assemble all menus into one
local awesome_menu = awful.menu {
	{ 'Awesome',      menu_awesome, beautiful.awesome_icon  },
	{ 'Power',        menu_power,   beautiful.icon.power    },
	{ 'Applications', xdg_menu,     beautiful.icon.app      },
	{ 'Terminal',     terminal,     beautiful.icon.terminal },
	{ 'File manager', filemanager,  beautiful.icon.folder   },
	{ 'Web browser',  webbrowser,   beautiful.icon.web      },
}

return awesome_menu