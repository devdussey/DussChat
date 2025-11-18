-- DussChat Addon
local DussChat = {}

-- Default settings
local defaults = {
    fontSize = 14,
    maxLines = 100,
    chatAlpha = 1.0,
    enableClassColors = true,
    hideBlizzardChat = true
}

function DussChat:CreateFrame()
    DussChatLogger:Info("Creating DussChat main frame")

    local success, result = pcall(function()
        local f = CreateFrame("Frame", "DussChatFrame", UIParent)
        f:SetSize(800, 400)
        f:SetPoint("TOPLEFT", 20, -20)
        return f
    end)

    if not success then
        DussChatLogger:Error("Failed to create frame", result)
        return
    end

    local f = result

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

    -- Scrolling Message Frame for chat display
    local scrollFrame = CreateFrame("ScrollingMessageFrame", "DussChatScrollFrame", f)
    scrollFrame:SetSize(770, 335)
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -35)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -15, 40)
    scrollFrame:SetFont("Fonts/FRIZQT__.TTF", DussChatDB.fontSize or 14)
    scrollFrame:SetJustifyH("LEFT")
    scrollFrame:SetFading(false)
    scrollFrame:SetMaxLines(DussChatDB.maxLines or 100)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        if delta > 0 then
            self:ScrollUp()
        else
            self:ScrollDown()
        end
    end)

    self.scrollFrame = scrollFrame

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
    input:SetPoint("TOPLEFT", inputFrame, "TOPLEFT", 5, 0)
    input:SetFont("Fonts/FRIZQT__.TTF", 12)
    input:SetMaxLetters(255)
    input:SetTextColor(1, 1, 1)
    input:SetAutoFocus(false)
    input:SetMultiLine(false)
    input:SetCountInvisibleLetters(false)
    input:EnableKeyboard(true)
    input:SetEnabled(true)

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

    self.mainFrame = f

    C_Timer.After(0.1, function()
        f:Show()
        f:Raise()
        DussChatLogger:Info("Main frame displayed successfully")
    end)

    DussChatLogger:Info("DussChat frame created successfully")
end

function DussChat:HideBlizzardChat()
    DussChatLogger:Info("Hiding Blizzard chat frames")
    ChatFrame1:Hide()
    ChatFrame2:Hide()
    ChatFrame3:Hide()
    ChatFrame4:Hide()
    ChatFrame5:Hide()
end

function DussChat:ShowBlizzardChat()
    DussChatLogger:Info("Showing Blizzard chat frames")
    ChatFrame1:Show()
    ChatFrame2:Show()
    ChatFrame3:Show()
    ChatFrame4:Show()
    ChatFrame5:Show()
end

function DussChat:AddMessage(text, r, g, b)
    if self.scrollFrame then
        self.scrollFrame:AddMessage(text, r or 1, g or 1, b or 1)
    end
end

