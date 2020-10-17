-- *** Farming_NextGen mod ***

farmingNG = {}
local path = minetest.get_modpath(minetest.get_current_modname())

if(minetest.get_translator ~= nil) then
    farmingNG.S = minetest.get_translator(minetest.get_current_modname())
else
    farmingNG.S = function ( s ) return s end
end

farmingNG.seeder_seed = {}
farmingNG.seeder_utils = {}
farmingNG.harvester_names = {}

-- register_seed(Seed ,Plantname)
-- Seed = fully name of the seed like "farming:seed_cotton"
-- Plantname = fully Name of the plant like "farming:cotton_1"

function farmingNG.register_seed(seed, plant)
    if(seed ~= "" and plant ~= "") then
       local new_seed = {}
       new_seed = {seed, plant}
       table.insert(farmingNG.seeder_seed, new_seed)
       return true
    end
    
    return false
      
end -- register_seed

-- register_util(Seedling, Util)
-- Seedling = fully name of the seedling like "farming_nextgen:grape_seedling"
-- Plantname = fully Name of the tool like "farming_plus:grapes_1"

function farmingNG.register_util(seedling, util)
    if(seedling ~= "" and util ~= "") then
        local new_util = {}
        new_util = {seedling, util}
       table.insert(farmingNG.seeder_utils, new_util)
       return true
    end
    
    return false
      
end -- register_seed


dofile(path.."/settings.lua")
dofile(path.."/seeder.lua")

if  farmingNG.harvester_machine then
      dofile(path.."/harvester.lua")
      
    -- register_harvestername(plantname)
    -- Plantname = fully Name of the plant like "farming:cotton_8"
      
    function farmingNG.register_harvest(plantname)
        if(plantname ~= "") then
            farmingNG.harvester_names[plantname] = true
            return true
            
        end -- if(plantname
        
        return false
            
    end -- function farmingNG.register_harvestername
    
else
    function farmingNG.register_harvestername(plantname)
        return false
    
    end -- function farmingNG.register_harvestername
    
end -- if(farmingNG.harvester_maschine


-- The following is only on Jungle Server valid
if farmingNG.havetech then   
	-- compatibility alias
	minetest.register_alias("technic:seeder", "farming_nextgen:seeder")
end


print("[MOD] FarmingNG alias" .. minetest.get_current_modname() .. " loaded.")


