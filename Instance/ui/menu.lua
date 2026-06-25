--[[
    menu.lua - Creates the UI
]]

local UI = {
    Window = nil,
    Tabs = {},
    Library = nil,
    Config = nil,
}

function UI:Init(library, themeManager, saveManager, config)
    self.Library = library
    self.Config = config
    
    local lib, theme, save = library:Init()
    
    -- Create Window
    self.Window = lib:CreateWindow({
        Title = config.Menu.Title,
        Center = config.Menu.Center,
        AutoShow = config.Menu.AutoShow,
        Size = config.Menu.Size,
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
    
    -- Setup Theme & Save
    local themeMgr = themeManager:Init(lib, save)
    local saveMgr = saveManager:Init(lib, themeMgr)
    
    themeMgr:ApplyToTab(self.Tabs.Settings)
    saveMgr:BuildConfigSection(self.Tabs.Settings)
    
    -- Add Menu Keybind
    self:SetupMenuKeybind()
    
    print("✓ UI Initialized")
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