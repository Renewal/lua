local AIO = AIO or require("AIO")
local DNDHandlers = AIO.AddHandlers("DND", {})

-- debug info that prints race, class, gender IDs
local function DebugInfo(event, player, command)
	if (command:find("dnd debug") ~= 1) then
		return
	else
		player:SendBroadcastMessage("Race: " ..player:GetRace())
		player:SendBroadcastMessage("Class: " ..player:GetClass())
		player:SendBroadcastMessage("Gender: " ..player:GetGender())
		return false
	end
end

-- DM menu debug command
local function DebugInfo(event, player, command)
	if (command:find("dnd dm") ~= 1) then
		return
	else
		AIO.Handle(player, "DND", "ShowMenu")
		return false
	end
end

-- function to grab group leader or player, then changing unit with AIO
local function UnitType(player)
	group = player:GetGroup()
	if (group ~= nil) then
		leaderguid = group:GetLeaderGUID()
		leader = GetPlayerByGUID(leaderguid)
		unit = leader
		return unit
	else
		unit = player
		return unit
	end
end

-- defines unit type for dnd queries
local function UnitType2(player)
	if (player:GetSelection():HasSpell(6603) == true) then
		-- player
		unit_type = 1
	else
		-- creature
		unit_type = 2
	end
end

-- grabs char stats on /reload
function DNDHandlers.GetCharStats(player)
	local DNDStats = CharDBQuery("SELECT guid, level, points, const, strength, dex, `int`, wis, cha, init, ac, hp FROM character_dnd WHERE guid = "  ..player:GetGUIDLow().. ";")
	level = tonumber(DNDStats:GetInt32(1))
	points = tonumber(DNDStats:GetInt32(2))
	const = tonumber(DNDStats:GetInt32(3))
	strength = tonumber(DNDStats:GetInt32(4))
	dex = tonumber(DNDStats:GetInt32(5))
	int = tonumber(DNDStats:GetInt32(6))
	wis = tonumber(DNDStats:GetInt32(7))
	cha = tonumber(DNDStats:GetInt32(8))
	init = tonumber(DNDStats:GetInt32(9))
	ac = tonumber(DNDStats:GetInt32(10))
	hp = tonumber(DNDStats:GetInt32(11))
	
	constmod = math.floor(const / 2)
	strengthmod = math.floor(strength / 2)
	dexmod = math.floor(dex / 2)
	intmod = math.floor(int / 2)
	wismod = math.floor(wis / 2)
	chamod = math.floor(cha / 2)
	
	AIO.Handle(player, "DND", "UpdateStats", level, points, const, strength, dex, int, wis, cha, init, constmod, strengthmod, dexmod, intmod, wismod, chamod, ac, hp)
	return false
end


--- for AddStats. just a timer since the query was too fast
function AddStats2(eventId, delay, repeats, player)
	local NewStat = CharDBQuery("SELECT " ..statz.. ", points, ac FROM character_dnd WHERE guid = " ..player:GetGUIDLow().. ";")
	local ACQuery = CharDBQuery("SELECT ac FROM dnd_template_stats WHERE class = " ..player:GetClass().. ";")
	newstatz = tonumber(NewStat:GetInt32(0))
	newpoints = tonumber(NewStat:GetInt32(1))
	newmod = tonumber(math.floor(NewStat:GetInt32(0) / 2))
	ac = 0
	if (statz == "dex") and (NewStat:GetInt32(2) < 20) then
		ac = tonumber((math.floor(newstatz / 2)) + (ACQuery:GetInt32(0)))
		CharDBExecute("UPDATE character_dnd SET ac = " ..ac.. " WHERE guid = " ..player:GetGUIDLow().. ";")
	elseif (statz == "dex") then
		ac = NewStat:GetInt32(2)
	end
	AIO.Handle(player, "DND", "PlusStats", statz, newstatz, newpoints, newmod, ac)
end

