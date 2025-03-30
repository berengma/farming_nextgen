--
-- The settings section for seeder
--
-- Is technic mod present ? If not use wearout tool instead
--
farmingNG.havetech = core.get_modpath("technic")

-- Maximum charge of the seeder 
farmingNG.seeder_max_charge = 
	tonumber(core.settings:get("farmingNG_seeder_max_charge")) or 900000

-- How much it costs to place a seed
farmingNG.seeder_charge_per_node =
	tonumber(core.settings:get("farmingNG_seeder_charge_per_node")) or 1800

-- more verbose chat messages
farmingNG.chaton = core.settings:get_bool("farmingNG_chaton", false)

-- easy recipe if technic mod is present
farmingNG.easy = core.settings:get_bool("farmingNG_easy", false)

-- Maximum charge of the harvester
farmingNG.harvester_max_charge =
	tonumber(core.settings:get("farmingNG_harvester_max_charge")) or 650000

-- Costs of harvesting one node
farmingNG.harvester_charge_per_node = 
	tonumber(core.settings:get("farmingNG_harvester_charge_per_node")) or 1300

-- make the tool available
farmingNG.harvester_machine = 
	core.settings:get_bool("farmingNG_harvester_machine", true)

-- harvests also wheat_7, rice_7 etc no need to wait until full grown 
farmingNG.harvester_nofullg =
	core.settings:get_bool("farmingNG_harvester_nofullg", true)

-- control sound volume
farmingNG.gain = tonumber(core.settings:get("farmingNG_gain")) or 0.5

-- enable the plough
farmingNG.plough_machine =
	core.settings:get_bool("farmingNG_enable_plough_machine", true)

-- Maximum charge of the plough 
farmingNG.plough_max_charge =
	tonumber(core.settings:get("farmingNG_plough_max_charge")) or 600000

-- Costs of ploughing one node of soil
farmingNG.plough_charge_per_node = 
	tonumber(core.settings:get("farmingNG_plough_charge_per_node")) or 2000

-- auto set water nodes for soil
farmingNG.plough_set_water_nodes =
	core.settings:get_bool("farmingNG_plough_auto_set_water_node", true)

-- Cleanup decorations above soil
farmingNG.plough_cleanup =
	core.settings:get_bool("farmingNG_plough_cleanup_deco", true)

-- Show plough position markers in seconds
farmingNG.show_plough_pos =
	tonumber(core.settings:get("farmingNG_show_plough_pos_time")) or 15