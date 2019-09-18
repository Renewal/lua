local AIO = AIO or require("AIO")
local WHandlers = AIO.AddHandlers("WH", {})
local Main = Main or require("Main")

local function WeaverChat(event, player, command)
	if (command:find("weaver ") ~= 1) then
		return
	elseif (player:GetGMRank() == 0) then
		return
	else
		command = string.gsub(command,"weaver ","")
		local GM = GetPlayersInWorld(2)
		for x=1,#GM,1 do
			if (GM[x]:GetGMRank() ~= 0) then
				GM[x]:SendBroadcastMessage("[|cff00FFFFWeaver announce by|r |cff66ffcc" ..player:GetName().. "|r]: " ..command)
			end
		end
		return false
	end
end

local function WeaverGob2(event, player, command)
	-- searches for object based on entry (so wooden chair is 22713)
	-- deletes it from world and weaver DB
	command = string.gsub(command,"wgob del ","")
	command = string.gsub(command," ","")
	command = Main.Sterilize(command)
	local CommandQuery1 = WorldDBQuery("SELECT entry, type, name FROM gameobject_template WHERE entry = '" ..command.. "';")
	local goober2 = player:GetNearestGameObject(100, command)
	if (tonumber(command) == nil) then
		player:SendBroadcastMessage("You must enter a valid number.")
		return false
	elseif (CommandQuery1 == nil) then
		player:SendBroadcastMessage("You must input a valid entry.")
		return false
	elseif (goober2 == nil) then
		player:SendBroadcastMessage("There was an error in finding the object. Try moving to the map this object is in to delete it.")
		return false
	else
		local goober = player:GetNearestGameObject(100, command):GetDBTableGUIDLow()
		local CommandQuery4 = WorldDBQuery("SELECT account, guid FROM weaver_owners WHERE guid = '" ..goober.. "';")
		if (CommandQuery4 == nil) then
			player:SendBroadcastMessage("That object has not been spawned by a weaver and cannot be deleted.")
			return false
		elseif (CommandQuery4 ~= nil) and (CommandQuery4:GetInt32(0) ~= player:GetAccountId()) then 
			player:SendBroadcastMessage("That object has not been spawned by you and cannot be deleted.")
			return false
		else
			goober2:RemoveFromWorld(true)
			player:SendBroadcastMessage("Deleted object with GUID: " ..goober.. ".")
			WorldDBExecute("DELETE FROM weaver_owners WHERE guid = '" ..goober.. "';")
			return false
		end
	end
end

local function WeaverGob3(event, player, command)
	command = string.gsub(command,"wgob add ","")
	command = string.gsub(command," ","")
	command = Main.Sterilize(command)
	local CommandQuery1 = WorldDBQuery("SELECT entry, type, name FROM gameobject_template WHERE entry = '" ..command.. "';")
	local CommandQuery2 = WorldDBQuery("SELECT guid FROM weaver_owners WHERE account = " ..player:GetAccountId()..  " AND type = 2;")
	local CommandQuery3 = WorldDBQuery("SELECT cap FROM weaver_caps WHERE type = 2 AND gmlevel = " ..player:GetGMRank().. ";")
	if (tonumber(command) == nil) then
		player:SendBroadcastMessage("You must enter a valid number.")
		return false
	elseif (CommandQuery1 == nil) then
		player:SendBroadcastMessage("You must input a valid entry.")
		return false
	elseif (CommandQuery1:GetInt32(1) == 25) then
		player:SendBroadcastMessage("You cannot spawn fishing nodes.")
		return false
	elseif (CommandQuery1:GetInt32(1) == 3) then
		player:SendBroadcastMessage("You cannot spawn lootable objects.")
		return false
	elseif (CommandQuery2 ~= nil) and (CommandQuery2:GetRowCount() >= CommandQuery3:GetInt32(0)) then
		player:SendBroadcastMessage("This action can not be completed as you have reached your weaver cap of " ..CommandQuery2:GetRowCount().. "/" ..CommandQuery3:GetInt32(0).. ".")
		return false
	else
		local x, y, z, o = player:GetLocation()
		local map = player:GetMapId()
		player:SetPhaseMask(3, false)
		PerformIngameSpawn(2, command, map, 0, x, y, z, o, true, 0, 2)
		local gob = player:GetNearestGameObject(1, command)
		local gobid = gob:GetDBTableGUIDLow()
		local CommandQuery8 = WorldDBQuery("SELECT guid FROM weaver_owners WHERE guid = " ..gobid.. " AND type = 2;")
		if (CommandQuery8 == nil) then
			gob:SetPhaseMask(1, true)
			gob:SaveToDB()
			player:SetPhaseMask(1, true)
			player:SendBroadcastMessage("You have spawned " ..CommandQuery1:GetString(2).. ". ([GUID:] " ..gobid.. ")")
			WorldDBQuery("INSERT INTO `world`.`weaver_owners` (`account`, `type`, `guid`) VALUES (" ..player:GetAccountId().. ", 2, " ..gobid.. ");")
			player:NearTeleport(x, y, (z + 1), o)
			return false
		else
			player:SetPhaseMask(1, true)
			player:SendBroadcastMessage("This action could not be completed as this object has a duplicate GUID entry. Try moving from a duplicate object nearby.")
			return false
		end	
	end
