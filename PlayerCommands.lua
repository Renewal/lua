local function Census(event, player, command)
	if (command:find("census") ~= 1) then
		return
	else
		people = GetPlayersInWorld(2)
		player:SendBroadcastMessage("|cffCCFF66[Census]:|r There are " ..#people.. " players online.")
		return false
	end
end

local function ResetPhase(event, player, command)
	if (command:find("reset phase") ~= 1) then
		return
	else
		player:SetPhaseMask(1, true)
		return false
	end
end

RegisterPlayerEvent(42, ResetPhase)
RegisterPlayerEvent(42, Census)