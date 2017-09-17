-- *** Farming_NextGen mod ***


local path = minetest.get_modpath(minetest.get_current_modname())


dofile(path.."/seeder.lua")

if minetest.get_modpath("technic") then
	-- compatibility alias
	minetest.register_alias("technic:seeder", "farming_nextgen:seeder")
end

