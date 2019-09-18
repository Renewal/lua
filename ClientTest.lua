local AIO = AIO or require("AIO")

if AIO.AddAddon() then
	return
end

local GrimHandlers = AIO.AddHandlers("Grim", {})

--- Frame1 start ---
local GrimFrame1 = CreateFrame("Frame", "GrimFrame1", UIParent, nil)
GrimFrame1:SetSize(340, 430)
GrimFrame1:SetMovable(true)
GrimFrame1:EnableMouse(true)
GrimFrame1:SetToplevel(true)
GrimFrame1:RegisterForDrag("LeftButton")
GrimFrame1:SetPoint("CENTER")
GrimFrame1:SetBackdrop(
{
    bgFile = "Interface/TALENTFRAME/DeathKnightUnholy-TopLeft.blp",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border.blp",
    edgeSize = 30,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
GrimFrame1:SetScript("OnDragStart", GrimFrame1.StartMoving)
GrimFrame1:SetScript("OnHide", GrimFrame1.StopMovingOrSizing)
GrimFrame1:SetScript("OnDragStop", GrimFrame1.StopMovingOrSizing)
GrimFrame1:Hide()
GrimFrame1:SetClampedToScreen(true)

--- Close button frame + button
local GrimFrame1F1 = CreateFrame("Frame", "GrimFrame1F1", GrimFrame1)
GrimFrame1F1:SetSize(30, 30)
GrimFrame1F1:EnableMouse(true)
GrimFrame1F1:SetToplevel(true)
GrimFrame1F1:SetPoint("TOPRIGHT",  -5, -5)
GrimFrame1F1:SetBackdrop(
{
    bgFile = "Interface/DialogFrame/UI-DialogBox-Corner.blp",
})
local GrimClose1 = CreateFrame("Button", "GrimClose1", GrimFrame1F1, "UIPanelCloseButton")
GrimClose1:SetPoint("CENTER", 3, 3)
GrimClose1:EnableMouse(true)
GrimClose1:SetSize(29, 29)
GrimClose1:SetScript("OnMouseDown", function() GameTooltip:Hide() PlaySound("GAMEDIALOGCLOSE", "SFX") GrimFrame1:Hide() end)

--- Title frame
local GrimFrame1F2 = CreateFrame("Frame", "GrimFrame1F2", GrimFrame1, nil)
GrimFrame1F2:SetSize(135, 25)
GrimFrame1F2:SetBackdrop(
{
    bgFile = "Interface/CHARACTERFRAME/UI-Party-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
GrimFrame1F2:SetPoint("TOP", 0, 4)

local GrimFrame1F2Text1 = GrimFrame1F2:CreateFontString("GrimFrame1F2Text1")
GrimFrame1F2Text1:SetFont("Fonts\\FRIZQT__.TTF", 13)
GrimFrame1F2Text1:SetSize(190, 5)
GrimFrame1F2Text1:SetPoint("CENTER", 0, 0)
GrimFrame1F2Text1:SetText("|cffFFC125Custom Talents|r")

--- Points available frame
local GrimFrame1F3 = CreateFrame("Frame", "GrimFrame1F3", GrimFrame1, nil)
GrimFrame1F3:SetSize(320, 20)
GrimFrame1F3:SetBackdrop(
{
    bgFile = "Interface/CHARACTERFRAME/UI-Party-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true,
    edgeSize = 10,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
GrimFrame1F3:SetPoint("BOTTOM", 0, 10)
local GrimFrame1F3Text1 = GrimFrame1F3:CreateFontString("GrimFrame1F3Text1")
local count = GetItemCount(29434)
GrimFrame1F3Text1:SetFont("Fonts\\FRIZQT__.TTF", 10)
GrimFrame1F3Text1:SetSize(190, 5)
GrimFrame1F3Text1:SetPoint("CENTER", 0, 1)
GrimFrame1F3Text1:SetText("|cffFFC125Points Available:|r " ..count)

server_talents = {
--[[ Below is information on the array and how to edit it.
{uniqueID, offset X, offset Y, {spell1, spell2, spell3}},
any changes to the "spell" array set need to be copied over to the server script array set and vice versa
--]]
{1, 35, -35, {20217}},
{2, 100, -35, {26889}},
{3, 165, -35, {1784}},
{4, 230, -35, {1842}},
{5, 35, -100, {921}},
{6, 100, -100, {1725}},
{7, 165, -100, {2836}},
{8, 230, -100, {2094}},
}

--Frame1 Button Frame
local GrimFrame1F3 = CreateFrame("Frame", "GrimFrame1F3", GrimFrame1)
GrimFrame1F3:SetSize(340, 430)
GrimFrame1F3:EnableMouse(true)
--GrimFrame1F3:SetToplevel(true)
GrimFrame1F3:SetPoint("TOPLEFT",  0, 0)
GrimFrame1F3:SetBackdrop(nil)
GrimFrame1F3:SetScript("OnDragStart", GrimFrame1.StartMoving)
GrimFrame1F3:SetScript("OnLeave", function() GameTooltip:Hide() end)
GrimFrame1F3:SetScript("OnHide", GrimFrame1.StopMovingOrSizing)
GrimFrame1F3:SetScript("OnDragStop", GrimFrame1.StopMovingOrSizing)

--[[
local function Tooltip1(self, motion, x)
	print("number x: " ..x.. ".")
	for y=1,#server_talents,1 do
		print("number y: " ..y.. ".")
		print("spell is " ..server_talents[x][4][y].. ".")
		if IsSpellKnown(server_talents[x][4][y], false) == true then
		--local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(server_talents[x][4][y])
		--GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		--GameTooltip:SetText("|cffFFFFFF" ..name.. "|r\nUse your tokens to refund your Spells.")
		GameTooltip:Show()
		--BaseFrameFadeIn(ResetFrame_main_AbilityResetButton_Highlight)
		--else
		--	break
		end
	end
end]]--


--Frame1 loop to create more buttons
for x=1,#server_talents,1 do
    local GrimFrame1Bx = CreateFrame("Button", "GrimFrame1B" ..x, GrimFrame1F3, nil)
	-- used for a good pushed texture?
	--local GrimFrame1Bx2 = CreateFrame("Button", "GrimFrame1B" ..x, GrimFrame1, nil)
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(server_talents[x][4][1])
	GrimFrame1Bx:SetPoint("TOPLEFT", server_talents[x][2], server_talents[x][3])
    GrimFrame1Bx:EnableMouse(true)
    GrimFrame1Bx:SetSize(40, 40)
    GrimFrame1Bx:SetPushedTexture(0.5,0.25,0.75,1)
    GrimFrame1Bx:SetHighlightTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight.blp")
	GrimFrame1Bx:SetNormalTexture(icon)
	GrimFrame1Bx:SetScript("OnEnter", function() AIO.Handle("Grim", "ToolTip1", x, spellID) GrimFrame1F3Text1:SetText("|cffFFC125Points Available:|r " ..GetItemCount(29434)) end)
    GrimFrame1Bx:SetScript("OnLeave", function() GameTooltip:Hide() GrimFrame1F3Text1:SetText("|cffFFC125Points Available:|r " ..GetItemCount(29434)) end)
	GrimFrame1Bx:SetScript("OnMouseDown", function() AIO.Handle("Grim", "Learn1", x) PlaySound("ACTIONBARBUTTONDOWN", "SFX") GrimFrame1F3Text1:SetText("|cffFFC125Points Available:|r " ..GetItemCount(29434)) end)
	GrimFrame1Bx:SetScript("OnMouseUp", function() GrimFrame1F3Text1:SetText("|cffFFC125Points Available:|r " ..GetItemCount(29434)) end)
end

function GrimHandlers.TT1(player, x, description)
	for y=1,#server_talents,1 do
		if (server_talents[x][4][y]) == nil then
			break
		else
		--elseif IsSpellKnown(server_talents[x][4][y], false) == true then
		local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(server_talents[x][4][y])
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR", 0, 50)
		--GameTooltip:SetText("|cffFFFFFF" ..name.. "|r\n" ..rank.. "\n" ..description , nil, nil, nil, 1, true)
		--GameTooltip:SetText(GetSpellLink(server_talents[x][4][y]).. "\n test")
		GameTooltip:SetHyperlink(GetSpellLink(server_talents[x][4][y]))
		GameTooltip:Show()
		--BaseFrameFadeIn(ResetFrame_main_AbilityResetButton_Highlight)
		--else
			--break
		end
	end
end

--- Frame1 Scrollbar
local frame = CreateFrame("Frame", "MyFrame", GrimFrame1) 
frame:SetSize(340, 410) 
frame:SetPoint("CENTER") 
--local texture = frame:CreateTexture() 
--texture:SetAllPoints() 
--texture:SetTexture(1,1,1,1) 
--frame.background = texture 
 
--scrollframe 
scrollframe = CreateFrame("ScrollFrame", nil, frame) 
scrollframe:SetPoint("TOPLEFT", 10, -10) 
scrollframe:SetPoint("BOTTOMRIGHT", -10, 10) 
scrollframe:SetToplevel(true)
scrollframe:EnableMouse(true)
--local texture = scrollframe:CreateTexture() 
--texture:SetAllPoints() 
--texture:SetTexture(.5,.5,.5,1) 
frame.scrollframe = scrollframe 
 

scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
scrollbar:SetPoint("TOPRIGHT", 0, -30) 
scrollbar:SetPoint("BOTTOMRIGHT", 0, 30) 
scrollbar:SetMinMaxValues(1, 200) 
scrollbar:SetValueStep(1) 
scrollbar:EnableMouse(true)
scrollbar.scrollStep = 1
scrollbar:SetValue(0) 
scrollbar:SetWidth(16) 
scrollbar:SetScript("OnValueChanged", 
function (self, value) 
self:GetParent():SetVerticalScroll(value) 
end) 
local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
scrollbg:SetAllPoints(scrollbar) 
scrollbg:SetTexture(0, 0, 0, 0.4) 
frame.scrollbar = scrollbar 
scrollframe:SetScrollChild(GrimFrame1F3)


--- Frame1 end ---

--- Guild Master Frame Start --- 

-- main frame
local GuildFrame1 = CreateFrame("Frame", "GuildFrame1", UIParent, "UIPanelDialogTemplate")
GuildFrame1:SetSize(175, 255)
GuildFrame1:SetMovable(true)
GuildFrame1:EnableMouse(true)
GuildFrame1:SetToplevel(true)
GuildFrame1:RegisterForDrag("LeftButton")
GuildFrame1:SetPoint("CENTER")
GuildFrame1:SetScript("OnDragStart", GuildFrame1.StartMoving)
GuildFrame1:SetScript("OnHide", GuildFrame1.StopMovingOrSizing)
GuildFrame1:SetScript("OnDragStop", GuildFrame1.StopMovingOrSizing)
GuildFrame1:Hide()
AIO.SavePosition(GuildFrame1)
local GuildText2 = GuildFrame1:CreateFontString("GuildText2")
GuildText2:SetFont("Fonts\\FRIZQT__.TTF", 12)
GuildText2:SetSize(190, 5)
GuildText2:SetPoint("CENTER", -10, 112)
GuildText2:SetText("Guild Master Panel")
GuildFrame1:SetClampedToScreen(true)

-- assign weaver frame
local GuildFrame2 = CreateFrame("Frame", "GuildFrame2", UIParent, "UIPanelDialogTemplate")
GuildFrame2:SetSize(175, 205)
GuildFrame2:SetMovable(true)
GuildFrame2:EnableMouse(true)
GuildFrame2:SetToplevel(true)
GuildFrame2:RegisterForDrag("LeftButton")
GuildFrame2:SetPoint("CENTER")
GuildFrame2:SetScript("OnDragStart", GuildFrame2.StartMoving)
GuildFrame2:SetScript("OnHide", GuildFrame2.StopMovingOrSizing)
GuildFrame2:SetScript("OnDragStop", GuildFrame2.StopMovingOrSizing)
GuildFrame2:Hide()
AIO.SavePosition(GuildFrame2)
GuildFrame2:SetClampedToScreen(true)
local GuildInput1 = CreateFrame("EditBox", "GuildInput1", GuildFrame2, "InputBoxTemplate")
GuildInput1:SetSize(100, 30)
GuildInput1:SetAutoFocus(false)
GuildInput1:SetPoint("CENTER", 0, 50)
GuildInput1:SetScript("OnEnterPressed", GuildInput1.ClearFocus)
GuildInput1:SetScript("OnEscapePressed", GuildInput1.ClearFocus)
local GuildText4 = GuildFrame2:CreateFontString("GuildText4")
GuildText4:SetFont("Fonts\\FRIZQT__.TTF", 12)
GuildText4:SetSize(190, 5)
GuildText4:SetPoint("CENTER", -45, -10)
GuildText4:SetText("|cffFFC125Weavers|r")
local GuildText5 = GuildFrame2:CreateFontString("GuildText5")
GuildText5:SetFont("Fonts\\FRIZQT__.TTF", 12)
GuildText5:SetSize(190, 5)
GuildText5:SetPoint("RIGHT", 65, -10)
GuildText5:SetText("|cffFFC125Rank|r")
-- lists current weavers + updates length if needed
function GrimHandlers.WeaverShow(player, v, name, rank)
	local GuildText0v = GuildFrame2:CreateFontString("GuildText0" ..v)
	GuildText0v:SetFont("Fonts\\FRIZQT__.TTF", 10)
	GuildText0v:SetSize(190, 5)
	GuildText0v:SetPoint("LEFT", -55, (-10 + (15 * v * -1)))
	if v >= 5 then
		GuildFrame2:SetSize(175, (200 + 20 * (v - 4)))
	end
	GuildText0v:SetText(name)
	local GuildText1v = GuildFrame2:CreateFontString("GuildText1" ..v)
	GuildText1v:SetFont("Fonts\\FRIZQT__.TTF", 10)
	GuildText1v:SetSize(50, 5)
	GuildText1v:SetPoint("RIGHT", -5, (-10 + (15 * v * -1)))
	GuildText1v:SetText(rank)
	GuildFrame2:SetScript("OnHide", function() GuildText0v:SetText("") GuildText1v:SetText("") end)
end


--- try to delete previous entry?
---GuildInput1:SetScript("OnHide", GuildInput1.ClearFocus)
--- okay popup
function confirmweaver()
	local input = GuildInput1:GetText()
	StaticPopupDialogs["ACCEPT_WEAVER"] = {
	  text = "Are you sure you want to assign " ..GuildInput1:GetText().. " as a weaver?",
	  button1 = "Yes",
	  button2 = "No",
	  OnAccept = function()
		  AIO.Handle("Grim", "ApplyWeaver1", input)
		  --AIO.Handle("Grim", "WeaverDisplay")
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("ACCEPT_WEAVER")
end
local GuildButton4 = CreateFrame("Button", "GuildButton4", GuildFrame2, "UIPanelButtonTemplate")
GuildButton4:SetPoint("CENTER", 0, 20)
GuildButton4:EnableMouse(true)
GuildButton4:SetSize(100, 30)
GuildButton4:SetText("Assign")
GuildButton4:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") confirmweaver()  end)
GuildButton4:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 155) GameTooltip:SetText("Assign Weavers\n|cffFFFFFFConfirms the assignment of a weaver after you have entered a valid name.|r" , nil, nil, nil, 1, true) end)
GuildButton4:SetScript("OnLeave", function() GameTooltip:Hide() end)
local GuildText3 = GuildFrame2:CreateFontString("GuildText3")
GuildText3:SetFont("Fonts\\FRIZQT__.TTF", 12)
GuildText3:SetSize(190, 5)
GuildText3:SetPoint("CENTER", -5, 87)
GuildText3:SetText("Assign Weavers")

-- buttons
local GuildButton1 = CreateFrame("Button", "GuildButton1", GuildFrame1, "UIPanelButtonTemplate")
GuildButton1:SetPoint("CENTER", 0, 70)
GuildButton1:EnableMouse(true)
GuildButton1:SetSize(125, 30)
GuildButton1:SetText("Assign Weavers")
GuildButton1:SetScript("OnMouseUp", function() AIO.Handle("Grim", "WeaverDisplay") PlaySound("GAMEDIALOGOPEN", "SFX") GuildFrame1:Hide() GuildFrame2:Show() end)
GuildButton1:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 210) GameTooltip:SetText("Assign Weavers\n|cffFFFFFFAssign a guild member to be a weaver, adding one to their current weaver rank. This requires you to have at least one weaver slot available. You gain one weaver slot for every ten guild members.|r" , nil, nil, nil, 1, true) end)
GuildButton1:SetScript("OnLeave", function() GameTooltip:Hide() end)
local GuildText1 = GuildFrame1:CreateFontString("GuildText1")
GuildText1:SetFont("Fonts\\FRIZQT__.TTF", 10)
GuildText1:SetSize(190, 5)
GuildText1:SetPoint("CENTER", 0, 50)
function GetWeavers()
	local z = 0
	AIO.Handle("Grim", "GetWeaves", z)
end
--GetWeavers()

local GuildButton2 = CreateFrame("Button", "GuildButton2", GuildFrame1, "UIPanelButtonTemplate")
GuildButton2:SetPoint("CENTER", 0, 20)
GuildButton2:EnableMouse(true)
GuildButton2:SetSize(125, 30)
GuildButton2:SetText("Set Wages")
GuildButton2:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") end)


local GuildButton3 = CreateFrame("Button", "GuildButton3", GuildFrame1, "UIPanelButtonTemplate")
GuildButton3:SetPoint("CENTER", 0, -25)
GuildButton3:EnableMouse(true)
GuildButton3:SetSize(125, 30)
GuildButton3:SetText("Set Taxes")
GuildButton3:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") end)

--- officer toggle
function confirmofficertoggle()
	StaticPopupDialogs["TOGGLE_OFFICER"] = {
	  text = "Do you want to disable or enable officer access to the guild panel?",
	  button1 = "Enable",
	  button2 = "Disable",
	  OnAccept = function()
		if IsGuildLeader(UnitName("player")) then
		  AIO.Handle("Grim", "OfficerEnable")
		else
		 print("|cffFFC125You must be the guild leader to do this.|r")
		end
	  end,
	  OnCancel = function()
		if IsGuildLeader(UnitName("player")) then
		  AIO.Handle("Grim", "OfficerDisable")
		else
		 print("|cffFFC125You must be the guild leader to do this.|r")
		end
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("TOGGLE_OFFICER")
end

local GuildButton4 = CreateFrame("Button", "GuildButton3", GuildFrame1, "UIPanelButtonTemplate")
GuildButton4:SetPoint("CENTER", 0, -70)
GuildButton4:EnableMouse(true)
GuildButton4:SetSize(125, 30)
GuildButton4:SetText("Toggle Officers")
GuildButton4:SetScript("OnMouseUp", function() confirmofficertoggle() PlaySound("GAMEDIALOGOPEN", "SFX") end)
GuildButton4:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 197) GameTooltip:SetText("Toggle Officers\n|cffFFFFFFEnable or disable officers being able to view the Guild Master Panel as well. Only the guild master can access this option. This only works for the default Officer rank.|r" , nil, nil, nil, 1, true) end)
GuildButton4:SetScript("OnLeave", function() GameTooltip:Hide() end)

--- reciever for getting weaver count. use the server to send this back when a new weaver is applied.
function GrimHandlers.SetWeavers(player, z)
	local maxmem = GetNumGuildMembers()
	local maxcount = math.floor(maxmem / 10)
	if maxmem < 10 then
		GuildText1:SetText("|cffFFC125Weavers:|r " ..z.. "/" ..1)
	else
		GuildText1:SetText("|cffFFC125Weavers:|r " ..z.. "/" ..maxcount)
	end
end


--- Master Frame start
local MasterFrame1 = CreateFrame("Frame", "MasterFrame1", UIParent)
MasterFrame1:SetSize(50, 55)
MasterFrame1:SetMovable(true)
MasterFrame1:EnableMouse(true)
MasterFrame1:RegisterForDrag("LeftButton")
MasterFrame1:SetPoint("CENTER")
MasterFrame1:SetBackdrop(
{
    bgFile = "Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal-Desaturated.blp",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
MasterFrame1:SetScript("OnDragStart", MasterFrame1.StartMoving)
MasterFrame1:SetScript("OnHide", MasterFrame1.StopMovingOrSizing)
MasterFrame1:SetScript("OnDragStop", MasterFrame1.StopMovingOrSizing)
MasterFrame1:SetClampedToScreen(true)

local MasterButton1 = CreateFrame("Button", "MasterButton1", MasterFrame1, nil)
MasterButton1:SetPoint("CENTER", 0, 10)
MasterButton1:EnableMouse(true)
MasterButton1:SetSize(35, 55)
MasterButton1:SetNormalTexture("Interface/BUTTONS/UI-MicroButton-Abilities-Disabled.blp")
MasterButton1:SetHighlightTexture("Interface/BUTTONS/UI-MicroButton-Abilities-Up.blp")
MasterButton1:SetPushedTexture("Interface/BUTTONS/UI-MicroButton-Abilities-Down.blp")
MasterButton1:SetScript("OnMouseUp", function() AIO.Handle("Grim", "InfluenceUpdate1") PlaySound("GAMEDIALOGOPEN", "SFX") end)
MasterButton1:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 200) GameTooltip:SetText("Influence Panel\n|cffFFFFFFClick to open the Influence Panel. This will show your level, experience, and experience to your next level. You can also use this to navigate to the custom talents.|r" , nil, nil, nil, 1, true) end)
MasterButton1:SetScript("OnLeave", function() GameTooltip:Hide() end)
AIO.SavePosition(MasterFrame1)


--- checks if guild master and adds button/expands frame if yes.
function PanelShow()
	MasterFrame1:SetSize(105, 60)
	local GuildMasterButton1 = CreateFrame("Button", "GuildMasterButton1", MasterFrame1, nil)
	GuildMasterButton1:SetPoint("CENTER", -20, 10)
	GuildMasterButton1:EnableMouse(true)
	GuildMasterButton1:SetSize(35, 55)
	GuildMasterButton1:SetNormalTexture("Interface/images/gm_normal.blp")
	GuildMasterButton1:SetHighlightTexture("Interface/images/gm_hover.blp")
	GuildMasterButton1:SetPushedTexture("Interface/images/gm_pressed.blp")
	GuildMasterButton1:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 0, 140) GameTooltip:SetText("Guild Master Panel\n|cffFFFFFFClick to open Guild Master configuration.|r" , nil, nil, nil, 1, true) end)
	GuildMasterButton1:SetScript("OnLeave", function() GameTooltip:Hide() end)
	MasterButton1:SetPoint("CENTER", 20, 10)
	if IsGuildLeader(UnitName("player")) then
		GuildMasterButton1:SetScript("OnMouseUp", function() GuildFrame1:Show() GetWeavers() PlaySound("GAMEDIALOGOPEN", "SFX") end)
	else
		GuildMasterButton1:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") AIO.Handle("Grim", "OfficerPanelCheck", global1) end)
	end
