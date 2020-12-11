--
-- The settings section for seeder
--
--
-- 
farmingNG.havetech = minetest.get_modpath("technic")		-- Is technic mod present ? If not use wearout tool instead
--
--
farmingNG.seeder_max_charge      = tonumber(minetest.settings:get("farmingNG_seeder_max_charge")) or 900000					-- Maximum charge of the seeder 
farmingNG.seeder_charge_per_node = tonumber(minetest.settings:get("farmingNG_seeder_charge_per_node")) or 1800				-- How much it costs to place a seed
--
farmingNG.chaton = minetest.settings:get_bool("farmingNG_chaton", false)												-- more verbose chat messages
farmingNG.easy = minetest.settings:get_bool("farmingNG_easy", false)													-- easy recipe if technic mod is present
--
farmingNG.harvester_max_charge     	= tonumber(minetest.settings:get("farmingNG_harvester_max_charge")) or 650000 			-- Maximum charge of the harvester
farmingNG.harvester_charge_per_node	= tonumber(minetest.settings:get("farmingNG_harvester_charge_per_node")) or 1300 		-- Costs of harvesting one node
farmingNG.harvester_machine 			= minetest.settings:get_bool("farmingNG_harvester_machine", true)    					-- make the tool available
farmingNG.harvester_nofullg    		= minetest.settings:get_bool("farmingNG_harvester_nofullg", true)    					-- harvests also wheat_7, rice_7 etc no need to wait until full grown 
farmingNG.gain						= tonumber(minetest.settings:get("farmingNG_gain")) or 0.5							-- control sound volume
