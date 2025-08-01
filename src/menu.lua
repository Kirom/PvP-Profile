local _, ns = ...

-- Menu system integration module
ns.menu = {}

-- Track selected player for dropdown menus
local selectedName, selectedRealm

-- Valid menu types (same as original addon)
local validTags = {
    MENU_LFG_FRAME_SEARCH_ENTRY = 1,
    MENU_LFG_FRAME_MEMBER_APPLY = 1,
}

local validTypes = {
    PLAYER = true,
    PARTY = true,
    RAID_PLAYER = true,
    FRIEND = true,
    GUILD = true,
    COMMUNITIES_GUILD_MEMBER = true,
    COMMUNITIES_WOW_MEMBER = true,
    BN_FRIEND = true,
    SELF = true,
    ENEMY_PLAYER = true,
    OTHER_PLAYER = true,
}

-- Validation function
local function IsValidMenu(rootDescription, contextData)
    if not contextData then
        local tagType = validTags[rootDescription.tag]
        return tagType == 1 -- LFG menus
    end
    local which = contextData.which
    return which and validTypes[which]
end

-- Get name and realm from LFG info (same as original)
local function GetLFGListInfo(owner)
    local resultID = owner.resultID
    if resultID then
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
        if searchResultInfo and searchResultInfo.leaderName then
            return ns.utils.GetNameRealm(searchResultInfo.leaderName)
        end
    end

    local memberIdx = owner.memberIdx
    if not memberIdx then
        return
    end
    local parent = owner:GetParent()
    if not parent then
        return
    end
    local applicantID = parent.applicantID
    if not applicantID then
        return
    end
    local fullName = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
    if fullName then
        return ns.utils.GetNameRealm(fullName)
    end

    return nil, nil
end

-- Get Battle.net account info (same as original)
local function GetBNetAccountInfo(accountInfo)
    if not accountInfo or not accountInfo.gameAccountInfo then
        return nil, nil
    end

    local gameAccountInfo = accountInfo.gameAccountInfo
    local characterName = gameAccountInfo.characterName
    local realmName = gameAccountInfo.realmName
    local characterLevel = gameAccountInfo.characterLevel

    return characterName, realmName, characterLevel
end

-- Get name and realm from menu context (same as original)
local function GetNameRealmForMenu(owner, rootDescription, contextData)
    -- Handle LFG list info
    if not contextData then
        local tagType = validTags[rootDescription.tag]
        if tagType == 1 then
            ns.utils.DebugPrint("Data found in LFG list info")
            return GetLFGListInfo(owner)
        end
        return
    end

    local name, realm

    -- Use contextData.name and contextData.server if both are available
    if contextData.name and contextData.server then
        name = contextData.name
        realm = contextData.server
        ns.utils.DebugPrint("Data found in contextData: name =", name, "server =", realm)
        return name, realm
    end

    -- Handle units (target, party members, etc.)
    local unit = contextData.unit
    if unit and UnitExists(unit) then
        name, realm = ns.utils.GetNameRealm(UnitName(unit))
        if contextData.server then
            realm = contextData.server
            ns.utils.DebugPrint("Data found in unit name with contextData server: name =", name, "server =", realm)
        else
            ns.utils.DebugPrint("Data found in unit data: name =", name, "realm =", realm)
        end
        return name, realm
    end

    -- Handle Battle.net friends
    local accountInfo = contextData.accountInfo
    if accountInfo then
        name, realm = GetBNetAccountInfo(accountInfo)
        if not realm then
            return -- Skip if no realm info (classic characters on retail)
        end
        ns.utils.DebugPrint("Data found in BNet friend info: name =", name, "realm =", realm)
        return name, realm
    end

    -- Handle regular name context (fallback)
    if contextData.name then
        name, realm = ns.utils.GetNameRealm(contextData.name)
        ns.utils.DebugPrint("Data found in regular name context: name =", name, "realm =", realm)
        return name, realm
    end

    -- Handle friends list
    if contextData.friendsList then
        local friendInfo = C_FriendList.GetFriendInfoByIndex(contextData.friendsList)
        if friendInfo and friendInfo.name then
            name, realm = ns.utils.GetNameRealm(friendInfo.name)
            ns.utils.DebugPrint("Data found in friends list: name =", name, "realm =", realm)
            return name, realm
        end
    end

    return nil, nil
