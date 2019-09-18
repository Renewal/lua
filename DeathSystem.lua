local AIO = AIO or require("AIO")
local DeathHandlers = AIO.AddHandlers("DeathSS", {})
local D = {}

--- DEBUG COMMAND TO SHOW DEATHFRAME1
--[[
local function DeathFrame(event, player, command)
	if (command:find("death") ~= 1) then
		return
	else
		amount = 1
		AIO.Handle(player, "DeathSS", "BigBattle", amount)
		return false
	end
end
]]

function DeathHandlers.EscapeConfirm(player)
	local DeathQuery4 = WorldDBQuery("SELECT amount FROM injury_escapes WHERE guid = " ..player:GetGUIDLow().. ";")
	if (DeathQuery4 == nil) then
		WorldDBExecute("INSERT INTO `world`.`injury_escapes` (`guid`, `amount`) VALUES (" ..player:GetGUIDLow().. ", 1);")
		player:RemoveAura(90012)
		player:RemoveAura(90000)
		player:Teleport(1, 16225.9, 16255, 13.0438, 4.35969)
		--- TO DO: ADD INJURIES
		return false
	elseif (DeathQuery4:GetInt32(0) >= 3) then
		player:SendBroadcastMessage("You have used all of your escapes.")
		return false
	else
		WorldDBExecute("UPDATE injury_escapes SET amount = amount + 1 WHERE guid = " ..player:GetGUIDLow().. ";")
		player:RemoveAura(90012)
		player:RemoveAura(90000)
		player:Teleport(1, 16225.9, 16255, 13.0438, 4.35969)
		--- TO DO: ADD INJURIES
		return false
	end
end

function DeathHandlers.SurrenderConfirm(player)
	player:AddAura(90000, player)
	player:RemoveAura(90012)
end

local function GMBroadcast(event, killer, killed)
	local GM = GetPlayersInWorld(2, true)
	for x=1,#GM,1 do
		if killer:GetOwner() then
			GM[x]:SendBroadcastMessage("|cffFF0000[Death System]:|r |cff66ffcc" ..killer:GetOwner():GetName().. "|r has death stunned |cff66ffcc" ..killed:GetName().. "|r.")
		else
			GM[x]:SendBroadcastMessage("|cffFF0000[Death System]:|r |cff66ffcc" ..killer:GetName().. "|r has death stunned |cff66ffcc" ..killed:GetName().. "|r.")
		end
	end
end

local function GMBroadcast2(event, player, command)
	local GM = GetPlayersInWorld(2, true)
	for x=1,#GM,1 do
		GM[x]:SendBroadcastMessage("|cffFF0000[Death System]:|r |cff66ffcc" ..player:GetName().. "|r has executed |cff66ffcc" ..player:GetSelection():GetName().. "|r.")
	end
end

local function DeathStun3(event, killer, killed)
	-- checks for hostiles in range to apply "big battle" debuff
	local rangeplayers = killed:GetPlayersInRange(30, 1, 1)
	if (rangeplayers == nil) then
		return false
	else
		count = 0
		for m=1,#rangeplayers,1 do
			if rangeplayers[m] == nil then
				break
			else
				count = count + 1
			end
		end
		local DeathQuery3 = WorldDBQuery("SELECT amount FROM injury_escapes WHERE guid = " ..killed:GetGUIDLow().. ";")
		if (count < 3) then
			return false
		elseif (DeathQuery3 == nil) then
			killed:AddAura(90012, killed)
			amount = 0
			AIO.Handle(killed, "DeathSS", "BigBattle", amount)
			return false
		elseif (DeathQuery3:GetInt32(0) >= 3) then
			killed:SendBroadcastMessage("You have used all of your escapes and you cannot decide your fate this time.")
			return false
		else
			killed:AddAura(90012, killed)
			amount = tonumber(DeathQuery3:GetInt32(0))
			AIO.Handle(killed, "DeathSS", "BigBattle", amount)
			return false
		end
	end
end

local function DeathStun(event, killer, killed)
	-- killed by player
	killed:ResurrectPlayer(10, false)
	killed:AddAura(90000, killed)
	killed:AddAura(90002, killed)
	GMBroadcast(event, killer, killed)
	DeathStun3(event, killer, killed)
