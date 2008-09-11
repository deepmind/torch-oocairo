require "runlocal"
require "lunit"
local Cairo = require "oocairo"

module("test.ps_surface", lunit.testcase, package.seeall)

teardown = clean_up_temp_files

function test_ps_levels ()
    local levels = Cairo.ps_get_levels()
    assert_table(levels)
    for k, v in pairs(levels) do
        assert_number(k)
        assert_string(v)
    end
end

local function draw_stuff (surface)
    local cr = Cairo.context_create(surface)
    cr:move_to(50, 50)
    cr:line_to(250, 150)
    cr:set_line_width(5)
    cr:set_source_rgb(1, 0, 0.5)
    cr:stroke()
end

local function check_ps_surface (surface)
    assert_userdata(surface)
    assert_equal("cairo surface object", surface._NAME)
    assert_equal("ps", surface:get_type())
end

local function check_file_contains_ps (filename)
    local fh = assert(io.open(filename, "rb"))
    local data = fh:read("*a")
    fh:close()
    assert_match("^%%!PS", data)
end

function test_create ()
    local filename = tmpname()
    local surface = Cairo.ps_surface_create(filename, 300, 200)
    check_ps_surface(surface)
    draw_stuff(surface)
    surface:finish()
    check_file_contains_ps(filename)
end

function test_create_stream ()
    local filename = tmpname()
    local fh = assert(io.open(filename, "wb"))
    local surface = Cairo.ps_surface_create(fh, 300, 200)
    check_ps_surface(surface)
    draw_stuff(surface)
    surface:finish()
    fh:close()
    check_file_contains_ps(filename)
end

function test_create_bad ()
    assert_error("wrong type instead of file/filename",
                 function () Cairo.ps_surface_create(true, 300, 200) end)
end

function test_set_size ()
    local surface = Cairo.ps_surface_create(tmpname(), 300, 200)
    surface:set_size(300, 400)
    draw_stuff(surface)
    surface:set_size(500, 600)
    draw_stuff(surface)
    surface:finish()
end

function test_eps ()
    local surface = Cairo.ps_surface_create(tmpname(), 300, 200)
    surface:set_eps(true)
    assert_true(surface:get_eps())
    surface:set_eps(false)
    assert_false(surface:get_eps())
end

-- vi:ts=4 sw=4 expandtab