end

-- Hook into the dropdown menu system - UPDATED for multiple providers
local function AddPvPProfileOptions(owner, rootDescription, contextData)
    -- Debug output
    if contextData then
        ns.utils.DebugPrint(
            "contextData.which =", contextData.which, "contextData.unit =", contextData.unit,
            "contextData.name =", contextData.name, "contextData.server =", contextData.server
        )
    else
        ns.utils.DebugPrint("No contextData, rootDescription.tag =", rootDescription.tag)
    end

    -- Check if this is a valid menu for our addon
    if not IsValidMenu(rootDescription, contextData) then
        ns.utils.DebugPrint("Menu not valid")
        return
    end

    local name, realm = GetNameRealmForMenu(owner, rootDescription, contextData)
    ns.utils.DebugPrint("Got name =", name, "realm =", realm)
    ns.utils.DebugPrint("Is Classic WoW cached:", ns.config.isClassicWoW)

    if name and realm then
        selectedName = name
        selectedRealm = realm

        -- Get enabled providers
        local enabledProviders = ns.providers.GetEnabledProviders()
        local providerCount = 0
        for _ in pairs(enabledProviders) do
            providerCount = providerCount + 1
        end

        -- Check if name-realm is enabled
        local showNameRealm = ns.config.SHOW_NAME_REALM

        -- Only add menu items if there are enabled providers or name-realm is enabled
        if providerCount > 0 or showNameRealm then
            rootDescription:CreateDivider()

            -- Add title
            rootDescription:CreateTitle("PvP Profile")

            -- Add individual buttons for each enabled provider
            for providerId, provider in pairs(enabledProviders) do
                rootDescription:CreateButton(provider.name, function()
                    local url = ns.url.GetProviderURL(selectedName, selectedRealm, providerId)
                    if url then
                        ns.ui.ShowCopyURLDialog(url, provider.name)
                    end
                end)
                ns.utils.DebugPrint("Added menu option for", provider.name)
            end

            -- Add Name-Realm button if enabled
            if showNameRealm then
                rootDescription:CreateButton("Name-Realm", function()
                    local nameRealm = ns.url.GetNameRealmFormat(selectedName, selectedRealm)
                    if nameRealm then
                        ns.ui.ShowCopyURLDialog(nameRealm, "Name-Realm")
                    end
                end)
                ns.utils.DebugPrint("Added Name-Realm menu option")
            end
        else
            ns.utils.DebugPrint("No enabled providers and name-realm disabled - skipping menu options")
        end
    else
        ns.utils.DebugPrint("No valid name/realm found - skipping menu option")
    end
end

-- Register menu hooks
function ns.menu.RegisterMenuHooks()
    -- Check if the new Menu system is available (TWW+)
    if Menu and Menu.ModifyMenu then
        local ModifyMenu = Menu.ModifyMenu

        ns.utils.DebugPrint("Menu system found, registering hooks...")

        -- Hook LFG frame menus (most important for our use case)
        local success, err = pcall(function()
            ModifyMenu("MENU_LFG_FRAME_SEARCH_ENTRY", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_LFG_FRAME_MEMBER_APPLY", ns.utils.GenerateClosure(AddPvPProfileOptions))

            -- Hook other player context menus
            ModifyMenu("MENU_UNIT_PLAYER", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_UNIT_PARTY", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_UNIT_RAID_PLAYER", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_UNIT_FRIEND", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_UNIT_GUILD", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_UNIT_COMMUNITIES_GUILD_MEMBER", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_UNIT_COMMUNITIES_WOW_MEMBER", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_UNIT_BN_FRIEND", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_UNIT_SELF", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_UNIT_ENEMY_PLAYER", ns.utils.GenerateClosure(AddPvPProfileOptions))
            ModifyMenu("MENU_UNIT_OTHER_PLAYER", ns.utils.GenerateClosure(AddPvPProfileOptions))
        end)

        if success then
            ns.utils.DebugPrint("Menu hooks registered successfully!")
            return true
        else
            print(
                "|cffff0000PvP Profile|r: Error registering menu hooks:",
                err,
                "Please report this to the developer."
            )
            return false
        end
    else
        print(
            "|cffff0000PvP Profile|r: Menu system not available! (WoW version may be too old).",
            "Please report this to the developer."
        )
        return false
    end
end