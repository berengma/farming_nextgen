-- The plough

local S = function(T)
	return T
end

local perNode = 65535 / (farmingNG.plough_max_charge / farmingNG.plough_charge_per_node)

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

local function getDecorations()
	local deco = {}
		for name, def in pairs(minetest.registered_nodes) do
			if def.groups["plant"] or def.groups["seed"] or def.groups["grass"] or def.groups["flower"] then
				table.insert(deco, name)
			end
		end
	return deco
end

farmingNG.deco = getDecorations()

local orange = function(text)
	return core.colorize("#ff8c00", text)
end

local green = function(text)
	return core.colorize("#63ca00", text)
end

local function plough(min, max, charge)
	local x = 0
	local z = 0

	if (not min or not max) then
		return charge
	end
	min, max = vector.sort(min, max)
	x = min.x
	while (x <= max.x) and (charge > 0) do
		z = min.z
		while (z <= max.z) and (charge > 0) do
			local tmp = vector.new(x, min.y, z)
			local water = vector.new(x, min.y - 1, z)
			local sec = vector.new(x, min.y - 2, z)

			--minetest.add_entity(tmp, "farming_nextgen:pos")
			minetest.set_node(tmp, {name = "farming:soil_wet"})
			if farmingNG.plough_set_water_nodes then
				if ((math.fmod(max.z - z, 4) == 0) or
					(math.fmod(max.x - x, 4) == 0)) and
					not minetest.find_node_near(tmp, 3,
					{name = 'default:water_source'}) then
						minetest.set_node(water, {name = "default:water_source"})
						minetest.set_node(sec, {name = "default:stone"})
				end
			end
			z = z + 1
			if farmingNG.havetech then
				charge = charge - farmingNG.plough_charge_per_node
			else
				charge = charge - perNode
			end
		end
		x = x + 1
	end
	if charge <= 0 then
		charge = 1
	end
	return charge
end

local function isInArea(pos, min, max)
	if (not pos or not min or not max) then
		return false
	end
	min, max = vector.sort(min, max)
	return vector.in_area(pos, min, max)
end

local function isAreaClean(min, max)
	local volume = 0
	local nodes = 0

	if (not min or not max) then
		return false
	end
	min, max = vector.sort(min, max)
	volume = (1 + max.x - min.x) * (1 + max.z - min.z)
	nodes = #minetest.find_nodes_in_area_under_air(min, max, "group:soil")
	--minetest.chat_send_all("CNT: "..volume.."  REL: "..nodes)
	return (volume == nodes)
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
		if obj and not obj:is_player() and (obj:get_luaentity().name == "farming_nextgen:pos") then
			obj:remove()
		end
	end
end

local function showMarkers(pos1, pos2)
	if (not pos1 and not pos2) then
		return
	end
	if pos1 then
		delete_pos(pos1)
		minetest.add_entity(pos1, "farming_nextgen:pos")
	end
	if pos2 then
		delete_pos(pos2)
		minetest.add_entity(pos2, "farming_nextgen:pos")
	end
end

local function isNearArea(pos, min, max)
	local volume = 0

	if not pos or not min or not max then
		return false
	end
	min, max = vector.sort(min, max)
	volume = (1 + max.x - min.x) * (1 + max.z - min.z)
	return ((vector.distance(pos, min) < math.sqrt(volume)) or
			(vector.distance(pos, max) < math.sqrt(volume)))
end

local function is_valid(pos1, pos2, name)
	local checkAreaDown = pos2
	local checkAreaUp = pos1
	if checkAreaDown and farmingNG.plough_set_water_nodes then
		checkAreaDown = vector.add(pos2, vector.new(0, -3, 0))
	end
	if checkAreaUp then
		checkAreaUp = vector.add(pos1, vector.new(0, 2, 0))
	end
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
	if minetest.is_area_protected(checkAreaUp, checkAreaDown, name or "", 1) then
		if name then
			minetest.chat_send_player(name, orange("There are already protections in this area"))
		end
		return false
	end 

	return true
end

