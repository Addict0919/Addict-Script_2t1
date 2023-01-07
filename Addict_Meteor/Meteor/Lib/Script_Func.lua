local text_func = require("Meteor/Lib/Text_Func")
local natives = require("Meteor/Lib/Natives")
local ScriptEvent = require("Meteor/Data/ScriptEvents")

local script_func = {}

function script_func.get_global_main(pid)
	return script.get_global_i(1894573 + (1 + (pid * 608) + 510))
end

function script_func.get_global_main_2(pid)
	return script.get_global_i(2657589 + 1 + (pid * 453) + 318 + 7)
end

function script_func.get_global_9()
	return script.get_global_i(1923597 + 9)
end

function script_func.get_global_10()
	return script.get_global_i(1923597 + 10)
end

function script_func.get_player_info_offset(pid, info_offset)
	return 1853910 + (1 + (pid * 862)) + 205 + info_offset
end

function script_func.get_player_info_i(pid, info_offset)
	return script.get_global_i(script_func.get_player_info_offset(pid, info_offset))
end

function script_func.get_player_money(pid)
	return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 56)
end

function script_func.get_player_station(pid)
    return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 53)
end

function script_func.get_player_test(pid)
    return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 10)
end

function script_func.get_player_test2(pid)
    return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 9)
end

function script_func.get_player_races_won(pid)
    return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 15)
end

function script_func.get_player_races_lost(pid)
    return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 16)
end

function script_func.get_player_deathmatch_won(pid)
    return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 20)
end

function script_func.get_player_deathmatch_lost(pid)
    return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 21)
end

function script_func.get_player_missions_created(pid)
    return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 50)
end

function script_func.get_null()
	return script.get_local_s(gameplay.get_hash_key("freemode"), 20, 32)
end

function script_func.is_player_in_interior(pid)
    return script.get_global_i(((2657589 + 1) + (pid * 453)) + 243) ~= 0
end

function script_func.Bounty(pid)	
	for i = 0, 31 do
	if player.is_player_valid(i) then
	script.trigger_script_event(1370461707, i, {player.player_id(), pid, 1, input_val, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, script_func.get_global_9(), script_func.get_global_10()})
end
end
end

function script_func.get_player_money_str(pid)
	local money = script_func.get_player_money(pid)
	local money_str = tostring("$ ")
	if money >= 1000000000 then
		money = money / 1000000000
		money_str = money_str .. money .. " B"
	elseif money >= 1000000 then
		money = money / 1000000
		money_str = money_str .. money .. " M"
	elseif money >= 1000 then
		money = money / 1000
		money_str = money_str .. money .. " K"
	else
		money_str = money_str .. money
	end
	return money_str
end

function script_func.get_player_station_str(pid)
	local station = script_func.get_player_station(pid)
	local station_str = tostring(" ")
	if string.find("165889415") then
	station_str = "Los Santos Rock Radio"
	elseif string.find("3051187993") then
	station_str = "Non-Stop-Pop FM"
	elseif string.find("4195868215") then
	station_str = "Radio Los Santos"
	end
	return station_str
end

function script_func.get_player_rank(pid)
	return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 6)
end

function script_func.is_loading_into_session() -- Credits to kektram for this function
	return script.get_global_i(1574988) == 66 or not natives.IS_PLAYER_CONTROL_ON(player.player_id())
end

function script_func.is_player_loading(pid)
	return script.get_global_i(2657589 + 1 + (pid * 453) + 230) == 0
end

function script_func.get_player_ceo_int(pid)
	return script.get_global_i(1894573 + 1 + 10 + 104 + (pid * 599))
end

function script_func.is_player_typing(pid) -- Credits to kektram for this function
	return script.get_global_i(1653913 + 2 + 241 + 136 + pid) & 1 << 16 ~= 0
end

function script_func.get_player_mugger_target()
	return script.get_global_i(1853910 + (player.player_id() * 862 + 1) + 141) ~= -1 and script.get_global_i(1853910 + (player.player_id() * 862 + 1) + 141) or nil
end

function script_func.is_player_passive(pid)
	return script.get_global_i(1894573 + (pid * 599 + 1) + 8) == 1
end

