--*******************************************************
--****                 The Seeder
--**** All coding made by Gundul except recursive_dig 
--**** was taken from technic:chainsaw mod coded by
--**** Maciej Kasatkin (RealBadAngel)
--*******************************************************


-- different values if technic not present
if not farmingNG.havetech then
      farmingNG.seeder_charge_per_node = math.floor(65535 / farmingNG.seeder_max_charge * farmingNG.seeder_charge_per_node)
      farmingNG.seeder_max_charge = 65535
end


-- grapes and beans from farming_plus need helpers to grow
if minetest.get_modpath("farming_plus") then
  
      minetest.register_craftitem("farming_nextgen:grape_seedling", {
	    description = "A grape seedling for the seeder",
	    inventory_image = "farming_grapes_1.png"
      })

      minetest.register_craftitem("farming_nextgen:bean_seedling", {
	    description = "A bean seedling for the seeder",
	    inventory_image = "farming_beanpole_1.png"
      })
      
      minetest.register_craft({
		  type = "shapeless",
		  output = "farming_nextgen:grape_seedling",
		  recipe = {"farming_plus:trellis","farming_plus:grapes"}
      })
      
      minetest.register_craft({
		  type = "shapeless",
		  output = "farming_nextgen:bean_seedling",
		  recipe = {"farming_plus:beanpole","farming_plus:beans"}
      })
end



-- The default soils
local soil_nodenames = {
	["farming:soil"] 	 	= true,
	["farming:soil_wet"] 		= true,
	["farming:desert_sand_soil"]    = true,
	["farming:desert_sand_soil_wet"]= true
}

-- the seed library {    name of seed, name after beeing planted  }
local seeder_seed = {
-- *** farming
	    {"farming:seed_barley", "farming:barley_1"},
	    {"farming:seed_hemp", "farming:hemp_1"},
	    {"farming:pumpkin_seed", "farming:pumpkin_1"},
	    {"farming:coffee_beans", "farming:coffee_1"},
	    {"farming:chili_pepper", "farming:chili_1"},
	    
-- *** farming_plus
	    {"farming_plus:carrot_seed", "farming_plus:carrot_1"},
	    {"farming_plus:chilli_seeds", "farming_plus:chilli_1"},
	    {"farming_plus:coffee_beans", "farming_plus:coffee_1"},
	    {"farming_plus:corn_seed", "farming_plus:corn_1"},
	    {"farming_plus:cucumber_seed", "farming_plus:cucumber_1"},
	    {"farming_plus:garlic_seed", "farming_plus:garlic_1"},
	    {"farming_plus:seed_hemp", "farming_plus:hemp_1"},
	    {"farming_plus:melon_seed", "farming_plus:melon_1"},
	    {"farming_plus:potato_seed", "farming_plus:potato_1"},
	    {"farming_plus:rhubarb_seed", "farming_plus:rhubarb_1"},
	    {"farming_plus:raspberry_seed", "farming_plus:raspberry_1"},
	    {"farming_plus:strawberry_seed", "farming_plus:strawberry_1"},
	    {"farming_plus:soy_seed", "farming_plus:soy_plant_1"},
	    {"farming_plus:tomato_seed", "farming_plus:tomato_1"},
	    {"farming_plus:walnut_item", "farming_plus:walnut_1"},
	    {"farming_plus:orange_seed", "farming_plus:orange_1"},
	    {"farming_plus:lemon_seed", "farming_plus:lemon_1"},
	    {"farming_plus:peach_seed", "farming_plus:peach_1"},
	    {"farming_plus:seed_barley", "farming_plus:barley_1"},
	    {"farming_plus:coffee_beans", "farming_plus:coffee_1"},
	
-- *** beer_test
	    {"beer_test:seed_oats", "beer_test:seed_oats"},

-- If you have Problems with growing wheat and cotton, then try the two lines below
	    {"farming:seed_wheat", "farming:wheat_1"},
	    {"farming:seed_cotton", "farming:cotton_1"}

-- If you haven't any Problems with growing wheat and cotton, then use the two lines below
--	    {"farming:seed_wheat", "farming:seed_wheat"},
--	    {"farming:seed_cotton", "farming:seed_cotton"}
	    
}

local seeder_utils = {
  {"farming_nextgen:grape_seedling", "farming_plus:grapes_1"},
  {"farming_nextgen:bean_seedling", "farming_plus:beanpole_1"}
}



local function check_valid_util(sname)
     for i in ipairs(seeder_utils) do
      if sname == seeder_utils[i][1] then return true end
     end
    return false
end

	    

-- function to check for valid seeds
local function check_valid_seed(sname)
  
    for i in ipairs(seeder_seed) do
      if sname == seeder_seed[i][1] then return true end
    end
    return false
end

--function to give name of seedlings
local function give_seedling(sname, util)

     if not util then
	  for i in ipairs(seeder_seed) do
	    if sname == seeder_seed[i][1] then return seeder_seed[i][2] end
	  end
     else
	  for i in ipairs(seeder_utils) do
	    if sname == seeder_utils[i][1] then return seeder_utils[i][2] end
	  end
     end
    return nil
end

