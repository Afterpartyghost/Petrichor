-- core/library.lua - Obsidian Library
local Library = {}

function Library:Init()
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    
    local lib = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local theme = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    local save = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    
    if not lib then
        error("Failed to load Obsidian Library")
    end
    
    return lib, theme, save
end

return Library