function DussChat:SetupChatEvents()
    DussChatLogger:Info("Setting up chat event handlers")

    local chatEvents = {
        "CHAT_MSG_SAY",
        "CHAT_MSG_YELL",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_WHISPER_INFORM",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_EMOTE",
        "CHAT_MSG_TEXT_EMOTE",
        "CHAT_MSG_SYSTEM",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_ACHIEVEMENT",
        "CHAT_MSG_LOOT",
        "CHAT_MSG_MONEY"
    }

    local chatFrame = CreateFrame("Frame")
    for _, event in ipairs(chatEvents) do
        chatFrame:RegisterEvent(event)
    end

    DussChatLogger:Debug("Registered " .. #chatEvents .. " chat events")

    chatFrame:SetScript("OnEvent", function(self, event, ...)
        local success, err = pcall(function()
            local text, sender, _, _, _, _, _, _, channel = ...
            local r, g, b = 1, 1, 1
            local message = ""

            -- Color coding based on event type
            if event == "CHAT_MSG_SAY" then
            r, g, b = 1, 1, 1
            message = string.format("[Say] %s: %s", sender, text)
        elseif event == "CHAT_MSG_YELL" then
            r, g, b = 1, 0.25, 0.25
            message = string.format("[Yell] %s: %s", sender, text)
        elseif event == "CHAT_MSG_WHISPER" then
            r, g, b = 1, 0.5, 1
            message = string.format("[From %s]: %s", sender, text)
        elseif event == "CHAT_MSG_WHISPER_INFORM" then
            r, g, b = 1, 0.5, 1
            message = string.format("[To %s]: %s", sender, text)
        elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
            r, g, b = 0.67, 0.67, 1
            message = string.format("[Party] %s: %s", sender, text)
        elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
            r, g, b = 1, 0.5, 0
            message = string.format("[Raid] %s: %s", sender, text)
        elseif event == "CHAT_MSG_RAID_WARNING" then
            r, g, b = 1, 0.28, 0
            message = string.format("[Raid Warning] %s: %s", sender, text)
        elseif event == "CHAT_MSG_INSTANCE_CHAT" or event == "CHAT_MSG_INSTANCE_CHAT_LEADER" then
            r, g, b = 1, 0.5, 0
            message = string.format("[Instance] %s: %s", sender, text)
        elseif event == "CHAT_MSG_GUILD" then
            r, g, b = 0.25, 1, 0.25
            message = string.format("[Guild] %s: %s", sender, text)
        elseif event == "CHAT_MSG_OFFICER" then
            r, g, b = 0.25, 0.75, 0.25
            message = string.format("[Officer] %s: %s", sender, text)
        elseif event == "CHAT_MSG_EMOTE" then
            r, g, b = 1, 0.5, 0.25
            message = string.format("%s %s", sender, text)
        elseif event == "CHAT_MSG_TEXT_EMOTE" then
            r, g, b = 1, 0.5, 0.25
            message = text
        elseif event == "CHAT_MSG_SYSTEM" then
            r, g, b = 1, 1, 0
            message = text
        elseif event == "CHAT_MSG_CHANNEL" then
            r, g, b = 1, 0.75, 0.75
            message = string.format("[%s] %s: %s", channel, sender, text)
        elseif event == "CHAT_MSG_ACHIEVEMENT" then
            r, g, b = 1, 1, 0
            message = text
        elseif event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_MONEY" then
            r, g, b = 0, 1, 1
            message = text
        end

            DussChat:AddMessage(message, r, g, b)
        end)

        if not success then
            DussChatLogger:Error("Chat event handler error: " .. event, tostring(err))
        end
    end)

    self.chatEventFrame = chatFrame
    DussChatLogger:Info("Chat event handlers initialized successfully")
end

function DussChat:InitDB()
    DussChatLogger:LoadEvent("Initializing DussChat database")

    -- Initialize saved variables with defaults
    if not DussChatDB then
        DussChatDB = {}
        DussChatLogger:Info("Created new DussChatDB")
    else
        DussChatLogger:Info("Loaded existing DussChatDB")
    end

    for k, v in pairs(defaults) do
        if DussChatDB[k] == nil then
            DussChatDB[k] = v
            DussChatLogger:Debug("Set default value for " .. k .. " = " .. tostring(v))
        end
    end

    DussChatLogger:Info("Database initialization complete")
end

function DussChat:Init()
    DussChatLogger:Startup("=== DussChat Initialization Started ===")

    local success, err = pcall(function()
        self:InitDB()
        self:CreateFrame()
        self:SetupChatEvents()

        if DussChatDB.hideBlizzardChat then
            self:HideBlizzardChat()
        end
    end)

    if success then
        DussChatLogger:Startup("=== DussChat Initialization Complete ===")
        print("|cFF00FFFF[DussChat]|r Loaded successfully! Type /dclogs to view logs")
    else
        DussChatLogger:Error("DussChat initialization failed", tostring(err))
        print("|cFFFF0000[DussChat]|r Failed to load! Error: " .. tostring(err))
    end
end

-- Slash commands
SLASH_DUSSCHAT1 = "/dusschat"
SLASH_DUSSCHAT2 = "/dc"
SlashCmdList["DUSSCHAT"] = function(msg)
    msg = msg:lower()
    DussChatLogger:Debug("Slash command executed: /dusschat " .. msg)

    if msg == "blizzard" then
        if ChatFrame1:IsShown() then
            DussChat:HideBlizzardChat()
        else
            DussChat:ShowBlizzardChat()
        end
    else
        if DussChat.mainFrame:IsShown() then
            DussChat.mainFrame:Hide()
            DussChatLogger:Info("Main frame hidden via slash command")
        else
            DussChat.mainFrame:Show()
            DussChat.mainFrame:Raise()
            DussChatLogger:Info("Main frame shown via slash command")
        end
    end
end

-- Load event
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
    if addon == "DussChat" then
        DussChatLogger:LoadEvent("ADDON_LOADED event fired for DussChat")
        DussChat:Init()
    end
end)
