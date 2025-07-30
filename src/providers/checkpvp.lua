-- Check-PvP.fr Provider
-- Provides URLs for Check-PvP profiles with retail and classic support

local _, ns = ...

-- Function to detect game version and set appropriate base URL
local function GetCheckPvPBaseURL()
    -- Use WOW_PROJECT_ID for reliable version detection
    -- Reference: https://warcraft.wiki.gg/wiki/WOW_PROJECT_ID
    local projectID = WOW_PROJECT_ID

    if projectID == 19 then -- WOW_PROJECT_MISTS_CLASSIC
        -- Mists of Pandaria Classic
        return "https://check-pvp-classic.fr"
    elseif projectID == 1 then -- WOW_PROJECT_MAINLINE
        -- Retail (TWW and future expansions)
        return "https://check-pvp.fr"
    else
        -- Fallback for unsupported project IDs - assume retail
        return "https://check-pvp.fr"
    end
end

-- Check-PvP provider implementation
local checkpvp = {
    id = "checkpvp",
    name = "Check-PvP",
    enabled = true,
    supportsClassic = true,  -- Supports both retail and classic
    websiteURL = function()
        -- Return appropriate URL based on WoW version
        local projectID = WOW_PROJECT_ID
        if projectID == 19 then return "check-pvp-classic.fr"
        elseif projectID == 1 then return "check-pvp.fr"
        else return "check-pvp.fr" end
    end,
    
    -- Generate Check-PvP URL for a player
    getURL = function(name, realm, regionCode, regionId)
        if not name or not realm then return nil end
        
        -- Get version-appropriate base URL
        local baseURL = GetCheckPvPBaseURL()
        
        -- Get English realm slug
        local englishRealm = ns.region.GetRealmSlug(realm)
        
        -- Debug output to help troubleshoot
        local guid = UnitGUID("player")
        local serverId = tonumber(string.match(guid or "", "^Player%-(%d+)") or 0) or 0
        ns.utils.DebugPrint(
            "Check-PvP URL generation - GUID =", guid, "ServerId =", serverId, "RegionId =", regionId,
            "RegionCode =", regionCode, "Realm =", realm, "Name =", name, "BaseURL =", baseURL
        )
        
        ns.utils.DebugPrint("Realm translation:", realm, "->", englishRealm)
        ns.utils.DebugPrint("Final URL components: region =", regionCode, "realm =", englishRealm, "name =", name)
        
        -- Construct Check-PvP URL: https://check-pvp.fr/[region]/[realm]/[name]
        return string.format("%s/%s/%s/%s", baseURL, regionCode, englishRealm, name)
    end
}

-- Register the provider
ns.providers.RegisterProvider(checkpvp) 