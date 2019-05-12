--
-- The settings section for seeder
--
--
-- 
farmingNG.havetech = minetest.get_modpath("technic")		-- Is technic mod present ? If not use wearout tool instead
--
--
farmingNG.seeder_max_charge      = 900000 			-- Maximum charge of the seeder 
farmingNG.seeder_charge_per_node = 1800				-- How much it costs to place a seed
--
farmingNG.chaton = false					-- more verbose chat messages
farmingNG.easy = false						-- easy recipe if technic mod is present
--
farmingNG.harvester_max_charge      = 650000 			-- Maximum charge of the harvester
farmingNG.harvester_charge_per_node = 1300 			-- Costs of harvesting one node
farmingNG.harvester_machine 	= true				-- make the tool available
farmingNG.harvester_nofullg     = true				-- harvests also wheat_7, rice_7 etc no need to wait until full grown 


minetest.register_node(":farming:soil", {
	description = "Soil",
	tiles = {"default_dirt.png^farming_soil.png", "default_dirt.png"},
	drop = "default:dirt",
	groups = {crumbly=3, not_in_creative_inventory=1, soil=2, grassland = 1, field = 1},
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "farming:soil",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.register_node(":farming:soil_wet", {
	description = "Wet Soil",
	tiles = {"default_dirt.png^farming_soil_wet.png", "default_dirt.png^farming_soil_wet_side.png"},
	drop = "default:dirt",
	groups = {crumbly=3, not_in_creative_inventory=1, soil=3, wet = 1, grassland = 1, field = 1},
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "farming:soil",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.register_node(":farming:desert_sand_soil", {
	description = "Desert Sand Soil",
	drop = "default:desert_sand",
	tiles = {"farming_desert_sand_soil.png", "default_desert_sand.png"},
	groups = {crumbly=3, not_in_creative_inventory = 1, falling_node=1, sand=1, soil = 2, desert = 1, field = 1},
	sounds = default.node_sound_sand_defaults(),
	soil = {
		base = "farming:desert_sand_soil",
		dry = "farming:desert_sand_soil",
		wet = "farming:desert_sand_soil_wet"
	}
})

minetest.register_node(":farming:desert_sand_soil_wet", {
	description = "Wet Desert Sand Soil",
	drop = "default:desert_sand",
	tiles = {"farming_desert_sand_soil_wet.png", "farming_desert_sand_soil_wet_side.png"},
	groups = {crumbly=3, falling_node=1, sand=1, not_in_creative_inventory=1, soil=3, wet = 1, desert = 1, field = 1},
	sounds = default.node_sound_sand_defaults(),
	soil = {
		base = "farming:desert_sand_soil",
		dry = "farming:desert_sand_soil",
		wet = "farming:desert_sand_soil_wet"
	}
})
