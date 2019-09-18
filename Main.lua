local M = {}

--- every hour, server does flush check.


local function Sterilize(parameter)
	tostring(parameter)
	parameter = string.gsub(parameter,"%;","")
	parameter = string.gsub(parameter,"`","")
	parameter = string.gsub(parameter,"(%a)'","%1`")
	parameter = string.gsub(parameter,"(%s)'(%a)","%1;%2")
	parameter = string.gsub(parameter,"'","")
	parameter = string.gsub(parameter,"(%a)`","%1''")
	parameter = string.gsub(parameter,"(%s);(%a)","%1''%2")
	return parameter
end

local function Check()
	return
end

local function GMBroadcast3(player, target)
	local GM = GetPlayersInWorld(2, true)
	for x=1,#GM,1 do
		GM[x]:SendBroadcastMessage("|cffFF0000[Death System]:|r |cff66ffcc" ..player:GetName().. "|r has freed |cff66ffcc" ..player:GetSelection():GetName().. "|r.")
	end
end

skin_sets_male = {
{3, 9} -- dark iron
}

skin_sets_female = {
{3, 8} -- dark iron
}

local function DNDWrite(event, player)
	print("processing DND...")
	print("processing DND...")
	print("processing DND...")
	local DNDQuery1 = CharDBQuery("SELECT * FROM character_dnd WHERE guid = " ..player:GetGUIDLow().. ";")
	local DNDSkin = CharDBQuery("SELECT skin FROM characters WHERE guid = " ..player:GetGUIDLow().. ";")
	local DNDClass = CharDBQuery("SELECT cons, str, dex, `int`, wis, cha, init, ac FROM dnd_template_stats WHERE class = " ..player:GetClass().. ";")
	local DNDRace = CharDBQuery("SELECT cons, str, dex, `int`, wis, cha FROM dnd_template_stats WHERE race = " ..player:GetRace().. ";")
	local DNDRace2 = CharDBQuery("SELECT cons, str, dex, `int`, wis, cha FROM dnd_template_stats WHERE race = " ..player:GetRace().. " AND skin = " ..DNDSkin:GetInt32(0).. " AND gender = " ..player:GetGender().. ";")	
	if (DNDQuery1 ~= nil) then
		return false
	elseif (DNDRace2 ~= nil) then
		constitution = ((DNDRace2:GetInt32(0)) + (DNDClass:GetInt32(0)))
		strength = ((DNDRace2:GetInt32(1)) + (DNDClass:GetInt32(1)))
		dexterity = ((DNDRace2:GetInt32(2)) + (DNDClass:GetInt32(2)))
		intellect = ((DNDRace2:GetInt32(3)) + (DNDClass:GetInt32(3)))
		wisdom = ((DNDRace2:GetInt32(4)) + (DNDClass:GetInt32(4)))
		charisma = ((DNDRace2:GetInt32(5)) + (DNDClass:GetInt32(5)))
		CharDBExecute("INSERT INTO `characters`.`character_dnd` (`guid`, `level`, `points`, `const`, `strength`, `dex`, `int`, `wis`, `cha`, `init`, `ac`) VALUES ('" ..player:GetGUIDLow().. "', '1', '54', '" ..constitution.. "', '" ..strength.. "', '" ..dexterity.. "', '" ..intellect.. "', '" ..wisdom.. "', '" ..charisma.. "', '" ..DNDClass:GetInt32(6).. "', '" ..DNDClass:GetInt32(7).. "');")
		print("processed for race and skin!")
		print("processed for race and skin!")
		print("processed for race and skin!")
		return false	
	elseif (DNDRace ~= nil) then
		constitution = ((DNDRace:GetInt32(0)) + (DNDClass:GetInt32(0)))
		strength = ((DNDRace:GetInt32(1)) + (DNDClass:GetInt32(1)))
		dexterity = ((DNDRace:GetInt32(2)) + (DNDClass:GetInt32(2)))
		intellect = ((DNDRace:GetInt32(3)) + (DNDClass:GetInt32(3)))
		wisdom = ((DNDRace:GetInt32(4)) + (DNDClass:GetInt32(4)))
		charisma = ((DNDRace:GetInt32(5)) + (DNDClass:GetInt32(5)))
		ac = ((math.floor(dexterity / 2)) + (DNDClass:GetInt32(7)))
		CharDBExecute("INSERT INTO `characters`.`character_dnd` (`guid`, `level`, `points`, `const`, `strength`, `dex`, `int`, `wis`, `cha`, `init`, `ac`) VALUES ('" ..player:GetGUIDLow().. "', '1', '54', '" ..constitution.. "', '" ..strength.. "', '" ..dexterity.. "', '" ..intellect.. "', '" ..wisdom.. "', '" ..charisma.. "', '" ..DNDClass:GetInt32(6).. "', '" ..ac.. "');")
		print("processed for race no skin!")
		print("processed for race no skin!")
		print("processed for race no skin!")
		return false
	else
		player:SendBroadcastMessage("There was an error in handling your character sheet stats! Please contact an admin right away.")
		print("ERROR")
		print("ERROR")
		print("ERROR")
		return false
	end
end

local function InfluenceWrite(event, player)
	local InfluenceQuery1 = CharDBQuery("SELECT curr, max, level FROM character_influence WHERE guid = " ..player:GetGUIDLow().. ";")
	if InfluenceQuery1 ~= nil then
		return false
	else
		CharDBExecute("INSERT INTO `characters`.`character_influence` (`guid`, `curr`, `max`, `level`) VALUES (" ..player:GetGUIDLow().. ", 1, 100, 1);")
		return false
	end
end

--- define a pointer to the function. most important part fam
M.Sterilize = Sterilize
M.GMBroadcast3 = GMBroadcast3
M.Check = Check
M.DNDWrite = DNDWrite
M.InfluenceWrite = InfluenceWrite

RegisterPlayerEvent(30, DNDWrite)
RegisterPlayerEvent(30, InfluenceWrite)

return M;