local _, ns = ...

-- URL generation module
ns.url = {}

-- Generate URLs for all enabled providers
function ns.url.GetAllURLs(name, realm)
    if not name or not realm then return {} end

    return ns.providers.GenerateURLs(name, realm)
end

-- Get the URL for a specific provider
function ns.url.GetProviderURL(name, realm, providerId)
    if not name or not realm or not providerId then return end

    return ns.providers.GenerateURLForProvider(name, realm, providerId)
end

-- Get name-realm format for manual searching
function ns.url.GetNameRealmFormat(name, realm)
    if not name or not realm then return end

    local englishRealm = ns.region.GetRealmSlug(realm)
    return string.format("%s-%s", name, englishRealm)
end
