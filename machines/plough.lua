-- The plough

local S = function(T)
	return T
end

minetest.register_entity("farming_nextgen:pos", 
{
		visual = "cube",
        collide_with_objects = false,                  
		visual_size = {x=1.1, y=1.1},
		textures = {"farming_nextgen_pos.png", "farming_nextgen_pos.png",
			"farming_nextgen_pos.png", "farming_nextgen_pos.png",
			"farming_nextgen_pos.png", "farming_nextgen_pos.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
		physical = false,
		pointable = false,
		lifetime = farmingNG.show_plough_pos,
		on_step = function(self, dtime)
			if self.lifetime > 0 then
				self.lifetime = self.lifetime - dtime
				return
			end
			self.object:remove()
		end,
})

local orange = function(text)
	return core.colorize("#ff8c00", text)
end

local function debug(current, pos1, pos2)
	minetest.chat_send_all(orange("Current: "..dump(current)))
	if pos1 then
		minetest.chat_send_all("Pos1: " ..minetest.pos_to_string(pos1))
	else
		minetest.chat_send_all("Pos1: NIL")
	end
	if pos2 then
		minetest.chat_send_all("Pos2: " ..minetest.pos_to_string(pos2))
	else
		minetest.chat_send_all("Pos2: NIL")
	end
end

local function delete_pos(pos)
	local objects = minetest.get_objects_inside_radius(pos, 1)

	for i = 1, #objects, 1 do
		local obj = objects[i]
		if (obj:get_luaentity().name == "farming_nextgen:pos") then
			obj:remove()
		end
	end
end

local function is_valid(pos1, pos2, name)
	if not pos1 or not pos2 then
		if name then
			minetest.chat_send_player(name, orange("One or more positions not set."))
		end
		return false
	end
	if (pos1.y ~= pos2.y ) then
		if name then
			minetest.chat_send_player(name, orange("You have to use your plough on level."))
		end
		return false
	end
	if (math.abs(pos1.x - pos2.x) * math.abs(pos1.z - pos2.z) > 
		(farmingNG.plough_max_charge / farmingNG.plough_charge_per_node)) then
			if name then
				minetest.chat_send_player(name, orange("Choosen area is too big."))
			end
			return false
	end
	return true
end

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
	    groups = {soil = 2, crumbly = 1},
	    inventory_image = "farming_nextgen_plough.png",
	    stack_max = 1,
	    liquids_pointable = false,
		on_place = function(itemstack, placer, pointed_thing)
	    	local name = placer:get_player_name()
			local meta = itemstack:get_meta()
			local current = meta:get_int("current")
			local pos1 = minetest.deserialize(meta:get("pos1"))
			local pos2 = minetest.deserialize(meta:get("pos2"))

			--debug(current, pos1, pos2)
			if pointed_thing.type ~= "node" then
				return itemstack
			end
			if current < 2 then
				if pos1 then
					delete_pos(pos1)
				end
				pos1 = pointed_thing.under
				if  pos2 and (vector.distance(pos1, pos2) == 0) then
					meta:set_string("pos1","")
					meta:set_string("pos2","")
					meta:set_int("current", 1)
					delete_pos(pos1)	
					return itemstack
				end
				meta:set_string("pos1", minetest.serialize(pos1))
				if (not is_valid(pos1, pos2, name)) then
					meta:set_string("pos2", "")
				end
				minetest.add_entity(pos1, "farming_nextgen:pos")
				meta:set_int("current", 2)
				return itemstack
			end
			if current == 2 then
				if pos2 then
					delete_pos(pos2)
				end
				pos2 = pointed_thing.under
				if (vector.distance(pos1, pos2) == 0) then
					meta:set_string("pos1","")
					meta:set_string("pos2","")
					meta:set_int("current", 1)
					delete_pos(pos1)	
					return itemstack
				end
				meta:set_string("pos2", minetest.serialize(pos2))
				if (not is_valid(pos1, pos2, name)) then
					meta:set_string("pos2", "")
					meta:set_int("current", 2)
					return itemstack
				end
				minetest.add_entity(pos1, "farming_nextgen:pos")
				minetest.add_entity(pos2, "farming_nextgen:pos")
				meta:set_int("current", 1)
			end
			return itemstack
		end,

	    on_use = function(itemstack, user, pointed_thing)
	      local name = user:get_player_name()
		  local meta = itemstack:get_meta()
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