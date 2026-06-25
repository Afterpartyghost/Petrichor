-- ui/menu.lua - Fixed
local UI = {
    Window = nil,
    Tabs = {},
    Library = nil,
    Config = nil,
}

function UI:Init(libraryModule, themeManagerModule, saveManagerModule, config)
    self.Config = config
    
    -- Initialize Obsidian library
    local lib, theme, save = libraryModule:Init()
    self.Library = lib
    
    -- Get size from config
    local size = config.Menu.Size or { X = 700, Y = 600 }
    
    -- Create Window
    self.Window = lib:CreateWindow({
        Title = config.Menu.Title or "instance",
        Center = true,
        AutoShow = true,
        Size = UDim2.new(0, size.X, 0, size.Y),
        ShowCustomCursor = true,
    })
    
    -- Create Tabs
    self.Tabs = {
        Combat = self.Window:AddTab("combat"),
        Character = self.Window:AddTab("character"),
        Visuals = self.Window:AddTab("visuals"),
        World = self.Window:AddTab("world"),
        Misc = self.Window:AddTab("misc"),
        Settings = self.Window:AddTab("settings"),
    }
    
    -- Setup Theme Manager - FIXED: Just use the theme directly
    local themeMgr = theme
    themeMgr:SetLibrary(lib)
    themeMgr:SetFolder("Instance")
    themeMgr:ApplyToTab(self.Tabs.Settings)
    
    -- Setup Save Manager - FIXED: Just use the save directly
    local saveMgr = save
    saveMgr:SetLibrary(lib)
    saveMgr:SetFolder("Instance/Rivals")
    saveMgr:IgnoreThemeSettings()
    saveMgr:SetIgnoreIndexes({ "MenuKeybind" })
    saveMgr:BuildConfigSection(self.Tabs.Settings)
    
    -- Setup menu keybind
    self:SetupMenuKeybind()
    
    print("✓ UI Initialized with Obsidian")
end

function UI:SetupMenuKeybind()
    local menuGroup = self.Tabs.Settings:AddLeftGroupbox("Menu")
    
    menuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu keybind"
    })
    
    menuGroup:AddButton("Unload", function()
        self.Library:Unload()
    end)
    
    self.Library.ToggleKeybind = self.Library.Options.MenuKeybind
end

-- Getter functions for tabs
function UI:GetCombatGroup(name)
    return self.Tabs.Combat:AddLeftGroupbox(name)
end

function UI:GetCombatRightGroup(name)
    return self.Tabs.Combat:AddRightGroupbox(name)
end

function UI:GetVisualsGroup(name)
    return self.Tabs.Visuals:AddLeftGroupbox(name)
end

function UI:GetVisualsRightGroup(name)
    return self.Tabs.Visuals:AddRightGroupbox(name)
end

function UI:GetCharacterGroup(name)
    return self.Tabs.Character:AddLeftGroupbox(name)
end

function UI:GetCharacterRightGroup(name)
    return self.Tabs.Character:AddRightGroupbox(name)
end

function UI:GetWorldGroup(name)
    return self.Tabs.World:AddLeftGroupbox(name)
end

function UI:GetWorldRightGroup(name)
    return self.Tabs.World:AddRightGroupbox(name)
end

function UI:GetMiscGroup(name)
    return self.Tabs.Misc:AddLeftGroupbox(name)
end

function UI:GetMiscRightGroup(name)
    return self.Tabs.Misc:AddRightGroupbox(name)
end

return UI
