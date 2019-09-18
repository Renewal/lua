local Main = Main or require("Main")
local DeathSystem = DeathSystem or require("DeathSystem");

local function InjuryHello(event, player, object) -- main menu
	player:GossipClearMenu()
	player:GossipMenuAddItem(0, "Free", 65004, 1, false, "Are you sure you want to free this player?")
	player:GossipMenuAddItem(10, "Bind or remove binds", 65004, 7, false, "Binding this player will make them pacified and silenced. Continue?")
	player:GossipMenuAddItem(10, "Bind and drag", 65004, 6, false, "Binding and dragging this player will temporarily unstun them to follow you while they are pacified and silenced. Continue?")
	player:GossipMenuAddItem(6, "Steal", 65004, 2)
	player:GossipMenuAddItem(4, "Injure (temporary)", 65004, 3)
	player:GossipMenuAddItem(4, "Injure (permanent)", 65004, 4)
	player:GossipMenuAddItem(9, "Execute", 65004, 5, false, "Are you sure you want to execute this player?")
	player:GossipMenuAddItem(0, "Nevermind", 65004, 0)
	player:GossipSendMenu(65004, object, MenuId)
end

local function InjuryHello2(event, player, object) -- steal
	player:GossipMenuAddItem(6, "Money", 65005, 11, false, "Steal all of this character's money?")
	player:GossipMenuAddItem(0, "Nevermind", 65005, 0)
	player:GossipSendMenu(65005, object, MenuId)
end

local function InjuryHello3(event, player, object) -- temp injury
	player:GossipMenuAddItem(0, "Break ribs", 65006, 21)
	player:GossipMenuAddItem(0, "Break arm", 65006, 22)
	player:GossipMenuAddItem(0, "Break leg", 65006, 23)
	player:GossipMenuAddItem(0, "Give concussion", 65006, 24)
	player:GossipMenuAddItem(0, "Wound deeply", 65006, 25)
	player:GossipMenuAddItem(0, "Nevermind", 65006, 0)
	player:GossipSendMenu(65006, object, MenuId)
end

local function InjuryHello4(event, player, object) -- perm injury
	player:GossipMenuAddItem(0, "Nevermind", 65007, 0)
	player:GossipSendMenu(65006, object, MenuId)
end

local function FollowTimer(eventId, delay, repeats, player)
	--- bugs any movespeed buffs. consider using an aura instead?
	local bounded = player:GetPlayersInRange(7, 1, 1)
	player:RemoveAura(66206)
--	player:SetSpeed(1, 1, true)
	player:SendBroadcastMessage("You are too tired to drag this person more.")
	for c=1,#bounded,1 do
		if (bounded[c]:HasAura(90005) == true) then
			bounded[c]:MoveClear(true)
			bounded[c]:AddAura(90000, bounded[c])
			bounded[c]:RemoveAura(66206)
			bounded[c]:GetAura(90000):SetDuration(remaining)
--			bounded[c]:SetSpeed(1, 1, true)
			player:SendBroadcastMessage("bound found")
		else
			player:SendBroadcastMessage("bound not found")
		end
	end
end

amt =  0

local function CombatReward(event, player)
	local rangeplayers = player:GetPlayersInRange(30, 2, 1)
	for z=1,#rangeplayers,1 do
		rangeplayers[z]:AddItem(999997, amt)
	end
	player:AddItem(999997, amt)
	return false
end

