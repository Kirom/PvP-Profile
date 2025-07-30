local _, ns = ...

-- PvP Profile Core - Main initialization and coordination
-- This file coordinates all addon modules and handles initialization

-- Initialize all addon components
local function Initialize()
    -- Register slash commands
    ns.commands.RegisterSlashCommands()

    -- Initialize event handling
    ns.events.Initialize()

    -- Initialize options panel
    ns.options.Initialize()
end

-- Start initialization
Initialize()