--- Iterator over positions to try to saw around a sawed node.
-- This returns positions in a 3x1x3 area around the position, plus the
-- position above it.  This does not return the bottom position to prevent
-- the seeder from cutting down nodes below the cutting position.
-- @param pos Sawing position.
function farmingNG.iterSawTries(pos)
	-- Copy position to prevent mangling it
	local pos = vector.new(pos)
	local i = 0

	return function()
		i = i + 1
		-- Given a (top view) area like so (where 5 is the starting position):
		-- X -->
		-- Z 123
		-- | 456
		-- V 789
		-- This will return positions 1, 4, 7, 2, 8 (skip 5), 3, 6, 9,
		-- and the position above 5.
		if i == 1 then
			-- Move to starting position
			pos.x = pos.x - 1
			pos.z = pos.z - 1
		elseif i == 4 or i == 7 then
			-- Move to next X and back to start of Z when we reach
			-- the end of a Z line.
			pos.x = pos.x + 1
			pos.z = pos.z - 2
		elseif i == 5 then
			-- Skip the middle position (we've already run on it)
			-- and double-increment the counter.
			pos.z = pos.z + 2
			i = i + 1
		elseif i <= 9 then
			-- Go to next Z.
			pos.z = pos.z + 1
		elseif i == 10 then
			-- Move back to center and up.
			-- The Y+ position must be last so that we don't dig
			-- straight upward and not come down (since the Y-
			-- position isn't checked).
			pos.x = pos.x - 1
			pos.z = pos.z - 1
			pos.y = pos.y + 1
		else
			return nil
		end
		return pos
	end
end

-- This function does all the hard work. Recursively we dig the node at hand
-- if it is in the table and then search the surroundings for more stuff to dig.
local function recursive_dig(pos, remaining_charge, seednum,seedstack, user)
	local uppos = {x =pos.x, y =(pos.y) +1,z =pos.z}
	local toppos = {x =pos.x, y =(pos.y) +2,z =pos.z}
	local name = user:get_player_name()
	
	if remaining_charge < farmingNG.seeder_charge_per_node or seedstack:is_empty() then
		return remaining_charge, seednum, seedstack
	end
	local node = minetest.get_node(pos)
	local upper = minetest.get_node(uppos)
	local top = minetest.get_node(toppos)
	local seedname = seedstack:get_name()
	local helpers = check_valid_util(upper.name)
	
	if node.name == "farming:weed" then
	    remaining_charge, seednum, seedstack = recursive_dig( {x=pos.x, y=pos.y-1, z=pos.z}, remaining_charge, seednum, seedstack, user)
	    return remaining_charge, seednum, seedstack
	end

	if not soil_nodenames[node.name] then
		return remaining_charge, seednum, seedstack
	end	
	
	if not check_valid_util(seedname) then
	      if upper.name == "air" or upper.name == "farming:weed" then
		    minetest.set_node(uppos, {name="air"})
		    remaining_charge = remaining_charge - farmingNG.seeder_charge_per_node
		    seednum = seednum +1
		    seedstack:take_item()
		    
		    if give_seedling(seedname,false) then
			  minetest.add_node(uppos, {name = give_seedling(seedname,false), param2 = 1})
			  minetest.get_node_timer(uppos):start(math.random(166, 286))
		    end
	      else
		    return remaining_charge, seednum, seedstack
	      end
	else
	     if (upper.name == "air" or upper.name == "farming:weed") and top.name == "air" then 
		    minetest.set_node(uppos, {name="air"})
		    remaining_charge = remaining_charge - farmingNG.seeder_charge_per_node
		    seednum = seednum +1
		    seedstack:take_item()
		    
		    if give_seedling(seedname, true) then
			  minetest.add_node(uppos, {name = give_seedling(seedname, true), param2 = 1})
			  minetest.get_node_timer(uppos):start(math.random(166, 286))
		    end
	     else
		    return remaining_charge, seednum, seedstack
	     end
	end

	-- Check surroundings and run recursively if any charge left
	for npos in farmingNG.iterSawTries(pos) do
		if remaining_charge < farmingNG.seeder_charge_per_node then
			break
		end
		if soil_nodenames[minetest.get_node(npos).name] then
			remaining_charge, seednum, seedstack = recursive_dig(npos, remaining_charge, seednum, seedstack, user)
		end
	end
	return remaining_charge, seednum, seedstack
end



-- Seeder entry point
local function seeder_dig(pos, current_charge, seednum, seedstack, user)
	-- Start sawing things down
	local remaining_charge, seednum, seedstack = recursive_dig(pos, current_charge, seednum, seedstack, user)
	minetest.sound_play("farming_nextgen_seeder", {pos = pos, gain = 1.0, max_hear_distance = 10})
	return remaining_charge, seednum, seedstack
end


if farmingNG.havetech then
  
	  local S = technic.getter

	  technic.register_power_tool("farming_nextgen:seeder", farmingNG.seeder_max_charge)


	  minetest.register_tool("farming_nextgen:seeder", {
		  description = S("Seed Machine"),
		  inventory_image = "farming_nextgen_seeder.png",
		  stack_max = 1,
		  wear_represents = "technic_RE_charge",
		  on_refill = technic.refill_RE_charge,
		  on_use = function(itemstack, user, pointed_thing)
		    local seednum=0
		    local name = user:get_player_name()
		    local privs = minetest.get_player_privs(name)
		    
			
			  if pointed_thing.type ~= "node" then
				  return itemstack
			  end

			  local meta = minetest.deserialize(itemstack:get_metadata())
			  if not meta or not meta.charge or
					  meta.charge < farmingNG.seeder_charge_per_node then
				  return
			  end

			  local inv = user:get_inventory()
			  local indexnumber = user:get_wield_index()+1
			  local seedstack = inv:get_stack("main", indexnumber)
			  local seedname = seedstack:get_name()

			  
			  
			  if minetest.is_protected(pointed_thing.under, name) then
				  minetest.record_protection_violation(pointed_thing.under, name)
				  return
			  end

			  -- Send current charge to digging function so that the
			  -- seeder will stop after digging a number of nodes
			  if seedname then
			    
			    if check_valid_seed(seedname) or check_valid_util(seedname) then
				meta.charge, seednum, seedstack = seeder_dig(pointed_thing.under, meta.charge, seednum, seedstack, user)
				minetest.chat_send_player(name,"*** You used :  "..seednum.." seeds")
			    else
				minetest.chat_send_player(name," *** you need valid seeds on the right side of your device")
			    end
			    
			    
			      
			  else
			      minetest.chat_send_player(name," *** you need valid seeds on the right side of your device")
			  end
			  
			  if not technic.creative_mode then
				  technic.set_RE_wear(itemstack, meta.charge, farmingNG.seeder_max_charge)
				  itemstack:set_metadata(minetest.serialize(meta))
			  end
			  inv:set_stack("main", indexnumber, seedstack)
			  return itemstack
		    
			  
		  end,
	  })

	  local mesecons_button = minetest.get_modpath("mesecons_button")
	  local trigger = mesecons_button and "mesecons_button:button_off" or "default:mese_crystal_fragment"

	  if farmingNG.easy then
		    minetest.register_craft({
			    output = "farming_nextgen:seeder",
			    recipe = {
				    {"technic:battery",                                    trigger,                      "technic:battery"              },
				    {"technic:stainless_steel_ingot",      "technic:stainless_steel_ingot",              "technic:stainless_steel_ingot"},
				    {"default:diamond",                              "",                                 "default:diamond"},
			    }
		    })
	  else
		    minetest.register_craft({
				    output = "farming_nextgen:seeder",
				    recipe = {
					    {"technic:red_energy_crystal",                                    trigger,                      "technic:red_energy_crystal"              },
					    {"technic:composite_plate",      "technic:composite_plate",              "technic:composite_plate"},
					    {"technic:rubber",                              "",                                 "technic:rubber"},
				    }
			    })
	  end
	  
else
	      
	  
	  minetest.register_tool("farming_nextgen:seeder", {
		  description = "Automatik seeding tool",
		  groups = {soil=3,soil=2},
		  inventory_image = "farming_nextgen_seeder.png",
		  stack_max=1,
		  liquids_pointable = false,
		  on_use = function(itemstack, user, pointed_thing)
		    local seednum=0
		    local name = user:get_player_name()
		    local privs = minetest.get_player_privs(name)
		    
			  
			  if pointed_thing.type ~= "node" then
				  return itemstack
			  end

			  local charge = 65535 - itemstack:get_wear()
			  
			  if not charge or  
					  charge < farmingNG.seeder_charge_per_node then
				  return
			  end

			  local inv = user:get_inventory()
			  local indexnumber = user:get_wield_index()+1
			  local seedstack = inv:get_stack("main", indexnumber)
			  local seedname = seedstack:get_name()

			  
			  
			  if minetest.is_protected(pointed_thing.under, name) then
				  minetest.record_protection_violation(pointed_thing.under, name)
				  return
			  end

			  
			  
			  if seedname then
			    if check_valid_seed(seedname) or check_valid_util(seedname) then
				charge, seednum, seedstack = seeder_dig(pointed_thing.under, charge, seednum, seedstack, user)
				if farmingNG.chaton then
				     minetest.chat_send_player(name,"*** You used :  "..seednum.." seeds     ".."Charge for "..math.floor(charge/farmingNG.seeder_charge_per_node).." seeds left")
				end
			    else
				minetest.chat_send_player(name," *** you need valid seeds on the right side of your device")
			    end
			  else
			      minetest.chat_send_player(name," *** you need valid seeds on the right side of your device")
			  end
			  
			  
			  itemstack:set_wear(65535-charge)
			  
			  inv:set_stack("main", indexnumber, seedstack)
			  return itemstack
		    
			  
		  end,
	  })

	  

	  minetest.register_craft({
		  output = "farming_nextgen:seeder",
		  recipe = {
			  {"default:mese",                                    "default:mese_crystal_fragment",                      "default:mese"              },
			  {"default:gold_ingot",      "default:bronze_ingot",              "default:gold_ingot"},
			  {"default:diamond",                              "",                                 "default:diamond"},
		  }
	  })
end

  
