local _, ns = ...

-- Utility functions module
ns.utils = {}

-- Debug print function
function ns.utils.DebugPrint(...)
    if ns.config.DEBUG then
        print("|cff00ff00PvP Profile:|r", ...)
    end
end

-- Parse name and realm from full name
function ns.utils.GetNameRealm(fullName)
    ns.utils.DebugPrint("GetNameRealm: fullName =", fullName)
    if not fullName then return end
    local name, realm = string.match(fullName, "^([^-]+)-(.+)$")
    if not name then
        name = fullName
        realm = GetRealmName()
    end
    return name, realm
end

-- Simple closure generator for menu callbacks
function ns.utils.GenerateClosure(func)
    return function(owner, rootDescription, contextData)
        return func(owner, rootDescription, contextData)
    end
end

-- Function to check if we're in classic WoW
function ns.utils.IsClassicWoW()
    -- Use WOW_PROJECT_ID for reliable version detection
    -- Reference: https://warcraft.wiki.gg/wiki/WOW_PROJECT_ID
    local projectID = WOW_PROJECT_ID
    local isClassic = projectID ~= 1 -- Not mainline retail
    ns.utils.DebugPrint("Is Classic:", isClassic)
    return isClassic
end