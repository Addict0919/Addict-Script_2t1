local natives = require("Meteor/Lib/Natives")

local memory = setmetatable({}, {__index = memory})

function memory.any_to_pointer(Handle)
	if Handle then
		if entity.is_an_entity(Handle) then
			return memory.get_any(Handle)
		end
	end
	return 0
end

function memory.handle_to_pointer(Handle)
	if Handle then
		if entity.is_an_entity(Handle) then
			if entity.is_entity_a_ped(Handle) then
				return memory.get_ped(Handle)
			elseif entity.is_entity_a_vehicle(Handle) then
				return memory.get_vehicle(Handle)
			elseif entity.is_entity_an_object(Handle) then
				return memory.get_object(Handle)
			else
				return memory.get_any(Handle)
			end
		end
	end
	return 0
end

function memory.pointer_to_handle(Pointer)
	if Pointer then
		return memory.get_entity(Pointer)
	end
	return 0
end

function memory.read_byte(Pointer, Offset)
	if Pointer then
		return memory.read_i8(Pointer, {Offset})
	end
	return 0
end

function memory.read_ubyte(Pointer, Offset)
	if Pointer then
		return memory.read_u8(Pointer, {Offset})
	end
	return 0
end

function memory.read_short(Pointer, Offset)
	if Pointer then
		return memory.read_i16(Pointer, {Offset})
	end
	return 0
end

function memory.read_ushort(Pointer, Offset)
	if Pointer then
		return memory.read_u16(Pointer, {Offset})
	end
	return 0
end

function memory.read_int(Pointer, Offset)
	if Pointer then
		return memory.read_i32(Pointer, {Offset})
	end
	return 0
end

function memory.read_uint(Pointer, Offset)
	if Pointer then
		return memory.read_u32(Pointer, {Offset})
	end
	return 0
end

function memory.read_long(Pointer, Offset)
	if Pointer then
		return memory.read_i64(Pointer, {Offset})
	end
	return 0
end

function memory.read_ulong(Pointer, Offset)
	if Pointer then
		return memory.read_u64(Pointer, {Offset})
	end
	return 0
end

function memory.read_float(Pointer, Offset)
	if Pointer then
		return memory.read_f32(Pointer, {Offset})
	end
	return 0
end

function memory.has_ped_seatbelt(Ped)
    if Ped then
        if entity.is_an_entity(Ped) and entity.is_entity_a_ped(Ped) then
			local Pointer = memory.handle_to_pointer(Ped)
			if Pointer ~= 0 and Pointer ~= nil then
				return memory.read_ubyte(Pointer, 0x145C) == 201
			end
        end
    end
    return false
end

function memory.get_player_invincible_but_has_reactions(Player)
    if Player then
		if player.is_player_valid(Player) then
			local PlayerPed = player.get_player_ped(Player)
			if entity.is_an_entity(PlayerPed) and entity.is_entity_a_ped(PlayerPed) and ped.is_ped_a_player(PlayerPed) then
				local Pointer = memory.handle_to_pointer(PlayerPed)
				if Pointer ~= 0 and Pointer ~= nil then
					return memory.read_ubyte(Pointer, 0x189) ~= 0
				end
			end
		end
    end
    return false
end

function memory.has_ped_noragdoll(Ped)
    if Ped then
        if entity.is_an_entity(Ped) and entity.is_entity_a_ped(Ped) then
			local Pointer = memory.handle_to_pointer(Ped)
			if Pointer ~= 0 and Pointer ~= nil then
				return memory.read_ubyte(Pointer, 0x10B8) ~= 32
			end
        end
    end
    return false
end

function memory.is_entity_frozen(Entity)
    if Entity then
        if entity.is_an_entity(Entity) then
			local Pointer = memory.handle_to_pointer(Entity)
			if Pointer ~= 0 and Pointer ~= nil then
				return memory.read_ushort(Pointer, 0x2E) & (1 << 1) ~= 0
			end
        end
    end
    return false
end

function memory.is_script_entity(Entity)
	if Entity then
		if entity.is_an_entity(Entity) then
			return natives.NETWORK_GET_ENTITY_NET_SCRIPT_ID(Entity) ~= 0 and natives.NETWORK_GET_NETWORK_ID_FROM_ENTITY(Entity) ~= 0 and not ped.is_ped_a_player(Entity) and not entity.is_entity_dead(Entity) and natives.IS_ENTITY_A_MISSION_ENTITY(Entity) and natives.GET_ENTITY_SCRIPT(Entity, 0) == "freemode" and not decorator.decor_exists_on(Entity, "PYV_Owner") and not decorator.decor_exists_on(Entity, "PYV_Vehicle") and not decorator.decor_exists_on(Entity, "PYV_Yacht") and not decorator.decor_exists_on(Entity, "Player_Vehicle") and not decorator.decor_exists_on(Entity, "CreatedByPegasus") and not decorator.decor_exists_on(Entity, "Player_Moon_Pool") and not decorator.decor_exists_on(Entity, "Player_Submarine") and not decorator.decor_exists_on(Entity, "Player_Submarine_Dinghy") and not decorator.decor_exists_on(Entity, "RespawnVeh")
		end
	end
	return false
end

function memory.get_entity_owner(Entity)
	if Entity then
		if entity.is_an_entity(Entity) then
			if network.is_session_started() then
				if not network.has_control_of_entity(Entity) then
					local Pointer = memory.handle_to_pointer(Entity)
					if Pointer ~= 0 and Pointer ~= nil then
						local NetObj = memory.read_ulong(Pointer, 0xD0)
						if NetObj ~= 0 and NetObj ~= nil then
							return memory.read_ubyte(NetObj, 0x49)
						end
					end
				end
			end
			return player.player_id()
		end
	end
end

function memory.get_entity_creator(Entity)
	if Entity then
		if entity.is_an_entity(Entity) then
			if memory.is_script_entity(Entity) then
				return natives.NETWORK_GET_NETWORK_ID_FROM_ENTITY(Entity) >> 16
			end
		end
	end
end

return memory