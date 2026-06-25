--[[
    saveManager.lua - Config management
]]

local SaveManager = {}

function SaveManager:Init(library, themeManager)
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    local save = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    
    save:SetLibrary(library)
    save:SetFolder("Instance/Rivals")
    save:IgnoreThemeSettings()
    save:SetIgnoreIndexes({ "MenuKeybind" })
    
    return save
end

return SaveManager