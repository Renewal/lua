local AIO = AIO or require("AIO")
local GrimHandlers = AIO.AddHandlers("Grim", {})
local Main = Main or require("Main")

server_spells = {
-- {unique ID for the button, item cost, {spell1, spell2, spell3}}
{1, 1, {20217}},
{2, 1, {26889}},
{3, 1, {1784, 1842, 921}},
{4, 1, {1842}},
{5, 2, {921}},
{6, 2, {1725}},
{7, 3, {2836}},
{8, 3, {2094}},

}

function GrimHandlers.InfluenceUpdate1(player)
	local InfluenceQuery1 = CharDBQuery("SELECT curr, max, level FROM character_influence WHERE guid = " ..player:GetGUIDLow().. ";")
	if (InfluenceQuery1 == nil) then
		player:SendBroadcastMessage("Error.")
		return false
	else
		currval = tonumber(InfluenceQuery1:GetInt32(0))
		maxval = tonumber(InfluenceQuery1:GetInt32(1))
		lvl = tonumber(InfluenceQuery1:GetInt32(2))
		AIO.Handle(player, "Grim", "GetValues2", currval, maxval, lvl)
		return false
	end
end

function GrimHandlers.ToolTip1(player, x)
	for z=1,#server_spells,1 do
		local description = WorldDBQuery("SELECT spelldescription0 FROM spell where ID = " ..server_spells[x][3][z].. ";"):GetString(0)
		if player:HasSpell(server_spells[x][3][z]) == true then
			AIO.Handle(player, "Grim", "TT1", x, description)
			break
		elseif description == nil then
			player:SendBroadcastMessage("Sorry but there appears to be an error in that talent. Please report this ASAP.")
		else
		--player:SendBroadcastMessage("description: " ..description.. ".")
		AIO.Handle(player, "Grim", "TT1", x, description)
		end
		--player:SendBroadcastMessage("spell: " ..server_spells[x][3][z].. ".")
	end
end

function GrimHandlers.GetWeaves(player, z)
	local WeaverCheck1 = CharDBQuery("SELECT * FROM guild_weavers WHERE guild = " ..player:GetGuildId().. ";")
	if WeaverCheck1 == nil then
		z = 0
		AIO.Handle(player, "Grim", "SetWeavers", z)
		return false
	end
	z = WeaverCheck1:GetRowCount()
	AIO.Handle(player, "Grim", "SetWeavers", z)
end

function GrimHandlers.LeaveWeaves(player)
	local WeaverCheck2 = CharDBQuery("SELECT guild FROM guild_weavers WHERE account = " ..player:GetAccountId().. ";")
	if (WeaverCheck2 == nil) then
		return false
	else
		CharDBExecute("DELETE FROM guild_weavers WHERE account = " ..player:GetAccountId().. ";")
		AuthDBExecute("UPDATE account_access SET gmlevel = gmlevel - 1 WHERE id = " ..player:GetAccountId().. ";")
		player:SendBroadcastMessage("You are no longer a guild weaver.")
		return false
	end
end

