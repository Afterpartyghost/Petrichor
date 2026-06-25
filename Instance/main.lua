-- main.lua
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

print("Loading Instance from GitHub...")

-- Load Core
local Config = LoadFile("core/config.lua")
local Utils = LoadFile("core/utilities.lua")
local Library = LoadFile("core/library.lua")
local ThemeManager = LoadFile("core/themeManager.lua")
local SaveManager = LoadFile("core/saveManager.lua")

-- Init Utils
Utils:Init()

-- Load UI
local UI = LoadFile("ui/menu.lua")

-- Initialize UI
UI:Init(Library, ThemeManager, SaveManager, Config)

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

print("✓ All modules loaded successfully!")