end


function GuildMasterShow()
	if IsGuildLeader(UnitName("player")) then
		PanelShow()
	else
		MasterFrame1:SetSize(50, 55)
	end
end

function OfficerShow()
	AIO.Handle("Grim", "OfficerCheck")
end

function GrimHandlers.OfficerShow2(player)
	PanelShow()
end

function GrimHandlers.PanelShow2(player)
--	GuildMasterButton1:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") GuildFrame1:Show() GetWeavers() end)
	GuildFrame1:Show()
	GetWeavers()
end

GuildMasterShow()
OfficerShow()

leave = 0
MasterFrame1:RegisterEvent("PLAYER_GUILD_UPDATE")
MasterFrame1:SetScript("OnEvent", function() if leave == 0 then AIO.Handle("Grim", "LeaveWeaves") leave = 1 else leave = 0 end end)

--- Master frame end


--- login stun
local StunFrame1 = CreateFrame("Frame", "StunFrame1", UIParent)
StunFrame1:SetSize(225, 300)
StunFrame1:SetBackdrop(
{
    bgFile = "Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal-Desaturated.blp",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
StunFrame1:SetMovable(true)
StunFrame1:EnableMouse(true)
StunFrame1:SetToplevel(true)
StunFrame1:RegisterForDrag("LeftButton")
StunFrame1:SetPoint("CENTER")
StunFrame1:SetScript("OnDragStart", StunFrame1.StartMoving)
StunFrame1:SetScript("OnHide", StunFrame1.StopMovingOrSizing)
StunFrame1:SetScript("OnDragStop", StunFrame1.StopMovingOrSizing)
function GrimHandlers.LoginStunRemove(player)
	StunFrame1:Show()
end
StunFrame1:Hide()
StunFrame1:SetClampedToScreen(true)
local StunFrameText1 = StunFrame1:CreateFontString("StunFrameText1")
StunFrameText1:SetFont("Fonts\\FRIZQT__.TTF", 12)
StunFrameText1:SetSize(205, 280)
StunFrameText1:SetPoint("LEFT", -5, 50)
StunFrameText1:SetText("Welcome to Project Project, the only project where projects have projects. We wanted to take this time to educated you about the projects though. You know, the hood? The Eazy-E ghetto type of stuff. You know what I mean. Anyways, it's bad out there. Be safe kiddos.", nil, nil, nil, 1, true)
local StunFrameButton1 = CreateFrame("Button", "StunFrameButton1", StunFrame1, "UIPanelButtonTemplate")
StunFrameButton1:SetPoint("CENTER", 0, -50)
StunFrameButton1:EnableMouse(true)
StunFrameButton1:SetSize(125, 30)
StunFrameButton1:SetText("Play!")
StunFrameButton1:SetScript("OnMouseUp", function() AIO.Handle("Grim", "OnLoginStunRemove") PlaySound("GAMEDIALOGOPEN", "SFX") StunFrame1:Hide() end)

--- INFLUENCE FRAMES START ---

local InfluenceFrame1 = CreateFrame("Frame", "InfluenceFrame1", UIParent, "UIPanelDialogTemplate")
InfluenceFrame1:SetSize(250, 350)
InfluenceFrame1:SetMovable(true)
InfluenceFrame1:EnableMouse(true)
InfluenceFrame1:SetToplevel(true)
InfluenceFrame1:RegisterForDrag("LeftButton")
InfluenceFrame1:SetPoint("CENTER")
InfluenceFrame1:SetScript("OnDragStart", InfluenceFrame1.StartMoving)
InfluenceFrame1:SetScript("OnHide", InfluenceFrame1.StopMovingOrSizing)
InfluenceFrame1:SetScript("OnDragStop", InfluenceFrame1.StopMovingOrSizing)
InfluenceFrame1:Hide()
AIO.SavePosition(InfluenceFrame1)
local InfluenceText1 = InfluenceFrame1:CreateFontString("InfluenceText1")
InfluenceText1:SetFont("Fonts\\FRIZQT__.TTF", 12)
InfluenceText1:SetSize(190, 5)
InfluenceText1:SetPoint("CENTER", -10, 159)
InfluenceText1:SetText("Influence Panel")
InfluenceFrame1:SetClampedToScreen(true)

local InfluenceFrame2 = CreateFrame("Frame", "InfluenceFrame2", InfluenceFrame1)
InfluenceFrame2:SetSize(227, 27)
InfluenceFrame2:SetPoint("CENTER", 1, 105)
InfluenceFrame2:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-DialogBox-Background", tile = true, tileSize = 16,
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3, },
})

