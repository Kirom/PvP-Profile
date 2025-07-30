-- PvP Profile Provider Registry
-- This module manages all website providers and makes it easy to add/remove supported websites

local _, ns = ...

-- Create provider registry namespace
ns.providers = {}

-- Registry for all providers
local registeredProviders = {}

-- Provider interface:
-- Each provider must implement:
-- - id: unique string identifier
-- - name: display name for the website
-- - getURL(name, realm, regionCode): function that returns the URL for the website
-- - enabled: boolean indicating if provider is enabled by default
-- - supportsClassic: boolean indicating if provider works in classic WoW
-- - websiteURL: string or function for display in options panel (optional)

-- Register a new provider
function ns.providers.RegisterProvider(provider)
    if not provider.id then
        error("Provider must have an 'id' field")
        return
    end

    if not provider.name then
        error("Provider must have a 'name' field")
        return
    end

    if not provider.getURL or type(provider.getURL) ~= "function" then
        error("Provider must have a 'getURL' function")
        return
    end

    if provider.supportsClassic == nil then
        error("Provider must have a 'supportsClassic' field (boolean)")
        return
    end

    registeredProviders[provider.id] = provider
    local classicSupport = provider.supportsClassic and "retail+classic" or "retail only"
    ns.utils.DebugPrint("Registered provider:", provider.id, "(" .. provider.name .. ") -", classicSupport)
end

-- Function to check if we're in classic WoW
local function IsClassicWoW()
    -- Use WOW_PROJECT_ID for reliable version detection
    local projectID = WOW_PROJECT_ID
    local isClassic = projectID ~= 1 -- Not mainline retail
    ns.utils.DebugPrint("Is Classic:", isClassic)
    return isClassic
end

-- Get all registered providers (filtered by WoW version compatibility)
function ns.providers.GetAllProviders()
    local compatibleProviders = {}
    local isClassic = IsClassicWoW()

    for providerId, provider in pairs(registeredProviders) do
        -- Include provider if it supports current WoW version
        if not isClassic or provider.supportsClassic then
            compatibleProviders[providerId] = provider
        else
            ns.utils.DebugPrint("Filtering out provider", provider.name, "- not compatible with classic")
        end
    end

    return compatibleProviders
end

-- Get a specific provider by ID
function ns.providers.GetProvider(providerId)
    return registeredProviders[providerId]
end

-- Get all enabled providers (filtered by both user preference and WoW version compatibility)
function ns.providers.GetEnabledProviders()
    local enabledProviders = {}
    local isClassic = IsClassicWoW()

    for providerId, provider in pairs(registeredProviders) do
        -- Check both WoW version compatibility AND user enabled setting
        local isCompatible = not isClassic or provider.supportsClassic
        local isUserEnabled = ns.IsWebsiteEnabled(providerId)

        if isCompatible and isUserEnabled then
            enabledProviders[providerId] = provider
            ns.utils.DebugPrint("Provider", provider.name, "enabled and compatible")
        else
            local reason = not isCompatible and "not compatible with classic" or "disabled by user"
            ns.utils.DebugPrint("Filtering out provider", provider.name, "-", reason)
        end
    end
    return enabledProviders
end

-- Generate URLs for all enabled providers
function ns.providers.GenerateURLs(name, realm)
    if not name or not realm then return {} end

    local urls = {}
    local regionCode, regionId = ns.region.GetRegion()

    for providerId, provider in pairs(ns.providers.GetEnabledProviders()) do
        local success, result = pcall(provider.getURL, name, realm, regionCode, regionId)
        if success and result then
            urls[providerId] = {
                provider = provider,
                url = result
            }
            ns.utils.DebugPrint("Generated URL for", provider.name .. ":", result)
        else
            ns.utils.DebugPrint("Failed to generate URL for", provider.name, "- Error:", result or "unknown")
        end
    end

    return urls
end

-- Get menu text for a provider
function ns.providers.GetMenuText(providerId)
    local provider = registeredProviders[providerId]
    if provider then
        return provider.name
    end
    return "Unknown Provider"
end