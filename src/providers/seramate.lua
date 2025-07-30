-- Seramate.com Provider
-- Provides URLs for Seramate PvP profiles

local _, ns = ...

-- Seramate provider implementation
local seramate = {
    id = "seramate",
    name = "Seramate", 
    enabled = true,
    supportsClassic = false, -- Retail only
    websiteURL = "seramate.com",
    
    -- Generate Seramate URL for a player
    getURL = function(name, realm, regionCode, regionId)
        if not name or not realm then return nil end
        
        -- Debug output to help troubleshoot
        local guid = UnitGUID("player")
        local serverId = tonumber(string.match(guid or "", "^Player%-(%d+)") or 0) or 0
        ns.utils.DebugPrint(
            "Seramate URL generation - GUID =", guid, "ServerId =", serverId, "RegionId =", regionId,
            "RegionCode =", regionCode, "Realm =", realm, "Name =", name
        )
        
        -- Get English realm slug
        local englishRealm = ns.region.GetRealmSlug(realm)
        
        ns.utils.DebugPrint("Realm translation:", realm, "->", englishRealm)
        
        -- Transform realm for Seramate format (lowercase, no spaces/hyphens)
        local seramateRealm = englishRealm:lower():gsub("[%s%-]", "")
        local seramateName = name:lower()
        local seramateRegion = regionCode:lower()
        
        ns.utils.DebugPrint("Final URL components: region =", seramateRegion, "realm =", seramateRealm, "name =", seramateName)
        
        -- Seramate URL format: https://seramate.com/[REGION]/[REALM]/[NAME]
        return string.format("https://seramate.com/%s/%s/%s", 
            seramateRegion, 
            seramateRealm, 
            seramateName
        )
    end
}

-- Register the provider
ns.providers.RegisterProvider(seramate)