-- updates stat values on +
-- TO DO: INCREASE COSTS. 10 - 15 = 2 points per. 15 - 20 = 3 points per. 1 - 10 = 1 point per.
function DNDHandlers.AddStats(player, stat)
	statz = tostring(stat)
	local DNDStats2 = CharDBQuery("SELECT " ..statz.. " FROM character_dnd WHERE guid = " ..player:GetGUIDLow().. " AND points > 0;")
	local LeftSpark = CharDBQuery("SELECT times FROM character_spark WHERE guid = " ..player:GetGUIDLow().. ";")
	if (DNDStats2 == nil) then
		player:SendBroadcastMessage("You do not have enough points to increase that stat!")
		return false
	elseif (LeftSpark == nil) then
		if (DNDStats2:GetInt32(0) >= 15) then
			player:SendBroadcastMessage("You cannot invest any more points in this stat until you leave the spark.")
		else
			CharDBExecute("UPDATE character_dnd SET points = points - 1 WHERE guid = " ..player:GetGUIDLow().. ";")
			CharDBExecute("UPDATE character_dnd SET " ..statz.. " = " ..statz.. " + 1 WHERE guid = " ..player:GetGUIDLow().. ";")
			player:RegisterEvent(AddStats2, 300, 1)
			return false
		end
	else
		CharDBExecute("UPDATE character_dnd SET points = points - 1 WHERE guid = " ..player:GetGUIDLow().. ";")
		CharDBExecute("UPDATE character_dnd SET " ..statz.. " = " ..statz.. " + 1 WHERE guid = " ..player:GetGUIDLow().. ";")
		player:RegisterEvent(AddStats2, 300, 1)
		return false
	end
end

function DNDHandlers.GetWeaverStatus(player)
	print("recieved")
	rank = tonumber(player:GetGMRank())
	AIO.Handle(player, "DND", "WeaverStatus", rank)
end

function DNDHandlers.SendOpen(player)
	local CombatQuery3 = CharDBQuery("SELECT guid FROM group_member WHERE memberguid = " ..player:GetGUIDLow().. ";")
	local CountCheck = CharDBQuery("SELECT name, init FROM dnd_combat WHERE partyid = " ..CombatQuery3:GetInt32(0).. ";")
	if (player:GetGMRank() == 0) then
		AIO.Handle(player, "DND", "ReceiveOpen2")
		return false
	elseif (player:GetGroup() == nil) or (CountCheck == nil) then
		message = 2
		AIO.Handle(player, "DND", "ReceiveOpen", message)
		return false
	else
		message = 1
		for x=1,CountCheck:GetRowCount(),1 do
			name = tostring(CountCheck:GetString(0))
			init = tonumber(CountCheck:GetInt32(1))
			AIO.Handle(player, "DND", "ReceiveOpen", message, x, name, init)
			CountCheck:NextRow()
		end
	end
end

