-- main.lua - Debug Version
local repo = "https://raw.githubusercontent.com/Afterpartyghost/Petrichor/refs/heads/main/Instance/"

local function LoadFile(path)
    print("📂 Loading: " .. path)
    local url = repo .. path
    print("   URL: " .. url)
    
    local content = game:HttpGet(url)
    if not content or #content == 0 then
        error("❌ File is empty: " .. path)
    end
    print("   Size: " .. #content .. " bytes")
    
    local fn, err = loadstring(content, "@" .. path)
    if not fn then
        error("❌ Failed to compile: " .. path .. "\n" .. tostring(err))
    end
    
    print("✅ Loaded: " .. path)
    return fn()
end

print("=== INSTANCE LOADER (DEBUG) ===")

-- Load Config first and check it
local Config = LoadFile("core/config.lua")
print("✅ Config loaded successfully")
print("   Config type: " .. type(Config))
if Config then
    print("   Config.Menu exists: " .. tostring(Config.Menu ~= nil))
    if Config.Menu then
        print("   Config.Menu.Title: " .. tostring(Config.Menu.Title))
        print("   Config.Menu.Size: " .. tostring(Config.Menu.Size))
    end
end

local Utils = LoadFile("core/utilities.lua")
print("✅ Utils loaded")

local Library = LoadFile("core/library.lua")
print("✅ Library loaded")

-- Init Utils
Utils:Init()
print("✅ Utils initialized")

-- Load UI
local UI = LoadFile("ui/menu.lua")
print("✅ UI loaded")

-- Initialize UI with debug
print("🔄 Initializing UI...")
UI:Init(Library, Config, Utils)
print("✅ UI initialized")

print("=== ALL LOADED ===")
