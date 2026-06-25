-- core/saveManager.lua - Fixed
local SaveManager = {}

function SaveManager:Init(library, themeManager)
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    local save = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    
    if not save then
        error("Failed to load Obsidian SaveManager")
    end
    
    -- Just return the save directly
    save:SetLibrary(library)
    save:SetFolder("Instance/Rivals")
    save:IgnoreThemeSettings()
    save:SetIgnoreIndexes({ "MenuKeybind" })
    
    return save
end

return SaveManager
