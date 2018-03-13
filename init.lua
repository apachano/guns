guns = {}

guns.path = minetest.get_modpath("guns")

dofile(guns.path ..'/functions.lua')
dofile(guns.path ..'/hud.lua')