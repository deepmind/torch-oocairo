-- This tests the 'in_fill' and 'in_stroke' methods.

require "runlocal"
local Cairo = require "oocairo"

local IMG_SZ, BLOB_SEP, BLOB_RADIUS = 800, 20, 9

local surface = Cairo.image_surface_create("rgb24", IMG_SZ, IMG_SZ)
local cr = Cairo.context_create(surface)

-- White background.
cr:set_source_rgb(1, 1, 1)
cr:paint()

-- Set up a path, but don't draw with it directly.
cr:move_to(0.05*IMG_SZ, 0.05*IMG_SZ)
cr:line_to(0.95*IMG_SZ, 0.3*IMG_SZ)
cr:curve_to(0.65*IMG_SZ, 1.3*IMG_SZ,
            0.25*IMG_SZ, 0.85*IMG_SZ,
            0.15*IMG_SZ, 0.6*IMG_SZ)
cr:set_line_width(30)

-- Collect lists of points which are inside the fill and/or the stroke areas.
-- They're stored for drawing later, because that's probably more efficient
-- than repeatedly saving and restoring the path we're testing to do the
-- drawing as we go.
local pnts_in_fill, pnts_in_stroke = {}, {}
for y = 0, IMG_SZ, BLOB_SEP do
    for x = 0, IMG_SZ, BLOB_SEP do
        if cr:in_fill(x, y) then
            pnts_in_fill[#pnts_in_fill + 1] = { x, y }
        end
        if cr:in_stroke(x, y) then
            pnts_in_stroke[#pnts_in_stroke + 1] = { x, y }
        end
    end
end

-- Use rounded lines of zero length as a simple way of drawing circles.
cr:new_path()
cr:set_line_cap("round")
cr:set_line_width(BLOB_RADIUS * 2)

-- Mark points found to be inside the area which would be stroked.
for _, pos in ipairs(pnts_in_stroke) do
    local x, y = unpack(pos)
    cr:move_to(x, y)
    cr:line_to(x, y)
end
cr:set_source_rgba(0, 0.5, 0, 0.5)
cr:stroke()

-- Mark points which would be inside the filled area.
for _, pos in ipairs(pnts_in_fill) do
    local x, y = unpack(pos)
    cr:move_to(x, y)
    cr:line_to(x, y)
end
cr:set_source_rgba(0.5, 0, 0, 0.5)
cr:stroke()

surface:write_to_png("inside-tests.png")

-- vi:ts=4 sw=4 expandtab