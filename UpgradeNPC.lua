-- check to see if player is guild master for upgrade option
-- check to see if player is supposed to be hostile or not

local function UpgradeHello(event, player, creature)
	player:GossipMenuAddItem(0, "Upgrade Me", 65008, 1, false, "Upgrading this soldier will cost $$ from the guild treasury. Continue?")
	player:GossipSendMenu(65008, creature, MenuId)
end

local function ThunkSelect(event, player, creature, sender, intid, code)
	if (intid == 1) then
	end
end

RegisterCreatureGossipEvent(190013, 1, ThunkHello)
RegisterCreatureGossipEvent(190013, 2, ThunkSelect)