--TO DO: Change to array
function DNDHandlers.GetWeapons(player)
	local mh = player:GetEquippedItemBySlot(15)
	local oh = player:GetEquippedItemBySlot(16)
	local ranged = player:GetEquippedItemBySlot(17)
	if (mh ~= nil) then
		local WeaponQuery1 = CharDBQuery("SELECT die_amount, die_sides, ac, stat FROM dnd_template_damage WHERE class = " ..mh:GetClass().. " and subclass = " ..mh:GetSubClass().. " ;")
		die_amount = tonumber(WeaponQuery1:GetInt32(0))
		die_sides = tonumber(WeaponQuery1:GetInt32(1))
		ac_mod = tonumber(WeaponQuery1:GetInt32(2))
		attribute = tostring(WeaponQuery1:GetString(3))
		slot = "mh"
		name = tostring(player:GetEquippedItemBySlot(15):GetName())
		AIO.Handle(player, "DND", "Weapons", die_amount, die_sides, ac_mod, attribute, slot, name)
	end
	if (oh ~= nil) then
		local WeaponQuery2 = CharDBQuery("SELECT die_amount, die_sides, ac, stat FROM dnd_template_damage WHERE class = " ..oh:GetClass().. " and subclass = " ..oh:GetSubClass().. " ;")
		die_amount = tonumber(WeaponQuery2:GetInt32(0))
		die_sides =  tonumber(WeaponQuery2:GetInt32(1))
		ac_mod = tonumber(WeaponQuery2:GetInt32(2))
		attribute = tostring(WeaponQuery2:GetString(3))
		slot = "oh"
		name = tostring(player:GetEquippedItemBySlot(16):GetName())
		AIO.Handle(player, "DND", "Weapons", die_amount, die_sides, ac_mod, attribute, slot, name)
	end
	if (ranged ~= nil) then
		local WeaponQuery3 = CharDBQuery("SELECT die_amount, die_sides, ac, stat FROM dnd_template_damage WHERE class = " ..ranged:GetClass().. " and subclass = " ..ranged:GetSubClass().. " ;")
		die_amount = tonumber(WeaponQuery3:GetInt32(0))
		die_sides =  tonumber(WeaponQuery3:GetInt32(1))
		ac_mod = tonumber(WeaponQuery3:GetInt32(2))
		attribute = tostring(WeaponQuery3:GetString(3))
		slot = "ranged"
		name = tostring(player:GetEquippedItemBySlot(17):GetName())
		AIO.Handle(player, "DND", "Weapons", die_amount, die_sides, ac_mod, attribute, slot, name)
	end
	--return false
end

function DNDHandlers.SendRoll(player, stat_type)
	--- make check to see if its characters turn to roll to prevent spam?
	-- or use aura as alternative to "roll cooldown"
	if (stat_type ~= "ac") then
		local StatQuery = CharDBQuery("SELECT " ..stat_type.. " FROM character_dnd WHERE guid = " ..player:GetGUIDLow().. ";")
		stat_mod = tonumber(math.floor(StatQuery:GetInt32(0) / 2))
	elseif (stat_type == "ac") then
		local StatQuery2 = CharDBQuery("SELECT dex FROM character_dnd WHERE guid = " ..player:GetGUIDLow().. ";")
		stat_mod = tonumber(math.floor(StatQuery2:GetInt32(0) / 2))
	end
	die = math.random(1, 20)
	newroll = tonumber(die + stat_mod)
	name = player:GetName()
	stat_type2 = tostring(stat_type)
	unit = UnitType(player)
	AIO.Handle(unit, "DND", "GetRoll", newroll, name, stat_type2)
	return false
end

--[[ old function for click damage
function DNDHandlers.SendDamage(player, slot)
	target = player:GetSelection()
	
	if (target == nil) then
		player:SendBroadcastMessage("You must have a target!")
		return false
	end
	
	item = player:GetEquippedItemBySlot(slot)
	if (item == nil) then
		player:SendBroadcastMessage("You must have a weapon equipped in that slot!")
		return false
	end
	
	target_name = target:GetName()
	item_class = item:GetClass()
	item_subclass = item:GetSubClass()
	roll = 0
	name = player:GetName()
	item_name = item:GetName()
	unit = UnitType(player)
	roll_type = "damage"
	local DamageQuery = CharDBQuery("SELECT die_amount, die_sides, ac FROM dnd_template_damage WHERE class = " ..item_class.. " AND subclass = " ..item_subclass.. ";")
	for x=1,(DamageQuery:GetInt32(0) + 1),1 do
		if x > DamageQuery:GetInt32(0) then
			--check for damage and shit here
			roll = tonumber(roll + DamageQuery:GetInt32(2))
			AIO.Handle(unit, "DND", "GetDamage", roll, name, item_name, target_name, roll_type)
			
			
		else
			die = math.random(1, DamageQuery:GetInt32(1))
			roll = tonumber(die + roll)
		end
	end
end
]]

