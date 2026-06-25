-- ui/menu.lua - Obsidian UI
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
    
    -- Create Window with Obsidian syntax
    self.Window = lib:CreateWindow({
        Title = config.Menu.Title or "instance",
        Center = config.Menu.Center or true,
        AutoShow = config.Menu.AutoShow or true,
        Size = config.Menu.Size or Vector2.new(700, 600),
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
    
    -- Setup Theme Manager
    local themeMgr = theme:Init(lib, save)
    local saveMgr = save:Init(lib, themeMgr)
    
    -- Apply to settings tab
    themeMgr:ApplyToTab(self.Tabs.Settings)
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
