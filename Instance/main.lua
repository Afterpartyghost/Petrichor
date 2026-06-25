--[[
    Instance.lua - Main Entry Point (Local Version)
]]

local function LoadFile(path)
    if not isfile(path) then
        error("File not found: " .. path)
    end
    local content = readfile(path)
    local fn, err = loadstring(content, "@" .. path)
    if not fn then
        error("Failed to load " .. path .. ": " .. err)
    end
    return fn()
end

print("Loading Instance...")

-- Load Core
local Config = LoadFile("instance/core/config.lua")
local Utils = LoadFile("instance/core/utilities.lua")
local Library = LoadFile("instance/core/library.lua")
local ThemeManager = LoadFile("instance/core/themeManager.lua")
local SaveManager = LoadFile("instance/core/saveManager.lua")

-- Load UI
local UI = LoadFile("instance/ui/menu.lua")

-- Initialize UI
UI:Init(Library, ThemeManager, SaveManager, Config)

-- Load Modules
local Modules = {
    Aimbot = LoadFile("instance/modules/aimbot.lua"),
    ESP = LoadFile("instance/modules/esp.lua"),
    Combat = LoadFile("instance/modules/combat.lua"),
    Visuals = LoadFile("instance/modules/visuals.lua"),
    Movement = LoadFile("instance/modules/movement.lua"),
    AntiAim = LoadFile("instance/modules/antiaim.lua"),
    Ragebot = LoadFile("instance/modules/ragebot.lua"),
    Misc = LoadFile("instance/modules/misc.lua"),
}

-- Initialize each module
print("Initializing Modules...")
for name, module in pairs(Modules) do
    if module and module.Init then
        pcall(function()
            module:Init(UI, Config, Utils)
            print("✓ " .. name .. " loaded")
        end)
    end
end

print("All modules loaded successfully!")