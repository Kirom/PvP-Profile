-- Drustvar.com Provider
-- Provides URLs for Drustvar PvP profiles

local _, ns = ...

-- Drustvar provider implementation
local drustvar = {
    id = "drustvar",
    name = "Drustvar",
    enabled = true,
    supportsClassic = false, -- Retail only
    websiteURL = "drustvar.com",

    -- Generate Drustvar URL for a player
    getURL = function(name, realm, regionCode, regionId)
        if not name or not realm then return nil end

        -- Debug output to help troubleshoot
        local guid = UnitGUID("player")
        local serverId = tonumber(string.match(guid or "", "^Player%-(%d+)") or 0) or 0
        ns.utils.DebugPrint(
            "Drustvar URL generation - GUID =", guid, "ServerId =", serverId, "RegionId =", regionId,
            "RegionCode =", regionCode, "Realm =", realm, "Name =", name
        )

        -- Get English realm slug
        local englishRealm = ns.region.GetRealmSlug(realm)

        ns.utils.DebugPrint("Realm translation:", realm, "->", englishRealm)

        -- Transform realm for Drustvar format (lowercase, no spaces/hyphens)
        local drustvarRealm = englishRealm:lower():gsub("[%s%-]", "")
        local drustvarName = name:lower()
        local drustvarRegion = regionCode:lower()

        ns.utils.DebugPrint(
            "Final URL components: region =", drustvarRegion, "realm =", drustvarRealm, "name =", drustvarName
        )

        -- Drustvar URL format: https://drustvar.com/character/[REGION]/[REALM]/[NAME]
        return string.format("https://drustvar.com/character/%s/%s/%s",
            drustvarRegion,
            drustvarRealm,
            drustvarName
        )
    end
}

-- Register the provider
ns.providers.RegisterProvider(drustvar)