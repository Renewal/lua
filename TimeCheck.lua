local function TimeCheck(event, player, command)
	if (command:find("time get") ~= 1) then
		return
	else
		player:SendBroadcastMessage(tostring(GetGameTime()))
		return false
	end
end

RegisterPlayerEvent(42, TimeCheck)