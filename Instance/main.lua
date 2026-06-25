-- main.lua - With Cleanup on Unload
local repo = "https://raw.githubusercontent.com/Afterpartyghost/Petrichor/refs/heads/main/Instance/"

local function LoadFile(path)
    print("Loading: " .. path)
    local content = game:HttpGet(repo .. path)
    local fn = loadstring(content, "@" .. path)
    if not fn then
        error("Failed to load: " .. path)
    end
    return fn()
end

print("Loading Instance...")

-- Load Core
local Config = LoadFile("core/config.lua")
local Utils = LoadFile("core/utilities.lua")
local Library = LoadFile("core/library.lua")

-- Load UI
local UI = LoadFile("ui/menu.lua")

-- Initialize UI
UI:Init(Library, Config, Utils)

-- Load Modules
local Modules = {
    Aimbot = LoadFile("modules/aimbot.lua"),
    ESP = LoadFile("modules/esp.lua"),
    Combat = LoadFile("modules/combat.lua"),
    Visuals = LoadFile("modules/visuals.lua"),
    Movement = LoadFile("modules/movement.lua"),
    AntiAim = LoadFile("modules/antiaim.lua"),
    Ragebot = LoadFile("modules/ragebot.lua"),
    Misc = LoadFile("modules/misc.lua"),
}

-- Store modules for cleanup
local LoadedModules = {}

-- Initialize each module
print("Initializing Modules...")
for name, module in pairs(Modules) do
    if module and module.Init then
        local ok, err = pcall(function()
            module:Init(UI, Config, Utils)
            LoadedModules[name] = module
        end)
        if ok then
            print("✓ " .. name .. " loaded")
        else
            warn("✗ " .. name .. " failed: " .. tostring(err))
        end
    end
end

-- Cleanup function for when menu is unloaded
local function CleanupAll()
    print("Cleaning up modules...")
    for name, module in pairs(LoadedModules) do
        if module and module.Cleanup then
            pcall(function()
                module:Cleanup()
                print("✓ " .. name .. " cleaned up")
            end)
        end
    end
    LoadedModules = {}
end

-- Hook into library unload
if UI and UI.Library then
    local oldUnload = UI.Library.Unload
    UI.Library.Unload = function(...)
        CleanupAll()
        if oldUnload then
            return oldUnload(...)
        end
    end
end

print("✓ All modules loaded!")