function script_func.get_prostitutes_solicited(pid)
	return script.get_global_i(1853910 + 1 + (pid * 862) + 205 + 54)
end

function script_func.get_lapdances_amount(pid)
	return script.get_global_i(1853910 + 1 + (pid * 862) + 205 + 55)
end

function script_func.get_player_kd(pid)
	return script.get_global_f(1853910 + (1 + (pid * 862)) + 205 + 26)
end

function script_func.get_player_deaths(pid)
	return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 29)
end

function script_func.get_player_kills(pid)
	return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 28)
end

function script_func.get_player_wallet(pid)
	return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 3)
end

function script_func.get_player_bank(pid)
	return script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 56) - script.get_global_i(1853910 + (1 + (pid * 862)) + 205 + 3)
end

function script_func.get_session_type()
	if network.is_session_started() then
		if natives.NETWORK_SESSION_IS_CLOSED_FRIENDS() then
			return "Closed Friends"
		elseif natives.NETWORK_SESSION_IS_CLOSED_CREW() then
			return "Closed Crew"
		elseif natives.NETWORK_SESSION_IS_SOLO() then
			return "Solo"
		elseif natives.NETWORK_SESSION_IS_PRIVATE() then
			return "Private"
		end
		return "Public"
	end
	return "Singleplayer"
end

function script_func.is_phone_open()
	if natives.GET_NUMBER_OF_REFERENCES_OF_SCRIPT_WITH_NAME_HASH(gameplay.get_hash_key("cellphone_flashhand")) > 0 or script.get_global_i(20266 + 1) > 3 then
		return true
	else
		return false
	end
end

function script_func.is_connected_to_sc()
	return web.get("https://google.com") ~= 0
end

function script_func.get_next_script_host()
	local am_door_host = natives.NETWORK_GET_HOST_OF_SCRIPT("am_doors", -1, 0)
	local fmmc_launcher_host = natives.NETWORK_GET_HOST_OF_SCRIPT("fmmc_launcher", -1, 0)
	local am_launcher_host = natives.NETWORK_GET_HOST_OF_SCRIPT("am_launcher", -1, 0)
	if fmmc_launcher_host ~= -1 and fmmc_launcher_host ~= script.get_host_of_this_script() then
		return fmmc_launcher_host
	elseif am_door_host ~= -1 and am_door_host ~= script.get_host_of_this_script() then
		return am_door_host
	elseif am_launcher_host ~= -1 and am_launcher_host ~= script.get_host_of_this_script() then
		return am_launcher_host
	end
	return script.get_host_of_this_script()
end

function script_func.get_player_from_host_priority(queueposition)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			if player.get_player_host_priority(pid) == queueposition then
				return pid
			end
		end
	end
end

function script_func.force_script_host()
	if network.is_session_started() and script.get_host_of_this_script() ~= player.player_id() then
		local Lobby = menu.get_feature_by_hierarchy_key("online.lobby.force_script_host")
		if Lobby ~= nil then
			Lobby:toggle()
		end
		local time = utils.time_ms() + 8000
		while time > utils.time_ms() and script.get_host_of_this_script() ~= player.player_id() do
			if player.is_player_valid(player.player_id()) then
				natives.REQUEST_SCRIPT("freemode")
				natives.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
			end
			system.yield(0)
		end
		return natives.NETWORK_GET_THIS_SCRIPT_IS_NETWORK_SCRIPT(), script.get_host_of_this_script() == player.player_id()
	end
end

function script_func.drop_kick(pid)
	if player.is_player_valid(pid) then
		if network.network_is_host() then
			network.network_session_kick_player(pid)
		else
			network.force_remove_player(pid, player.get_host() ~= pid)
		end
	end
end

function script_func.script_event_kick(pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event_2(1 << pid, ScriptEvent["Kick 1"], pid, -210634234)
	end
end

function script_func.script_event_crash(pid)
	if player.is_player_valid(pid) then -- Skidded from kektram, Credits to him
		script.trigger_script_event_2(1 << pid, ScriptEvent["Script Teleport"], player.player_id(), 1, math.random(2000000000, 2147483647))
		script.trigger_script_event_2(1 << pid, ScriptEvent["Infinite Loop"], player.player_id(), 0, math.random(2000000000, 2147483647))
	end
end

return script_func