end

local function DeathStun2(event, killer, killed)
-- checks if killed is killed by a pet
	if not(killer:GetOwner()) then
		return false
	else
		GMBroadcast(event, killer, killed)
		DeathStun3(event, killer, killed)
		killed:ResurrectPlayer(10, false)
		killed:AddAura(90000, killed)
		killed:AddAura(90002, killed)
	end	
end

-- list of spells to check for and consider "injured"
local injury_list = {
{20217},
{25771},
}

local function DeathCommand2(event, player, command)
	local target = player:GetSelection()
	--- check if player exceeds 10 executes passed a "validated" amount
	AIO.Handle(player, "DeathSS", "DeathScreenShot")
	AIO.Handle(target, "DeathSS", "DeathScreenShot")
	player:SendBroadcastMessage("|cffFF0000[Death System]:|r You have executed |cff66ffcc" ..target:GetName().. "|r.")
	target:SendBroadcastMessage("|cffFF0000[Death System]:|r You have been executed by |cff66ffcc" ..player:GetName().. "|r.")
	target:CreateCorpse()
	target:SpawnBones()
	target:Teleport(1, 16225.9, 16255, 13.0438, 4.35969)
	target:RemoveAura(90000)
	target:AddAura(90001, target)
	GMBroadcast2(event, player, command)
	local rangeplayers = player:GetPlayersInRange(30, 2, 1)
	local playedtime = target:GetTotalPlayedTime()
	WorldDBExecute("INSERT INTO `world`.`injury_logs` (`action`, `victim_guid`, `victim_name`, `victim_account`, `guid`, `name`, `account`, `spellid`, `money`, `location_x`, `location_y`, `location_z`, `timestamp`) VALUES (1, " ..target:GetGUIDLow().. ", '" ..target:GetName().. "', " ..target:GetAccountId().. ", " ..player:GetGUIDLow().. ", '" ..player:GetName().. "', " ..player:GetAccountId().. ", 0, 0, " ..target:GetX().. ", " ..target:GetY().. ", " ..target:GetZ().. ", " ..tostring(GetGameTime()).. ");")
	injured = 0
	for v=1,#injury_list,1 do
		if target:HasAura(injury_list[v][1]) then
			injured = 1
			break
		end
	end
	for z=1,#rangeplayers,1 do
		if injured == 1 then
			rangeplayers[z]:AddItem(999997, math.floor(1 * (playedtime / 21600)))
			WorldDBExecute("INSERT INTO `world`.`injury_logs` (`action`, `victim_guid`, `victim_name`, `victim_account`, `guid`, `name`, `account`, `spellid`, `money`, `location_x`, `location_y`, `location_z`, `timestamp`) VALUES (5, " ..target:GetGUIDLow().. ", '" ..target:GetName().. "', " ..target:GetAccountId().. ", " ..rangeplayers[z]:GetGUIDLow().. ", '" ..rangeplayers[z]:GetName().. "', " ..rangeplayers[z]:GetAccountId().. ", 0, 0, " ..target:GetX().. ", " ..target:GetY().. ", " ..target:GetZ().. ", " ..tostring(GetGameTime()).. ");")
		else
			rangeplayers[z]:AddItem(999997, math.floor(1 * (playedtime / 10800)))
			WorldDBExecute("INSERT INTO `world`.`injury_logs` (`action`, `victim_guid`, `victim_name`, `victim_account`, `guid`, `name`, `account`, `spellid`, `money`, `location_x`, `location_y`, `location_z`, `timestamp`) VALUES (5, " ..target:GetGUIDLow().. ", '" ..target:GetName().. "', " ..target:GetAccountId().. ", " ..rangeplayers[z]:GetGUIDLow().. ", '" ..rangeplayers[z]:GetName().. "', " ..rangeplayers[z]:GetAccountId().. ", 0, 0, " ..target:GetX().. ", " ..target:GetY().. ", " ..target:GetZ().. ", " ..tostring(GetGameTime()).. ");")
		end
	end
	if injured == 1 then
		player:AddItem(999997, math.floor(1 * (playedtime / 21600)))
		return false
	else
		player:AddItem(999997, math.floor(1 * (playedtime / 10800)))
		return false
	end
