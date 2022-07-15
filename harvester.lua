-- The harvester

local S = farmingNG.S

    -- farming
	farmingNG.harvester_names["farming:artichoke_5"] = true
	farmingNG.harvester_names["farming:wheat_8"] = true
	farmingNG.harvester_names["farming:wheat_7"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:wheat_6"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:cotton_8"] = true
	farmingNG.harvester_names["farming:cotton_7"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:cotton_6"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:weed"] 	= false
	farmingNG.harvester_names["farming:pumpkin"]	= true
	farmingNG.harvester_names["farming:barley_7"]	= true
	farmingNG.harvester_names["farming:barley_6"]	= farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:barley_5"]	= farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:blueberry_4"]	= true
	farmingNG.harvester_names["farming:carrot_8"]	= true
	farmingNG.harvester_names["farming:chili_8"]	= true
	farmingNG.harvester_names["farming:coffee_5"]	= true
	farmingNG.harvester_names["farming:corn_8"]	= true
	farmingNG.harvester_names["farming:cucumber_4"]	= true
	farmingNG.harvester_names["farming:garlic_5"]	= true
	farmingNG.harvester_names["farming:hemp_8"]	= true
	farmingNG.harvester_names["farming:melon_8"]	= true
	farmingNG.harvester_names["farming:onion_5"]	= true
	farmingNG.harvester_names["farming:parsley_3"]	= true
	farmingNG.harvester_names["farming:pepper_5"]	= true					-- green
	farmingNG.harvester_names["farming:pepper_6"]	= true					-- yellow
	farmingNG.harvester_names["farming:pepper_7"]	= true					-- red
	farmingNG.harvester_names["farming:pineapple_8"]	= true
	farmingNG.harvester_names["farming:potato_4"]	= true
	farmingNG.harvester_names["farming:pumpkin_8"]	= true
	farmingNG.harvester_names["farming:raspberry_4"]	= true
	farmingNG.harvester_names["farming:rhubarb_3"]	= true
	farmingNG.harvester_names["farming:tomato_8"]	= true
	farmingNG.harvester_names["farming:grapes_8"]	= true
	farmingNG.harvester_names["farming:beanpole_5"]	= true
	farmingNG.harvester_names["farming:pea_5"]	= true
	farmingNG.harvester_names["farming:beetroot_5"]	= true
	farmingNG.harvester_names["farming:rice_8"] = true
	farmingNG.harvester_names["farming:rice_7"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:rice_6"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:oat_8"] = true
	farmingNG.harvester_names["farming:oat_7"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:oat_6"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:rye_8"] = true
	farmingNG.harvester_names["farming:rye_7"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:rye_6"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:cabbage_6"] = true
	farmingNG.harvester_names["farming:mint_4"] = true
	farmingNG.harvester_names["farming:lettuce_5"] = true
	farmingNG.harvester_names["farming:blackberry_4"] = true
	farmingNG.harvester_names["farming:soy_6"]	= farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:soy_7"]	= true
	farmingNG.harvester_names["farming:sunflower_8"] = true
	farmingNG.harvester_names["farming:vanilla_7"] = farmingNG.harvester_nofullg
	farmingNG.harvester_names["farming:vanilla_8"] = true
	farmingNG.harvester_names["farming:sunflower_8"] = true
	
    -- beer_test
    farmingNG.harvester_names["beer_test:oats_8"]	= true

    -- farming_plus
    farmingNG.harvester_names["farming_plus:melon"]	= true
	farmingNG.harvester_names["farming_plus:tomato"] = true
	farmingNG.harvester_names["farming_plus:chilli"] = true
	farmingNG.harvester_names["farming_plus:garlic"] = true
	farmingNG.harvester_names["farming_plus:soy_plant"] = true
	farmingNG.harvester_names["farming_plus:cucumber"] = true
	farmingNG.harvester_names["farming_plus:coffee"] = true
	farmingNG.harvester_names["farming_plus:potato"] = true
	farmingNG.harvester_names["farming_plus:carrot"] = true
	farmingNG.harvester_names["farming_plus:garlic"] = true
	farmingNG.harvester_names["farming_plus:rhubarb"]= true
	farmingNG.harvester_names["farming_plus:barley_7"]= true
	farmingNG.harvester_names["farming_plus:hemp_8"]= true
	farmingNG.harvester_names["farming_plus:beanpole_5"]= true
	farmingNG.harvester_names["farming_plus:grapes_8"]= true
	farmingNG.harvester_names["farming_plus:corn"]	= true
	farmingNG.harvester_names["farming_plus:cornb"]	= true
	farmingNG.harvester_names["farming_plus:cornc"]	= true
    