end

-- previous weaver obj spawn method in case new method does not work
--[[
local function WeaverGob3(event, player, command)
	command = string.gsub(command,"wgob add ","")
	command = string.gsub(command," ","")
	command = Main.Sterilize(command);
	local CommandQuery1 = WorldDBQuery("SELECT entry, type, name FROM gameobject_template WHERE entry = '" ..command.. "';")
	local CommandQuery2 = WorldDBQuery("SELECT guid FROM weaver_owners WHERE account = " ..player:GetAccountId()..  " AND type = 2;")
	local CommandQuery3 = WorldDBQuery("SELECT cap FROM weaver_caps WHERE type = 2 AND gmlevel = " ..player:GetGMRank().. ";")
	--local GOBCheck1 = WorldDBQuery("SELECT ")
	if (tonumber(command) == nil) then
		player:SendBroadcastMessage("You must enter a valid number.")
		return false
	elseif (CommandQuery1 == nil) then
		player:SendBroadcastMessage("You must input a valid entry.")
		return false
	elseif (CommandQuery1:GetInt32(1) == 25) then
		player:SendBroadcastMessage("You cannot spawn fishing nodes.")
		return false
	elseif (CommandQuery1:GetInt32(1) == 3) then
		player:SendBroadcastMessage("You cannot spawn lootable objects.")
		return false
	else
		local x = player:GetX()
		local y = player:GetY()
		local z = player:GetZ()
		local o = player:GetO()
		local map = player:GetMapId()
		if (CommandQuery3 == nil) then
			print("[Eluna] Error: Error in WeaverCommands.lua - CommandQuery3 has resulted nil.")
			player:SendBroadcastMessage("There was an error in spawning your gameobject. Please report this to an administrator ASAP.")
			return false
		elseif (CommandQuery2 ~= nil) and (CommandQuery2:GetRowCount() >= CommandQuery3:GetInt32(0)) then
			player:SendBroadcastMessage("This action could not be completed as you have reached your weaver cap of " ..CommandQuery3:GetInt32(0).. "/" ..CommandQuery3:GetInt32(0).. ".")
			return false
		else
			PerformIngameSpawn(2, command, map, 0, x, y, z, o, true)
			local gob = player:GetNearestGameObject(3, command):GetDBTableGUIDLow()
			player:SendBroadcastMessage("You have spawned " ..CommandQuery1:GetString(2).. ". ([GUID:] " ..gob.. ")")
			WorldDBQuery("INSERT INTO `world`.`weaver_owners` (`account`, `type`, `guid`) VALUES (" ..player:GetAccountId().. ", 2, " ..gob.. ");")
			player:NearTeleport(x, y, (z + 1), o)
			return false
		end
	end
end]]