function GrimHandlers.ApplyWeaver1(player, input)
	local target = GetPlayerByName(input)
	--local charname = Main.Sterilize(input)
	if (target == nil) then -- checks if target exists
		player:SendBroadcastMessage("That character name does not exist.")
		return false
	--[[local WeaverCheck10 = CharDBQuery("SELECT guid FROM characters WHERE name = '" ..charname.. "';")
	if (WeaverCheck10 == nil) then
		player:SendBroadcastMessage("That character name does not exist.")
		return false]]
	elseif (player:GetGuildId() == nil) then -- checks if player in guild
		player:SendBroadcastMessage("Not sure how you got this message. Blaze it fgt. #420")
		return false
	else -- if account exists, then continue
		local WeaverCheck2 = CharDBQuery("SELECT guild FROM guild_weavers WHERE account = " ..target:GetAccountId().. ";")
		local WeaverCheck4 = AuthDBQuery("SELECT id, gmlevel FROM account_access WHERE id = " ..target:GetAccountId().. ";")
		local WeaverCheck5 = CharDBQuery("SELECT guildid, guid FROM guild_member WHERE guildid = "  ..player:GetGuildId().. ";")
		local WeaverCheck6 = CharDBQuery("SELECT guild FROM guild_weavers WHERE guild = " ..player:GetGuildId().. ";")
		if (WeaverCheck2 ~= nil) and (WeaverCheck2:GetInt32(0) ~= player:GetGuildId()) then -- check if an entry is somehow still existant after leaving a guild target was weaver in
			player:SendBroadcastMessage("This player is already appointed weaver by another guild.")
			return false
		elseif (target:GetGuildId() ~= player:GetGuildId()) then -- check if in same guild as target
			player:SendBroadcastMessage("This character is not in your guild.")
			return false
		elseif (WeaverCheck2 ~= nil) and (WeaverCheck2:GetInt32(0) == player:GetGuildId()) then -- if in same guild from check above, and  if weaver entry is found, then delete
			AuthDBExecute("UPDATE account_access SET gmlevel = gmlevel - 1 WHERE id = " ..target:GetAccountId().. ";")
			CharDBExecute("DELETE FROM guild_weavers WHERE account = " ..target:GetAccountId().. ";")
			target:SendBroadcastMessage("You are no longer a guild weaver.")
			player:SendBroadcastMessage(target:GetName().. " is no longer a guild weaver.")
			return false
		elseif (WeaverCheck6 ~= nil) and (WeaverCheck6:GetRowCount() >= math.floor(WeaverCheck5:GetRowCount() / 10)) then
			player:SendBroadcastMessage("You have met your maximum weaver count.")
			return false
		elseif (WeaverCheck4 == nil) then
			AuthDBExecute("INSERT INTO `auth`.`account_access` (`id`, `gmlevel`) VALUES (" ..target:GetAccountId().. ", 1);")
			CharDBExecute("INSERT INTO `characters`.`guild_weavers` (`account`, `guild`) VALUES (" ..target:GetAccountId().. ", " ..target:GetGuildId().. ");")
			target:SendBroadcastMessage("You have been appointed as a guild weaver.")
			player:SendBroadcastMessage("You have appointed " ..target:GetName().. " as a guild weaver.")
			return false
		elseif (WeaverCheck4:GetInt32(1) >= 2) then
			player:SendBroadcastMessage("This player cannot go any higher in their weaver status.")
			return false
		else
			AuthDBExecute("UPDATE account_access SET gmlevel = gmlevel + 1 WHERE id = " ..target:GetAccountId().. ";")
			CharDBExecute("INSERT INTO `characters`.`guild_weavers` (`account`, `character`, `guild`) VALUES (" ..target:GetAccountId().. ", '" ..target:GetName().. "'," ..target:GetGuildId().. ");")
			target:SendBroadcastMessage("You have been appointed as a guild weaver.")
			player:SendBroadcastMessage("You have appointed " ..target:GetName().. " as a guild weaver.")
			return false
		end
	end
end


function GrimHandlers.Learn1(player, x)
	if (x == nil) then
		print("[Eluna]: Error loading LUA script: SeverTest.lua. X is a nil value for buttons.")
		player:SendBroadcastMessage("The button you are trying to press does not exist.")
		return false
	else
		for y=1,#server_spells,1 do
			if (player:HasSpell(server_spells[x][3][y]) == false) then
				if (player:HasItem(29434, server_spells[x][2]) == true) then
					player:LearnSpell(server_spells[x][3][y])
					player:RemoveItem(29434, server_spells[x][2])
					return false
				else
					player:SendBroadcastMessage("You do not have enough points.")
				end
			--   else
				--player:SendBroadcastMessage("You already know that.")
				--break
			end
		end
	end
end

function GrimHandlers.OnLoginStunApply(event, player)
	if (player:GetGMRank() >= 3) then
		return false
	else
		player:AddAura(90004, player)
		AIO.Handle(player, "Grim", "LoginStunRemove")
	end
end

function GrimHandlers.OnLoginStunRemove(player)
	player:RemoveAura(90004)
end

