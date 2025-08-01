-- Check-PvP.fr Provider
-- Provides URLs for Check-PvP profiles with retail and classic support

local _, ns = ...

-- Function to detect game version and set appropriate base URL
local function GetCheckPvPBaseURL()
    local isClassic = ns.config.isClassicWoW
    if isClassic then
        return "check-pvp-classic.fr"
    else
        return "check-pvp.fr"
    end
end

-- Check-PvP provider implementation
local checkpvp = {
    id = "checkpvp",
    name = "Check-PvP",
    enabled = true,
    supportsClassic = true,  -- Supports both retail and classic
    baseURL = GetCheckPvPBaseURL(),

    -- Generate Check-PvP URL for a player
    getFullURL = function(self, name, realm, regionCode, regionId)
        if not name or not realm then return nil end

        -- Get English realm slug
        local englishRealm = ns.region.GetRealmSlug(realm)

        -- Debug output to help troubleshoot
        local guid = UnitGUID("player")
        local serverId = tonumber(string.match(guid or "", "^Player%-(%d+)") or 0) or 0
        ns.utils.DebugPrint(
            "Check-PvP URL generation - GUID =", guid, "ServerId =", serverId, "RegionId =", regionId,
            "RegionCode =", regionCode, "Realm =", realm, "Name =", name
        )

        ns.utils.DebugPrint("Realm translation:", realm, "->", englishRealm)
        ns.utils.DebugPrint("Final URL components: region =", regionCode, "realm =", englishRealm, "name =", name)

        -- Construct Check-PvP URL: https://check-pvp.fr/[region]/[realm]/[name]
        return string.format("https://%s/%s/%s/%s", self.baseURL, regionCode, englishRealm, name)
    end
}

-- Register the provider
ns.providers.RegisterProvider(checkpvp)