local function WeaverGob(event, player, command)
	if (command:find("wgob") ~= 1) then
		return
	elseif (player:GetGMRank() == 0) then
		return
	elseif (command:find("wgob del ") == 1) then
		WeaverGob2(event, player, command)
		return false
	elseif (command:find("wgob add ") == 1) then
		WeaverGob3(event, player, command)
		return false
	end
end

local function WeaverNPC2(event, player, command)
	-- cleans command of any possible malicious syntax and strictly grabs the value after the command
	command = string.gsub(command,"wnpc add ","")
	command = string.gsub(command," ","")
	command = Main.Sterilize(command);
	local CommandQuery5 = WorldDBQuery("SELECT entry, name, rank FROM creature_template WHERE entry = '" ..command.. "';")
	local CommandQuery6 = WorldDBQuery("SELECT guid FROM weaver_owners WHERE account = " ..player:GetAccountId()..  " AND type = 1;")
	local CommandQuery7 = WorldDBQuery("SELECT cap, max_rank FROM weaver_caps WHERE type = 1 AND gmlevel = " ..player:GetGMRank().. ";")
--	local CommandQuery9 = WorldDBQuery("SELECT id FROM weaver_npc_whitelist WHERE entry = " ..command.. ";")
	if (tonumber(command) == nil) then
		player:SendBroadcastMessage("You must enter a valid number.")
		return false
	elseif (CommandQuery5 == nil) then
		player:SendBroadcastMessage("You must provide a valid entry.")
		return false
	elseif (CommandQuery7 == nil) then
		player:SendBroadcastMessage("There was an error in spawning your creature. Please report this to an administrator ASAP.")
		print("[Eluna] Error: Error in WeaverCommands.lua - CommandQuery7 has resulted nil.")
		return false
	elseif (CommandQuery5:GetInt32(2) > CommandQuery7:GetInt32(1)) then
		player:SendBroadcastMessage("You cannot spawn a creature of that rank.")
		return false
	-- WHITELIST CODE IF NEEDED
	--[[
	elseif (CommandQuery9 == nil) then
		player:SendBroadcastMessage("That creature is not a whitelisted creature to be spawned by a weaver.")
		return false
	]]
	elseif (CommandQuery6 ~= nil) and (CommandQuery6:GetRowCount() >= CommandQuery7:GetInt32(0)) then
		player:SendBroadcastMessage("This action can not be completed as you have reached your weaver cap of " ..CommandQuery6:GetRowCount().. "/" ..CommandQuery7:GetInt32(0).. ".")
		return false
	else
		local x, y, z, o = player:GetLocation()
		local map = player:GetMapId()
		player:SetPhaseMask(3, false)
		PerformIngameSpawn(1, command, map, 0, x, y, z, o, true, 0, 2)
		local npc = player:GetNearestCreature(3, command)
		local npcid = npc:GetDBTableGUIDLow()
		local CommandQuery8 = WorldDBQuery("SELECT guid FROM weaver_owners WHERE guid = " ..npcid.. " AND type = 1;")
		if (CommandQuery8 == nil) then
			npc:SetPhaseMask(1, true)
			player:SetPhaseMask(1, true)
			npc:SaveToDB()
			player:SendBroadcastMessage("You have spawned " ..CommandQuery5:GetString(1).. ". ([GUID:] " ..npcid.. ")")
			WorldDBQuery("INSERT INTO `world`.`weaver_owners` (`account`, `type`, `guid`) VALUES (" ..player:GetAccountId().. ", 1, " ..npcid.. ");")
			return false
		else
			player:SetPhaseMask(1, true)
			player:SendBroadcastMessage("This action could not be completed as this NPC has a duplicate GUID entry. Try moving from a duplicate NPC nearby.")
			return false
		end
	end
