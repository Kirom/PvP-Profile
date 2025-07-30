local _, ns = ...

-- Region detection module
ns.region = {}

-- Region mapping
local REGION_TO_LTD = { "us", "kr", "eu", "tw", "cn" }

-- Get region from player GUID or fallback to current region
function ns.region.GetRegion()
    local guid = UnitGUID("player")
    if not guid then
        return "eu", 3 -- fallback
    end

    local serverId = tonumber(string.match(guid, "^Player%-(%d+)") or 0) or 0
    local regionId = ns.regionIDs[serverId]

    -- Fallback to GetCurrentRegion() but with correct mapping
    if not regionId or regionId < 1 or regionId > #REGION_TO_LTD then
        regionId = GetCurrentRegion()
    end

    -- Fallback to EU if no regionId is found
    if not regionId then
        regionId = 3 -- EU fallback
    end

    local regionCode = REGION_TO_LTD[regionId] or "eu"
    return regionCode, regionId
end

-- Get English realm slug from localized name
function ns.region.GetRealmSlug(realm)
    return ns.realmSlugs[realm] or realm
end 