if not farmingNG.havetech then
      farmingNG.harvester_charge_per_node = math.floor(65535 / farmingNG.harvester_max_charge * farmingNG.harvester_charge_per_node)
      farmingNG.harvester_max_charge = 65535
end

-- Table for saving what was sawed down
local produced = {}

-- Save the items sawed down so that we can drop them in a nice single stack
local function handle_drops(drops)
	for _, item in ipairs(drops) do
		local stack = ItemStack(item)
		local name = stack:get_name()
		local p = produced[name]
		if not p then
			produced[name] = stack
		else
			p:set_count(p:get_count() + stack:get_count())
		end
	end
end


-- This function does all the hard work. Recursively we dig the node at hand
-- if it is in the table and then search the surroundings for more stuff to dig.
local function recursive_harvest(pos, remaining_charge)
	if remaining_charge < farmingNG.harvester_charge_per_node then
		return remaining_charge
	end
	local node = minetest.get_node(pos)

	if not farmingNG.harvester_names[node.name] then
		return remaining_charge
	end

	
	handle_drops(minetest.get_node_drops(node.name, ""))
	minetest.remove_node(pos)
	remaining_charge = remaining_charge - farmingNG.harvester_charge_per_node
	if remaining_charge < 1 then remaining_charge = 1 end

	-- Check surroundings and run recursively if any charge left
	for npos in farmingNG.iterSawTries(pos) do
		if remaining_charge < farmingNG.harvester_charge_per_node then
			break
		end
		if farmingNG.harvester_names[minetest.get_node(npos).name] then
			remaining_charge = recursive_harvest(npos, remaining_charge)
		end
	end
	return remaining_charge
end

-- Function to randomize positions for new node drops
local function get_drop_pos(pos)
	local drop_pos = {}

	for i = 0, 8 do
		-- Randomize position for a new drop
		drop_pos.x = pos.x + math.random(-3, 3)
		drop_pos.y = pos.y - 1
		drop_pos.z = pos.z + math.random(-3, 3)

		-- Move the randomized position upwards until
		-- the node is air or unloaded.
		for y = drop_pos.y, drop_pos.y + 5 do
			drop_pos.y = y
			local node = minetest.get_node_or_nil(drop_pos)

			if not node then
				-- If the node is not loaded yet simply drop
				-- the item at the original digging position.
				return pos
			elseif node.name == "air" then
				-- Add variation to the entity drop position,
				-- but don't let drops get too close to the edge
				drop_pos.x = drop_pos.x + (math.random() * 0.8) - 0.5
				drop_pos.z = drop_pos.z + (math.random() * 0.8) - 0.5
				return drop_pos
			end
		end
	end

	-- Return the original position if this takes too long
	return pos
end

--  entry point
local function harvester_dig(pos, current_charge)
	-- Start sawing things down
	local remaining_charge = recursive_harvest(pos, current_charge)
	minetest.sound_play("farming_nextgen_seeder", {pos = pos, gain = farmingNG.gain,
			max_hear_distance = 10})

	-- Now drop items for the player
	for name, stack in pairs(produced) do
		-- Drop stacks of stack max or less
		local count, max = stack:get_count(), stack:get_stack_max()
		stack:set_count(max)
		while count > max do
			minetest.add_item(get_drop_pos(pos), stack)
			count = count - max
		end
		stack:set_count(count)
		minetest.add_item(get_drop_pos(pos), stack)
	end

	-- Clean up
	produced = {}

	return remaining_charge
end