end

local function WeaverNPC3(event, player, command)
	local target = player:GetSelection()
	local CommandQuery10 = WorldDBQuery("SELECT guid FROM weaver_owners WHERE guid = " ..target:GetDBTableGUIDLow().. " AND type = 1;")
	if (target == nil) then
		player:SendBroadcastMessage("You must have a target.")
		return false
	elseif (CommandQuery10 == nil) then
		player:SendBroadcastMessage("You cannnot delete that NPC as it is not under your ownership.")
		return false
	else
		WorldDBExecute("DELETE FROM weaver_owners WHERE guid = " ..target:GetDBTableGUIDLow().. " AND type = 1;")
		target:SetPhaseMask(2, true)
		target:SaveToDB()
		player:SendBroadcastMessage("You have deleted " ..target:GetName().. ". [GUID:] " ..target:GetDBTableGUIDLow().. ".")
		return false
	end
end

local function WeaverNPC4(event, player, command)
	local target = player:GetSelection()
	if (target == nil) then
		player:SendBroadcastMessage("You must have a target.")
		return false
	end
	
	local target_entry = target:GetEntry()
	local CommandQuery11 = WorldDBQuery("SELECT rank FROM creature_template WHERE entry = " ..target_entry.. ";")
	local CommandQuery12 = WorldDBQuery("SELECT max_rank FROM weaver_caps WHERE type = 1 AND gmlevel = " ..player:GetGMRank().. ";")
	if (CommandQuery11:GetInt32(0) > CommandQuery12:GetInt32(0)) then
		player:SendBroadcastMessage("You cannot use a creature of that rank.")
		return false
	elseif (command:find("wnpc pacify") == 1) then
		target:AddAura(90008, target)
		return false
	elseif (command:find("wnpc stun") == 1) then
		target:AddAura(90009, target)
		return false
	elseif (command:find("wnpc unaura") == 1) then
		target:RemoveAura(90008)
		target:RemoveAura(90009)
		return false
	end
end

local function WeaverNPC(event, player, command)
	if (command:find("wnpc") ~= 1) then
		return
	elseif (player:GetGMRank() == 0) then
		return
	elseif (command:find("wnpc add ") == 1) then
		WeaverNPC2(event, player, command)
		return false
	elseif (command:find("wnpc del") == 1) then
		WeaverNPC3(event, player, command)
		return false
	elseif (command:find("wnpc pacify") == 1) or (command:find("wnpc stun") == 1) or (command:find("wnpc unaura") == 1) then
		WeaverNPC4(event, player, command)
		return false
	end
end

local function WeaverComeToMe(event, player, command)
	if (command:find("wcometome") ~= 1) then
		return
	elseif (player:GetGMRank() == 0) then
		return
	end
	
	local target = player:GetSelection()
	local target_entry = target:GetEntry()
	local CommandQuery11 = WorldDBQuery("SELECT rank FROM creature_template WHERE entry = " ..target_entry.. ";")
	local CommandQuery12 = WorldDBQuery("SELECT max_rank FROM weaver_caps WHERE type = 1 AND gmlevel = " ..player:GetGMRank().. ";")
	local x, y, z, o = player:GetLocation()
	if target == nil then
		player:SendBroadcastMessage("You must have a target.")
		return false
	elseif (CommandQuery11:GetInt32(0) > CommandQuery12:GetInt32(0)) then
		player:SendBroadcastMessage("You cannot use a creature of that rank.")
		return false
	elseif (command:find("wcometome walk") == 1) then
		target:SetWalk(true)
		target:MoveTo(0, x, y, z, true)
		return false
	elseif (command:find("wcometome run") == 1) then
		target:SetWalk(false)
		target:MoveTo(0, x, y, z, true)
		return false
	elseif (command:find("wcometome home") == 1) then
		target:MoveHome()
		target:SetWalk(false)
		return false
	else
		-- help message. add .help command in future
		player:SendBroadcastMessage("Syntax: .wcometome $subcommand \nMakes the target NPC walk or run to your location. Subcommand home returns the NPC to its spawn point.\nwalk\nrun\nhome")
		return false
	end