function DNDHandlers.SendAccuracy(player, slot)
	target = player:GetSelection()
	local AccuracyQuery2 = CharDBQuery("SELECT ac FROM dnd_combat WHERE guid = " ..target:GetGUIDLow().. " AND `type` = " ..unit_type.. ";")
	
	if (target == nil) then
		player:SendBroadcastMessage("You must have a target!")
		return false
	elseif (AccuracyQuery2 == nil) then
		player:SendBroadcastMessage("This target is not part of a combat rotation.")
		return false
	end
	
	target_name = target:GetName()
	item = player:GetEquippedItemBySlot(slot)
	item_class = item:GetClass()
	item_subclass = item:GetSubClass()
	item_name = item:GetName()
	roll = math.random(1, 20)
	local AccuracyQuery = CharDBQuery("SELECT ac FROM dnd_template_damage WHERE class = " ..item_class.. " AND subclass = " ..item_subclass.. ";")
	roll = tonumber(roll + AccuracyQuery:GetInt32(0))
	unit = UnitType(player)
	unit_type = UnitType2(player)
	roll_type = "accuracy"
	success = "Failed!"
	if (AccuracyQuery2:GetInt32(0) < roll) then
		CharDBExecute("INSERT INTO `characters`.`dnd_combat_temp` (`attacker`, `attacker_type`, `target`, `target_type`, `success`) VALUES ('" ..player:GetGUIDLow().. "', '1', '" ..target:GetGUIDLow().. "', '" ..unit_type.. "', '1');")
		success = "Success!"
	else
		CharDBExecute("INSERT INTO `characters`.`dnd_combat_temp` (`attacker`, `attacker_type`, `target`, `target_type`, `success`) VALUES ('" ..player:GetGUIDLow().. "', '1', '" ..target:GetGUIDLow().. "', '" ..unit_type.. "', '0');")
	end
	AIO.Handle(unit, "DND", "GetDamage", roll, name, item_name, target_name, roll_type, success)
end

-- assign creatures to combat rotation
-- TO DO: FIX INPUT FOR NAMES AND SQL ERROR WITH " ' "
function DNDHandlers.AssignTarget(player, input1, input2, input3, input4, mass)
	target = player:GetSelection()
	
	if (target == nil) then
		player:SendBroadcastMessage("You need a target first!")
		return false
	end
	
	-- checks if creature exists in combat order
	local CheckQuery = CharDBQuery("SELECT guid FROM dnd_combat WHERE guid = " ..target:GetGUIDLow().. " and type = 2;")
	local CombatQuery3 = CharDBQuery("SELECT guid FROM group_member WHERE memberguid = " ..player:GetGUIDLow().. ";")
	if (CombatQuery3 == nil) then
		player:SendBroadcastMessage("You must be in a party to add creatures to a combat rotation.")
		return false
	elseif (mass == true) then
		CharDBExecute("UPDATE dnd_combat SET hp = " ..input1.. " WHERE name = '" ..target:GetName().. "' AND `type` = '2' AND partyid = " ..CombatQuery3:GetInt32(0).. ";")
		CharDBExecute("UPDATE dnd_combat SET ac = " ..input2.. " WHERE name = '" ..target:GetName().. "' AND `type` = '2' AND partyid = " ..CombatQuery3:GetInt32(0).. ";")
		CharDBExecute("UPDATE dnd_combat SET die_sides = " ..input3.. " WHERE name = '" ..target:GetName().. "' AND `type` = '2' AND partyid = " ..CombatQuery3:GetInt32(0).. ";")
		CharDBExecute("UPDATE dnd_combat SET die_amount = " ..input4.. " WHERE name = '" ..target:GetName().. "' AND `type` = '2' AND partyid = " ..CombatQuery3:GetInt32(0).. ";")
		player:SendBroadcastMessage("You have updated the stats of all creatures in your rotation with the name of '" ..target:GetName().. "'.")
		if (CheckQuery == nil) then
			CharDBExecute("INSERT INTO `characters`.`dnd_combat` (`type`, `guid`, `name`, `hp`, `ac`, `die_sides`, `die_amount`, `init`, `partyid`) VALUES ('2', '" ..target:GetGUIDLow().. "', '" ..target:GetName().. "', '" ..input1.. "', '" ..input2.. "', '" ..input3.. "', '" ..input4.. "', '0', '" ..CombatQuery3:GetInt32(0).. "');")
		end
		return false
	elseif (CheckQuery ~= nil) then
		player:SendBroadcastMessage("This target already exists in someone's combat order.")
		return false
	elseif (mass == false) then
		CharDBExecute("INSERT INTO `characters`.`dnd_combat` (`type`, `guid`, `name`, `hp`, `ac`, `die_sides`, `die_amount`, `init`, `partyid`, `entry`) VALUES ('2', '" ..target:GetGUIDLow().. "', '" ..target:GetName().. "', '" ..input1.. "', '" ..input2.. "', '" ..input3.. "', '" ..input4.. "', '0', '" ..CombatQuery3:GetInt32(0).. "', '" ..target:GetEntry().. "');")
		player:SendBroadcastMessage("You have added the creature '" ..target:GetName().. "' to your rotation.")
		return false
	end
