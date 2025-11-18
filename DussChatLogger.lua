-- DussChat Logger Module
-- Logs errors, startup events, and other important information

local DussChatLogger = {}

-- Log levels
DussChatLogger.LogLevel = {
    ERROR = "ERROR",
    WARNING = "WARNING",
    INFO = "INFO",
    STARTUP = "STARTUP",
    LOAD = "LOAD",
    DEBUG = "DEBUG"
}

-- Maximum number of log entries to keep
local MAX_LOG_ENTRIES = 500

-- Color codes for log levels
local LOG_COLORS = {
    ERROR = "|cFFFF0000",      -- Red
    WARNING = "|cFFFFAA00",    -- Orange
    INFO = "|cFFFFFFFF",       -- White
    STARTUP = "|cFF00FF00",    -- Green
    LOAD = "|cFF00FFFF",       -- Cyan
    DEBUG = "|cFFAAAAAA"       -- Gray
}

-- Initialize log storage
function DussChatLogger:Init()
    if not DussChatDB then
        DussChatDB = {}
    end

    if not DussChatDB.logs then
        DussChatDB.logs = {}
    end

    if not DussChatDB.logSettings then
        DussChatDB.logSettings = {
            enabled = true,
            logLevel = "INFO",
            maxEntries = MAX_LOG_ENTRIES,
            logToChat = false
        }
    end

    self:Log("STARTUP", "DussChatLogger initialized")
end

-- Get current timestamp
function DussChatLogger:GetTimestamp()
    return date("%Y-%m-%d %H:%M:%S")
end

-- Add a log entry
function DussChatLogger:Log(level, message, details)
    if not DussChatDB or not DussChatDB.logSettings then
        return
    end

    if not DussChatDB.logSettings.enabled then
        return
    end

    local logEntry = {
        timestamp = self:GetTimestamp(),
        level = level,
        message = message,
        details = details or "",
        session = date("%Y%m%d")
    }

    table.insert(DussChatDB.logs, logEntry)

    -- Trim logs if exceeded max entries
    while #DussChatDB.logs > DussChatDB.logSettings.maxEntries do
        table.remove(DussChatDB.logs, 1)
    end

    -- Optionally print to chat
    if DussChatDB.logSettings.logToChat then
        local color = LOG_COLORS[level] or "|cFFFFFFFF"
        print(string.format("%s[DussChat %s]|r %s: %s", color, level, logEntry.timestamp, message))
    end
end

-- Convenience methods for different log levels
function DussChatLogger:Error(message, details)
    self:Log("ERROR", message, details)
end

function DussChatLogger:Warning(message, details)
    self:Log("WARNING", message, details)
end

function DussChatLogger:Info(message, details)
    self:Log("INFO", message, details)
end

function DussChatLogger:Startup(message, details)
    self:Log("STARTUP", message, details)
end

function DussChatLogger:LoadEvent(message, details)
    self:Log("LOAD", message, details)
end

function DussChatLogger:Debug(message, details)
    self:Log("DEBUG", message, details)
end

-- Get recent logs
function DussChatLogger:GetRecentLogs(count)
    if not DussChatDB or not DussChatDB.logs then
        return {}
    end

    count = count or 50
    local logs = {}
    local totalLogs = #DussChatDB.logs
    local startIndex = math.max(1, totalLogs - count + 1)

    for i = startIndex, totalLogs do
        table.insert(logs, DussChatDB.logs[i])
    end

    return logs
end

-- Get logs by level
function DussChatLogger:GetLogsByLevel(level, count)
    if not DussChatDB or not DussChatDB.logs then
        return {}
    end

    count = count or 50
    local logs = {}

    for i = #DussChatDB.logs, 1, -1 do
        if DussChatDB.logs[i].level == level then
            table.insert(logs, DussChatDB.logs[i])
            if #logs >= count then
                break
            end
        end
    end

    return logs
end

-- Clear all logs
function DussChatLogger:ClearLogs()
    if DussChatDB and DussChatDB.logs then
        DussChatDB.logs = {}
        self:Info("All logs cleared")
        return true
    end
    return false
end

-- Get log statistics
function DussChatLogger:GetStats()
    if not DussChatDB or not DussChatDB.logs then
        return nil
    end

    local stats = {
        total = #DussChatDB.logs,
        ERROR = 0,
        WARNING = 0,
        INFO = 0,
        STARTUP = 0,
        LOAD = 0,
        DEBUG = 0
    }

    for _, log in ipairs(DussChatDB.logs) do
        stats[log.level] = (stats[log.level] or 0) + 1
    end

    return stats
end

