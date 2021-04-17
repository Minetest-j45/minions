local minions = {}

chest_fs = "size[10,7]" ..
"list[context;tc;1,1;8,3;]" ..
"list[current_player;main;1,5;8,1;]"

local function tablefind(tab,el)
	for index, value in pairs(tab) do
		if value == el then
			return index
		end
	end
end

minions.register_minion = function(name, description, texture, node_itemstring, drop_node_itemstring, radius)
  
	minions[name] = {}
  
  
	minetest.register_node(minetest.get_current_modname()..":" .. name,
		{
			description = description,
			tiles = {texture}, 
		},
    
		on_place = function(itemstack, placer, pointed_thing)
			table.insert(minions[name], pointed_thing.above)
		end,
    
		on_dig = function(pos, node, player)
			local tablenumber = tablefind(minions[name], pos)
			table.remove(minions[name], tonumber(tablenumber))
		end,
		
		on_construct = function(pos)
			minetest.get_meta(pos):set_string("formspec", chest_fs)
			minetest.get_inventory({type = "node", pos = pos}):set_size("tc", 24)
		end,
	)
  
	local timer = 0
	minetest.register_globalstep(function(dtime)
		timer = timer + dtime;
		if timer >= 1 then
			for _, minion_pos in minions[name] do
				local pos1 = vector.add(minion_pos, {x = radius, y = radius, z = radius})
				local pos2 = vector.add(minion_pos, {x = -radius, y = -radius, z = -radius})
				for _, pos in minetest.find_nodes_in_area(pos1, pos2, node_itemstring) do
					minetest.remove_node(pos)
					minetest.get_inventory({type = "node", pos = pos}):add_stack("tc", drop_node_itemstring)
				end
			end
		timer = 0
		end
	end)
end