local function CharDeleteCleanup(event, guid)
	local WeaverCheck7 = CharDBQuery("SELECT account FROM characters WHERE guid = " ..guid.. ";")
	local WeaverCheck2 = CharDBQuery("SELECT account FROM guild_weavers WHERE account = " ..WeaverCheck7:GetInt32(0).. ";")
	if (WeaverCheck7 == nil) then
		print("Error in cleaning up character GUID. ServerTest.lua, function CharDeleteCleanup.")
		return false
	elseif (WeaverCheck2 == nil) then	
		return false
	else
		CharDBExecute("DELETE FROM guild_weavers WHERE account = " ..WeaverCheck7:GetInt32(0).. ";")
		AuthDBExecute("UPDATE account_access SET gmlevel = gmlevel - 1 WHERE id = " ..WeaverCheck7:GetInt32(0).. ";")
	end
end

function GrimHandlers.WeaverDisplay(player)
	local WeaverCheck8 = CharDBQuery("SELECT `character`, account FROM guild_weavers WHERE guild = " ..player:GetGuildId().. ";")
	if (WeaverCheck8 == nil) then
		return false
	else
		for v=1,WeaverCheck8:GetRowCount(),1 do
			local WeaverCheck9 = AuthDBQuery("SELECT gmlevel FROM account_access WHERE id = " ..WeaverCheck8:GetInt32(1).. ";")
			name = WeaverCheck8:GetString(0)
			rank = WeaverCheck9:GetInt32(0)
			AIO.Handle(player, "Grim", "WeaverShow", v, name, rank)
			WeaverCheck8:NextRow()
		end
	end
end

function GrimHandlers.OfficerCheck(player)
	local OCheckQuery1 = CharDBQuery("SELECT guid, enabled FROM guild_panel_enabled WHERE guid = " ..player:GetGuildId().. " AND enabled = 1;")
	if (OCheckQuery1 == nil) then
		return false
	elseif (player:GetGuildRank() ~= 1) then
		return false
	else
		AIO.Handle(player, "Grim", "OfficerShow2")
		return false
	end
end

function GrimHandlers.OfficerEnable(player)
	local OCheckQuery1 = CharDBQuery("SELECT guid, enabled FROM guild_panel_enabled WHERE guid = " ..player:GetGuildId().. ";")
	if (OCheckQuery1 == nil) then
		CharDBExecute("INSERT INTO `characters`.`guild_panel_enabled` (`guid`, `enabled`) VALUES (" ..player:GetGuildId().. ", 1);")
		player:SendBroadcastMessage("Officers are now allowed to see the guild panel.")
		return false
	elseif (OCheckQuery1 ~= nil) then
		CharDBExecute("UPDATE guild_panel_enabled SET enabled = 1 WHERE guid = " ..player:GetGuildId().. ";")
		player:SendBroadcastMessage("Officers are now allowed to see the guild panel.")
		return false
	end
end

function GrimHandlers.OfficerDisable(player)
	local OCheckQuery1 = CharDBQuery("SELECT guid, enabled FROM guild_panel_enabled WHERE guid = " ..player:GetGuildId().. ";")
	if (OCheckQuery1 == nil) then
		CharDBExecute("INSERT INTO `characters`.`guild_panel_enabled` (`guid`, `enabled`) VALUES (" ..player:GetGuildId().. ", 0);")
		player:SendBroadcastMessage("Officers are not allowed to see the guild panel.")
	elseif (OCheckQuery1 ~= nil) then
		CharDBExecute("UPDATE guild_panel_enabled SET enabled = 0 WHERE guid = " ..player:GetGuildId().. ";")
		player:SendBroadcastMessage("Officers are not allowed to see the guild panel.")
		return false
	end		
end

function GrimHandlers.OfficerPanelCheck(player)
	local OCheckQuery1 = CharDBQuery("SELECT guid, enabled FROM guild_panel_enabled WHERE guid = " ..player:GetGuildId().. " AND enabled = 1;")
	if OCheckQuery1 == nil then
		player:SendBroadcastMessage("You do not have the permissions to use this panel.")
		return false
	elseif (player:GetGuildRank() ~= 1) then
		player:SendBroadcastMessage("You do not have the permissions to use this panel.")
		return false
	else
		AIO.Handle(player, "Grim", "PanelShow2")
		return false
	end
end

RegisterPlayerEvent(2, CharDeleteCleanup)
RegisterPlayerEvent(3, GrimHandlers.OnLoginStunApply)