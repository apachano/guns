function guns.register_ammo(modname, ammo)
	-- Information on ammo object
	-- name -> name of ammo eg: 22cal_incendiary
	-- max_ammo -> The maximum ammo allowed in a stack
	-- damage -> Damage done on player impact -> Not is use currently
	-- entity -> The entity when the ammo is fired
	-- entity.visual
	-- entity.visual_size
	-- entity.textures -> A table of textures for the bullet entity
	-- entity.hit_player -> Function called when hits player, parameters are (self, player)
	-- entity.hit_node -> Function called when hits node, parameters are (self, pos, node)

	minetest.register_craftitem(modname .. ":" .. ammo.name, {
		description = ammo.name .. " ammo",
		groups = {ammo = 1},
		inventory_image = ammo.inventory_image,
		--weild_image
		--weild_scale
		stack_max = ammo.max_ammo,
		--liquids_pointable
	})

	if not ammo.entity.hit_mob then ammo.entity.hit_mob = ammo.entity.hit_player end

	minetest.register_entity(modname .. ":" .. ammo.name .. "_entity",{
		physical = false,
		visual = ammo.entity.visual,
		visual_size = ammo.entity.visual_size,
		textures = ammo.entity.textures,
		hit_player = ammo.entity.hit_player,
		hit_mob = ammo.entity.hit_mob,
		hit_node = ammo.entity.hit_node,
		collisionbox = {0, 0, 0, 0, 0, 0},
		timer = 0,
		switch = 0,
		owner_id = ammo.entity.owner_id,

		onstep = function(self)
			local pos = self.object:get_pos()

			-- If the bullet hits a node do this
			if self.hit_node then
				local node = node_ok(pos).name

				if minetest.registered_nodes[node].walkable then
					self.hit_node(self, pos, node)

					if self.drop == true then
						pos.y = pos.y + 1
						self.lastpos = (self.lastpos or pos)
						minetest.add_item(self.lastpos, self.object:get_luaentity().name)
					end

					self.object:remove() ; -- print ("hit node")
					return
				end
			end


			-- If the bullet hits a player or a mob do this
			if self.hit_player or self.hit_mob then
				for _,player in pairs(minetest.get_objects_inside_radius(pos, 1.0)) do
					if self.hit_player
					and player:is_player() then
						self.hit_player(self, player)
						self.object:remove() ; -- print ("hit player")
						return
					end

					local entity = player:get_luaentity()

					if entity
					and self.hit_mob
					and entity._cmi_is_mob == true
					and tostring(player) ~= self.owner_id
					and entity.name ~= self.object:get_luaentity().name then
						self.hit_mob(self, player)
						self.object:remove() ;  --print ("hit mob")
						return
					end
				end
			end

			self.lastpos = pos
		end
	})
end

function guns.register_part(modname, part)

	minetest.register_craftitem(modname .. ":" .. part.name,{
		description = part.name,
		groups = {par = 1},
		inventory_image = part.inventory_image,
		--weild_image
		--weild_scale
		stack_max = part.stack_max,
		--liquids_pointable
	})
end

function guns.register_scope(modname, scope)

end

function guns.register_gun(modname, gun)
	-- Information on amo object
	-- name -> name of gun eg: ruger_22
	-- ammo -> item name of the ammo eg: if your mod "pistols" registers an ammo with 
	-- 		  ammo.name = "22cal_incendiary" then you should put "pistols:22cal_incendiary"
	-- inventory_image -> the inventory image for the gun
	-- weild_image -> Separate weild imge if you want diferent from inventory image
	-- sound.fire -> Sound to be played when the gun successfully fires
	-- sound.empty -> Sound to be player if the gun is empty and player tries to fire

	minetest.register_craftitem(modname .. ":" .. gun.name,{
		description = gun.name,
		groups = {gun = 1},
		inventory_image = gun.inventory_image,
		weild_image = gun.weild_image,
		--weild_scale
		stack_max = 1,
		--liquids_pointable
		on_use = function(itemstack, user, pointed_thing)
				local inventory = user:get_inventory()

				
				if inventory:contains_item("main", gun.ammo) then
					--Fire gun
					inventory:remove_item("main", gun.ammo)
					minetest.sound_play(gun.sound_fire, {object=user})
					local aim = user:get_look_dir()
					local pos = user:get_pos()
					local bullet = minetest.add_entity({x=pos.x,y=pos.y+1.5,z=pos.z}, gun.ammo .. "_entity")
					bullet:set_velocity({x=aim.x*19, y=aim.y*19, z=aim.z*19})
				else
					--Play empty noise
					minetest.sound_play(gun.sound_empty, {object=user})
				end
				return itemstack
			end
	})

end