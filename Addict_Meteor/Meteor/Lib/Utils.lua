local natives = require("Meteor/Lib/Natives")

local utilities = {}

function utilities.dec_to_ipv4(ip)
	if ip then
		return string.format("%i.%i.%i.%i", ip >> 24 & 255, ip >> 16 & 255, ip >> 8 & 255, ip & 255)
	end
end

function utilities.ipv4_to_dec(ipstring) -- Credits to GeeMan for this function
	if ipstring then
		local fields = {}
		local pattern = string.format("([^%s]+)", ".")
		ipstring:gsub(pattern, function(c) fields[#fields + 1] = c end)
		local ip_dec = 0
		for i = 1, 4 do
			ip_dec = ip_dec + fields[i] * (256)^(3 - i + 1)
		end
		return math.tointeger(ip_dec)
	end
end

function utilities.get_rotation_from_entity_to_position(Entity, Position)
	local entity_pos = Entity
	if math.type(Entity) == "integer" then
		entity_pos = entity.get_entity_coords(Entity)
	end
	local pos = Position
	local height = 2;

	local X = pos.x - entity_pos.x
	local Y = pos.y - entity_pos.y
	local Z = (entity_pos.z - pos.z + height) * -1

	local pointAtHeadingAngle = math.atan(X, Y) * -180 / math.pi
	local pointAtAngle = math.asin(Z / pos:magnitude(entity_pos)) / (2 * math.pi) * 360

	return v3(pointAtAngle, 0, pointAtHeadingAngle)
end

function utilities.get_distance_between(pos1, pos2) -- Credits to kektram for this function
	if math.type(pos1) == "integer" then
		pos1 = entity.get_entity_coords(pos1)
	end
	if math.type(pos2) == "integer" then 
		pos2 = entity.get_entity_coords(pos2)
	end
	return pos1:magnitude(pos2)
end

function utilities.request_control(Entity, Time)
	Time = Time or 5000
	if Entity and entity.is_an_entity(Entity) then
		if not network.has_control_of_entity(Entity) then
			network.request_control_of_entity(Entity)
			local time = utils.time_ms() + Time
			while not network.has_control_of_entity(Entity) and time > utils.time_ms() do
				system.yield(0)
				network.request_control_of_entity(Entity)
			end
		end
		return network.has_control_of_entity(Entity)
	end
end

function utilities.force_request_control(Entity, Time)
	Time = Time or 5000
	if Entity and entity.is_an_entity(Entity) then
		if not network.has_control_of_entity(Entity) then
			natives.SET_NETWORK_ID_CAN_MIGRATE(natives.NETWORK_GET_NETWORK_ID_FROM_ENTITY(Entity), true)
			network.request_control_of_entity(Entity)
			local time = utils.time_ms() + Time
			while not network.has_control_of_entity(Entity) and time > utils.time_ms() do
				system.yield(0)
				network.request_control_of_entity(Entity)
			end
		end
		return network.has_control_of_entity(Entity)
	end
end

function utilities.get_current_shooting_direction()
	if player.is_player_valid(player.player_id()) then
		local timeout = utils.time_ms() + 1000
		local success, v3_start = ped.get_ped_bone_coords(player.get_player_ped(player.player_id()), 0x67f2, v3(0, 0, 0))
		while timeout > utils.time_ms() and not success do
			success, v3_start = ped.get_ped_bone_coords(player.get_player_ped(player.player_id()), 0x67f2, v3(0, 0, 0))
			system.yield(0)
		end
		if not success then
			v3_start = player.get_player_coords(player.player_id())
		end
		local dir = cam.get_gameplay_cam_rot()
		dir:transformRotToDir()
		return v3_start, v3_start + dir * 150
	end
end

function utilities.get_current_vehicle_shooting_direction()
	if player.is_player_valid(player.player_id()) then
		local v3_start = entity.get_entity_coords(player.get_player_vehicle(player.player_id()))
		local dir = entity.get_entity_rotation(player.get_player_vehicle(player.player_id()))
		dir.y = 0
		dir:transformRotToDir()
		return v3_start, v3_start + dir * 15000
	end
end

function utilities.get_current_aim_velocity_vector()
	local pos = player.get_player_coords(player.player_id())
	local dir = cam.get_gameplay_cam_rot()
	dir:transformRotToDir()
	dir = dir * 8
	pos = pos + dir
	dir = nil
	local pos_target = player.get_player_coords(player.player_id())
	dir = cam.get_gameplay_cam_rot()
	dir:transformRotToDir()
	dir = dir * 100
	pos_target = pos_target + dir
	local vectorV3 = pos_target - pos
	return vectorV3
end

function utilities.get_spectator_of_player(pid)
	local spectator = nil
	if player.is_player_valid(pid) then
		for i = 0, 31 do
			if player.is_player_valid(i) then
				if network.get_player_player_is_spectating(i) == pid then
					spectator = i
				end
			end
		end
	end
	return spectator
end

function utilities.request_model(Hash)
	local time = utils.time_ms() + 500
	while not streaming.has_model_loaded(Hash) and time > utils.time_ms() do
		system.yield(0)
		streaming.request_model(Hash)
	end
end

function utilities.offset_coords(pos, heading, distance, rotationorder)
	if rotationorder == 1 then
		heading = math.rad((heading - 180) * -1)
	elseif rotationorder == 2 then
		heading = math.rad((heading + 90) * -1)
	elseif rotationorder == 3 then
		heading = math.rad((heading - 360) * -1)
	else
		heading = math.rad((heading - 90) * -1)
	end
	pos.x = pos.x + (math.sin(heading) * -distance)
	pos.y = pos.y + (math.cos(heading) * -distance)
	return pos
end

return utilities