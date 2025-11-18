-- DussChat Options Panel

local DussChatOptions = {}

function DussChatOptions:CreatePanel()
    local panel = CreateFrame("Frame", "DussChatOptionsPanel", UIParent, "BackdropTemplate")
    panel:SetSize(500, 450)
    panel:SetPoint("CENTER", UIParent, "CENTER")
    panel:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    panel:SetBackdropColor(0, 0, 0, 0.8)
    panel:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -15)
    title:SetText("DussChat Options")

    -- Font Size
    local fsLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fsLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)
    fsLabel:SetText("Font Size:")

    local fsSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    fsSlider:SetMinMaxValues(10, 20)
    fsSlider:SetValue(DussChatDB.fontSize)
    fsSlider:SetWidth(200)
    fsSlider:SetPoint("TOPLEFT", fsLabel, "BOTTOMLEFT", 0, -10)
    fsSlider:SetScript("OnValueChanged", function(self, value)
        DussChatDB.fontSize = value
        _G[self:GetName() .. "Low"]:SetText("10")
        _G[self:GetName() .. "High"]:SetText("20")
        _G[self:GetName() .. "Text"]:SetText("Font Size: " .. value)
    end)

    -- Max Lines
    local mlLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mlLabel:SetPoint("TOPLEFT", fsSlider, "BOTTOMLEFT", 0, -20)
    mlLabel:SetText("Max Lines:")

    local mlSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    mlSlider:SetMinMaxValues(50, 500)
    mlSlider:SetValue(DussChatDB.maxLines)
    mlSlider:SetWidth(200)
    mlSlider:SetPoint("TOPLEFT", mlLabel, "BOTTOMLEFT", 0, -10)
    mlSlider:SetScript("OnValueChanged", function(self, value)
        DussChatDB.maxLines = value
        _G[self:GetName() .. "Low"]:SetText("50")
        _G[self:GetName() .. "High"]:SetText("500")
        _G[self:GetName() .. "Text"]:SetText("Max Lines: " .. value)
    end)

    -- Chat Alpha
    local alphaLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    alphaLabel:SetPoint("TOPLEFT", mlSlider, "BOTTOMLEFT", 0, -20)
    alphaLabel:SetText("Chat Transparency:")

    local alphaSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    alphaSlider:SetMinMaxValues(0.2, 1.0)
    alphaSlider:SetValue(DussChatDB.chatAlpha)
    alphaSlider:SetWidth(200)
    alphaSlider:SetPoint("TOPLEFT", alphaLabel, "BOTTOMLEFT", 0, -10)
    alphaSlider:SetScript("OnValueChanged", function(self, value)
        DussChatDB.chatAlpha = value
        _G[self:GetName() .. "Low"]:SetText("0.2")
        _G[self:GetName() .. "High"]:SetText("1.0")
        _G[self:GetName() .. "Text"]:SetText("Transparency: " .. string.format("%.2f", value))
        if DussChat.mainFrame then
            DussChat.mainFrame:SetAlpha(value)
        end
    end)

    -- Class Colors Checkbox
    local classColorCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    classColorCheck:SetPoint("TOPLEFT", alphaSlider, "BOTTOMLEFT", 0, -15)
    classColorCheck:SetChecked(DussChatDB.enableClassColors)
    classColorCheck:SetScript("OnClick", function(self)
        DussChatDB.enableClassColors = self:GetChecked()
    end)

    local classColorLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classColorLabel:SetPoint("LEFT", classColorCheck, "RIGHT", 5, 0)
    classColorLabel:SetText("Enable Class Colors")

    -- Hide Blizzard Chat Checkbox
    local hideBlizzardCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    hideBlizzardCheck:SetPoint("TOPLEFT", classColorCheck, "BOTTOMLEFT", 0, -10)
    hideBlizzardCheck:SetChecked(DussChatDB.hideBlizzardChat)
    hideBlizzardCheck:SetScript("OnClick", function(self)
        DussChatDB.hideBlizzardChat = self:GetChecked()
        if DussChatDB.hideBlizzardChat then
            DussChat:HideBlizzardChat()
        else
            DussChat:ShowBlizzardChat()
        end
    end)

    local hideBlizzardLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hideBlizzardLabel:SetPoint("LEFT", hideBlizzardCheck, "RIGHT", 5, 0)
    hideBlizzardLabel:SetText("Hide Blizzard Chat Frames")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, panel, "GameMenuButtonTemplate")
    closeBtn:SetText("Close")
    closeBtn:SetSize(80, 25)
    closeBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
    closeBtn:SetScript("OnClick", function()
        panel:Hide()
    end)

    -- Reset button
    local resetBtn = CreateFrame("Button", nil, panel, "GameMenuButtonTemplate")
    resetBtn:SetText("Reset")
    resetBtn:SetSize(80, 25)
    resetBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
    resetBtn:SetScript("OnClick", function()
        DussChatDB.fontSize = 14
        DussChatDB.maxLines = 100
        DussChatDB.chatAlpha = 1.0
        DussChatDB.enableClassColors = true
        DussChatDB.hideBlizzardChat = true
        fsSlider:SetValue(14)
        mlSlider:SetValue(100)
        alphaSlider:SetValue(1.0)
        classColorCheck:SetChecked(true)
        hideBlizzardCheck:SetChecked(true)
        DussChat:HideBlizzardChat()
    end)

    panel:Hide()

    return panel
end

-- Slash command for options
SLASH_DUSSCHATOPTIONS1 = "/dusschatoptions"
SlashCmdList["DUSSCHATOPTIONS"] = function()
    if DussChatOptions.panel then
        if DussChatOptions.panel:IsShown() then
            DussChatOptions.panel:Hide()
        else
            DussChatOptions.panel:Show()
        end
    end
end

-- Initialize options on load
local optionsFrame = CreateFrame("Frame")
optionsFrame:RegisterEvent("ADDON_LOADED")
optionsFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "DussChat" then
        DussChatOptions.panel = DussChatOptions:CreatePanel()
    end
end)
