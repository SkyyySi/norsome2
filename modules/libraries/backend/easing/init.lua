#!/usr/bin/env lua
--[[ Define some commonly used math objects to simpler variables
to make the code look a little cleaner (and to allow copy-pasting)
from https://easings.net *cough* ]]
local pi   = math.pi
local sin  = math.sin
local cos  = math.cos
local tan  = math.tan
local pow  = math.pow
local sqrt = math.sqrt

--[[ The table that contains all functions ]]
local easing = {}

--[[ Generates a lookup-table, which can be faster in some cases
(though it probably won't matter on any system from the last 25 years).
func is the easing function that should be called (without brackets),
steps is optional and defines how many steps there should be between 0 and 1 ]]
function easing.render(func, steps)
	if not steps then steps = 10000 end
	local out

	for i=0,steps do
		out[i] = func(i/steps)
	end

	return out
end

--[[ Sine easings ]]
function easing.easeInSine(x)
	return 1 - cos((x * pi) / 2)
end

function easing.easeOutSine(x)
	return sin((x * pi) / 2)
end

function easing.easeInOutSine(x)
	return -(cos(pi * x) - 1) / 2
end

--------------------------------------------------------------------

--[[ Quadratic easings ]]
function easing.easeInQuad(x)
	return x * x
end

function easing.easeOutQuad(x)
	return 1 - (1 - x) * (1 - x)
end

function easing.easeInOutQuad(x)
	if x < 0.5 then
		return 2 * x * x
	end

	return 1 - pow(-2 * x + 2, 2) / 2
end

--------------------------------------------------------------------

--[[ Cubic easings ]]
function easing.easeInCubic(x)
	return x * x * x
end

function easing.easeOutCubic(x)
	return 1 - pow(1 - x, 3)
end

function easing.easeInOutCubic(x)
	if x < 0.5 then
		return 4 * x * x * x
	end

	return 1 - pow(-2 * x + 2, 3) / 2
end

--------------------------------------------------------------------

--[[ Quarted easings ]]
function easing.easeInQuart(x)
	return x * x * x * x
end

function easing.easeOutQuart(x)
	return 1 - pow(1 - x, 4)
end

function easing.easeInOutQuart(x)
	if x < 0.5 then
		return 8 * x * x * x * x
	end

	return 1 - pow(-2 * x + 2, 4) / 2
end

--------------------------------------------------------------------

--[[ Quinted easings ]]
function easing.easeInQuint(x)
	return x * x * x * x * x
end

function easing.easeOutQuint(x)
	return 1 - pow(1 - x, 5)
end

function easing.easeInOutQuint(x)
	if x < 0.5 then
		return 16 * x * x * x * x * x
	end

	return 1 - pow(-2 * x + 2, 5) / 2
end

--------------------------------------------------------------------

--[[ Exponential easings ]]
function easing.easeInExpo(x)
	if x == 0 then
		return 0
	end

	return pow(2, 10 * x - 10)
end

function easing.easeOutExpo(x)
	if x == 1 then
		return 1
	end

	return 1 - pow(2, -10 * x)
end

function easing.easeInOutExpo(x)
	if     x == 0 then return 0
	elseif x == 1 then return 1
	elseif x < 0.5 then
		return pow(2, 20 * x - 10) / 2
	end

	return (2 - pow(2, -20 * x + 10)) / 2
end

--------------------------------------------------------------------

--[[ Circular easings ]]
function easing.easeInCirc(x)
	return 1 - sqrt(1 - pow(x, 2))
end

function easing.easeOutCirc(x)
	return sqrt(1 - pow(x - 1, 2))
end

function easing.easeInOutCirc(x)
	if x < 0.5 then
		return (1 - sqrt(1 - pow(2 * x, 2))) / 2
	end

	return (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2
end

--------------------------------------------------------------------

--[[ Backing easings ]]
function easing.easeInBack(x)
	local c1 = 1.70158
	local c3 = c1 + 1

	return c3 * x * x * x - c1 * x * x;
end

function easing.easeOutBack(x)
	local c1 = 1.70158
	local c3 = c1 + 1

	return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2)
end

function easing.easeInOutBack(x)
	local c1 = 1.70158
	local c2 = c1 * 1.525

	if x < 0.5 then
		return (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
	end

	return (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
end

--------------------------------------------------------------------

--[[ Elastic easings ]]
function easing.easeInElastic(x)
	local c4 = (2 * pi) / 3

	if     x == 0 then return 0
	elseif x == 1 then return 1
	else return -pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * c4)
	end
end

function easing.easeOutElastic(x)
	local c4 = (2 * pi) / 3

	if     x == 0 then return 0
	elseif x == 1 then return 1
	end

	return pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1
end

function easing.easeInOutElastic(x)
	local c5 = (2 * pi) / 4.5

	if     x == 0 then return 0
	elseif x == 1 then return 1
	elseif x < 0.5 then
		return -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
	end

	return -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
end

--------------------------------------------------------------------

--[[ Bouncing easings ]]
function easing.easeOutBounce(x)
	local n1 = 7.5625;
	local d1 = 2.75;

	if x < 1 / d1 then
		return n1 * x * x;
	elseif (x < 2 / d1) then
		return n1 * (x - (1.5 / d1)) * x + 0.75;
	elseif (x < 2.5 / d1) then
		return n1 * (x - (2.25 / d1)) * x + 0.9375;
	else
		return n1 * (x - (2.625 / d1)) * x + 0.984375;
	end
end

function easing.easeInBounce(x)
	return 1 - easing.easeOutBounce(1 - x)
end

function easing.easeInOutBounce(x)
	if x < 0.5 then
		return (1 - easing.easeOutBounce(1 - 2 * x)) / 2
	end

	return (1 + easing.easeOutBounce(2 * x - 1)) / 2
end

--------------------------------------------------------------------

return easing