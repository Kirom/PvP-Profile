local _, ns = ...

-- Commands module for slash command handling
ns.commands = {}

-- Help text
local function ShowHelp()
    print("|cff00ff00PvP Profile|r - Available commands:")
    print("/pvpprofile or /pvp - Show this help")
    print("/pvpprofile namerealm - Toggle name-realm button in context menus")
    print("/pvpprofile autoclose - Toggle auto-close dialog")
    print("/pvpprofile debug - Toggle debug output")
    print("/pvpprofile options - Open options panel")
    print("/pvpprofile providers - List available providers")
    print("/pvpprofile enable <provider> - Enable a provider")
    print("/pvpprofile disable <provider> - Disable a provider")
end

-- Handle slash commands
local function HandleSlashCommand(msg)
    local command, arg = string.match(msg, "^(%S*)%s*(.-)$")
    command = string.lower(command or "")

    if command == "" or command == "help" then
        ShowHelp()
    elseif command == "namerealm" then
        local newValue = not ns.config.SHOW_NAME_REALM
        ns.SetConfig("SHOW_NAME_REALM", newValue)
        local statusText = newValue and "enabled" or "disabled"
        print("|cff00ff00PvP Profile:|r Name-Realm button", statusText)
    elseif command == "autoclose" then
        local newValue = not ns.config.AUTO_CLOSE_DIALOG
        ns.SetConfig("AUTO_CLOSE_DIALOG", newValue)
        local statusText = newValue and "enabled" or "disabled"
        print("|cff00ff00PvP Profile:|r Auto-close dialog", statusText)
    elseif command == "debug" then
        local newValue = not ns.config.DEBUG
        ns.SetConfig("DEBUG", newValue)
        local statusText = newValue and "enabled" or "disabled"
        print("|cff00ff00PvP Profile:|r Debug output", statusText)
    elseif command == "options" then
        ns.options.Open()
    elseif command == "providers" then
        print("|cff00ff00PvP Profile:|r Available providers:")
        for providerId, provider in pairs(ns.providers.GetAllProviders()) do
            local status = ns.IsWebsiteEnabled(providerId) and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
            print("  " .. provider.name .. " (" .. providerId .. ") - " .. status)
        end
    elseif command == "enable" then
        local providerId = string.lower(arg or "")
        if providerId == "" then
            print("|cffff0000PvP Profile:|r Please specify a provider to enable")
            return
        end

        local provider = ns.providers.GetProvider(providerId)
        if provider then
            ns.SetConfig("ENABLED_WEBSITES", true, providerId)
            print("|cff00ff00PvP Profile:|r Enabled", provider.name)
        else
            print("|cffff0000PvP Profile:|r Unknown provider:", providerId)
        end
    elseif command == "disable" then
        local providerId = string.lower(arg or "")
        if providerId == "" then
            print("|cffff0000PvP Profile:|r Please specify a provider to disable")
            return
        end

        local provider = ns.providers.GetProvider(providerId)
        if provider then
            ns.SetConfig("ENABLED_WEBSITES", false, providerId)
            print("|cff00ff00PvP Profile:|r Disabled", provider.name)
        else
            print("|cffff0000PvP Profile:|r Unknown provider:", providerId)
        end
    else
        print("|cffff0000PvP Profile:|r Unknown command:", command)
        ShowHelp()
    end
end

-- Register slash commands
function ns.commands.RegisterSlashCommands()
    SLASH_PVPPROFILE1 = "/pvpprofile"
    SLASH_PVPPROFILE2 = "/pvp"
    SlashCmdList["PVPPROFILE"] = HandleSlashCommand

    ns.utils.DebugPrint("Slash commands registered")
end