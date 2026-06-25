-- core/themeManager.lua - Fixed
local ThemeManager = {}

function ThemeManager:Init(library, saveManager)
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    local theme = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    
    if not theme then
        error("Failed to load Obsidian ThemeManager")
    end
    
    -- Just return the theme directly, it already has all methods
    theme:SetLibrary(library)
    theme:SetFolder("Instance")
    
    return theme
end

return ThemeManager