InfluenceFrame2.bar1 = CreateFrame("StatusBar", nil, InfluenceFrame2)
InfluenceFrame2.bar1:SetPoint("TOPLEFT", 3, -3)
InfluenceFrame2.bar1:SetPoint("TOPRIGHT", -3, -3)
InfluenceFrame2.bar1:SetHeight(21)
InfluenceFrame2.bar1:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
InfluenceFrame2.bar1:GetStatusBarTexture():SetHorizTile(false)
InfluenceFrame2.bar1:GetStatusBarTexture():SetVertTile(false)
InfluenceFrame2.bar1:SetMinMaxValues(1, 100)
InfluenceFrame2.bar1:SetValue(25)
InfluenceFrame2.bar1:SetStatusBarColor(0.5, 0, 0.5)
local InfluenceText2 = InfluenceFrame2:CreateFontString("InfluenceText2")
InfluenceText2:SetFont("Fonts\\FRIZQT__.TTF", 12)
InfluenceText2:SetSize(190, 5)
InfluenceText2:SetPoint("CENTER", 0, 0)
local InfluenceText3 = InfluenceFrame2:CreateFontString("InfluenceText3")
InfluenceText3:SetFont("Fonts\\FRIZQT__.TTF", 12)
InfluenceText3:SetSize(190, 5)
InfluenceText3:SetPoint("CENTER", -75, 28)
InfluenceText3:SetText("|cffFFC125Influence:|r")
local InfluenceText5 = InfluenceFrame2:CreateFontString("InfluenceText5")
InfluenceText5:SetFont("Fonts\\FRIZQT__.TTF", 12)
InfluenceText5:SetSize(190, 5)
InfluenceText5:SetPoint("CENTER", 75, 28)
--- make level update on frame show
InfluenceText5:SetText("Level 1")
local InfluenceText4 = InfluenceFrame2:CreateFontString("InfluenceText4")
InfluenceText4:SetFont("Fonts\\FRIZQT__.TTF", 12)
InfluenceText4:SetSize(210, 300)
InfluenceText4:SetPoint("CENTER", 0, -120)
InfluenceText4:SetJustifyH("left")
InfluenceText4:SetJustifyV("center")
InfluenceText4:SetText("Influence is a measurement of your gameplay. On each level of Influence, you gain |cffFFC125one talent point|r, |cffFFC125three|r |cff9933CC[Influence Token]|r, and the requirement for your next level is |cffFFC125increased by ten points|r. An |cff9933CC[Influence Token]|r can be used at a vendor to purchase items such as material packs, APTs, and even |cffFF9900[Weaver Shards]|r. There are many ways to gain influence, some easy, some hard, but each with their own different reward. These methods will remain unlisted as a result. So, what are you waiting for? Go play and gain some influence!")
local InfluenceButton1 = CreateFrame("Button", "InfluenceButton1", InfluenceFrame2, "UIPanelButtonTemplate")
InfluenceButton1:SetPoint("CENTER", 0, -240)
InfluenceButton1:EnableMouse(true)
InfluenceButton1:SetSize(125, 30)
InfluenceButton1:SetText("Talents")
InfluenceButton1:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") GrimFrame1:Show() InfluenceFrame1:Hide() end)

