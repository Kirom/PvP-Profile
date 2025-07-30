-- Seramate.com Provider
-- Provides URLs for Seramate PvP profiles

local _, ns = ...

-- Seramate provider implementation
local seramate = {
    id = "seramate",
    name = "Seramate",
    enabled = true,
    supportsClassic = false, -- Retail only
    baseURL = "seramate.com",

    -- Generate Seramate URL for a player
    getFullURL = function(self, name, realm, regionCode, regionId)
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

        -- Seramate URL format: https://seramate.com/[REGION]/[REALM]/[NAME]
        return string.format("https://%s/%s/%s/%s",
            self.baseURL,
            regionCode,
            englishRealm,
            name
        )
    end
}

-- Register the provider
ns.providers.RegisterProvider(seramate)