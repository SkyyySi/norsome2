#!/usr/bin/env lua
--local gears         = require('gears')
--local awful         = require('awful')
--local naughty       = require('naughty')
--local base          = require('modules.libraries.backend.base')
local smart_run_cmd = require('modules.libraries.backend.smart_run_cmd')

-- Example syntax:
--[[
autostart {
	commands = {
		{ 'playerctld', 'daemon' }, -- Will be run using awful.spawn
		{ 'pasystray' }, -- Will be run using awful.spawn
		'picom', -- Will be run using awful.spawn.with_shell
	},
	rerun   = true,
	timeout = 5,
}
--]]

-- This function will run a table of strings and/or other tables
-- with smart_run_cmd using the same, shared options.
-- If you just want to add some programs to your autostart,
-- this is the library you want to use. If you want to do
-- some fancier stuff, you may want to use smart_run_cmd directly.
local function autostart(arg)
	-- Provide default arguments (except for commands, which has to be passed).
	local argv = {
		commands = arg.commands,         -- The commands you want to run.
		rerun    = arg.rerun   or false, -- If true, awesome will continuously check if the command is still running and re-run it if it isn't.
		timeout  = arg.timeout or 5,     -- The amount of seconds awesome should wait between each check.
	}

	-- Loop over each element in the argv.commands table and run it.
	for _,v in pairs(argv.commands) do
		local with_shell = false
		if type(v) == 'string' then with_shell = true end
		smart_run_cmd {
			command    = v,
			strict     = true,
			with_shell = with_shell,
			rerun      = argv.rerun,
			timeout    = argv.timeout,
		}
	end
end

return autostart
