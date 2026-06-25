-- ui/menu.lua - More Defensive
local UI = {
    Window = nil,
    Tabs = {},
    Library = nil,
    Config = nil,
}

function UI:Init(libraryModule, config, utils)
    print("🔄 UI:Init called")
    print("   config type: " .. type(config))
    
    self.Config = config or {}
    self.Utils = utils
    
    -- Initialize Obsidian library
    print("   Loading library...")
    local lib, theme, save = libraryModule:Init()
    self.Library = lib
    print("   Library loaded")
    
    -- Get config values with defaults
    local title = "instance"
    local size = { X = 700, Y = 600 }
    local autoShow = true
    
    -- SAFELY check config
    if type(config) == "table" then
        print("   Config is a table, checking Menu...")
        if config.Menu then
            print("   Config.Menu exists!")
            title = config.Menu.Title or "instance"
            size = config.Menu.Size or { X = 700, Y = 600 }
            autoShow = config.Menu.AutoShow or true
        else
            print("   ⚠️ Config.Menu is nil, using defaults")
        end
    else
        print("   ⚠️ Config is not a table! Type: " .. type(config))
    end
    
    print("   Title: " .. title)
    print("   Size: " .. size.X .. "x" .. size.Y)
    
    -- Create Window
    self.Window = lib:CreateWindow({
        Title = title,
        Center = true,
        AutoShow = autoShow,
        Size = UDim2.new(0, size.X, 0, size.Y),
        ShowCustomCursor = true,
    })
    print("   Window created")
    
    -- Create Tabs
    self.Tabs = {
        Combat = self.Window:AddTab("combat"),
        Character = self.Window:AddTab("character"),
        Visuals = self.Window:AddTab("visuals"),
        World = self.Window:AddTab("world"),
        Misc = self.Window:AddTab("misc"),
        Settings = self.Window:AddTab("settings"),
    }
    print("   Tabs created")
    
    -- Setup Theme Manager
    if theme and type(theme.SetLibrary) == "function" then
        theme:SetLibrary(lib)
        theme:SetFolder("Instance")
        theme:ApplyToTab(self.Tabs.Settings)
        print("   Theme Manager setup")
    end
    
    -- Setup Save Manager
    if save and type(save.SetLibrary) == "function" then
        save:SetLibrary(lib)
        save:SetFolder("Instance/Rivals")
        save:IgnoreThemeSettings()
        save:SetIgnoreIndexes({ "MenuKeybind" })
        save:BuildConfigSection(self.Tabs.Settings)
        print("   Save Manager setup")
    end
    
    -- Setup menu keybind
    self:SetupMenuKeybind()
    
    print("✓ UI Initialized Successfully")
end

function UI:SetupMenuKeybind()
    local menuGroup = self.Tabs.Settings:AddLeftGroupbox("Menu")
    
    menuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu keybind"
    })
    
    menuGroup:AddButton("Unload", function()
        if self.Library then
            self.Library:Unload()
        end
    end)
    
    if self.Library and self.Library.Options then
        self.Library.ToggleKeybind = self.Library.Options.MenuKeybind
    end
end

-- Getter functions for tabs
function UI:GetCombatGroup(name)
    return self.Tabs and self.Tabs.Combat and self.Tabs.Combat:AddLeftGroupbox(name)
end

function UI:GetCombatRightGroup(name)
    return self.Tabs and self.Tabs.Combat and self.Tabs.Combat:AddRightGroupbox(name)
end

function UI:GetVisualsGroup(name)
    return self.Tabs and self.Tabs.Visuals and self.Tabs.Visuals:AddLeftGroupbox(name)
end

function UI:GetVisualsRightGroup(name)
    return self.Tabs and self.Tabs.Visuals and self.Tabs.Visuals:AddRightGroupbox(name)
end

function UI:GetCharacterGroup(name)
    return self.Tabs and self.Tabs.Character and self.Tabs.Character:AddLeftGroupbox(name)
end

function UI:GetCharacterRightGroup(name)
    return self.Tabs and self.Tabs.Character and self.Tabs.Character:AddRightGroupbox(name)
end

function UI:GetWorldGroup(name)
    return self.Tabs and self.Tabs.World and self.Tabs.World:AddLeftGroupbox(name)
end

function UI:GetWorldRightGroup(name)
    return self.Tabs and self.Tabs.World and self.Tabs.World:AddRightGroupbox(name)
end

function UI:GetMiscGroup(name)
    return self.Tabs and self.Tabs.Misc and self.Tabs.Misc:AddLeftGroupbox(name)
end

function UI:GetMiscRightGroup(name)
    return self.Tabs and self.Tabs.Misc and self.Tabs.Misc:AddRightGroupbox(name)
end

return UI