end

D.DeathCommand2 = DeathCommand2

local function DeathCommand3(event, player, command)
	local target = player:GetSelection()
	---- add gsub to search for a possible name/entry and not rely on target
	-- no wait, fuck gsub. do it with a GMpanel UI
	if (player:GetGMRank() == 3) then
	tostring(command)
		if (command:find("execute gm") == 1) then
			string.gsub(command,"execute gm","")
			DeathCommand2(event, player, command)
			return false
		elseif (command:find("execute disable") == 1) then
			local DeathQuery1 = CharDBQuery("SELECT account FROM injury_action_disable WHERE account = " ..target:GetAccountId().. ";")
			if (DeathQuery1 ~= nil) then
				CharDBQuery("DELETE FROM `characters`.`injury_action_disable` WHERE  `account`=" ..target:GetAccountId().. " AND `command`='execute' LIMIT 1;")
				player:SendBroadcastMessage("Command 'execute' enabled on " ..target:GetAccountName().. ".")
				return false
			else
				CharDBQuery("INSERT INTO `characters`.`injury_action_disable` (`account`, `command`) VALUES (" ..target:GetAccountId().. ", 'execute');")
				player:SendBroadcastMessage("Command 'execute' disabled on " ..target:GetAccountName().. ".")
				return false
			end
		end
	end
end

local function DeathCommand(event, player, command)
	local target = player:GetSelection()
	local DeathQuery2 = CharDBQuery("SELECT account FROM injury_action_disable WHERE account = " ..player:GetAccountId().. ";")
	if (command:find("execute") ~= 1) then
		return
	elseif (target == nil) then
		player:SendBroadcastMessage("You must have a target.")
		return false
	elseif (target == player) then
		player:SendBroadcastMessage("You cannot target yourself.")
		return false
	elseif (target:HasSpell(6603) == false) then
		player:SendBroadcastMessage("You must target a player.")
		return false
	elseif (command:find("execute gm") == 1) then
		DeathCommand3(event, player, command)
		return false
	elseif (command:find("execute disable") == 1) then
		DeathCommand3(event, player, command)
		return false
	elseif (target:HasAura(90000) == false) then
		player:SendBroadcastMessage("Your target must be death stunned.")
		return false
	elseif (target:HasAura(90012) == true) then
		player:SendBroadcastMessage("You cannot act against a target that is deciding their own fate.")
		return false
	elseif (player:GetGroup() ~= nil) and (target:GetGroup() ~= nil) and (target:GetGroup() == player:GetGroup()) then
		player:SendBroadcastMessage("Your target cannot be in your group.")
		return false
	elseif (target:IsWithinDistInMap(player, 2) == false) then
		player:SendBroadcastMessage("You must be closer to your target.")
		return false
	elseif (player:IsInCombat() == true) then
		player:SendBroadcastMessage("You cannot be in combat.")
		return false
	elseif (player:HasAura(1784) == true) then
		player:SendBroadcastMessage("You cannot be in stealth.")
		return false
	elseif (player:GetTotalPlayedTime() <= 64800) then
		player:SendBroadcastMessage("You do not have enough /played time to execute.")
		return false
	elseif (DeathQuery2 ~= nil) then
		player:SendBroadcastMessage("This command is disabled for you.")
		return false
	elseif (DeathQuery2 == nil) then
		DeathCommand2(event, player, command)
		return false
	else
		player:SendBroadcastMessage("Something fucked up.")
		return false
	end
end

local function DeathCheck(event, player, newZone, newArea)
	if (player:HasAura(90001) == false) then
		return false
	elseif (player:GetZoneId() == 876) then
		return false
	else
		-- log player when they try to escape. nah fuck it, the message might be enough.
		player:SendBroadcastMessage("Your attempt to escape has been logged.")
		player:Teleport(1, 16225.9, 16255, 13.0438, 4.35969)
	end
end

RegisterPlayerEvent(27, DeathCheck)
RegisterPlayerEvent(42, DeathCommand)
--RegisterPlayerEvent(42, DeathFrame)
RegisterPlayerEvent(8, DeathStun2)
RegisterPlayerEvent(6, DeathStun)

return D;