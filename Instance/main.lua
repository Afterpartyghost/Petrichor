-- main.lua - Obsidian Version
local repo = "https://raw.githubusercontent.com/Afterpartyghost/Petrichor/refs/heads/main/Instance/"

local function LoadFile(path)
    local url = repo .. path
    print("Loading: " .. path)
    
    local content = game:HttpGet(url)
    if not content or #content == 0 then
        error("File is empty: " .. path)
    end
    
    local fn, err = loadstring(content, "@" .. path)
    if not fn then
        error("Failed to compile: " .. path .. "\n" .. err)
    end
    
    return fn()
end

print("Loading Instance (Obsidian)...")

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

-- Initialize modules
print("Initializing Modules...")
for name, module in pairs(Modules) do
    if module and module.Init then
        local ok, err = pcall(function()
            module:Init(UI, Config, Utils)
        end)
        if ok then
            print("✓ " .. name .. " loaded")
        else
            warn("✗ " .. name .. " failed: " .. tostring(err))
        end
    end
end

print("✓ All modules loaded!")
