require "runlocal"
require "lunit"
local Cairo = require "oocairo"

module("test.context", lunit.testcase, package.seeall)

function setup ()
    surface = Cairo.image_surface_create("rgb24", 23, 45)
    cr = Cairo.context_create(surface)
end
function teardown ()
    surface = nil
    cr = nil
end

function test_antialias ()
    assert_error("bad value", function () cr:set_antialias("foo") end)
    assert_equal("default", cr:get_antialias(), "default intact after error")
    for _, v in ipairs({ "default", "none", "gray", "subpixel" }) do
        cr:set_antialias(v)
        assert_equal(v, cr:get_antialias())
    end
end

function test_dash ()
    for i, dashpat in ipairs{ {}, {3}, {3,6,9} } do
        for offset = 0, #dashpat do
            local msg = "dash pattern " .. i .. ", offset " .. offset
            cr:set_dash(dashpat, offset)
            local newpat, newoffset = cr:get_dash()
            assert_equal(#dashpat, #newpat, msg .. ", pattern length")
            for j, v in ipairs(dashpat) do
                assert_equal(v, newpat[j], msg .. ", pattern value " .. j)
            end
            assert_equal(offset, newoffset, msg .. ", offset")
        end
    end
end

function test_dash_bad ()
    assert_error("bad offset type", function () cr:set_dash({}, "foo") end)
    assert_error("bad dash type", function () cr:set_dash({"foo"}, 1) end)
    assert_error("bad dash value", function () cr:set_dash({-1}, 1) end)
    assert_error("bad dash total value", function () cr:set_dash({0,0}, 1) end)
    local pat, offset = cr:get_dash()
    assert_equal(0, #pat, "default pattern intact after errors")
    assert_equal(0, offset, "default offset intact after errors")
end

function test_fill_rule ()
    assert_error("bad value", function () cr:set_fill_rule("foo") end)
    assert_equal("winding", cr:get_fill_rule(), "default intact after error")
    for _, v in ipairs({ "winding", "even-odd" }) do
        cr:set_fill_rule(v)
        assert_equal(v, cr:get_fill_rule())
    end
end

function test_line_cap ()
    assert_error("bad value", function () cr:set_line_cap("foo") end)
    assert_equal("butt", cr:get_line_cap(), "default intact after error")
    for _, v in ipairs({ "butt", "round", "square" }) do
        cr:set_line_cap(v)
        assert_equal(v, cr:get_line_cap())
    end
end

function test_line_join ()
    assert_error("bad value", function () cr:set_line_join("foo") end)
    assert_equal("miter", cr:get_line_join(), "default intact after error")
    for _, v in ipairs({ "miter", "round", "bevel" }) do
        cr:set_line_join(v)
        assert_equal(v, cr:get_line_join())
    end
end

function test_line_width ()
    assert_error("bad type", function () cr:set_line_width("foo") end)
    assert_error("negative width", function () cr:set_line_width(-3) end)
    assert_equal(2, cr:get_line_width(), "default intact after error")
    for _, v in ipairs({ 0, 1, 2, 23.5 }) do
        cr:set_line_width(v)
        assert_equal(v, cr:get_line_width())
    end
end

function test_miter_limit ()
    assert_error("bad type", function () cr:set_miter_limit("foo") end)
    assert_equal(10, cr:get_miter_limit(), "default intact after error")
    for _, v in ipairs({ 0, 1, 2, 23.5 }) do
        cr:set_miter_limit(v)
        assert_equal(v, cr:get_miter_limit())
    end
end

function test_operator ()
    assert_error("bad value", function () cr:set_operator("foo") end)
    assert_equal("over", cr:get_operator(), "default intact after error")
    for _, v in ipairs({
        "clear",
        "source", "over", "in", "out", "atop",
        "dest", "dest-over", "dest-in", "dest-out", "dest-atop",
        "xor", "add", "saturate",
    }) do
        cr:set_operator(v)
        assert_equal(v, cr:get_operator())
    end
end

function test_save_restore ()
    cr:save()
    cr:set_line_width(3)
    cr:save()
    cr:set_line_width(4)
    cr:restore()
    assert_equal(3, cr:get_line_width())
    cr:restore()
    assert_equal(2, cr:get_line_width())
end

function test_source_rgb ()
    cr:set_source_rgb(0.1, 0.2, 0.3)
    assert_error("not enough args", function () cr:set_source_rgb(0.1, 0.2) end)
    assert_error("bad arg type 1", function () cr:set_source_rgb("x", 0, 0) end)
    assert_error("bad arg type 2", function () cr:set_source_rgb(0, "x", 0) end)
    assert_error("bad arg type 3", function () cr:set_source_rgb(0, 0, "x") end)
end

function test_source_rgba ()
    cr:set_source_rgba(0.1, 0.2, 0.3, 0.4)
    assert_error("not enough args",
                 function () cr:set_source_rgba(0.1, 0.2, 0.3) end)
    assert_error("bad arg type 1",
                 function () cr:set_source_rgba("x", 0, 0, 0) end)
    assert_error("bad arg type 2",
                 function () cr:set_source_rgba(0, "x", 0, 0) end)
    assert_error("bad arg type 3",
                 function () cr:set_source_rgba(0, 0, "x", 0) end)
    assert_error("bad arg type 4",
                 function () cr:set_source_rgba(0, 0, 0, "x") end)
end

function test_target ()
    local targ = cr:get_target()
    assert_userdata(targ)
    assert_equal("cairo surface object", targ._NAME)
end

function test_tolerance ()
    assert_error("bad type", function () cr:set_tolerance("foo") end)
    assert_equal(0.1, cr:get_tolerance(), "default intact after error")
    for _, v in ipairs({ 0.05, 1, 2, 23.5 }) do
        cr:set_tolerance(v)
        assert_equal(v, cr:get_tolerance())
    end
end

-- vi:ts=4 sw=4 expandtab