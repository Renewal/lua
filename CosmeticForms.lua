local function Form1(eventId, delay, repeats, player)
	local CosmeticQuery1 = WorldDBQuery("SELECT value1, value2 FROM lua_intid WHERE id = " ..spell1.. ";")
	for b=1,CosmeticQuery1:GetRowCount(),1 do
		if (player:HasAura(CosmeticQuery1:GetInt32(0)) == true) then
			player:SetDisplayId(CosmeticQuery1:GetInt32(1))
			player:RemoveAura(CosmeticQuery1:GetInt32(0))
			return false
		end
		CosmeticQuery1:NextRow()
	end
end

local function BearCosmetic(event, player, spell, skipCheck)
	if (spell:GetEntry() == 9634) or (spell:GetEntry() == 768) or (spell:GetEntry() == 763) then
		spell1 = tonumber(spell:GetEntry())
		player:RegisterEvent(Form1, 100, 1)
	else
		return false
	end
end

RegisterPlayerEvent(5, BearCosmetic)