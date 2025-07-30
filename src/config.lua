-- PvP Profile Configuration
-- This file contains user-configurable settings for the addon

local _, ns = ...

-- Create config namespace
ns.config = {}

-- Default configuration values
local defaults = {
    DEBUG = false,                                -- Set to true to enable debug output
    COPY_MODE = "name",                           -- Copy mode: "url" for full URL, "name" for name-realm
    AUTO_CLOSE_DIALOG = true,                     -- Auto-close copy dialog after Ctrl+C
    -- Website enable/disable flags
    ENABLED_WEBSITES = {
        checkpvp = true,                          -- Enable Check-PvP.fr by default (supports classic)
        drustvar = true,                          -- Enable Drustvar.com by default (retail only)
        seramate = true,                          -- Enable Seramate.com by default (retail only)
    },
}

-- Fixed settings (not user-configurable)
ns.config.DIALOG_TITLE = "PvP Profile"           -- Title of the URL dialog
ns.config.FRAME_STRATA = "DIALOG"                -- Frame strata for URL dialog
ns.config.FRAME_LEVEL = 100                      -- Frame level for URL dialog

-- Initialize config with defaults
for key, value in pairs(defaults) do
    if type(value) == "table" then
        ns.config[key] = {}
        for subKey, subValue in pairs(value) do
            ns.config[key][subKey] = subValue
        end
    else
        ns.config[key] = value
    end
end

-- Function to load user settings from saved variables
local function LoadUserConfig()
    if PvPProfileDB then
        for key, value in pairs(PvPProfileDB) do
            if defaults[key] ~= nil then          -- Only load known config keys
                if type(defaults[key]) == "table" then
                    ns.config[key] = ns.config[key] or {}
                    if type(value) == "table" then
                        for subKey, subValue in pairs(value) do
                            ns.config[key][subKey] = subValue
                        end
                    end
                else
                    ns.config[key] = value
                end
            end
        end
    end
end

-- Function to save user settings to saved variables
function ns.SetConfig(key, value, subKey)
    if subKey then
        -- Handle nested config like ENABLED_WEBSITES.drustvar
        if defaults[key] ~= nil and type(defaults[key]) == "table" then
            ns.config[key] = ns.config[key] or {}
            ns.config[key][subKey] = value
            PvPProfileDB = PvPProfileDB or {}
            PvPProfileDB[key] = PvPProfileDB[key] or {}
            PvPProfileDB[key][subKey] = value
        else
            print("|cffff0000PvP Profile:|r Unknown config key:", key .. "." .. subKey)
        end
    else
        -- Handle top-level config
        if defaults[key] ~= nil then
            ns.config[key] = value
            PvPProfileDB = PvPProfileDB or {}
            PvPProfileDB[key] = value
        else
            print("|cffff0000PvP Profile:|r Unknown config key:", key)
        end
    end

    -- Refresh options panel
    if ns.options and ns.options.RefreshOptionsPanel then
        ns.options.RefreshOptionsPanel()
    end
end

-- Function to check if a website is enabled
function ns.IsWebsiteEnabled(websiteId)
    return ns.config.ENABLED_WEBSITES and ns.config.ENABLED_WEBSITES[websiteId] == true
end

-- Initialize saved variables and load user config
local configFrame = CreateFrame("Frame")
configFrame:RegisterEvent("ADDON_LOADED")
configFrame:SetScript("OnEvent", function(_, _, addonName)
    if addonName == "PvPProfile" then
        -- Initialize saved variables if they don't exist
        PvPProfileDB = PvPProfileDB or {}

        -- Load user configuration
        LoadUserConfig()

        -- Refresh options panel (delay to ensure it's created)
        if ns.options and ns.options.RefreshOptionsPanel then
            C_Timer.After(0.1, ns.options.RefreshOptionsPanel)
        end

        configFrame:UnregisterEvent("ADDON_LOADED")
    end
end) 