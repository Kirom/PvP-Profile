local _, ns = ...

-- Events module for handling WoW game events
ns.events = {}

-- Create event frame
local eventFrame = CreateFrame("Frame")

-- Event handlers
local function OnAddonLoaded(event, addonName)
    if addonName == "PvPProfile" then
        
        print("|cff00ff00PvP Profile|r: Addon loaded!")
        print("|cff00ff00PvP Profile|r: Type |cffffffff/pvp|r or navigate to the Options > AddOns > PvP Profile menu for options.")
        
        -- Register menu hooks once the addon is loaded
        ns.menu.RegisterMenuHooks()
        
        -- Unregister this event since we only need it once
        eventFrame:UnregisterEvent("ADDON_LOADED")
    end
end

-- Initialize events
function ns.events.Initialize()
    -- Register for addon loaded event
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "ADDON_LOADED" then
            OnAddonLoaded(event, ...)
        end
    end)
end