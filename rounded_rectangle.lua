local gears = require("gears")
local dpi = require('beautiful.xresources').apply_dpi
-- A function to create rounded rectangles with custom rounding sizes
local function rounded_rectangle(size)
    local s = size or dpi(10)
    local shape
    function shape(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, s)
    end
    return shape
end

return rounded_rectangle