end


-- determines if player or creature, then sends invite if player
function DNDHandlers.OpenInput(player)
	target = player:GetSelection()
	
	if (target == nil) then
		player:SendBroadcastMessage("You need a target first!")
		return false
	end

	target_guid = tonumber(target:GetGUIDLow())
	target_name = target:GetName()
	
	if (target:HasSpell(59752) == true) then
		-- player
		local CombatQuery1 = CharDBQuery("SELECT guid FROM dnd_combat WHERE `type` = 1 AND guid = " ..target_guid.. ";")
		group = player:GetGroup()
		target_group = target:GetGroup()
		if (CombatQuery1 ~= nil) then
			player:SendBroadcastMessage("That target is already in a combat rotation.")
			return false
		elseif (group ~= target_group) or (group == nil) then
			player:SendBroadcastMessage("Target is not in your group.")
			return false
		else
		-- accept popup
			player_name = tostring(player:GetName())
			AIO.Handle(target, "DND", "ConfirmInvite", player_name, target_guid)
			player:SendBroadcastMessage("You have sent a combat rotation invite to " ..target:GetName().. ".")
			return false
		end
	else
		-- npc
		AIO.Handle(player, "DND", "OpenWeaverInput")
		return false
	end
end

-- accept/decline player invite to rotation
function DNDHandlers.SendResponse(player, player_name, target_guid, response)
	player_first = GetPlayerByName(player_name)
	if (response == 1) then
		local CombatQuery2 = CharDBQuery("SELECT hp, ac, init FROM character_dnd WHERE guid = " ..target_guid.. ";")
		local CombatQuery3 = CharDBQuery("SELECT guid FROM group_member WHERE memberguid = " ..player:GetGUIDLow().. ";")
		init = tonumber(CombatQuery2:GetInt32(2) + math.random(1,20))
		CharDBExecute("INSERT INTO `characters`.`dnd_combat` (`type`, `guid`, `name`, `hp`, `ac`, `init`, `partyid`) VALUES ('1', '" ..target_guid.. "', '" ..target_name.. "', '" ..CombatQuery2:GetInt32(0).. "', '" ..CombatQuery2:GetInt32(1).. "', '" ..init.. "', '" ..CombatQuery3:GetInt32(0).. "');")
		player:SendBroadcastMessage("You have been added to a combat rotation by " ..player_name.. ".")
		player_first:SendBroadcastMessage(player:GetName().. " has accepted the invite to your combat rotation.")
		return false
	else
		player:SendBroadcastMessage("You have declined the invite.")
		player_first:SendBroadcastMessage(player:GetName().. " has declined the invite to your combat rotation.")
		return false
	end
end

