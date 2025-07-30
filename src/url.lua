local _, ns = ...

-- URL generation module
ns.url = {}

-- Generate URLs for all enabled providers
function ns.url.GetAllURLs(name, realm)
    if not name or not realm then return {} end

    return ns.providers.GenerateURLs(name, realm)
end

-- Get the appropriate copy text based on current copy mode and selected provider
function ns.url.GetCopyText(name, realm, providerId)
    if not name or not realm then return end

    if ns.config.COPY_MODE == "name" then
        -- Return name-realm format for manual searching
        local englishRealm = ns.region.GetRealmSlug(realm)
        return string.format("%s-%s", name, englishRealm)
    else
        -- Return full URL for the specified provider
        if providerId then
            local urls = ns.url.GetAllURLs(name, realm)
            if urls[providerId] then
                return urls[providerId].url
            end
        end

        -- Fallback to first available URL if no specific provider
        local urls = ns.url.GetAllURLs(name, realm)
        return urls[1].url
    end
end