--- statusbar documentation: http://wowprogramming.com/docs/widgets/StatusBar
-- make bar values update on frame show
function GetValues()
	currval1 = InfluenceFrame2.bar1:GetValue()
	minval, maxval = InfluenceFrame2.bar1:GetMinMaxValues()
	InfluenceText2:SetText(currval1.. " / " ..maxval)
	InfluenceText2:Show()
end

function GrimHandlers.GetValues2(player, currval, maxval, lvl)
	InfluenceFrame2.bar1:SetMinMaxValues(1, maxval)
	InfluenceFrame2.bar1:SetValue(currval)
	InfluenceText2:SetText(currval.. " / " ..maxval)
	InfluenceText5:SetText("Level " ..lvl)
	InfluenceFrame1:Show()
end

--[[
--parent frame 
local frame = CreateFrame("Frame", "MyFrame", UIParent) 
frame:SetSize(150, 200) 
frame:SetPoint("CENTER") 
local texture = frame:CreateTexture() 
texture:SetAllPoints() 
texture:SetTexture(1,1,1,1) 
frame.background = texture 
 
--scrollframe 
scrollframe = CreateFrame("ScrollFrame", nil, frame) 
scrollframe:SetPoint("TOPLEFT", 10, -10) 
scrollframe:SetPoint("BOTTOMRIGHT", -10, 10) 
local texture = scrollframe:CreateTexture() 
texture:SetAllPoints() 
texture:SetTexture(.5,.5,.5,1) 
frame.scrollframe = scrollframe 
 
scrollbar 
scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
scrollbar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -16) 
scrollbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 16) 
scrollbar:SetMinMaxValues(1, 200) 
scrollbar:SetValueStep(1) 
scrollbar.scrollStep = 1
scrollbar:SetValue(0) 
scrollbar:SetWidth(16) 
scrollbar:SetScript("OnValueChanged", 
function (self, value) 
self:GetParent():SetVerticalScroll(value) 
end) 
local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
scrollbg:SetAllPoints(scrollbar) 
scrollbg:SetTexture(0, 0, 0, 0.4) 
frame.scrollbar = scrollbar 
 
--content frame 
local content = CreateFrame("Frame", nil, scrollframe) 
content:SetSize(128, 128) 
local texture = content:CreateTexture() 
texture:SetAllPoints() 
texture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo") 
content.texture = texture 
scrollframe.content = content 
 
scrollframe:SetScrollChild(content)
scrollframe:Show()
--]]

function GrimHandlers.ShowFrame(player)
    GrimFrame1:Show()
end

