function Push(event, player, command)
	if (player:GetGMRank() < 3) then
		return
	elseif (command:find("pull") ~= 1) then
		return
	else
		if (command:find("pull dbc") == 1) then
			player:SendBroadcastMessage("Pulling DBC . . .")
			os.execute ('bash /home/grimreapaa/eluna_server/data/dbc/PushDBC.sh &')
			player:SendBroadcastMessage("DBC has been pulled. You may need to restart the server before the changes can take affect.")
			return false
		elseif (command:find("pull lua") == 1) then
			os.execute ('bash /home/grimreapaa/eluna_server/bin/lua_scripts/PushLUA.sh')
			player:SendBroadcastMessage("LUA has been pulled. You may need to wait a minute or two before reloading to see the changes.")
			return false
		end
	end
end

RegisterPlayerEvent(42, Push)