local onPlace =  function(itemstack, placer, pointed_thing)
   	local name = placer:get_player_name()
	local meta = itemstack:get_meta()
	local node = nil
	local current = meta:get_int("current")
	local pos1 = minetest.deserialize(meta:get("pos1"))
	local pos2 = minetest.deserialize(meta:get("pos2"))

	--debug(current, pos1, pos2)
	if pointed_thing.type ~= "node" then
		return itemstack
	end
	-- on_place from this tool and on_rightclick from node do not go together
	-- well. To enable the anvil repair, we get it's registration and call
	-- it's method on_rightclick right away!
	node = minetest.get_node(pointed_thing.under)
	if not farmingNG.havetech and node.name == "anvil:anvil" then
		local nodedef = minetest.registered_nodes[node.name]
		nodedef.on_rightclick(pointed_thing.under, node, placer, itemstack, pointed_thing)
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
		if not pos1 then
			meta:set_string("pos1","")
			meta:set_string("pos2","")
			meta:set_int("current", 1)
			delete_pos(pos1)
			delete_pos(pos2)
			return itemstack
		end
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
			if (pos1.y ~= pos2.y) and not meta:contains("posReset") then
				meta:set_int("posReset", 1)
			elseif (pos1.y ~= pos2.y) and meta:contains("posReset") then
				meta:set_string("posReset", "")
				meta:set_string("pos1", "")
				delete_pos(pos1)
				meta:set_int("current", 1)
			end
			return itemstack
		end
		showMarkers(pos1, pos2)
		meta:set_int("current", 1)
	end
	return itemstack
end

local onUse = function(itemstack, user, pointed_thing)
	local name = user:get_player_name()
	local meta = itemstack:get_meta()
   	local privs = minetest.get_player_privs(name)
	local charge = 0
	local pos = pointed_thing.under
	local areaMin = minetest.deserialize(meta:get("pos1"))
	local areaMax = minetest.deserialize(meta:get("pos2"))
     
	if farmingNG.havetech then
		charge =  meta:get_int("technic:charge")
	else
		charge = 65535 - itemstack:get_wear()
	end

    if pointed_thing.type ~= "node" then
	    return itemstack
    end
	--minetest.chat_send_all("Charge = "..dump(charge))
    if not charge or  
		    charge < farmingNG.plough_charge_per_node then
		    minetest.chat_send_player(name, orange(S(" *** Your device needs to be serviced")))
	    return
    end
	if not meta or not (meta:contains("pos1") and meta:contains("pos2")) then
		minetest.chat_send_player(name, orange("You need to set positions first"))
		return itemstack
	end
	if isNearArea(pos, areaMin, areaMax) then
		showMarkers(areaMin, areaMax)
	end
	if not isInArea(pos, areaMin, areaMax) then
		minetest.chat_send_player(name, orange("You have to click in your defined area"))
		return
	end
    if minetest.is_protected(pos, name) then
		minetest.chat_send_player(name, orange("Parts of your choosen area are already protected"))
	    minetest.record_protection_violation(pos, name)
	    return
    end
   if not isAreaClean(areaMin, areaMax) then
		minetest.chat_send_player(name, orange("Please clean up your area before ploughing it."))
		return
   end
    charge = plough(areaMin, areaMax, charge)
	--minetest.chat_send_all("Charge = "..dump(charge).."\nPer Node ="..perNode.."\n----------\n")
	if farmingNG.havetech then
		if not technic.creative_mode then
			meta:set_int("technic:charge", charge)
			technic.set_RE_wear(itemstack, charge, farmingNG.plough_max_charge)
		end
		return itemstack
	end
    itemstack:set_wear(65535 - charge)
    return itemstack
    
end

if farmingNG.havetech then
	-- registration of technic tool and recipe
	technic.register_power_tool("farming_nextgen:plough", farmingNG.plough_max_charge)

	minetest.register_tool("farming_nextgen:plough", {
		description = S("plough"),
		inventory_image = "farming_nextgen_plough.png",
		stack_max = 1,
		wear_represents = "technic_RE_charge",
		on_refill = technic.refill_RE_charge,
		on_place = onPlace,
	    on_use = onUse,
	  })

	local mesecons_button = minetest.get_modpath("mesecons_button")
	local trigger = mesecons_button and "mesecons_button:button_off" or "default:mese_crystal_fragment"

	minetest.register_craft({
		output = "farming_nextgen:plough",
		recipe = {
			{"technic:battery",            trigger,                  "technic:battery"},
			{"technic:carbon_plate", "technic:machine_casing", "technic:carbon_plate"},
			{"technic:rubber",             "",                       "technic:rubber"},
		}
	})

else -- registration of basic non technic tool and recipe
		    
    minetest.register_tool("farming_nextgen:plough", {
	    description = S("plough"),
	    groups = {soil = 2, crumbly = 1},
	    inventory_image = "farming_nextgen_plough.png",
	    stack_max = 1,
	    liquids_pointable = false,
		node_placement_prediction = nil,
		node_dig_prediction = "",
		on_place = onPlace,
	    on_use = onUse,
    })

    minetest.register_craft({
	    output = "farming_nextgen:plough",
	    recipe = {
		    {"default:diamondblock",			"default:mese_crystal_fragment",	"default:diamondblock"},
		    {"default:steel_ingot",				"default:tin_ingot",				"default:steel_ingot"},
		    {"default:mese_crystal_fragment",	"",									"default:mese_crystal_fragment"},
	    }
    })
   
end