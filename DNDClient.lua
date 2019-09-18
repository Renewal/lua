local AIO = AIO or require("AIO")

if AIO.AddAddon() then
	return
end

local DNDHandlers = AIO.AddHandlers("DND", {})

-- functions/definitions

-- char sheet actions based on target
function Name()
local charname = GetUnitName("player", false)
local targetname = GetUnitName("target", false)
	if (targetname ~= nil) and (targetname ~= charname) then
		MasterCharSheetText1:SetText(targetname.. "'s Character Sheet")
	else
		MasterCharSheetText1:SetText(charname.. "'s Character Sheet")
	end
end

-- array set for character portrait icons. 2 = male, 3 = female
char_icons_male = {
["Human"] = {"Interface/ICONS/Achievement_Character_Human_Male.blp", 2},
["Dwarf"] = {"Interface/ICONS/Achievement_Character_Dwarf_Male.blp", 2},
["Night Elf"] = {"Interface/ICONS/Achievement_Character_Nightelf_Male.blp", 2},
["Gnome"] = {"Interface/ICONS/Achievement_Character_Gnome_Male.blp", 2},
["Draenei"] = {"Interface/ICONS/Achievement_Character_Draenei_Male.blp", 2},
["Orc"] = {"Interface/ICONS/Achievement_Character_Orc_Male.blp", 2},
["Undead"] = {"Interface/ICONS/Achievement_Character_Undead_Male.blp", 2},
["Scourge"] = {"Interface/ICONS/Achievement_Character_Undead_Male.blp", 2},
["Tauren"] = {"Interface/ICONS/Achievement_Character_Tauren_Male.blp", 2},
["Blood Elf"] = {"Interface/ICONS/Achievement_Character_Bloodelf_Male.blp", 2},
["Troll"] = {"Interface/ICONS/Achievement_Character_Troll_Male.blp", 2},
}

char_icons_female = {
["Human"] = {"Interface/ICONS/Achievement_Character_Human_Female.blp", 3},
["Dwarf"] = {"Interface/ICONS/Achievement_Character_Dwarf_Female.blp", 3},
["Night Elf"] = {"Interface/ICONS/Achievement_Character_Nightelf_Female.blp", 3},
["Gnome"] = {"Interface/ICONS/Achievement_Character_Gnome_Female.blp", 3},
["Draenei"] = {"Interface/ICONS/Achievement_Character_Draenei_Female.blp", 3},
["Orc"] = {"Interface/ICONS/Achievement_Character_Orc_Female.blp", 3},
["Undead"] = {"Interface/ICONS/Achievement_Character_Undead_Female.blp", 3},
["Scourge"] = {"Interface/ICONS/Achievement_Character_Undead_Female.blp",3},
["Tauren"] = {"Interface/ICONS/Achievement_Character_Tauren_Female.blp", 3},
["Blood Elf"] = {"Interface/ICONS/Achievement_Character_Bloodelf_Female.blp", 3},
["Troll"] = {"Interface/ICONS/Achievement_Character_Troll_Female.blp", 3},
}

-- function to set texture based on above array
local function IconSet()
local sex = UnitSex("player")
local race = UnitRace("player")
	if (sex == 2) then
		CharIcon:SetTexture(char_icons_male[race][1])
	else
		CharIcon:SetTexture(char_icons_female[race][1])
	end
end

-- precursor for UpdateStats
function GrabStats()
	AIO.Handle("DND", "GetCharStats")
end

-- precursor for Weapons
function GrabWeapons()
	AIO.Handle("DND", "GetWeapons")
end

-- precursor for Weaver Status
function GrabWeaverStatus()
	AIO.Handle("DND", "GetWeaverStatus")
end

attribute_array = {
["dex"] = {"Dexterity"},
["`int`"] = {"Intellect"},
["wis"] = {"Wisdom"},
["cha"] = {"Charisma"},
["strength"] = {"Strength"},
["const"] = {"Constitution"},
["ac"] = {"Armor Class"},
["AC"] = {"Armor Class"},
}

-- used on /reload to grab weapon stats
function DNDHandlers.Weapons(player, die_amount, die_sides, ac_mod, attribute, slot, name)
	renamed = attribute_array[attribute][1]
	
	if (slot == "mh") then
		MainHandButtonFont:SetText("|cffFFFFFF" ..name.. "\n" ..die_amount.. "d" ..die_sides.. "\nAC: " ..ac_mod.. "\nStat: " ..renamed.. "|r")
	elseif (slot == "oh") then
		OffHandButtonFont:SetText("|cffFFFFFF" ..name.. "\n" ..die_amount.. "d" ..die_sides.. "\nAC: " ..ac_mod.. "\nStat: " ..renamed.. "|r")
	elseif (slot == "ranged") then
		RangedButtonFont:SetText("|cffFFFFFF" ..name.. "\n" ..die_amount.. "d" ..die_sides.. "\nAC: " ..ac_mod.. "\nStat: " ..renamed.. "|r")
	end
end

-- used on every /reload to grab stats
function DNDHandlers.UpdateStats(player, level, points, const, strength, dex, int, wis, cha, init, constmod, strengthmod, dexmod, intmod, wismod, chamod, ac, hp)
	MasterCharSheetText2:SetText("Level " ..level)
	ConstitutionButtonFont:SetText(const)
	StrengthButtonFont:SetText(strength)
	DexterityButtonFont:SetText(dex)
	IntellectButtonFont:SetText(int)
	WisdomButtonFont:SetText(wis)
	CharismaButtonFont:SetText(cha)
	ConstitutionModText:SetText("|cffFFC125" ..constmod.. "|r")
	StrengthModText:SetText("|cffFFC125" ..strengthmod.. "|r")
	DexterityModText:SetText("|cffFFC125" ..dexmod.. "|r")
	IntellectModText:SetText("|cffFFC125" ..intmod.. "|r")
	WisdomModText:SetText("|cffFFC125" ..wismod.. "|r")
	CharismaModText:SetText("|cffFFC125" ..chamod.. "|r")
	ArmorClassButtonFont:SetText(ac)
	HealthButtonFont:SetText(hp)
	if (points == 0) then
		MasterCharSheetText5:SetText(nil)
	else
		MasterCharSheetText5:SetText("|cff00FFCC" ..points.. "|r")
	end
end

-- used on every /reload  to refresh weaver status
--[[
function DNDHandlers.WeaverStatus(player, rank)
	if (rank == 0) then
		WeaverShowTexture:SetVertexColor(0.5, 0.5, 0.5)
		WeaverShow:SetScript("OnMouseUp", function() end)
		--WeaverShow:Disable()
	end
end
]]

-- show frame + update names in combat order
function DNDHandlers.ReceiveOpen(player, message, x, name, init)
	if (message == 1) then
		y = tonumber(x + 10)
		t = y
		z = tonumber(x)
		local z = WeaverMain:CreateFontString(x)
		z:SetFont("Fonts\\FRIZQT__.TTF", 10)
		z:SetSize(190, 5)
		z:SetPoint("LEFT", 28, (5 + (15 * x * -1)))
		z:SetText(name)
		z:SetJustifyH("LEFT")
		local t = WeaverMain:CreateFontString(y)
		t:SetFont("Fonts\\FRIZQT__.TTF", 10)
		t:SetSize(50, 5)
		t:SetPoint("RIGHT", -28, (5 + (15 * x * -1)))
		t:SetText(init)
		t:SetJustifyH("RIGHT")
		WeaverMain:SetScript("OnHide", function() x:SetText(nil) y:SetText(nil) x:Hide() y:Hide() end)
		WeaverMain:Show()
		return false
	elseif (message == 2) then
		WeaverMain:Show()
		return false
	end
end