-- Display logs in chat
function DussChatLogger:DisplayLogs(count, level)
    local logs
    if level then
        logs = self:GetLogsByLevel(level, count or 20)
    else
        logs = self:GetRecentLogs(count or 20)
    end

    print("|cFF00FFFFDussChat Logs|r")
    print("======================")

    if #logs == 0 then
        print("|cFFFF0000No logs found|r")
        return
    end

    for _, log in ipairs(logs) do
        local color = LOG_COLORS[log.level] or "|cFFFFFFFF"
        local details = log.details ~= "" and (" - " .. log.details) or ""
        print(string.format("%s[%s] %s|r: %s%s", color, log.level, log.timestamp, log.message, details))
    end

    print("======================")
end

-- Export logs to string (for copying)
function DussChatLogger:ExportLogs()
    if not DussChatDB or not DussChatDB.logs then
        return "No logs available"
    end

    local output = "DussChat Log Export\n"
    output = output .. "Generated: " .. self:GetTimestamp() .. "\n"
    output = output .. "======================\n\n"

    for _, log in ipairs(DussChatDB.logs) do
        local details = log.details ~= "" and (" - " .. log.details) or ""
        output = output .. string.format("[%s] %s: %s%s\n", log.level, log.timestamp, log.message, details)
    end

    return output
end

-- Wrap a function with error logging
function DussChatLogger:WrapFunction(funcName, func)
    return function(...)
        local success, result = pcall(func, ...)
        if not success then
            self:Error("Function error: " .. funcName, result)
            print("|cFFFF0000DussChat Error:|r " .. funcName .. " failed. Check logs with /dclogs")
        end
        return result
    end
end

-- Make logger globally accessible
_G.DussChatLogger = DussChatLogger

-- Initialize on load
local loggerFrame = CreateFrame("Frame")
loggerFrame:RegisterEvent("ADDON_LOADED")
loggerFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "DussChat" then
        DussChatLogger:Init()
        DussChatLogger:Startup("DussChat addon loading...")
    end
end)

-- Slash commands for log management
SLASH_DUSSCHATLOGS1 = "/dclogs"
SLASH_DUSSCHATLOGS2 = "/dusschatlogs"
SlashCmdList["DUSSCHATLOGS"] = function(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word:lower())
    end

    if #args == 0 or args[1] == "show" then
        local count = tonumber(args[2]) or 20
        DussChatLogger:DisplayLogs(count)
    elseif args[1] == "errors" then
        local count = tonumber(args[2]) or 20
        DussChatLogger:DisplayLogs(count, "ERROR")
    elseif args[1] == "startup" then
        local count = tonumber(args[2]) or 20
        DussChatLogger:DisplayLogs(count, "STARTUP")
    elseif args[1] == "clear" then
        DussChatLogger:ClearLogs()
        print("|cFF00FFFF[DussChat]|r Logs cleared")
    elseif args[1] == "stats" then
        local stats = DussChatLogger:GetStats()
        if stats then
            print("|cFF00FFFFDussChat Log Statistics|r")
            print("======================")
            print("Total Logs: " .. stats.total)
            print("|cFFFF0000Errors:|r " .. stats.ERROR)
            print("|cFFFFAA00Warnings:|r " .. stats.WARNING)
            print("|cFFFFFFFFInfo:|r " .. stats.INFO)
            print("|cFF00FF00Startup:|r " .. stats.STARTUP)
            print("|cFF00FFFFLoad:|r " .. stats.LOAD)
            print("|cFFAAAAAAAADebug:|r " .. stats.DEBUG)
            print("======================")
        end
    elseif args[1] == "toggle" then
        if DussChatDB and DussChatDB.logSettings then
            DussChatDB.logSettings.enabled = not DussChatDB.logSettings.enabled
            print("|cFF00FFFF[DussChat]|r Logging " .. (DussChatDB.logSettings.enabled and "enabled" or "disabled"))
        end
    elseif args[1] == "chatlog" then
        if DussChatDB and DussChatDB.logSettings then
            DussChatDB.logSettings.logToChat = not DussChatDB.logSettings.logToChat
            print("|cFF00FFFF[DussChat]|r Chat logging " .. (DussChatDB.logSettings.logToChat and "enabled" or "disabled"))
        end
    elseif args[1] == "help" then
        print("|cFF00FFFFDussChat Logger Commands|r")
        print("/dclogs [show] [count] - Show recent logs")
        print("/dclogs errors [count] - Show error logs")
        print("/dclogs startup [count] - Show startup logs")
        print("/dclogs clear - Clear all logs")
        print("/dclogs stats - Show log statistics")
        print("/dclogs toggle - Enable/disable logging")
        print("/dclogs chatlog - Toggle logging to chat")
        print("/dclogs help - Show this help")
    else
        print("|cFFFF0000Unknown command.|r Type /dclogs help for available commands")
    end
end)
