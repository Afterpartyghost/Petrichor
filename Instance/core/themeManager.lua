--[[
    themeManager.lua - Theme management
]]

local ThemeManager = {}

function ThemeManager:Init(library, saveManager)
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    local theme = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    
    theme:SetLibrary(library)
    theme:SetFolder("Instance")
    
    return theme
end

return ThemeManager