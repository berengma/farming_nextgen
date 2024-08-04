-- The plough


local function ploughing(pos, charge)
	if (not pos) then
		return charge
	end
	return charge
end

if farmingNG.havetech then
	if technic.plus then
		technic.register_power_tool("farming_nextgen:plough", {
			description = S("plough"),
			inventory_image = "farming_nextgen_plough.png",
			max_charge = farmingNG.plough_max_charge,
			on_use = function(itemstack, user, pointed_thing)
				local name = user:get_player_name()

				if pointed_thing.type ~= "node" then
					return
				end

				local charge = technic.get_RE_charge(itemstack)
				if charge < farmingNG.plough_charge_per_node then
					return
				end

				local pos_above_soil = vector.add(pointed_thing.under, { x = 0, y = 1, z = 0 })
				if minetest.is_protected(pos_above_soil, name) then
					minetest.record_protection_violation(pos_above_soil, name)
					return
				end

				charge = ploughing(pointed_thing.under, charge)
				if not technic.creative_mode then
					technic.set_RE_charge(itemstack, charge)
					return itemstack
				end
			end,
		})
	else
		    
	  technic.register_power_tool("farming_nextgen:plough", farmingNG.plough_max_charge)



	  minetest.register_tool("farming_nextgen:plough", {
		  description = S("plough"),
		  inventory_image = "farming_nextgen_plough.png",
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
					  meta.charge < farmingNG.plough_charge_per_node then
				  return
			  end

			  
			  local pos_above_soil = vector.add(pointed_thing.under,
			                                    { x = 0, y = 1, z = 0 })
			  if minetest.is_protected(pos_above_soil, name) then
				  minetest.record_protection_violation(pos_above_soil, name)
				  return
			  end

			  -- Send current charge to digging function so that the
			  -- plough will stop after digging a number of nodes
			  meta.charge = ploughing(pointed_thing.under, meta.charge)
			  if not technic.creative_mode then
				  technic.set_RE_wear(itemstack, meta.charge, farmingNG.plough_max_charge)
				  itemstack:set_metadata(minetest.serialize(meta))
			  end
			  return itemstack
		    
			  
		  end,
	  })

	end

	local mesecons_button = minetest.get_modpath("mesecons_button")
	local trigger = mesecons_button and "mesecons_button:button_off" or "default:mese_crystal_fragment"

	minetest.register_craft({
		output = "farming_nextgen:plough",
		recipe = {
			{"technic:battery",            trigger,                  "technic:battery"},
			{"technic:diamond_drill_head", "technic:machine_casing", "technic:diamond_drill_head"},
			{"technic:rubber",             "",                       "technic:rubber"},
		}
	})


else

		    
		    minetest.register_tool("farming_nextgen:plough", {
			    description = S("plough"),
			    groups = {soil=3,soil=2},
			    inventory_image = "farming_nextgen_plough.png",
			    stack_max=1,
			    liquids_pointable = false,
			    on_use = function(itemstack, user, pointed_thing)
			      local seednum=0
			      local name = user:get_player_name()
				  local meta = itemstack:get_meta();
			      local privs = minetest.get_player_privs(name)
			      
				 
				    if pointed_thing.type ~= "node" then
					    return itemstack
				    end

				    local charge = 65535 - itemstack:get_wear()
				    
				    if not charge or  
						    charge < farmingNG.plough_charge_per_node then
						    minetest.chat_send_player(name,S(" *** Your device needs to be serviced"))
					    return
				    end

					if not meta or not (meta:contains("pos1") and meta:contains("pos2")) then
						return itemstack
					end

        		    local pos_above_soil = vector.add(pointed_thing.under,
			                                        {x = 0, y = 1, z = 0})
				    if minetest.is_protected(pos_above_soil, name) then
					    minetest.record_protection_violation(pos_above_soil, name)
					    return
				    end
				    
				    charge = ploughing(pointed_thing.under, charge)
				    itemstack:set_wear(65535-charge)
				    return itemstack
				    
			    end,
		    })

		    

		    minetest.register_craft({
			    output = "farming_nextgen:plough",
			    recipe = {
				    {"default:diamondblock",			"default:mese_crystal_fragment",	"default:diamondblock"},
				    {"default:gold_ingot",				"default:bronze_ingot",				"default:gold_ingot"},
				    {"default:mese_crystal_fragment",	"",									"default:mese_crystal_fragment"},
			    }
		    })
	  

	    
end