local function InjurySelect(event, player, object, sender, intid, code, menuid)
	local target = player:GetSelection()
	local DeathQuery2 = CharDBQuery("SELECT account FROM injury_action_disable WHERE account = " ..player:GetAccountId().. ";")
	if (intid == 0) then
		player:GossipComplete()
		return false
	elseif (target == nil) then -- check target
		player:SendBroadcastMessage("You must have a target.")
		player:GossipComplete()
		return false
	elseif (target == player) then -- self target
		player:SendBroadcastMessage("You cannot target yourself.")
		player:GossipComplete()
		return false
	elseif (target:HasSpell(6603) == false) then -- player check
		player:SendBroadcastMessage("You must target a player.")
		player:GossipComplete()
		return false
	elseif (target:IsWithinDistInMap(player, 2) == false) then -- range check
		player:SendBroadcastMessage("You must be closer to your target.")
		player:GossipComplete()
		return false
	elseif (player:IsInCombat() == true) then -- combat check
		player:SendBroadcastMessage("You cannot be in combat.")
		player:GossipComplete()
		return false
	elseif (player:HasAura(1784) == true) then -- stealth check
		player:SendBroadcastMessage("You cannot be in stealth.")
		player:GossipComplete()
		return false
	elseif (target:HasAura(90012) == true) then -- big battle check
		player:SendBroadcastMessage("You cannot act against a target that is deciding their own fate.")
		return false
	elseif (intid == 1) then -- free
		player:GossipComplete()
		if (target:HasAura(90000) == false) then
			player:SendBroadcastMessage("Your target must be death stunned.")
			player:GossipComplete()
			return false
		else
			target:SendBroadcastMessage("|cffFF0000[Death System]:|r You have been freed by |cff66ffcc" ..player:GetName().. "|r.")
			player:SendBroadcastMessage("|cffFF0000[Death System]:|r You have freed |cff66ffcc" ..target:GetName().. "|r.")
			Main.GMBroadcast3(player, target)
			WorldDBExecute("INSERT INTO `world`.`injury_logs` (`action`, `victim_guid`, `victim_name`, `victim_account`, `guid`, `name`, `account`, `spellid`, `money`, `location_x`, `location_y`, `location_z`, `timestamp`) VALUES (6, " ..target:GetGUIDLow().. ", '" ..target:GetName().. "', " ..target:GetAccountId().. ", " ..player:GetGUIDLow().. ", '" ..player:GetName().. "', " ..player:GetAccountId().. ", 0, 0, " ..target:GetX().. ", " ..target:GetY().. ", " ..target:GetZ().. ", " ..tostring(GetGameTime()).. ");")
			target:RemoveAura(90000)
			return false
		end
	elseif (player:GetGroup() ~= nil) and (target:GetGroup() ~= nil) and (target:GetGroup() == player:GetGroup()) then -- group check
		player:SendBroadcastMessage("Your target cannot be in your group.")
		return false
	elseif (intid == 7) then -- bind
		if (target:HasAura(90000) == true) and (target:HasAura(90005) == false) then
			player:SendBroadcastMessage("|cffFF0000[Death System]:|r You have bound |cff66ffcc" ..target:GetName().. "|r.")
			target:SendBroadcastMessage("|cffFF0000[Death System]:|r You have bound by |cff66ffcc" ..target:GetName().. "|r.")
			player:AddAura(90005, target)
			return false
		elseif (target:HasAura(90005) == true) then
			target:SendBroadcastMessage("|cffFF0000[Death System]:|r You have been unbound by |cff66ffcc" ..player:GetName().. "|r.")
			player:SendBroadcastMessage("|cffFF0000[Death System]:|r You have unbound |cff66ffcc" ..target:GetName().. "|r.")
			target:RemoveAura(90005)
			return false
		end
	elseif (intid == 6) then -- bind drag
		player:GossipComplete()
		if (target:HasAura(90005) == true) then
			target:SendBroadcastMessage("|cffFF0000[Death System]:|r You have been unbound by |cff66ffcc" ..player:GetName().. "|r.")
			player:SendBroadcastMessage("|cffFF0000[Death System]:|r You have unbound |cff66ffcc" ..target:GetName().. "|r.")
			target:RemoveAura(90005)
			target:RemoveAura(66206)
			player:RemoveAura(66206)
			player:RemoveEvents()
			return false
		elseif (player:HasAura(90006) == true) then
			player:SendBroadcastMessage("You are too tired to drag this person more.")
			return false
		elseif (target:HasAura(90000) == true) then
			local DeathStun = target:GetAura(90000)
			remaining = DeathStun:GetDuration()
