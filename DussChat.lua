-- DussChat Addon
local DussChat = {}

function DussChat:CreateFrame()
    local f = CreateFrame("Frame", "DussChatFrame", UIParent)
    f:SetSize(800, 400)
    f:SetPoint("TOPLEFT", 20, -20)

    -- Background texture
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(f)
    bg:SetColorTexture(0, 0, 0, 0.85)

    -- Title bar background
    local titleBg = f:CreateTexture(nil, "BACKGROUND")
    titleBg:SetSize(800, 25)
    titleBg:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    titleBg:SetColorTexture(0.1, 0.1, 0.1, 1)

    -- Title text
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", f, "TOPLEFT", 10, -8)
    title:SetText("DussChat")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, f)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -3)
    local closeTex = closeBtn:CreateFontString(nil, "OVERLAY")
    closeTex:SetFont("Fonts/FRIZQT__.TTF", 16)
    closeTex:SetPoint("CENTER", closeBtn, "CENTER")
    closeTex:SetText("X")
    closeBtn:SetScript("OnClick", function()
        f:Hide()
    end)

    -- Input box frame at bottom
    local inputFrame = CreateFrame("Frame", nil, f)
    inputFrame:SetSize(700, 20)
    inputFrame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 15, 8)

    -- Input background
    local inputBg = inputFrame:CreateTexture(nil, "BACKGROUND")
    inputBg:SetAllPoints(inputFrame)
    inputBg:SetColorTexture(0.05, 0.05, 0.05, 0.9)

    -- Text input
    local input = CreateFrame("EditBox", "DussChatInputBox", inputFrame)
    input:SetSize(700, 20)
    input:SetPoint("TOPLEFT", inputFrame, "TOPLEFT", 0, 0)
    input:SetFont("Fonts/FRIZQT__.TTF", 12)
    input:SetMaxLetters(255)
    input:SetTextColor(1, 1, 1)
    input:SetAutoFocus(false)
    input:SetMultiLine(false)
    input:SetCountInvisibleLetters(false)

    input:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        if text ~= "" then
            SendChatMessage(text, "SAY")
            self:SetText("")
        end
    end)

    input:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)

    input:SetScript("OnTextChanged", function(self)
        -- Keep size locked
        self:SetSize(700, 20)
    end)

    input:SetScript("OnSizeChanged", function(self)
        -- Prevent size changes
        self:SetSize(700, 20)
    end)

    self.input = input

    -- Make draggable
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    self.frame = f

    C_Timer.After(0.1, function()
        f:Show()
        f:Raise()
    end)
end

function DussChat:HideBlizzardChat()
    ChatFrame1:Hide()
    ChatFrame2:Hide()
    ChatFrame3:Hide()
    ChatFrame4:Hide()
    ChatFrame5:Hide()
end

function DussChat:ShowBlizzardChat()
    ChatFrame1:Show()
    ChatFrame2:Show()
    ChatFrame3:Show()
    ChatFrame4:Show()
    ChatFrame5:Show()
end

function DussChat:Init()
    self:CreateFrame()
    self:HideBlizzardChat()
end

-- Slash commands
SLASH_DUSSCHAT1 = "/dusschat"
SLASH_DUSSCHAT2 = "/dc"
SlashCmdList["DUSSCHAT"] = function(msg)
    msg = msg:lower()
    if msg == "blizzard" then
        if ChatFrame1:IsShown() then
            DussChat:HideBlizzardChat()
        else
            DussChat:ShowBlizzardChat()
        end
    else
        if DussChat.frame:IsShown() then
            DussChat.frame:Hide()
        else
            DussChat.frame:Show()
            DussChat.frame:Raise()
        end
    end
end

-- Load event
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
    if addon == "DussChat" then
        DussChat:Init()
    end
end)
