#!/usr/bin/env lua
local base = {}

function base.round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

-- https://stackoverflow.com/questions/1426954/split-string-in-lua#comment73602874_7615129
-- Splits a variable into a table, using the second argument as the field seperator.
function base.split(inputstr, sep)
	sep=sep or '%s'
	local t={}
	for field,s in string.gmatch(inputstr, '([^'..sep..']*)('..sep..'?)') do
		table.insert(t,field)
		if s=='' then
			return t
		end
	end
end

-- Splits an environment variable with a $PATH-like syntax.
function base.split_env(var)
	local var_split = base.split(os.getenv('PATH'), ':')
	return var_split
end

function base.untable(table)
	local str = ''
	for i,v in pairs(table) do
		str = str .. tostring(i) .. ':\t' .. tostring(v) .. '\n'
	end
	return str
end

return base