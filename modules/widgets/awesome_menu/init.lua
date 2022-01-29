#!/usr/bin/env lua
local gears         = require("gears")
local awful         = require("awful")
local awful_menu    = require("modules.widgets.awesome_menu.awful_menu")
local hotkeys_popup = require("awful.hotkeys_popup")

local script = [[
	cfgdir=']]..gears.filesystem.get_configuration_dir()..[[modules/external/archmenu'
	[ -d "${cfgdir}" ] || mkdir -p "${cfgdir}"
	xdg_menu --desktop GNOME --format awesome --root-menu "/etc/xdg/menus/arch-applications.menu" > "${cfgdir}/init.lua"
	sed -i 's/^xdgmenu = {$/local xdg_menu = {/' "${cfgdir}/init.lua"
	printf '%s\n' 'return xdg_menu' >> "${cfgdir}/init.lua"
]]

awful.spawn({"sh", "-c", script})

local xdg_menu = require('modules.external.archmenu')

-- Generate an xdg app menu
--awful.spawn.with_shell('xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu > ' .. config_dir .. 'archmenu.lua')

-- Create a launcher widget and a main menu.
-- Entries related to awesome itself
local menu_awesome = {
	{ "Show hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
	{ "Show manual", terminal .. " -e man awesome" },
	{ "Edit config", editor_cmd .. " " .. config_dir },
	{ "Restart awesome", awesome.restart },
	{ "Quit awesome", function() awesome.quit() end },
}

-- Entries related to power management
local menu_power = {
	{ "Lock session", "loginctl lock-session" },
	{ "Shutdown",     "sudo poweroff"         },
	{ "Reboot",       "sudo reboot"           },
	{ "Suspend",      "systemctl suspend"     },
	{ "Hibernate",    "systemctl hibernate"   },
}

-- Assemble all menus into one
local awesome_menu = awful_menu {
	{ "Awesome",      menu_awesome, beautiful.awesome_icon  },
	{ "Power",        menu_power,   beautiful.icon.power    },
	{ "Applications", xdg_menu,     beautiful.icon.app      },
	{ "Terminal",     terminal,     beautiful.icon.terminal },
	{ "File manager", filemanager,  beautiful.icon.folder   },
	{ "Web browser",  webbrowser,   beautiful.icon.web      },
}

return awesome_menu