if farmingNG.havetech then
	if technic.plus then
		technic.register_power_tool("farming_nextgen:harvester", {
			description = S("Harvester"),
			inventory_image = "farming_nextgen_harvester.png",
			max_charge = farmingNG.harvester_max_charge,
			on_use = function(itemstack, user, pointed_thing)
				local name = user:get_player_name()

				if pointed_thing.type ~= "node" then
					return
				end

				local charge = technic.get_RE_charge(itemstack)
				if charge < farmingNG.harvester_charge_per_node then
					return
				end

				local pos_above_soil = vector.add(pointed_thing.under, { x = 0, y = 1, z = 0 })
				if minetest.is_protected(pos_above_soil, name) then
					minetest.record_protection_violation(pos_above_soil, name)
					return
				end

				-- Send current charge to digging function so that the
				-- harvester will stop after digging a number of nodes
				charge = harvester_dig(pointed_thing.under, charge)
				if not technic.creative_mode then
					technic.set_RE_charge(itemstack, charge)
					return itemstack
				end
			end,
		})
	else
		    
	  technic.register_power_tool("farming_nextgen:harvester", farmingNG.harvester_max_charge)



	  minetest.register_tool("farming_nextgen:harvester", {
		  description = S("Harvester"),
		  inventory_image = "farming_nextgen_harvester.png",
		  stack_max = 1,
		  wear_represents = "technic_RE_charge",
		  on_refill = technic.refill_RE_charge,
		  on_use = function(itemstack, user, pointed_thing)
		    local name = user:get_player_name()
		    
			
			  if pointed_thing.type ~= "node" then
				  return itemstack
			  end

			  local meta = minetest.deserialize(itemstack:get_metadata())
			  if not meta or not meta.charge or
					  meta.charge < farmingNG.harvester_charge_per_node then
				  return
			  end

			  
			  local pos_above_soil = vector.add(pointed_thing.under,
			                                    { x = 0, y = 1, z = 0 })
			  if minetest.is_protected(pos_above_soil, name) then
				  minetest.record_protection_violation(pos_above_soil, name)
				  return
			  end

			  -- Send current charge to digging function so that the
			  -- harvester will stop after digging a number of nodes
			  meta.charge = harvester_dig(pointed_thing.under, meta.charge)
			  if not technic.creative_mode then
				  technic.set_RE_wear(itemstack, meta.charge, farmingNG.harvester_max_charge)
				  itemstack:set_metadata(minetest.serialize(meta))
			  end
			  return itemstack
		    
			  
		  end,
	  })

	end

	local mesecons_button = minetest.get_modpath("mesecons_button")
	local trigger = mesecons_button and "mesecons_button:button_off" or "default:mese_crystal_fragment"

	minetest.register_craft({
		output = "farming_nextgen:harvester",
		recipe = {
			{"technic:battery",            trigger,                  "technic:battery"},
			{"technic:diamond_drill_head", "technic:machine_casing", "technic:diamond_drill_head"},
			{"technic:rubber",             "",                       "technic:rubber"},
		}
	})


else

		    
		    minetest.register_tool("farming_nextgen:harvester", {
			    description = S("Harvester"),
			    groups = {soil=3,soil=2},
			    inventory_image = "farming_nextgen_harvester.png",
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
						    charge < farmingNG.harvester_charge_per_node then
						    minetest.chat_send_player(name,S(" *** Your device needs to be serviced"))
					    return
				    end

        		    local pos_above_soil = vector.add(pointed_thing.under,
			                                        { x = 0, y = 1, z = 0 })
				    if minetest.is_protected(pos_above_soil, name) then
					    minetest.record_protection_violation(pos_above_soil, name)
					    return
				    end
				    
				    charge = harvester_dig(pointed_thing.under, charge)
				    itemstack:set_wear(65535-charge)
				    return itemstack
				    
			    end,
		    })

		    

		    minetest.register_craft({
			    output = "farming_nextgen:harvester",
			    recipe = {
				    {"default:diamondblock",                                    "default:mese_crystal_fragment",                      "default:diamondblock"              },
				    {"default:gold_ingot",      "default:bronze_ingot",              "default:gold_ingot"},
				    {"default:mese_crystal_fragment",                              "",                                 "default:mese_crystal_fragment"},
			    }
		    })
	  

	    
end
