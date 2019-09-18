local APTQuery1 = WorldDBQuery("SELECT item, object FROM apt_template")

local function APTOnUse(event, player, item, target)
	guidlow = tonumber(item:GetGUIDLow())
	itementry = tonumber(item:GetEntry())
	local APTQuery10 = WorldDBQuery("SELECT object FROM apt_template WHERE item = " ..itementry.. ";")
	if (APTQuery1 == nil) then
		player:SendBroadcastMessage("An error has occurred with spawning your APT. Please contact an administrator ASAP.")
		return
	else
		return
	end
end

local function APTSpawn(event, player, spell, skipCheck)
	local APTQuery10 = WorldDBQuery("SELECT object FROM apt_template WHERE item = " ..itementry.. ";")
	local spellx, spelly, spellz = spell:GetTargetDest()
	local o = player:GetO()
	PerformIngameSpawn(2, APTQuery10:GetInt32(0), player:GetMapId(), 0, spellx, spelly, spellz, o, true, 0, 2)
	PerformIngameSpawn(1, 32277, player:GetMapId(), 0, spellx, spelly, spellz, o, true, 0, 2)
	player:SetPhaseMask(3, false)
	local dummy = player:GetNearestCreature(100, 32277, 0, 1)
	local object = dummy:GetNearestGameObject(2, APTQuery10:GetInt32(0))
	local objectguid = object:GetDBTableGUIDLow()
	dummy:SetPhaseMask(2, true)
	local APTQuery12 = WorldDBQuery("SELECT object_guid FROM apt_spawned WHERE object_guid = " ..objectguid.. ";")
	--- checks if by any possible chance if there is a duplicate entry. if there is, keep object in unseen phase.
	if (APTQuery12 ~= nil) then
		player:SendBroadcastMessage("Your APT could not be spawned. Try spawning the APT further apart from any other APT.")
		return false
	else
		player:SetPhaseMask(1, true)
		WorldDBExecute("INSERT INTO `world`.`apt_spawned` (`account`, `character`, `item_guid`, `object_guid`, `item`, `timestamp`) VALUES (" ..player:GetAccountId().. ", " ..player:GetGUIDLow().. ", " ..guidlow.. ", " ..objectguid.. ", " ..itementry.. ", " ..tostring(GetGameTime()).. ");")
		object:SetPhaseMask(1, true)
		object:SaveToDB()
		dummy:RemoveFromWorld(true)
		return false
	end
end

local function APTDespawn(event, player, spell, skipCheck)
	local APTQuery10 = WorldDBQuery("SELECT object FROM apt_template WHERE item = " ..itementry.. ";")
	local APTQuery11 = WorldDBQuery("SELECT account, `character`, item_guid, object_guid, item FROM apt_spawned WHERE item_guid = " ..guidlow.. ";")
	local spellx, spelly, spellz = spell:GetTargetDest()
	local o = player:GetO()
	PerformIngameSpawn(1, 32277, player:GetMapId(), 0, spellx, spelly, spellz, o, false, 1)
--	local object = 1
	local object = player:GetNearestCreature(100, 32277):GetNearestGameObject(50, APTQuery10:GetInt32(0))
	local objectguid = object:GetDBTableGUIDLow()
	if object == nil then
		player:SendBroadcastMessage("No object found. Try moving closer.")
		return false
	elseif objectguid ~= APTQuery11:GetInt32(3) then
		player:SendBroadcastMessage("Your APT could not be deleted. Try targeting closer to the object.")
		return false
	else
		WorldDBExecute("DELETE FROM apt_spawned WHERE item_guid = " ..guidlow.. ";")
		object:RemoveFromWorld(true)
		return false
	end
end

local function GetSpell2(event, player, spell, skipCheck)
	if (spell:GetEntry() ~= 90013) then
		return false
	end
	
	local APTQuery10 = WorldDBQuery("SELECT object FROM apt_template WHERE item = " ..itementry.. ";")
	if (itementry == nil) then
		player:SendBroadcastMessage("There was an error in spawning your APT. Please report this to an administrator ASAP.")
		print("[Eluna]: Error in APT.lua - definition itementry is nil.")
		return false
	elseif (APTQuery10 == nil) then
		player:SendBroadcastMessage("There was an error in spawning your APT. Please report this to an administrator immediately.")
		print("[Eluna]: Error in APT.lua - APTQuery10 is nil.")
		return false
	elseif (APTQuery10 ~= nil) then
		local APTQuery11 = WorldDBQuery("SELECT account, `character`, item_guid, object_guid, item FROM apt_spawned WHERE item_guid = " ..guidlow.. ";")
		if (APTQuery11 == nil) then
			APTSpawn(event, player, spell, skipCheck)
			return
		elseif (APTQuery11 ~= nil) then
			APTDespawn(event, player, spell, skipCheck)
			return
		end
	end
end

--- loads events for items from apt_template
for x=1,APTQuery1:GetRowCount(),1 do
	if APTQuery1 == nil then
		break
	else
		RegisterItemEvent(APTQuery1:GetInt32(0), 2, APTOnUse)
		APTQuery1:NextRow()
	end
end

RegisterPlayerEvent(5, GetSpell2)


--- cleans up all APTs spawned after 72 hours on .server shutdown command, provided there is a timer.
local function APTCleanUp(event, code, mask)
	local CleanQuery1 = WorldDBQuery("SELECT object_guid, timestamp FROM apt_spawned;")
	local stime1 = tonumber(tostring(GetGameTime()))
	WorldDBExecute("DELETE FROM creature WHERE id = 32277")
	for n=1,CleanQuery1:GetRowCount(),1 do
		if CleanQuery1 == nil then
			break
		else
			if ((stime1) > (CleanQuery1:GetInt32(1) + 259200)) then
				WorldDBExecute("DELETE FROM gameobject WHERE guid = " ..CleanQuery1:GetInt32(0).. ";")
				WorldDBExecute("DELETE FROM apt_spawned WHERE object_guid = " ..CleanQuery1:GetInt32(0).. ";")
				CleanQuery1:NextRow()
			end
		end
	end
end

RegisterServerEvent(11, APTCleanUp)