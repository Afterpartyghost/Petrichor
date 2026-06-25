-- ui/menu.lua - Complete Rewrite
local UI = {
    Window = nil,
    Tabs = {},
    Library = nil,
}

function UI:Init(libraryModule, config, utils)
    print("🔄 UI:Init started")
    
    -- Initialize Obsidian library
    local lib, theme, save = libraryModule:Init()
    self.Library = lib
    
    -- Create Window with hardcoded values (ignore config for now)
    self.Window = lib:CreateWindow({
        Title = "instance",
        Center = true,
        AutoShow = true,
        Size = UDim2.new(0, 700, 0, 600),
        ShowCustomCursor = true,
    })
    
    print("✅ Window created")
    
    -- Create Tabs
    self.Tabs = {
        Combat = self.Window:AddTab("combat"),
        Character = self.Window:AddTab("character"),
        Visuals = self.Window:AddTab("visuals"),
        World = self.Window:AddTab("world"),
        Misc = self.Window:AddTab("misc"),
        Settings = self.Window:AddTab("settings"),
    }
    
    print("✅ Tabs created")
    
    -- Setup Theme Manager
    if theme then
        pcall(function()
            theme:SetLibrary(lib)
            theme:SetFolder("Instance")
            theme:ApplyToTab(self.Tabs.Settings)
        end)
    end
    
    -- Setup Save Manager
    if save then
        pcall(function()
            save:SetLibrary(lib)
            save:SetFolder("Instance/Rivals")
            save:IgnoreThemeSettings()
            save:SetIgnoreIndexes({ "MenuKeybind" })
            save:BuildConfigSection(self.Tabs.Settings)
        end)
    end
    
    -- Setup menu keybind
    self:SetupMenuKeybind()
    
    print("✅ UI Initialized Successfully")
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
    
    if self.Library then
        self.Library.ToggleKeybind = self.Library.Options and self.Library.Options.MenuKeybind
    end
end

-- Getter functions for tabs
function UI:GetCombatGroup(name)
    if self.Tabs and self.Tabs.Combat then
        return self.Tabs.Combat:AddLeftGroupbox(name)
    end
    return nil
end

function UI:GetCombatRightGroup(name)
    if self.Tabs and self.Tabs.Combat then
        return self.Tabs.Combat:AddRightGroupbox(name)
    end
    return nil
end

function UI:GetVisualsGroup(name)
    if self.Tabs and self.Tabs.Visuals then
        return self.Tabs.Visuals:AddLeftGroupbox(name)
    end
    return nil
end

function UI:GetVisualsRightGroup(name)
    if self.Tabs and self.Tabs.Visuals then
        return self.Tabs.Visuals:AddRightGroupbox(name)
    end
    return nil
end

function UI:GetCharacterGroup(name)
    if self.Tabs and self.Tabs.Character then
        return self.Tabs.Character:AddLeftGroupbox(name)
    end
    return nil
end

function UI:GetCharacterRightGroup(name)
    if self.Tabs and self.Tabs.Character then
        return self.Tabs.Character:AddRightGroupbox(name)
    end
    return nil
end

function UI:GetWorldGroup(name)
    if self.Tabs and self.Tabs.World then
        return self.Tabs.World:AddLeftGroupbox(name)
    end
    return nil
end

function UI:GetWorldRightGroup(name)
    if self.Tabs and self.Tabs.World then
        return self.Tabs.World:AddRightGroupbox(name)
    end
    return nil
end

function UI:GetMiscGroup(name)
    if self.Tabs and self.Tabs.Misc then
        return self.Tabs.Misc:AddLeftGroupbox(name)
    end
    return nil
end

function UI:GetMiscRightGroup(name)
    if self.Tabs and self.Tabs.Misc then
        return self.Tabs.Misc:AddRightGroupbox(name)
    end
    return nil
end

return UI
