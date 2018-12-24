-- *** Farming_NextGen mod ***

farmingNG = {}
local path = minetest.get_modpath(minetest.get_current_modname())


dofile(path.."/settings.lua")
dofile(path.."/seeder.lua")

if  farmingNG.harvester_machine then
      dofile(path.."/harvester.lua")
end


-- The following is only on Jungle Server valid
if farmingNG.havetech then   
	-- compatibility alias
	minetest.register_alias("technic:seeder", "farming_nextgen:seeder")
end