function DNDHandlers.ReceiveOpen2(player)
	WeaverMainButton1:Disable()
	WeaverMainButton1:SetScript("OnMouseUp", function() end)
	WeaverMainButton2:Disable()
	WeaverMainButton2:SetScript("OnMouseUp", function() end)
	WeaverMainButton3:Disable()
	WeaverMainButton3:SetScript("OnMouseUp", function() end)
	WeaverMainButton4:Disable()
	WeaverMainButton4:SetScript("OnMouseUp", function() end)
	WeaverMain:Show()
end

-- used for each + on stats
function DNDHandlers.PlusStats(player, statz, newstatz, newpoints, newmod, ac)
	if (newpoints == 0) then
		MasterCharSheetText5:SetText(nil)
	else
		MasterCharSheetText5:SetText("|cff00FFCC" ..newpoints.. "|r")
	end
	
	if (statz == "const") then
		ConstitutionButtonFont:SetText(newstatz)
		ConstitutionModText:SetText("|cffFFC125" ..newmod.. "|r")
	elseif (statz == "strength") then
		StrengthButtonFont:SetText(newstatz)
		StrengthModText:SetText("|cffFFC125" ..newmod.. "|r")
	elseif (statz == "dex") then
		DexterityButtonFont:SetText(newstatz)	
		DexterityModText:SetText("|cffFFC125" ..newmod.. "|r")
		ArmorClassButtonFont:SetText(ac)
	elseif (statz == "`int`") then
		IntellectButtonFont:SetText(newstatz)
		IntellectModText:SetText("|cffFFC125" ..newmod.. "|r")
	elseif (statz == "wis") then
		WisdomButtonFont:SetText(newstatz)
		WisdomModText:SetText("|cffFFC125" ..newmod.. "|r")
	elseif (statz == "cha") then
		CharismaButtonFont:SetText(newstatz)
		CharismaModText:SetText("|cffFFC125" ..newmod.. "|r")		
	end
end

-- grabs roll results for stats
function DNDHandlers.GetRoll(player, newroll, name, stat_type2)
	-- check to see if in raid, party, or none. do proper chat channel based on those
	renamed = attribute_array[stat_type2][1]
	if (UnitInRaid("target") ~= nil) then
		-- raid chat
		channel = "RAID"
	elseif (UnitInParty("target") ~= nil) then
		-- raid warning
		channel = "PARTY"
	else
		-- emote
		channel = "EMOTE"
	end
	SendChatMessage("|cffFF0000[Roll System]:|r |cffFFC125" ..name.. " has rolled " ..newroll.. " for " ..renamed.. ".|r", channel)
end

-- grabs roll results for damages
function DNDHandlers.GetDamage(player, roll, name, item_name, target_name, roll_type, success)
	if (UnitInRaid("target") ~= nil) then
		-- raid chat
		channel = "RAID"
	elseif (UnitInParty("target") ~= nil) then
		-- raid warning
		channel = "PARTY"
	else
		-- emote
		channel = "EMOTE"
	end
	SendChatMessage("|cffFF0000[Roll System]:|r |cffFFC125" ..name.. " attacked " ..target_name.. " with " ..item_name.. " and rolled " ..roll.. " for " ..roll_type.. ". " ..tostring(success).. "|r", channel)
end