--			player:SetSpeed(1, 0.5, true)
--			target:SetSpeed(1, 0.6, true)
			player:SendBroadcastMessage("|cffFF0000[Death System]:|r You have bound |cff66ffcc" ..target:GetName().. "|r.")
			target:SendBroadcastMessage("|cffFF0000[Death System]:|r You have bound by |cff66ffcc" ..target:GetName().. "|r.")
			target:RemoveAura(90000)
			target:AddAura(90005, target)
			player:AddAura(90006, player)
			target:MoveFollow(player)
			player:CastSpell(target, 66206, true)
			player:CastSpell(target, 90007, true)
			player:RegisterEvent(FollowTimer, 61000, 1)
			return false
		else
			player:SendBroadcastMessage("Your target must be death stunned.")
			return false
		end
	elseif (target:HasAura(90000) == false) then
		player:SendBroadcastMessage("Your target must be death stunned.")
		player:GossipComplete()
		return false
	elseif (intid == 2) then -- steal
		player:GossipClearMenu()
		InjuryHello2(event, player, object)
		return false
	elseif (intid == 3) then -- temp injury menu
		player:GossipClearMenu()
		InjuryHello3(event, player, object)
		return false
	elseif (intid >= 21 and intid <= 29) then --- temp injury actions
		local InjuryQuery1 = WorldDBQuery("SELECT value1, value2 FROM lua_intid WHERE id = 1 AND intid = " ..intid ..";")
		player:GossipClearMenu()
		player:GossipComplete()
		if (InjuryQuery1 == nil) then
			player:SendBroadcastMessage("There was an error.")
			return false
		else
			--- value2 must either point to value1 or point to another spell.
			target:SendBroadcastMessage("|cffFF0000[Death System]:|r |cff66ffcc" ..player:GetName().. "|r has injured you.")
			player:SendBroadcastMessage("|cffFF0000[Death System]:|r You have injured |cff66ffcc" ..target:GetName().. "|r.")
			WorldDBExecute("INSERT INTO `world`.`injury_logs` (`action`, `victim_guid`, `victim_name`, `victim_account`, `guid`, `name`, `account`, `spellid`, `money`, `location_x`, `location_y`, `location_z`, `timestamp`) VALUES (3, " ..target:GetGUIDLow().. ", '" ..target:GetName().. "', " ..target:GetAccountId().. ", " ..player:GetGUIDLow().. ", '" ..player:GetName().. "', " ..player:GetAccountId().. ", " ..InjuryQuery1:GetInt32(0).. ", 0, " ..target:GetX().. ", " ..target:GetY().. ", " ..target:GetZ().. ", " ..tostring(GetGameTime()).. ");")
			if (target:HasAura(InjuryQuery1:GetInt32(1)) == true) then
				player:AddAura(InjuryQuery1:GetInt32(0), target)
				player:AddAura(InjuryQuery1:GetInt32(1), target)
				return false
			else
				amt = 1
				player:AddAura(InjuryQuery1:GetInt32(0), target)
				player:AddAura(InjuryQuery1:GetInt32(1), target)
				CombatReward(event, player)
				return false
			end
		end
	elseif (intid == 4) then -- perm injury
		player:GossipClearMenu()
		if (player:GetTotalPlayedTime() <= 43200) then
			player:SendBroadcastMessage("You must have 12 hours /played time or more to permanently injure.")
			player:GossipComplete()
			return false
		else
			InjuryHello4(event, player, object)
			return false
		end
	elseif (player:GetTotalPlayedTime() <= 1) then -- execute 64800
		player:SendBroadcastMessage("You must have 18 hours /played time or more to execute.")
		player:GossipComplete()
		return false
	elseif (intid == 11) then
	local RobQuery1 = CharDBQuery("SELECT money FROM `characters` WHERE guid = " ..target:GetGUIDLow().. ";")
		if RobQuery1 == nil then
			player:SendBroadcastMessage("There was an error in robbing this target.")
			return false
		else
			target:SendBroadcastMessage("|cffFF0000[Death System]:|r |cff66ffcc" ..player:GetName().. "|r stole " ..RobQuery1:GetInt32(0).. " copper from you.")
			player:SendBroadcastMessage("|cffFF0000[Death System]:|r You stole " ..RobQuery1:GetInt32(0).. " copper from |cff66ffcc" ..target:GetName().. "|r.")
			WorldDBExecute("INSERT INTO `world`.`injury_logs` (`action`, `victim_guid`, `victim_name`, `victim_account`, `guid`, `name`, `account`, `spellid`, `money`, `location_x`, `location_y`, `location_z`, `timestamp`) VALUES (4, " ..target:GetGUIDLow().. ", '" ..target:GetName().. "', " ..target:GetAccountId().. ", " ..player:GetGUIDLow().. ", '" ..player:GetName().. "', " ..player:GetAccountId().. ", 0, " ..RobQuery1:GetInt32(0).. ", " ..target:GetX().. ", " ..target:GetY().. ", " ..target:GetZ().. ", " ..tostring(GetGameTime()).. ");")
			player:ModifyMoney(RobQuery1:GetInt32(0))
			target:ModifyMoney(-1 * RobQuery1:GetInt32(0))
			target:SaveToDB()
			player:SaveToDB()
			return false
		end
	elseif (DeathQuery2 ~= nil) then
		player:SendBroadcastMessage("This is disabled for you.")
		player:GossipComplete()
		return false
	elseif (DeathQuery2 == nil) then
		DeathSystem.DeathCommand2(event, player, command)
		return false
	else
		player:GossipComplete()
		return false
	end
end

local function StealthCockBlocks(event, player, spell, skipCheck)
	if (spell:GetEntry() ~= 1784) then
		return false
	elseif player:HasAura(90005) == false then
		return false
	else
		player:RemoveAura(1784)
	end
end

RegisterPlayerEvent(5, StealthCockBlocks)
RegisterItemGossipEvent(999996, 1, InjuryHello)
RegisterItemGossipEvent(999996, 2, InjurySelect)