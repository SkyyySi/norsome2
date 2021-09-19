#!/usr/bin/env lua
local gears   = require('gears')
local awful   = require('awful')
local naughty = require('naughty')
local base    = require('modules.libraries.backend.base')

-- This function will run a table with awful.spawn, but only if it is not already running.
-- Addionally, if strict is true, it will only check if the exact process
-- passed is running insead of searching for matches in a way like:
-- `echo 'this is some string i think' | grep 'some string'` <-- will return success (0).
-- You should use that option if you, for example, only want to kill sh but not bash/zsh/fish/etc.
-- Or if you just like having predictable code ;)
local function smart_run_cmd(arg)
	-- Provide default arguments (except for command, which has to be passed).
	local argv = {
		command    = arg.command,             -- The command you want to run.
		strict     = arg.strict     or false, -- If true, it will only be checked for the exact command (see above).
		with_shell = arg.with_shell or false, -- Whether to use awful.spawn.with_shell or awful.spawn.
		rerun      = arg.rerun      or false, -- If true, awesome will continuously check if the command is still running and re-run it if it isn't.
		timeout    = arg.timeout    or 5,     -- The amount of seconds awesome should wait between each check.
		verbose    = arg.verbose    or false, -- If true, verbose information will be printed through notifications (useful for debugging).
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

	-- Passing a string between "\<" and "\>" will cause `pgrep` to only look for exact matches.
	if argv.strict then
		cmd_string = [[\<]] .. cmd_string .. [[\>]]
	end

	-- The code actually responsible for running the command is in its own function in order
	-- to make the timer below easier to implement (without unnecessary code duplication).
	local function run_cmd()
		awful.spawn.easy_async({ 'pgrep', '-fU', os.getenv('USER'), '--', cmd_string }, function(_,_,_,exit_code)
			-- If the `pgrep`-command above returns zero as its exit code, it means that the process is already running.
			-- In that case, tell the user if verbose mode is active and return.
			if exit_code == 0 then
				if argv.verbose then
					naughty.notification { message = 'Nothing was executed because "' .. argv.command[1] .. '" appears to be already running!'}
				end

				return
			end

			if argv.verbose then
				naughty.notification { message = 'cmd_string:\n' .. cmd_string }
				naughty.notification { message = 'cmd (table):\n' .. base.untable(argv.command) }
			end

			if argv.with_shell then
				awful.spawn.with_shell(argv.command)
			else
				awful.spawn(argv.command)
			end
		end)
	end

	-- If argv.timeout is true, a gears.timer object will be created.
	-- It's ordered like this since I belive that loop execution is
	-- overall the less used usecase.
	if not argv.rerun then
		run_cmd()
	else
		gears.timer {
			timeout  = argv.timeout,
			call_now  = true,
			autostart = true,
			callback  = function()
				run_cmd()
			end
		}
	end
end

return smart_run_cmd