-- clear targets of rotation
function DNDHandlers.ClearTargets(player, response)
	local CombatQuery3 = CharDBQuery("SELECT guid FROM group_member WHERE memberguid = " ..player:GetGUIDLow().. ";")
	if (response == 1) and (CombatQuery3 ~= nil) then
		CharDBExecute("DELETE FROM dnd_combat WHERE partyid = " ..CombatQuery3:GetInt32(0).. ";")
		player:SendBroadcastMessage("You have cleared your combat rotation.")
	end
end

function DNDHandlers.RollInit(player)
	local CombatQuery3 = CharDBQuery("SELECT guid FROM group_member WHERE memberguid = " ..player:GetGUIDLow().. ";")
	local CountCheck = CharDBQuery("SELECT name, init, type, guid FROM dnd_combat WHERE partyid = " ..CombatQuery3:GetInt32(0).. ";")
	if (CombatQuery3 == nil) then
		player:SendBroadcastMessage("You are not in a party, or a combat rotation controlled by players.")
		return false
	elseif (CountCheck == nil) then
		player:SendBroadcastMessage("There are no targets in your combat rotation.")
		return false
	else
		for v=1,CountCheck:GetRowCount(),1 do
			if (CountCheck:GetInt32(2) == 1) then
				local GetInitChar = CharDBQuery("SELECT init FROM character_dnd WHERE guid = " ..CountCheck:GetInt32(3).. ";")
				roll = tonumber(math.random(1,20) + GetInitChar:GetInt32(0))
				CharDBExecute("UPDATE dnd_combat SET init = " ..roll.. " WHERE guid = " ..CountCheck:GetInt32(3).. " AND type = 1;")
				CountCheck:NextRow()
			else
				roll = tonumber(math.random(1,20))
				CharDBExecute("UPDATE dnd_combat SET init = " ..roll.. " WHERE guid = " ..CountCheck:GetInt32(3).. " AND type = 2;")
				CountCheck:NextRow()
			end
		end
		-- TO DO: MESSAGES LIKE ACCURACY/DAMAGE
		player:SendBroadcastMessage("You have rerolled initiative.")
	end
end

--listening function to grab hpbar
local function DNDHandlers.HPBarGet(cause)
	local target = player:GetSelection()
	if (player:HasAura(90018) == false) then
		return false
	elseif (target == nil) then
		return false
	else
		
	end
end

local function CombatStop(player, begin)

end

local function CombatStart(player, begin)
	local CombatQuery3 = CharDBQuery("SELECT `guid` FROM group_member WHERE `memberGuid` = '" ..player:GetGUIDLow().. "';")

	if (CombatQuery3 == nil) then
		player:SendBroadcastMessage("You are not in a party.")
		return false
	end

	local CombatQuery4 = CharDBQuery("SELECT `name`, `init`, `guid`, `type`, `entry`, `status` FROM dnd_combat WHERE partyid = '" ..tonumber(CombatQuery3:GetInt32(0)).. "' ORDER BY `init` DESC;")
	
	if (CombatQuery4 == nil) then
		player:SendBroadcastMessage("There are no targets in your combat rotation.")
		return false
	end

	turn = nil
	
	for x=1,CombatQuery4:GetRowCount(),1 do
		-- player
		if (CombatQuery4:GetInt32(3) == 1) then
			guid = tonumber(CombatQuery4:GetInt32(2))
			target = GetPlayerByGUID(guid)
			print(turn)
			-- if target nil, skip
			if (target == nil) then
				CharDBExecute("UPDATE dnd_combat SET status = 1 WHERE guid = " ..guid.. " AND type = 1;")
				player:SendBroadcastMessage("A player has been skipped because they are not online.")
				CombatQuery4:NextRow()
			-- remove target if not in group
			elseif (target:GetGroup() ~= player:GetGroup()) then
				player:SendBroadcastMessage("A player has been removed from the combat rotation since they are no longer in your party.")
				CharDBExecute("DELETE FROM dnd_combat WHERE guid = " ..guid.. " AND type = 1;")
				CombatQuery4:NextRow()
			-- if its players turn
			elseif (target:HasAura(90019) == true) and (turn ~= true) then
				turn = true
				print(turn)
				player:RegisterEvent(Wait, 5000, 1)
				return false
			-- if status == 1
			elseif (CombatQuery4:GetInt32(5) == 1) or (turn == true) then
				target:AddAura(90018, target)
