local AIO = AIO or require("AIO")

if AIO.AddAddon() then
	return
end

local DeathHandlers = AIO.AddHandlers("DeathSS", {})

local DeathFrame1 = CreateFrame("Frame", "DeathFrame1", UIParent, "UIPanelDialogTemplate")
DeathFrame1:SetSize(250, 225)
DeathFrame1:SetMovable(true)
DeathFrame1:EnableMouse(true)
DeathFrame1:SetToplevel(true)
DeathFrame1:RegisterForDrag("LeftButton")
DeathFrame1:SetPoint("CENTER")
DeathFrame1:SetScript("OnDragStart", DeathFrame1.StartMoving)
DeathFrame1:SetScript("OnHide", DeathFrame1.StopMovingOrSizing)
DeathFrame1:SetScript("OnDragStop", DeathFrame1.StopMovingOrSizing)
AIO.SavePosition(DeathFrame1)
DeathFrame1:SetClampedToScreen(true)
DeathFrame1:Hide()
local DeathText1 = DeathFrame1:CreateFontString("DeathText1")
DeathText1:SetFont("Fonts\\FRIZQT__.TTF", 12)
DeathText1:SetSize(190, 5)
DeathText1:SetPoint("CENTER", -10, 97)
DeathText1:SetText("Death Panel")

function confirmescape()
	StaticPopupDialogs["CONFIRM_ESCAPE"] = {
	  text = "Are you sure you want to use one of your escapes?",
	  button1 = "Yes",
	  button2 = "No",
	  OnAccept = function()
		  AIO.Handle("DeathSS", "EscapeConfirm")
		  DeathFrame1:Hide()
	  end,
	  OnDecline = function()
		  DeathFrame1:Hide()
	  end,
	  timeout = 0,
	  whileDead = false,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CONFIRM_ESCAPE")
end

function confirmsurrender()
	StaticPopupDialogs["CONFIRM_SURRENDER"] = {
	  text = "Are you sure you want to surrender?",
	  button1 = "Yes",
	  button2 = "No",
	  OnAccept = function()
		  AIO.Handle("DeathSS", "SurrenderConfirm")
		  DeathFrame1:Hide()
	  end,
	  OnDecline = function()
		  DeathFrame1:Hide()
	  end,
	  timeout = 0,
	  whileDead = false,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("CONFIRM_SURRENDER")
end

local DeathButton1 = CreateFrame("Button", "DeathButton1", DeathFrame1, "UIPanelButtonTemplate")
DeathButton1:SetPoint("CENTER", 0, -30)
DeathButton1:EnableMouse(true)
DeathButton1:SetSize(125, 30)
DeathButton1:SetText("Surrender")
DeathButton1:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") confirmsurrender() end)

local DeathButton2 = CreateFrame("Button", "DeathButton2", DeathFrame1, "UIPanelButtonTemplate")
DeathButton2:SetPoint("CENTER", 0, -70)
DeathButton2:EnableMouse(true)
DeathButton2:SetSize(125, 30)
DeathButton2:SetText("Escape")
DeathButton2:SetScript("OnMouseUp", function() PlaySound("GAMEDIALOGOPEN", "SFX") confirmescape() end)

local DeathText2 = DeathFrame1:CreateFontString("DeathText2")
DeathText2:SetFont("Fonts\\FRIZQT__.TTF", 12)
DeathText2:SetSize(210, 300)
DeathText2:SetPoint("CENTER", 0, 40)
DeathText2:SetJustifyH("left")
--DeathText2:SetJustifyV("center")
DeathText2:SetText("You have participated in a |cffFFC125large scale battle|r! You can |cffFFC125escape with major wounds|r, or you can |cffFFC125submit yourself|r to the fate of your foes. However, be warned as you only have |cffFFC125three|r escapes.")


function DeathHandlers.DeathScreenShot(player)
	print("Screenshot taken.")
    Screenshot()
end

function DeathHandlers.BigBattle(player, amount)
	DeathButton2:SetText("Escape |cffFFFFFF" ..amount.. "/3|r")
	DeathFrame1:Show()
end