end

local function WeaverYellSayEmote2(event, player, command)	
	local target = player:GetSelection()
	local target_entry = target:GetEntry()
	local CommandQuery11 = WorldDBQuery("SELECT rank FROM creature_template WHERE entry = " ..target_entry.. ";")
	local CommandQuery12 = WorldDBQuery("SELECT max_rank FROM weaver_caps WHERE type = 1 AND gmlevel = " ..player:GetGMRank().. ";")
	
	if (CommandQuery11 == nil) then
		player:SendBroadcastMessage("Well shit that broke. Uh... Never really planned for that. Report this bug ASAP.")
		return false
	elseif (CommandQuery12 == nil) then
		player:SendBroadcastMessage("An unexpected error occurred. Please report this to an administrator ASAP.")
		return false
	elseif (CommandQuery11:GetInt32(0) > CommandQuery12:GetInt32(0)) then
		player:SendBroadcastMessage("You cannot use a creature of that rank.")
		return false
	elseif (command:find("wyell ") == 1) then
		command = string.gsub(command,"wyell ","")
		target:SendUnitYell(command, 0)
		return false
	elseif (command:find("wemote ") == 1) then
		command = string.gsub(command,"wemote ","")
		target:SendUnitEmote(command)
		return false
	elseif (command:find("wsay ") == 1) then
		command = string.gsub(command,"wsay ","")
		target:SendUnitSay(command, 0)
		return false
	else
		player:SendBroadcastMessage("Enter your desired message after the command. Example: '.wyell Marco!' Will make the NPC yell Marco.")
	end
end

local function WeaverYellSayEmote(event, player, command)
	local target = player:GetSelection()
	if (command:find("wyell") == 1) or (command:find("wsay") == 1) or (command:find("wemote") == 1) then
		WeaverYellSayEmote2(event, player, command)
		return false
	elseif (command:find("wyell") ~= 1) or (command:find("wsay") ~= 1) or (command:find("wemote") ~= 1) then
		return
	elseif (player:GetGMRank() == 0) then
		return
	elseif (target == nil) then
		player:SendBroadcastMessage("You need a target.")
		return false
	end
end

-- BROKE. ONLY JUST_DIED DEATHSTATE (1) CAN BE USED. DOES NOT WORK.
--[[
local function WeaverDeathState(event, player, command)
	if (command:find("wdeathstate") ~= 1) then
		return
	elseif (player:GetGMRank() == 0) then
		return
	end
	
	print("command")
	local target = player:GetSelection()
	if target == nil then
		player:SendBroadcastMessage("You must have a target.")
		return false
	elseif (command:find("wdeathstate on") == 1) then
		player:SendBroadcastMessage("dead")
		target:SetDeathState(1)
		return false
	elseif (command:find("wdeathstate off") == 1) then
		player:SendBroadcastMessage("alive")
		target:SetDeathState(0)
		return false
	end	
end]]

--- cleans up all weaver duplicates on .server shutdown command, provided there is a timer.
local function WeaverCleanUp(event, code, mask)
	WorldDBExecute("DELETE FROM gameobject where map in (0, 1) and phasemask = 2 and id != 533847 and id != 192676 and id != 1734")
	WorldDBExecute("DELETE FROM creature where map in (0, 1) and phasemask = 2 and id != 32277 and id != 30627 and id != 30617")
end

RegisterServerEvent(11, WeaverCleanUp)

--RegisterPlayerEvent(42, WeaverDeathState)
RegisterPlayerEvent(42, WeaverComeToMe)
RegisterPlayerEvent(42, WeaverYellSayEmote)
RegisterPlayerEvent(42, WeaverNPC)
RegisterPlayerEvent(42, WeaverChat)
RegisterPlayerEvent(42, WeaverGob)