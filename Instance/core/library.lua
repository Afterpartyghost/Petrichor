--[[
    library.lua - LinoriaLib wrapper
]]

local Library = {}

function Library:Init()
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    
    local lib = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local theme = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    local save = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    
    return lib, theme, save
end

return Library