--				target:SendBroadcastMessage("Combat has started for you! You are now stunned while you wait your turn.")
				CombatQuery4:NextRow()
			-- target exists, target in same group, status ~= 1, and does not have turn aura
			elseif (turn == nil) then
				CharDBExecute("UPDATE dnd_combat SET status = 1 WHERE guid = " ..guid.. " AND type = 1;")
				target:AddAura(90018, target)
				target:AddAura(90019, target)
				target:SendBroadcastMessage("It is now your turn! Press start and you will have five seconds to move.")
				AIO.Handle(target, "DND", "Start")
				turn = true
				CombatQuery4:NextRow()
			-- target exists, target in same group, status ~= 1, and does not have turn aura BUT someone is already in turn			
			end
		-- creature
		else
			creatures = player:GetCreaturesInRange(200, CombatQuery4:GetInt32(4), 0, 1)
			for n=1,#creatures,1 do
				-- creature GUID = query, and turn hasn't started
				if (creatures[n]:GetGUIDLow() == CombatQuery4:GetInt32(2)) and (turn == nil) and (CombatQuery4:GetInt32(5) == 0) then
					creatures[n]:AddAura(90019, creatures[n])
					creatures[n]:AddAura(90018, creatures[n])
					turn = true
					CharDBExecute("UPDATE dnd_combat SET status = 1 WHERE guid = " ..CombatQuery4:GetInt32(2).. " and type = 2;")
					CombatQuery4:NextRow()
					break
				-- turn has started, creature guid = query
				elseif (creatures[n]:GetGUIDLow() == CombatQuery4:GetInt32(2)) or (turn == true) then
					creatures[n]:AddAura(90018, creatures[n])
					CombatQuery4:NextRow()
					break
				-- turn doesnt matter, guid cant be found
				elseif (n == #creatures) then
					CharDBExecute("UPDATE dnd_combat SET status = 1 WHERE guid = " ..CombatQuery4:GetInt32(2).. " and type = 2;")
					player:SendBroadcastMessage("A creature has been skipped because it could not be found.")
					CombatQuery4:NextRow()
					break
				end
			end
		end
	end
end

function DNDHandlers.Combat(player, begin)
	if (begin == true) then
		CombatStart(player, begin)
		return false
	else
		CombatStop(player, begin)
		return false
	end
end

local function TurnStop(eventId, delay, repeats, player)
	player:AddAura(90018, player)
	player:SendBroadcastMessage("Your movement has stopped.")
end

function DNDHandlers.StartTurn(player)
	player:RegisterEvent(TurnStop, 5000, 1)
	player:RemoveAura(90018)
end

local function EndTurnSpell(event, player, spell, skipCheck)
	if (spell:GetEntry() ~= 90020) then
		return false
	end
	
	if (player:GetGMRank() ~= 0) then
		unit = player:GetSelection()
	else
		unit = player
	end
	
	-- has no turn, not weaver
	if (player:HasAura(90019) ~= true) and (player:GetGMRank() == 0) then
		player:SendBroadcastMessage("You cannot end your turn when it is not your turn.")
		return false
	-- is weaver, or has turn
	else
		local CombatQuery3 = CharDBQuery("SELECT guid FROM group_member WHERE memberguid = " ..player:GetGUIDLow().. ";")
		local CombatQuery5 = CharDBQuery("SELECT status FROM dnd_combat WHERE partyid = " ..CombatQuery3:GetInt32(0).. " ORDER BY init DESC;")
		for z=1,CombatQuery5:GetRowCount(),1 do
			if (CombatQuery5:GetInt32(0) == 1) and (z == CombatQuery5:GetRowCount()) then
				CharDBExecute("UPDATE dnd_combat SET status = 0 WHERE partyid = " ..CombatQuery3:GetInt32(0).. ";")
			else
				CombatQuery5:NextRow()
			end
		end
		begin = true
		unit:RemoveAura(90019)
		CombatStart(player, begin)
		return false
	end
end

--local function AttackSpells(event, player, spell, skipCheck)
local function DNDHandlers.AttackSpells(player, slot)
	target = player:GetSelection()
	-- if its any of the dnd damage spells, is players turn, and target has a dnd stun
	if (target == nil) then
		player:SendBroadcastMessage("You must have a target.")
		return false
	elseif (target:HasAura(90018) ~= true) then
		player:SendBroadcastMessage("You cannot cast this spell on someone not in your turn order.")
		return false
	elseif (player:GetEquippedItemBySlot(slot) == nil) then
		player:SendBroadcastMessage("You must have a weapon equipped.")
		return false
	elseif (player:HasAura(90019) ~= true) then
		player:SendBroadcastMessage("You cannot cast when it is not your turn.")
		return false
	end
	
	unit_type = UnitType2(player)
	
	local DamageQuery1 = CharDBQuery("SELECT target, success FROM dnd_combat_temp WHERE attacker = " ..player:GetGUIDLow().. " AND attacker_type = " ..unit_type.. ";")
	local DamageQuery2 = CharDBQuery("SELECT hp WHERE attacker = " ..target:GetGUIDLow().. " AND attacker_type = " ..unit_type.. " AND `type` = 3;")
	
	-- checks to see if player has a successful accuracy roll against a target
	if (DamageQuery1 == nil) then
		player:SendBroadcastMessage("You can only attack after successfully landing an accuracy roll.")
		return false
	-- checks to see if accuracy roll target = damage roll target
	elseif (DamageQuery1:GetInt32(0) ~= target:GetGUIDLow()) then
		player:SendBroadcastMessage("You can only attack the same target you previously rolled an accuracy roll on.")
		return false
	elseif (DamageQuery1:GetInt32(1) == 0) then
		player:SendBroadcastMessage("You can only attack after successfully landing an accuracy roll.")
		return false
	-- checks to see if target already has hp entry, if yes - do damage, else insert.
	elseif (DamageQuery1:GetInt32(1) == 1) then
		item = player:GetEquippedItemBySlot(slot)
		target_name = target:GetName()
		item_class = item:GetClass()
		item_subclass = item:GetSubClass()
		roll = 0
		name = player:GetName()
		item_name = item:GetName()
		unit = UnitType(player)
		roll_type = "damage"
		local DamageQuery = CharDBQuery("SELECT die_amount, die_sides, ac FROM dnd_template_damage WHERE class = " ..item_class.. " AND subclass = " ..item_subclass.. ";")
		local DamageQuery3 = CharDBQuery("SELECT hp FROM dnd_combat_temp WHERE attacker = " ..)
		for x=1,(DamageQuery:GetInt32(0) + 1),1 do
			if x > DamageQuery:GetInt32(0) then
				--check for damage and shit here
				roll = tonumber(roll + DamageQuery:GetInt32(2))
				AIO.Handle(unit, "DND", "GetDamage", roll, name, item_name, target_name, roll_type)
				CharDBExecute("UPDATE dnd_combat_temp SET HP = HP - " ..roll.. " WHERE ;")
			else
				die = math.random(1, DamageQuery:GetInt32(1))
				roll = tonumber(die + roll)
			end
		end	
	
	
		if (DamageQuery2 == nil) then
			
		else
			CharDBExecute("UPDATE dnd_combat_temp SET hp = hp - " .. ";")
		return false	
		end
	end
end

RegisterPlayerEvent(42, DebugInfo)
RegisterPlayerEvent(5, EndTurnSpell)
--RegisterPlayerEvent(5, AttackSpells)