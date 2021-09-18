-- Convert HSL (hue saturation lightness) to RGB (red green blue)
-- Original code by John Chin-Jew/Wavalab:
-- https://github.com/Wavalab/rgb-hsl-rgb
local base = require('modules.libraries.base')

local colorlib = {}

function colorlib.hsl2hex(h, s, l, a)
	a = a or 100
	local r, g, b

	h = (h / 360)
	s = (s / 100)
	l = (l / 100)
	a = (a / 100)

	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else
		local function hue2rgb(p, q, t)
			if t < 0   then t = t + 1 end
			if t > 1   then t = t - 1 end
			if t < 1/6 then return p + (q - p) * 6 * t end
			if t < 1/2 then return q end
			if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
			return p
		end

		local q
		if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
		local p = 2 * l - q

		r = hue2rgb(p, q, h + 1/3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1/3)
	end

	local out_r,out_b,out_g,out_a = nil,nil,nil,nil

	out_r = string.format('%x', base.round(r * 255))
	if #out_r < 2 then out_r = '0'..out_r end

	out_g = string.format('%x', base.round(g * 255))
	if #out_g < 2 then out_g = '0'..out_g end

	out_b = string.format('%x', base.round(b * 255))
	if #out_b < 2 then out_b = '0'..out_b end

	if a and a ~= 100 then
		out_a = string.format('%x', base.round(a * 255))
		if #out_a < 2 then out_a = '0'..out_a end
	end

	local out = ''
	out = out_r .. out_g .. out_b
	return tostring('#'..out)
end

return colorlib