-- accuracy or damage for x weapon
function ConfirmWeapon(slot)
	StaticPopupDialogs["CONFIRM_WEAPON"] = {
	  text = "You are about to roll for accuracy. If you succeed, you can attack for damage next. Continue?",
	  button1 = "Accept", --onaccept
	  button2 = "Decline", -- oncancel
	  OnAccept = function()
		AIO.Handle("DND", "SendAccuracy", slot)
	  end,
	  OnCancel = function()
		--deprecated and used for click damage
		--AIO.Handle("DND", "SendDamage", slot)
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CONFIRM_WEAPON")
end

-- opens npc input for weaver menu
function DNDHandlers.OpenWeaverInput(player)
	WeaverMainInput:Show()
end

-- invite to combat rotation
function DNDHandlers.ConfirmInvite(player, player_name, target_guid)
	StaticPopupDialogs["CONFIRM_COMBAT_ROTATION"] = {
	  text = "You have been invited to a combat rotation by " ..player_name.. ", do you accept?",
	  button1 = "Accept", --onaccept
	  button2 = "Decline", -- oncancel
	  OnAccept = function()
		response = 1
		AIO.Handle("DND", "SendResponse", player_name, target_guid, response)
	  end,
	  OnCancel = function()
		response = 2
		AIO.Handle("DND", "SendResponse", player_name, target_guid, response)
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CONFIRM_COMBAT_ROTATION")
end

-- clear targets
function ConfirmClearTargets()
	StaticPopupDialogs["CLEAR_TARGETS"] = {
	  text = "Are you sure you want to clear your combat rotation?",
	  button1 = "Accept", --onaccept
	  button2 = "Decline", -- oncancel
	  OnAccept = function()
		response = 1
		AIO.Handle("DND", "ClearTargets", response)
	  end,
	  OnCancel = function()
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CLEAR_TARGETS")
end

-- confirm assign creature
-- clear targets
function ConfirmAssignCreature(input1, input2, input3, input4)
	StaticPopupDialogs["CONFIRM_CREATURE"] = {
	  text = "Are you sure you want to add this creature to your combat rotation?",
	  button1 = "Accept", --onaccept
	  button2 = "Decline", -- oncancel
	  OnAccept = function()
		mass = false
		AIO.Handle("DND", "AssignTarget", input1, input2, input3, input4, mass)
	  end,
	  OnCancel = function()
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CONFIRM_CREATURE")
end

-- creature en masse
function ConfirmAssignCreatureMass(input1, input2, input3, input4)
	StaticPopupDialogs["CONFIRM_CREATURE_MASS"] = {
	  text = "Are you sure you want update all creatures with the same name in your combat rotation?",
	  button1 = "Accept", --onaccept
	  button2 = "Decline", -- oncancel
	  OnAccept = function()
		mass = true
		AIO.Handle("DND", "AssignTarget", input1, input2, input3, input4, mass)
	  end,
	  OnCancel = function()
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CONFIRM_CREATURE_MASS")
end

function ConfirmRollInit()
	StaticPopupDialogs["CONFIRM_ROLL_INIT"] = {
	  text = "Are you sure you want to reroll all iniative for your combat rotation?",
	  button1 = "Accept", --onaccept
	  button2 = "Decline", -- oncancel
	  OnAccept = function()
		mass = true
		AIO.Handle("DND", "RollInit")
	  end,
	  OnCancel = function()
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CONFIRM_ROLL_INIT")
end

function ConfirmCombat()
	StaticPopupDialogs["CONFIRM_COMBAT"] = {
	  text = "Do you wish to start or stop combat?",
	  button1 = "Start", --onaccept
	  button2 = "Stop", -- oncancel
	  OnAccept = function()
		begin = true
		AIO.Handle("DND", "Combat", begin)
	  end,
	  OnCancel = function()
		begin = false
		AIO.Handle("DND", "Combat", begin)
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CONFIRM_COMBAT")
end

function ConfirmStart()
	StaticPopupDialogs["CONFIRM_START"] = {
	  text = "Do you wish to start your turn? You will have five seconds to move immediately after accepting.",
	  button1 = "Accept", --onaccept
	  button2 = "Decline", -- oncancel
	  OnAccept = function()
		StartFrame:Hide()
		AIO.Handle("DND", "StartTurn")
	  end,
	  OnCancel = function()
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CONFIRM_START")
end

function ConfirmSpell1()
	StaticPopupDialogs["CONFIRM_SPELLS1"] = {
	  text = "You are about to attack. Do you wish to strike with your mainhand or offhand?",
	  button1 = "Mainhand", --onaccept
	  button2 = "Offhand", -- oncancel
	  OnAccept = function()
		slot = 15
		AIO.Handle("DND", "AttackSpells", slot)
	  end,
	  OnCancel = function()
		slot = 16
		AIO.Handle("DND", "AttackSpells", slot)
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CONFIRM_SPELLS1")
end

-- "START!" pop up
function DNDHandlers.Start(player)
	StartFrame:Show()
end

-- microbutton
local SheetOpen = CreateFrame("Button", "SheetOpen", UIParent, nil)
SheetOpen:SetPoint("BOTTOM", 229, 2)
SheetOpen:EnableMouse(true)
SheetOpen:SetSize(28, 58)
SheetOpen:SetNormalTexture("Interface/BUTTONS/UI-MicroButton-Abilities-Disabled.blp")
SheetOpen:SetHighlightTexture("Interface/BUTTONS/UI-MicroButton-Abilities-Up.blp")
SheetOpen:SetPushedTexture("Interface/BUTTONS/UI-MicroButton-Abilities-Down.blp")
SheetOpen:SetScript("OnMouseUp", function() MasterCharSheet:Show() PlaySound("GAMEDIALOGOPEN", "SFX") Name() end)
SheetOpen:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 185) GameTooltip:SetText("Character Sheet\n|cffFFFFFFClick to open your character sheet. All the information needed for roll-based encounters is here. You can also use this to set your character sheet stats and reset them.|r" , nil, nil, nil, 1, true) end)
SheetOpen:SetScript("OnLeave", function() GameTooltip:Hide() end)
SheetOpen:SetFrameLevel(100)


-- char sheet
local MasterCharSheet = CreateFrame("Frame", "MasterCharSheet", UIParent, "UIPanelDialogTemplate")
MasterCharSheet:SetSize(350, 500)
MasterCharSheet:SetMovable(true)
MasterCharSheet:EnableMouse(true)
MasterCharSheet:SetToplevel(true)
MasterCharSheet:RegisterForDrag("LeftButton")
MasterCharSheet:SetPoint("CENTER")
MasterCharSheet:SetScript("OnDragStart", MasterCharSheet.StartMoving)
MasterCharSheet:SetScript("OnHide", MasterCharSheet.StopMovingOrSizing)
MasterCharSheet:SetScript("OnDragStop", MasterCharSheet.StopMovingOrSizing)
AIO.SavePosition(MasterCharSheet)
local MasterCharSheetText1 = MasterCharSheet:CreateFontString("MasterCharSheetText1")
MasterCharSheetText1:SetFont("Fonts\\FRIZQT__.TTF", 12)
MasterCharSheetText1:SetSize(190, 5)
MasterCharSheetText1:SetPoint("CENTER", -10, 235)
local MasterCharSheetText2 = MasterCharSheet:CreateFontString("MasterCharSheetText2")
MasterCharSheetText2:SetFont("Fonts\\FRIZQT__.TTF", 12)
MasterCharSheetText2:SetSize(50, 5)
MasterCharSheetText2:SetPoint("TOPLEFT", 100, -53)
MasterCharSheetText2:SetJustifyH("left")
MasterCharSheetText2:SetText("Level 1")
local MasterCharSheetText3 = MasterCharSheet:CreateFontString("MasterCharSheetText3")
MasterCharSheetText3:SetFont("Fonts\\FRIZQT__.TTF", 12)
MasterCharSheetText3:SetSize(100, 5)
MasterCharSheetText3:SetPoint("TOPLEFT", 100, -75)
MasterCharSheetText3:SetJustifyH("left")
MasterCharSheetText3:SetText(UnitRace("player"))
local MasterCharSheetText4 = MasterCharSheet:CreateFontString("MasterCharSheetText4")
MasterCharSheetText4:SetFont("Fonts\\FRIZQT__.TTF", 12)
MasterCharSheetText4:SetSize(50, 5)
MasterCharSheetText4:SetPoint("TOPLEFT", 100, -97)
MasterCharSheetText4:SetJustifyH("left")
MasterCharSheetText4:SetText(UnitClass("player"))
MasterCharSheet:SetClampedToScreen(true)
AIO.SavePosition(MasterCharSheet)
MasterCharSheet:Hide()

-- char icon texture + points text
local CharIcon = MasterCharSheet:CreateTexture("CharIcon")
CharIcon:SetSize(64, 64)
CharIcon:SetPoint("TOPLEFT", 30, -47)
local MasterCharSheetText5 = MasterCharSheet:CreateFontString("MasterCharSheetText5")
MasterCharSheetText5:SetFont("Fonts\\FRIZQT__.TTF", 100)
MasterCharSheetText5:SetSize(50, 5)
MasterCharSheetText5:SetPoint("TOPLEFT", 37, -80)
MasterCharSheetText5:SetJustifyH("CENTER")
MasterCharSheetText5:SetText("|cff00FFCC54|r")

-- some combat UI
local function CombatUI()
local StartFrame = CreateFrame("Frame", "StartFrame", UIParent, nil)
StartFrame:SetSize(85, 85)
StartFrame:SetMovable(true)
StartFrame:EnableMouse(true)
StartFrame:SetToplevel(true)
StartFrame:RegisterForDrag("LeftButton")
StartFrame:SetPoint("CENTER")
StartFrame:SetScript("OnDragStart", MasterCharSheet.StartMoving)
StartFrame:SetScript("OnHide", MasterCharSheet.StopMovingOrSizing)
StartFrame:SetScript("OnDragStop", MasterCharSheet.StopMovingOrSizing)
StartFrame:Hide()

local StartFrameButton = CreateFrame("Button", "StartFrameButton", StartFrame, "UIPanelButtonTemplate")
StartFrameButton:SetPoint("CENTER", 0, 0)
StartFrameButton:EnableMouse(true)
StartFrameButton:SetSize(75, 75)
StartFrameButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") ConfirmStart() end)
StartFrameButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
StartFrameButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
StartFrameButton:SetText("Start!")
StartFrameButton:SetNormalTexture(nil)
local StartFrameButtonTexture = StartFrameButton:CreateTexture("StartFrameButtonTexture", "ARTWORK")
StartFrameButtonTexture:SetTexture("Interface/ICONS/INV_Sword_04.blp")
StartFrameButtonTexture:SetAllPoints()
local StartFrameButtonFont = StartFrameButton:CreateFontString("StartFrameButtonFont")
StartFrameButtonFont:SetFont("Fonts\\FRIZQT__.TTF", 20)
StartFrameButtonFont:SetText("Start!")
StartFrameButtonFont:SetPoint("CENTER", 0, 0)
StartFrameButton:SetFontString(StartFrameButtonFont)
end


-- all weaver UI
-- TO DO: MAKE SCROLLBAR FOR MAIN SCREEN
local function MakeWeaver()
-- button on char sheet to open weaver frame
local WeaverShow = CreateFrame("Button", "WeaverShow", MasterCharSheet, "UIPanelButtonTemplate")
WeaverShow:SetPoint("BOTTOMLEFT", 257, 25)
WeaverShow:EnableMouse(true)
WeaverShow:SetSize(64, 64)
WeaverShow:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") AIO.Handle("DND", "SendOpen") print("open") end)
WeaverShow:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Weaver Panel\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
WeaverShow:SetScript("OnLeave", function() GameTooltip:Hide() end)
WeaverShow:SetNormalTexture(nil)
local WeaverShowTexture = WeaverShow:CreateTexture("WeaverShowTexture", "ARTWORK")
WeaverShowTexture:SetTexture("Interface/ICONS/Mail_GMIcon.blp")
WeaverShowTexture:SetAllPoints()
local WeaverShowFont = WeaverShow:CreateFontString("WeaverShowFont")
WeaverShowFont:SetFont("Fonts\\FRIZQT__.TTF", 20)
WeaverShowFont:SetText(nil)
WeaverShowFont:SetPoint("CENTER", 0, 0)
WeaverShow:SetFontString(WeaverShowFont)

-- main frame
local WeaverMain = CreateFrame("Frame", "WeaverMain", UIParent, "UIPanelDialogTemplate")
WeaverMain:SetSize(315, 300)
WeaverMain:SetMovable(true)
WeaverMain:EnableMouse(true)
WeaverMain:SetToplevel(true)
WeaverMain:RegisterForDrag("LeftButton")
WeaverMain:SetPoint("CENTER")
WeaverMain:SetScript("OnDragStart", WeaverMain.StartMoving)
WeaverMain:SetScript("OnHide", WeaverMain.StopMovingOrSizing)
WeaverMain:SetScript("OnDragStop", WeaverMain.StopMovingOrSizing)
AIO.SavePosition(WeaverMain)
WeaverMain:Hide()
local WeaverMainTextFont1 = WeaverMain:CreateFontString("WeaverMainTextFont1")
WeaverMainTextFont1:SetFont("Fonts\\FRIZQT__.TTF", 12)
WeaverMainTextFont1:SetSize(200, 100)
WeaverMainTextFont1:SetPoint("CENTER", -3, 135)
WeaverMainTextFont1:SetJustifyH("center")
WeaverMainTextFont1:SetText("Weaver Control Panel")
local WeaverMainTextFont2 = WeaverMain:CreateFontString("WeaverMainTextFont2")
WeaverMainTextFont2:SetFont("Fonts\\FRIZQT__.TTF", 12)
WeaverMainTextFont2:SetSize(200, 100)
WeaverMainTextFont2:SetPoint("CENTER", -28, 10)
WeaverMainTextFont2:SetJustifyH("LEFT")
WeaverMainTextFont2:SetText("|cffFFC125Name|r")
local WeaverMainTextFont3 = WeaverMain:CreateFontString("WeaverMainTextFont3")
WeaverMainTextFont3:SetFont("Fonts\\FRIZQT__.TTF", 12)
WeaverMainTextFont3:SetSize(200, 100)
WeaverMainTextFont3:SetPoint("CENTER", 28, 10)
WeaverMainTextFont3:SetJustifyH("RIGHT")
WeaverMainTextFont3:SetText("|cffFFC125Init|r")

local WeaverMainButton1 = CreateFrame("Button", "WeaverMainButton1", WeaverMain, "UIPanelButtonTemplate")
WeaverMainButton1:SetPoint("TOPLEFT", 25, -40)
WeaverMainButton1:EnableMouse(true)
WeaverMainButton1:SetSize(125, 30)
WeaverMainButton1:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") AIO.Handle("DND", "OpenInput") end)
WeaverMainButton1:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
WeaverMainButton1:SetScript("OnLeave", function() GameTooltip:Hide() end)
WeaverMainButton1:SetText("Assign Target")

local WeaverMainButton2 = CreateFrame("Button", "WeaverMainButton2", WeaverMainButton1, "UIPanelButtonTemplate")
WeaverMainButton2:SetPoint("CENTER", 140, 0)
WeaverMainButton2:EnableMouse(true)
WeaverMainButton2:SetSize(125, 30)
WeaverMainButton2:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") ConfirmRollInit() end)
WeaverMainButton2:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
WeaverMainButton2:SetScript("OnLeave", function() GameTooltip:Hide() end)
WeaverMainButton2:SetText("Roll Initiative")

local WeaverMainButton3 = CreateFrame("Button", "WeaverMainButton3", WeaverMainButton1, "UIPanelButtonTemplate")
WeaverMainButton3:SetPoint("CENTER", 140, -40)
WeaverMainButton3:EnableMouse(true)
WeaverMainButton3:SetSize(125, 30)
WeaverMainButton3:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") ConfirmCombat() end)
WeaverMainButton3:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
WeaverMainButton3:SetScript("OnLeave", function() GameTooltip:Hide() end)
WeaverMainButton3:SetText("Toggle Combat")

local WeaverMainButton4 = CreateFrame("Button", "WeaverMainButton4", WeaverMainButton1, "UIPanelButtonTemplate")
WeaverMainButton4:SetPoint("CENTER", 0, -40)
WeaverMainButton4:EnableMouse(true)
WeaverMainButton4:SetSize(125, 30)
WeaverMainButton4:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") ConfirmClearTargets() end)
WeaverMainButton4:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
WeaverMainButton4:SetScript("OnLeave", function() GameTooltip:Hide() end)
WeaverMainButton4:SetText("Clear Targets")


-- input menu
local WeaverMainInput = CreateFrame("Frame", "WeaverMainInput", UIParent, "UIPanelDialogTemplate")
WeaverMainInput:SetSize(300, 340)
WeaverMainInput:SetMovable(true)
WeaverMainInput:EnableMouse(true)
WeaverMainInput:SetToplevel(true)
WeaverMainInput:RegisterForDrag("LeftButton")
WeaverMainInput:SetPoint("CENTER")
WeaverMainInput:SetScript("OnDragStart", WeaverMainInput.StartMoving)
WeaverMainInput:SetScript("OnHide", WeaverMainInput.StopMovingOrSizing)
WeaverMainInput:SetScript("OnDragStop", WeaverMainInput.StopMovingOrSizing)
AIO.SavePosition(WeaverMainInput)
WeaverMainInput:Hide()

local WeaverInput1 = CreateFrame("EditBox", "WeaverInput1", WeaverMainInput, "InputBoxTemplate")
WeaverInput1:SetSize(75, 75)
WeaverInput1:SetAutoFocus(false)
WeaverInput1:SetPoint("CENTER", 0, 65)
WeaverInput1:SetScript("OnEnterPressed", WeaverInput1.ClearFocus)
WeaverInput1:SetScript("OnEscapePressed", WeaverInput1.ClearFocus)
local WeaverInputFont1 = WeaverInput1:CreateFontString("WeaverInputFont1")
WeaverInputFont1:SetFont("Fonts\\stonehenge.ttf", 14)
WeaverInputFont1:SetSize(100, 100)
WeaverInputFont1:SetPoint("CENTER", -105, 0)
WeaverInputFont1:SetJustifyH("RIGHT")
WeaverInputFont1:SetText("|cffFFC125Armor Class|r")
local WeaverInputTexture1 = WeaverInput1:CreateTexture("WeaverInputTexture1")
WeaverInputTexture1:SetSize(40, 40)
WeaverInputTexture1:SetPoint("CENTER", 70, 0)
WeaverInputTexture1:SetTexture("Interface/ICONS/DNDArmorClass.blp")

local WeaverInput2 = CreateFrame("EditBox", "WeaverInput2", WeaverInput1, "InputBoxTemplate")
WeaverInput2:SetSize(75, 75)
WeaverInput2:SetAutoFocus(false)
WeaverInput2:SetPoint("CENTER", 0, 50)
WeaverInput2:SetScript("OnEnterPressed", WeaverInput2.ClearFocus)
WeaverInput2:SetScript("OnEscapePressed", WeaverInput2.ClearFocus)
local WeaverInputFont2 = WeaverInput2:CreateFontString("WeaverInputFont2")
WeaverInputFont2:SetFont("Fonts\\stonehenge.ttf", 14)
WeaverInputFont2:SetSize(100, 100)
WeaverInputFont2:SetPoint("CENTER", -105, 0)
WeaverInputFont2:SetJustifyH("RIGHT")
WeaverInputFont2:SetText("|cffFFC125Health Points|r")
local WeaverInputTexture2 = WeaverInput2:CreateTexture("WeaverInputTexture2")
WeaverInputTexture2:SetSize(40, 40)
WeaverInputTexture2:SetPoint("CENTER", 70, 0)
WeaverInputTexture2:SetTexture("Interface/ICONS/DNDHealth.blp")

local WeaverInput3 = CreateFrame("EditBox", "WeaverInput3", WeaverInput1, "InputBoxTemplate")
WeaverInput3:SetSize(75, 75)
WeaverInput3:SetAutoFocus(false)
WeaverInput3:SetPoint("CENTER", 0, -50)
WeaverInput3:SetScript("OnEnterPressed", WeaverInput3.ClearFocus)
WeaverInput3:SetScript("OnEscapePressed", WeaverInput3.ClearFocus)
local WeaverInputFont3 = WeaverInput3:CreateFontString("WeaverInputFont3")
WeaverInputFont3:SetFont("Fonts\\stonehenge.ttf", 14)
WeaverInputFont3:SetSize(100, 100)
WeaverInputFont3:SetPoint("CENTER", -105, 0)
WeaverInputFont3:SetJustifyH("RIGHT")
WeaverInputFont3:SetText("|cffFFC125Die Sides\n(ie: Xd1)|r")
local WeaverInputTexture3 = WeaverInput3:CreateTexture("WeaverInputTexture3")
WeaverInputTexture3:SetSize(40, 40)
WeaverInputTexture3:SetPoint("CENTER", 70, 0)
WeaverInputTexture3:SetTexture("Interface/ICONS/INV_Sword_04.blp")

local WeaverInput4 = CreateFrame("EditBox", "WeaverInput4", WeaverInput1, "InputBoxTemplate")
WeaverInput4:SetSize(75, 75)
WeaverInput4:SetAutoFocus(false)
WeaverInput4:SetPoint("CENTER", 0, -100)
WeaverInput4:SetScript("OnEnterPressed", WeaverInput4.ClearFocus)
WeaverInput4:SetScript("OnEscapePressed", WeaverInput4.ClearFocus)
local WeaverInputFont4 = WeaverInput4:CreateFontString("WeaverInputFont4")
WeaverInputFont4:SetFont("Fonts\\stonehenge.ttf", 14)
WeaverInputFont4:SetSize(100, 100)
WeaverInputFont4:SetPoint("CENTER", -105, 0)
WeaverInputFont4:SetJustifyH("RIGHT")
WeaverInputFont4:SetText("|cffFFC125Die Amount\n(ie: 1dX)|r")
local WeaverInputTexture4 = WeaverInput4:CreateTexture("WeaverInputTexture4")
WeaverInputTexture4:SetSize(40, 40)
WeaverInputTexture4:SetPoint("CENTER", 70, 0)
WeaverInputTexture4:SetTexture("Interface/ICONS/INV_Misc_Dice_02.blp")

local WeaverInputButton1 = CreateFrame("Button", "WeaverInputButton1", WeaverInput1, "UIPanelButtonTemplate")
WeaverInputButton1:SetPoint("CENTER", 0, -150)
WeaverInputButton1:EnableMouse(true)
WeaverInputButton1:SetSize(125, 30)
WeaverInputButton1:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") input1 = tonumber(WeaverInput2:GetText()) input2 = tonumber(WeaverInput1:GetText()) input3 = tonumber(WeaverInput3:GetText()) input4 = tonumber(WeaverInput4:GetText()) if (input1 == nil) or (input2 == nil) or (input3 == nil) or (input4 == nil) then print("You cannot use letters.") return false else ConfirmAssignCreature(input1, input2, input3, input4) end end)
WeaverInputButton1:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
WeaverInputButton1:SetScript("OnLeave", function() GameTooltip:Hide() end)
WeaverInputButton1:SetText("Confirm!")

local WeaverInputButton2 = CreateFrame("Button", "WeaverInputButton1", WeaverInput1, "UIPanelButtonTemplate")
WeaverInputButton2:SetPoint("CENTER", 0, -195)
WeaverInputButton2:EnableMouse(true)
WeaverInputButton2:SetSize(125, 40)
WeaverInputButton2:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") input1 = tonumber(WeaverInput2:GetText()) input2 = tonumber(WeaverInput1:GetText()) input3 = tonumber(WeaverInput3:GetText()) input4 = tonumber(WeaverInput4:GetText()) if (input1 == nil) or (input2 == nil) or (input3 == nil) or (input4 == nil) then print("You cannot use letters.") return false else ConfirmAssignCreatureMass(input1, input2, input3, input4) end end)
WeaverInputButton2:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
WeaverInputButton2:SetScript("OnLeave", function() GameTooltip:Hide() end)
WeaverInputButton2:SetText("Apply To\nSame Names")

end

-- weapons into a function for organization
local function MakeWeapons()
-- event to get weapons on every inventory changed
MasterCharSheet:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
MasterCharSheet:SetScript("OnEvent", function(self, event, slot, hasItem) if (slot == 16) or (slot == 17) or (slot == 18) then OffHandButtonFont:SetText("|cffFFFFFFNot equipped|r") MainHandButtonFont:SetText("|cffFFFFFFNot equipped|r") RangedButtonFont:SetText("|cffFFFFFFNot equipped|r") slotz = tonumber(slot) AIO.Handle("DND", "GetWeapons") end end)

local MasterCharSheetText6 = MasterCharSheet:CreateFontString("MasterCharSheetText6")
MasterCharSheetText6:SetFont("Fonts\\stonehenge.ttf", 16)
MasterCharSheetText6:SetSize(200, 10)
MasterCharSheetText6:SetPoint("BOTTOMLEFT", 178, 357)
MasterCharSheetText6:SetJustifyH("left")
MasterCharSheetText6:SetText("|cffFFC125Equipped Weapons|r")
MasterCharSheetText6:SetWordWrap(true)

local MasterCharSheetText7 = MasterCharSheet:CreateFontString("MasterCharSheetText7")
MasterCharSheetText7:SetFont("Fonts\\stonehenge.ttf", 14)
MasterCharSheetText7:SetSize(200, 10)
MasterCharSheetText7:SetPoint("BOTTOMLEFT", 178, 332)
MasterCharSheetText7:SetJustifyH("left")
MasterCharSheetText7:SetText("|cffFFC125Main Hand|r")
MasterCharSheetText7:SetWordWrap(true)
local MainHandButton = CreateFrame("Button", "MainHandButton", MasterCharSheet, "UIPanelButtonTemplate")
MainHandButton:SetPoint("BOTTOMLEFT", 180, 265)
MainHandButton:EnableMouse(true)
MainHandButton:SetSize(150, 65)
MainHandButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") slot = 15 ConfirmWeapon(slot) end)
MainHandButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
MainHandButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
MainHandButton:SetNormalTexture(nil)
MainHandButton:SetPushedTexture(nil)
local MainHandButtonFont = MainHandButton:CreateFontString("MainHandButtonFont")
MainHandButtonFont:SetSize(150, 65)
MainHandButtonFont:SetFont("Fonts\\stonehenge.ttf", 12)
MainHandButtonFont:SetText("|cffFFFFFFNot equipped|r")
MainHandButtonFont:SetPoint("CENTER", 0, 0)
MainHandButtonFont:SetJustifyH("left")
MainHandButton:SetFontString(MainHandButtonFont)


local MasterCharSheetText8 = MasterCharSheet:CreateFontString("MasterCharSheetText8")
MasterCharSheetText8:SetFont("Fonts\\stonehenge.ttf", 14)
MasterCharSheetText8:SetSize(200, 10)
MasterCharSheetText8:SetPoint("BOTTOMLEFT", 180, 247)
MasterCharSheetText8:SetJustifyH("left")
MasterCharSheetText8:SetText("|cffFFC125Off Hand|r")
MasterCharSheetText8:SetWordWrap(true)
local OffHandButton = CreateFrame("Button", "OffHandButton", MasterCharSheet, "UIPanelButtonTemplate")
OffHandButton:SetPoint("BOTTOMLEFT", 180, 180)
OffHandButton:EnableMouse(true)
OffHandButton:SetSize(150, 65)
OffHandButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") slot = 16 ConfirmWeapon(slot) end)
OffHandButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
OffHandButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
OffHandButton:SetNormalTexture(nil)
OffHandButton:SetPushedTexture(nil)
local OffHandButtonFont = OffHandButton:CreateFontString("OffHandButtonFont")
OffHandButtonFont:SetSize(150, 65)
OffHandButtonFont:SetFont("Fonts\\stonehenge.ttf", 12)
OffHandButtonFont:SetText("|cffFFFFFFNot equipped|r")
OffHandButtonFont:SetPoint("CENTER", 0, 0)
OffHandButtonFont:SetJustifyH("left")
OffHandButton:SetFontString(OffHandButtonFont)


local MasterCharSheetText9 = MasterCharSheet:CreateFontString("MasterCharSheetText9")
MasterCharSheetText9:SetFont("Fonts\\stonehenge.ttf", 14)
MasterCharSheetText9:SetSize(200, 10)
MasterCharSheetText9:SetPoint("BOTTOMLEFT", 182, 162)
MasterCharSheetText9:SetJustifyH("left")
MasterCharSheetText9:SetText("|cffFFC125Ranged|r")
MasterCharSheetText9:SetWordWrap(true)
local RangedButton = CreateFrame("Button", "RangedButton", MasterCharSheet, "UIPanelButtonTemplate")
RangedButton:SetPoint("BOTTOMLEFT", 180, 95)
RangedButton:EnableMouse(true)
RangedButton:SetSize(150, 65)
RangedButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") slot = 17 ConfirmWeapon(slot) end)
RangedButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
RangedButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
RangedButton:SetNormalTexture(nil)
RangedButton:SetPushedTexture(nil)
local RangedButtonFont = RangedButton:CreateFontString("RangedButtonFont")
RangedButtonFont:SetSize(150, 65)
RangedButtonFont:SetFont("Fonts\\stonehenge.ttf", 12)
RangedButtonFont:SetText("|cffFFFFFFNot equipped|r")
RangedButtonFont:SetPoint("CENTER", 0, 0)
RangedButtonFont:SetJustifyH("left")
RangedButton:SetFontString(RangedButtonFont)

end

--- stat icon/buttons/texts/modifiers
-- made into a function for organization's sake
local function Stats()

local ConstitutionButton = CreateFrame("Button", "ConstitutionButton", MasterCharSheet, "UIPanelButtonTemplate")
ConstitutionButton:SetPoint("BOTTOMLEFT", 85, 330)
ConstitutionButton:EnableMouse(true)
ConstitutionButton:SetSize(40, 40)
ConstitutionButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") stat_type = "const" AIO.Handle("DND", "SendRoll", stat_type) end)
ConstitutionButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
ConstitutionButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
ConstitutionButton:SetNormalTexture(nil)
local ConstitutionTexture = ConstitutionButton:CreateTexture("ConstitutionTexture", "ARTWORK")
ConstitutionTexture:SetTexture("Interface/ICONS/Ability_Warrior_BullRush.blp")
ConstitutionTexture:SetAllPoints()
local ConstitutionButtonFont = ConstitutionButton:CreateFontString("ConstitutionButtonFont")
ConstitutionButtonFont:SetFont("Fonts\\FRIZQT__.TTF", 20)
ConstitutionButtonFont:SetText("10")
ConstitutionButtonFont:SetPoint("CENTER", 0, 0)
ConstitutionButton:SetFontString(ConstitutionButtonFont)
local ConstitutionIncrease = CreateFrame("Button", "ConstitutionIncrease", MasterCharSheet, nil)
ConstitutionIncrease:SetSize(30, 30)
ConstitutionIncrease:SetPoint("BOTTOMLEFT", 130, 336)
ConstitutionIncrease:EnableMouse(true)
ConstitutionIncrease:SetNormalTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
ConstitutionIncrease:SetHighlightTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
ConstitutionIncrease:SetPushedTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
ConstitutionIncrease:SetScript("OnMouseUp", function() stat = "const" AIO.Handle("DND", "AddStats", stat) end)
local ConstitutionMod = MasterCharSheet:CreateTexture("ConstitutionMod")
ConstitutionMod:SetSize(40, 40)
ConstitutionMod:SetPoint("BOTTOMLEFT", 30, 330)
ConstitutionMod:SetTexture("Interface/ICONS/INV_Misc_Dice_02.blp")
local ConstitutionModText = MasterCharSheet:CreateFontString("ConstitutionModText")
ConstitutionModText:SetFont("Fonts\\FRIZQT__.TTF", 20)
ConstitutionModText:SetSize(40, 40)
ConstitutionModText:SetPoint("BOTTOMLEFT", 30, 330)
ConstitutionModText:SetJustifyH("CENTER")
ConstitutionModText:SetText("|cffFFC1250|r")


local StrengthButton = CreateFrame("Button", "StrengthButton", MasterCharSheet, "UIPanelButtonTemplate")
StrengthButton:SetPoint("BOTTOMLEFT", 85, 270)
StrengthButton:EnableMouse(true)
StrengthButton:SetSize(40, 40)
StrengthButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") stat_type = "strength" AIO.Handle("DND", "SendRoll", stat_type) end)
StrengthButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
StrengthButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
StrengthButton:SetNormalTexture(nil)
local StrengthTexture = StrengthButton:CreateTexture("StrengthTexture", "ARTWORK")
StrengthTexture:SetTexture("Interface/ICONS/Spell_Nature_Strength.blp")
StrengthTexture:SetAllPoints()
local StrengthButtonFont = StrengthButton:CreateFontString("StrengthButtonFont")
StrengthButtonFont:SetFont("Fonts\\FRIZQT__.TTF", 20)
StrengthButtonFont:SetText("10")
StrengthButtonFont:SetPoint("CENTER", 0, 0)
StrengthButton:SetFontString(StrengthButtonFont)
local StrengthIncrease = CreateFrame("Button", "StrengthIncrease", MasterCharSheet, nil)
StrengthIncrease:SetSize(30, 30)
StrengthIncrease:SetPoint("BOTTOMLEFT", 130, 276)
StrengthIncrease:EnableMouse(true)
StrengthIncrease:SetNormalTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
StrengthIncrease:SetHighlightTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
StrengthIncrease:SetPushedTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
StrengthIncrease:SetScript("OnMouseUp", function() stat = "strength" AIO.Handle("DND", "AddStats", stat) end)
local StrengthMod = MasterCharSheet:CreateTexture("StrengthMod")
StrengthMod:SetSize(40, 40)
StrengthMod:SetPoint("BOTTOMLEFT", 30, 270)
StrengthMod:SetTexture("Interface/ICONS/INV_Misc_Dice_02.blp")
local StrengthModText = MasterCharSheet:CreateFontString("StrengthModText")
StrengthModText:SetFont("Fonts\\FRIZQT__.TTF", 20)
StrengthModText:SetSize(40, 40)
StrengthModText:SetPoint("BOTTOMLEFT", 30, 270)
StrengthModText:SetJustifyH("CENTER")
StrengthModText:SetText("|cffFFC1250|r")

local DexterityButton = CreateFrame("Button", "DexterityButton", MasterCharSheet, "UIPanelButtonTemplate")
DexterityButton:SetPoint("BOTTOMLEFT", 85, 210)
DexterityButton:EnableMouse(true)
DexterityButton:SetSize(40, 40)
DexterityButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") stat_type = "dex" AIO.Handle("DND", "SendRoll", stat_type) end)
DexterityButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
DexterityButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
DexterityButton:SetNormalTexture(nil)
local DexterityTexture = DexterityButton:CreateTexture("DexterityTexture", "ARTWORK")
DexterityTexture:SetTexture("Interface/ICONS/ability_rogue_energeticrecovery.blp")
DexterityTexture:SetAllPoints()
local DexterityButtonFont = DexterityButton:CreateFontString("DexterityButtonFont")
DexterityButtonFont:SetFont("Fonts\\FRIZQT__.TTF", 20)
DexterityButtonFont:SetText("10")
DexterityButtonFont:SetPoint("CENTER", 0, 0)
DexterityButton:SetFontString(DexterityButtonFont)
local DexterityIncrease = CreateFrame("Button", "DexterityIncrease", MasterCharSheet, nil)
DexterityIncrease:SetSize(30, 30)
DexterityIncrease:SetPoint("BOTTOMLEFT", 130, 216)
DexterityIncrease:EnableMouse(true)
DexterityIncrease:SetNormalTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
DexterityIncrease:SetHighlightTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
DexterityIncrease:SetPushedTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
DexterityIncrease:SetScript("OnMouseUp", function() stat = "dex" AIO.Handle("DND", "AddStats", stat) end)
local DexterityMod = MasterCharSheet:CreateTexture("DexterityMod")
DexterityMod:SetSize(40, 40)
DexterityMod:SetPoint("BOTTOMLEFT", 30, 210)
DexterityMod:SetTexture("Interface/ICONS/INV_Misc_Dice_02.blp")
local DexterityModText = MasterCharSheet:CreateFontString("DexterityModText")
DexterityModText:SetFont("Fonts\\FRIZQT__.TTF", 20)
DexterityModText:SetSize(40, 40)
DexterityModText:SetPoint("BOTTOMLEFT", 30, 210)
DexterityModText:SetJustifyH("CENTER")
DexterityModText:SetText("|cffFFC1250|r")

local IntellectButton = CreateFrame("Button", "IntellectButton", MasterCharSheet, "UIPanelButtonTemplate")
IntellectButton:SetPoint("BOTTOMLEFT", 85, 150)
IntellectButton:EnableMouse(true)
IntellectButton:SetSize(40, 40)
IntellectButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") stat_type = "`int`" AIO.Handle("DND", "SendRoll", stat_type) end)
IntellectButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
IntellectButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
IntellectButton:SetNormalTexture(nil)
local IntellectTexture = IntellectButton:CreateTexture("IntellectTexture", "ARTWORK")
IntellectTexture:SetTexture("Interface/ICONS/Spell_Holy_SpiritualGuidence.blp")
IntellectTexture:SetAllPoints()
local IntellectButtonFont = IntellectButton:CreateFontString("IntellectButtonFont")
IntellectButtonFont:SetFont("Fonts\\FRIZQT__.TTF", 20)
IntellectButtonFont:SetText("10")
IntellectButtonFont:SetPoint("CENTER", 0, 0)
IntellectButton:SetFontString(IntellectButtonFont)
local IntellectIncrease = CreateFrame("Button", "IntellectIncrease", MasterCharSheet, nil)
IntellectIncrease:SetSize(30, 30)
IntellectIncrease:SetPoint("BOTTOMLEFT", 130, 156)
IntellectIncrease:EnableMouse(true)
IntellectIncrease:SetNormalTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
IntellectIncrease:SetHighlightTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
IntellectIncrease:SetPushedTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
IntellectIncrease:SetScript("OnMouseUp", function() stat = "`int`" AIO.Handle("DND", "AddStats", stat) end)
local IntellectMod = MasterCharSheet:CreateTexture("IntellectMod")
IntellectMod:SetSize(40, 40)
IntellectMod:SetPoint("BOTTOMLEFT", 30, 150)
IntellectMod:SetTexture("Interface/ICONS/INV_Misc_Dice_02.blp")
local IntellectModText = MasterCharSheet:CreateFontString("IntellectModText")
IntellectModText:SetFont("Fonts\\FRIZQT__.TTF", 20)
IntellectModText:SetSize(40, 40)
IntellectModText:SetPoint("BOTTOMLEFT", 30, 150)
IntellectModText:SetJustifyH("CENTER")
IntellectModText:SetText("|cffFFC1250|r")

local WisdomButton = CreateFrame("Button", "WisdomButton", MasterCharSheet, "UIPanelButtonTemplate")
WisdomButton:SetPoint("BOTTOMLEFT", 85, 90)
WisdomButton:EnableMouse(true)
WisdomButton:SetSize(40, 40)
WisdomButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") stat_type = "wis" AIO.Handle("DND", "SendRoll", stat_type) end)
WisdomButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
WisdomButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
WisdomButton:SetNormalTexture(nil)
local WisdomTexture = WisdomButton:CreateTexture("WisdomTexture", "ARTWORK")
WisdomTexture:SetTexture("Interface/ICONS/Spell_Holy_SurgeOfLight.blp")
WisdomTexture:SetAllPoints()
local WisdomButtonFont = WisdomButton:CreateFontString("WisdomButtonFont")
WisdomButtonFont:SetFont("Fonts\\FRIZQT__.TTF", 20)
WisdomButtonFont:SetText("10")
WisdomButtonFont:SetPoint("CENTER", 0, 0)
WisdomButton:SetFontString(WisdomButtonFont)
local WisdomIncrease = CreateFrame("Button", "WisdomIncrease", MasterCharSheet, nil)
WisdomIncrease:SetSize(30, 30)
WisdomIncrease:SetPoint("BOTTOMLEFT", 130, 96)
WisdomIncrease:EnableMouse(true)
WisdomIncrease:SetNormalTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
WisdomIncrease:SetHighlightTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
WisdomIncrease:SetPushedTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
WisdomIncrease:SetScript("OnMouseUp", function() stat = "wis" AIO.Handle("DND", "AddStats", stat) end)
local WisdomMod = MasterCharSheet:CreateTexture("WisdomMod")
WisdomMod:SetSize(40, 40)
WisdomMod:SetPoint("BOTTOMLEFT", 30, 90)
WisdomMod:SetTexture("Interface/ICONS/INV_Misc_Dice_02.blp")
local WisdomModText = MasterCharSheet:CreateFontString("WisdomModText")
WisdomModText:SetFont("Fonts\\FRIZQT__.TTF", 20)
WisdomModText:SetSize(40, 40)
WisdomModText:SetPoint("BOTTOMLEFT", 30, 90)
WisdomModText:SetJustifyH("CENTER")
WisdomModText:SetText("|cffFFC1250|r")

local CharismaButton = CreateFrame("Button", "CharismaButton", MasterCharSheet, "UIPanelButtonTemplate")
CharismaButton:SetPoint("BOTTOMLEFT", 85, 30)
CharismaButton:EnableMouse(true)
CharismaButton:SetSize(40, 40)
CharismaButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") stat_type = "cha" AIO.Handle("DND", "SendRoll", stat_type) end)
CharismaButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
CharismaButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
CharismaButton:SetNormalTexture(nil)
local CharismaTexture = CharismaButton:CreateTexture("CharismaTexture", "ARTWORK")
CharismaTexture:SetTexture("Interface/ICONS/Spell_Misc_EmotionHappy.blp")
CharismaTexture:SetAllPoints()
local CharismaButtonFont = CharismaButton:CreateFontString("CharismaButtonFont")
CharismaButtonFont:SetFont("Fonts\\FRIZQT__.TTF", 20)
CharismaButtonFont:SetText("10")
CharismaButtonFont:SetPoint("CENTER", 0, 0)
CharismaButton:SetFontString(CharismaButtonFont)
local CharismaIncrease = CreateFrame("Button", "CharismaIncrease", MasterCharSheet, nil)
CharismaIncrease:SetSize(30, 30)
CharismaIncrease:SetPoint("BOTTOMLEFT", 130, 36)
CharismaIncrease:EnableMouse(true)
CharismaIncrease:SetNormalTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Up")
CharismaIncrease:SetHighlightTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
CharismaIncrease:SetPushedTexture("Interface/BUTTONS/UI-SpellbookIcon-NextPage-Down")
CharismaIncrease:SetScript("OnMouseUp", function() stat = "cha" AIO.Handle("DND", "AddStats", stat) end)
local CharismaMod = MasterCharSheet:CreateTexture("CharismaMod")
CharismaMod:SetSize(40, 40)
CharismaMod:SetPoint("BOTTOMLEFT", 30, 30)
CharismaMod:SetTexture("Interface/ICONS/INV_Misc_Dice_02.blp")
local CharismaModText = MasterCharSheet:CreateFontString("CharismaModText")
CharismaModText:SetFont("Fonts\\FRIZQT__.TTF", 20)
CharismaModText:SetSize(40, 40)
CharismaModText:SetPoint("BOTTOMLEFT", 30, 30)
CharismaModText:SetJustifyH("CENTER")
CharismaModText:SetText("|cffFFC1250|r")

local HealthButton = CreateFrame("Button", "HealthButton", MasterCharSheet, "UIPanelButtonTemplate")
HealthButton:SetPoint("TOPLEFT", 258, -47)
HealthButton:EnableMouse(true)
HealthButton:SetSize(64, 64)
--HealthButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") stat_type = "hp" AIO.Handle("DND", "SendRoll", stat_type) end)
HealthButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
HealthButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
HealthButton:SetNormalTexture(nil)
local HealthTexture = HealthButton:CreateTexture("HealthTexture", "ARTWORK")
HealthTexture:SetTexture("Interface/ICONS/DNDHealth.blp")
HealthTexture:SetAllPoints()
local HealthButtonFont = HealthButton:CreateFontString("HealthButtonFont")
HealthButtonFont:SetFont("Fonts\\FRIZQT__.TTF", 20)
HealthButtonFont:SetText("10")
HealthButtonFont:SetPoint("CENTER", 0, 0)
HealthButton:SetFontString(HealthButtonFont)

local ArmorClassButton = CreateFrame("Button", "ArmorClassButton", MasterCharSheet, "UIPanelButtonTemplate")
ArmorClassButton:SetPoint("TOPLEFT", 179, -47)
ArmorClassButton:EnableMouse(true)
ArmorClassButton:SetSize(64, 64)
ArmorClassButton:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") stat_type = "ac" AIO.Handle("DND", "SendRoll", stat_type) end)
ArmorClassButton:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Strength\n|cffFFFFFFStrength is the measure of your character's muscle and raw physical power. Click to roll for Strength.|r" , nil, nil, nil, 1, true) end)
ArmorClassButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
ArmorClassButton:SetNormalTexture(nil)
local ArmorClassTexture = ArmorClassButton:CreateTexture("ArmorClassTexture", "ARTWORK")
ArmorClassTexture:SetTexture("Interface/ICONS/DNDArmorClass.blp")
ArmorClassTexture:SetAllPoints()
local ArmorClassButtonFont = ArmorClassButton:CreateFontString("ArmorClassButtonFont")
ArmorClassButtonFont:SetFont("Fonts\\FRIZQT__.TTF", 20)
ArmorClassButtonFont:SetText("10")
ArmorClassButtonFont:SetPoint("CENTER", 0, 0)
ArmorClassButton:SetFontString(ArmorClassButtonFont)

end

-- frame + event functions for strike
local function Spells1()
	local SpellsFrame1 = CreateFrame("Frame", "SpellsFrame1", UIParent, nil)
	SpellsFrame1:SetSize(1, 1)
	SpellsFrame1:SetPoint("BOTTOMLEFT")
	SpellsFrame1:SetFrameLevel(1)
	SpellsFrame1:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	SpellsFrame1:SetScript("OnEvent", function(unitID, spell, rank, lineID, spellID) if (spellID ~= 90025) or (spellID ~= 90023) then return false elseif (spellID == 90025) then ConfirmSpell1() elseif (spellID == 90023) then slot = 17 AIO.Handle("DND", "AttackSpells", slot) end end)
	SpellsFrame1:Show()
end


-- dnd hp bar
-- todo: add tooltip describing the bar and its purpose
local function HPBar()
	local HPFrame2 = CreateFrame("Frame", "HPFrame2", UIParent, nil)
	local HPFrame = CreateFrame("Frame", "HPFrame", HPFrame2, nil)
	HPFrame:SetBackdrop(
{
    bgFile = nil,
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border.blp",
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
	HPFrame:SetSize(123, 28)
	HPFrame2:SetSize(145, 78)
	local HPFrameText1 = HPFrame:CreateFontString("HPFrameText1")
	HPFrameText1:SetFont("Fonts\\FRIZQT__.TTF", 12)
	HPFrameText1:SetSize(190, 5)
	HPFrameText1:SetPoint("CENTER", 0, 0)
	HPFrameText1:SetText("50/50")
	HPFrame.HPBar = CreateFrame("StatusBar", nil, HPFrame)
	HPFrame.HPBar:SetPoint("TOPLEFT", 7, -7)
	HPFrame.HPBar:SetPoint("TOPRIGHT", -7, -7)
	HPFrame.HPBar:SetHeight(16)
	HPFrame.HPBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	HPFrame.HPBar:GetStatusBarTexture():SetHorizTile(false)
	HPFrame.HPBar:GetStatusBarTexture():SetVertTile(false)
	HPFrame.HPBar:SetMinMaxValues(1, 100)
	HPFrame.HPBar:SetValue(50)
	HPFrame.HPBar:SetStatusBarColor(0.5, 0.1, 0)
	HPFrame.HPBar:SetFrameLevel(1)
	HPFrameText1:Hide()
	HPFrame:SetPoint("CENTER", 0, 0)
	HPFrame2:SetPoint("TOPLEFT", 233, -66)
	HPFrame2:RegisterForDrag("LeftButton")
	HPFrame2:EnableMouse(true)
	HPFrame2:SetMovable(true)
	HPFrame2:SetScript("OnDragStart", HPFrame2.StartMoving)
	HPFrame2:SetScript("OnHide", HPFrame2.StopMovingOrSizing)
	HPFrame2:SetScript("OnDragStop", HPFrame2.StopMovingOrSizing)
	HPFrame2:SetScript("OnEnter", function() HPFrameText1:Show() end)
	HPFrame2:SetScript("OnLeave", function() HPFrameText1:Hide() end)
	AIO.SavePosition(HPFrame2)
	HPFrame2:Hide()
end

-- frame + event functions for hidden frames
local function HiddenFrames()
	local HiddenFrames = CreateFrame("Frame", "HiddenFrames", UIParent, nil)
	HiddenFrames:SetSize(1, 1)
	HiddenFrames:SetPoint("BOTTOMLEFT")
	HiddenFrames:SetFrameLevel(1)
	HiddenFrames:RegisterEvent("PLAYER_TARGET_CHANGED")
	-- looks for waiting aura on player before sending to server to prevent spamming server
	-- grabs hp bar but only if you are in a  turn order (waiting aura)
	HiddenFrames:SetScript("OnEvent", function(cause) for i=1,40 do local _,_,_,_,_,_,_,_,_,_,spellID = UnitAura("player", i, "HARMFUL"); if (spellID == 90018) then AIO.Handle("DND", "HPBarGet") return false end end end)
	HiddenFrames:Show()
end

Spells1()
MakeWeapons()
IconSet()
Stats()
GrabStats()
GrabWeapons()
MakeWeaver()
GrabWeaverStatus()
CombatUI()
HPBar()
HiddenFrames()