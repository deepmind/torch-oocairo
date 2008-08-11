#include <cairo.h>
#include <lua.h>
#include <lauxlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>

int luaopen_oocairo (lua_State *L);

#define MT_NAME_CONTEXT ("6404c570-6711-11dd-b66f-00e081225ce5")
#define MT_NAME_SURFACE ("6d31a064-6711-11dd-bdd8-00e081225ce5")
/*
6d83bf34-6711-11dd-b4c2-00e081225ce5
6dd49a26-6711-11dd-88fd-00e081225ce5
6e2f4c64-6711-11dd-acfc-00e081225ce5
*/

static const char * const format_option_names[] = {
    "argb32", "rgb24", "a8", "a1", 0
};
static const cairo_format_t format_option_values[] = {
    CAIRO_FORMAT_ARGB32, CAIRO_FORMAT_RGB24, CAIRO_FORMAT_A8, CAIRO_FORMAT_A1
};

static const char * const linecap_names[] = {
    "butt", "round", "square", 0
};
static const cairo_line_cap_t linecap_values[] = {
    CAIRO_LINE_CAP_BUTT, CAIRO_LINE_CAP_ROUND, CAIRO_LINE_CAP_SQUARE
};

#include "obj_surface.c"
#include "obj_context.c"

static const luaL_Reg
constructor_funcs[] = {
    { "image_surface_create", image_surface_create },
    { "context_create", context_create },
    { 0, 0 }
};

static void
add_funcs_to_table (lua_State *L, const luaL_Reg *funcs) {
    const luaL_Reg *l;
    for (l = funcs; l->name; ++l) {
        lua_pushstring(L, l->name);
        lua_pushcfunction(L, l->func);
        lua_rawset(L, -3);
    }
}

static void
create_object_metatable (lua_State *L, const char *mt_name,
                         const char *debug_name, const luaL_Reg *methods)
{
    if (luaL_newmetatable(L, mt_name)) {
        lua_pushliteral(L, "_NAME");
        lua_pushstring(L, debug_name);
        lua_rawset(L, -3);
        add_funcs_to_table(L, methods);
        lua_pushliteral(L, "__index");
        lua_pushvalue(L, -2);
        lua_rawset(L, -3);
    }
    lua_pop(L, 1);
}

int
luaopen_oocairo (lua_State *L) {
#ifdef VALGRIND_LUA_MODULE_HACK
    /* Hack to allow Valgrind to access debugging info for the module. */
    luaL_getmetatable(L, "_LOADLIB");
    lua_pushnil(L);
    lua_setfield(L, -2, "__gc");
    lua_pop(L, 1);
#endif

    /* Create the table to return from 'require' */
    lua_createtable(L, 0, 3);
    lua_pushliteral(L, "_NAME");
    lua_pushliteral(L, "cairo");
    lua_rawset(L, -3);
    lua_pushliteral(L, "_VERSION");
    lua_pushliteral(L, VERSION);
    lua_rawset(L, -3);
    add_funcs_to_table(L, constructor_funcs);

    /* Create the metatables for objects of different types. */
    create_object_metatable(L, MT_NAME_CONTEXT, "cairo context object",
                            context_methods);
    create_object_metatable(L, MT_NAME_SURFACE, "cairo surface object",
                            surface_methods);

    return 1;
}

/* vi:set ts=4 sw=4 expandtab: */
