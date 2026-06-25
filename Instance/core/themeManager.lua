-- core/themeManager.lua - Obsidian Theme Manager
local ThemeManager = {}

function ThemeManager:Init(library, saveManager)
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    local theme = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    
    if not theme then
        error("Failed to load Obsidian ThemeManager")
    end
    
    theme:SetLibrary(library)
    theme:SetFolder("Instance")
    
    return theme
end

return ThemeManager
