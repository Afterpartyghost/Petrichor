--[[
    visuals.lua - Visuals Module (FOV, Crosshair, etc.)
]]

local Visuals = {}
local Config, Utils, UI

function Visuals:Init(uiModule, configModule, utilsModule)
    Config = configModule
    Utils = utilsModule
    UI = uiModule
    
    self.FOVObjects = {}
    self:SetupUI()
    self:StartFOVLoop()
    self:SetupCrosshair()
end

function Visuals:SetupUI()
    -- FOV Circle
    local fovGroup = UI:GetVisualsRightGroup("FOV Circle")
    
    fovGroup:AddToggle("FOVEnabled", {
        Text = "Show FOV",
        Default = Config.Visuals.FOV.Enabled,
        Callback = function(val)
            Config.Visuals.FOV.Enabled = val
        end,
    }):AddColorPicker("FOVColor", {
        Default = Config.Visuals.FOV.Color,
        Title = "FOV Color",
        Callback = function(val)
            Config.Visuals.FOV.Color = val
        end,
    })
    
    fovGroup:AddSlider("FOVThickness", {
        Text = "Thickness",
        Default = Config.Visuals.FOV.Thickness,
        Min = 0.5,
        Max = 5,
        Rounding = 1,
        Compact = true,
        Callback = function(val)
            Config.Visuals.FOV.Thickness = val
        end,
    })
    
    fovGroup:AddToggle("FOVFilled", {
        Text = "Filled FOV",
        Default = Config.Visuals.FOV.Filled,
        Callback = function(val)
            Config.Visuals.FOV.Filled = val
        end,
    })
    
    fovGroup:AddSlider("FOVFillTransparency", {
        Text = "Fill Transparency",
        Default = Config.Visuals.FOV.FillTransparency,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Compact = true,
        Callback = function(val)
            Config.Visuals.FOV.FillTransparency = val
        end,
    })
    
    -- Crosshair
    local crossGroup = UI:GetVisualsRightGroup("Crosshair")
    
    crossGroup:AddToggle("CrosshairEnabled", {
        Text = "Enable Crosshair",
        Default = Config.Visuals.Crosshair.Enabled,
        Callback = function(val)
            Config.Visuals.Crosshair.Enabled = val
        end,
    }):AddColorPicker("CrosshairColor", {
        Default = Config.Visuals.Crosshair.Color,
        Title = "Crosshair Color",
        Callback = function(val)
            Config.Visuals.Crosshair.Color = val
        end,
    })
    
    crossGroup:AddSlider("CrosshairSize", {
        Text = "Size",
        Default = Config.Visuals.Crosshair.Size,
        Min = 4,
        Max = 20,
        Rounding = 0,
        Compact = true,
        Callback = function(val)
            Config.Visuals.Crosshair.Size = val
        end,
    })
    
    crossGroup:AddSlider("CrosshairGap", {
        Text = "Gap",
        Default = Config.Visuals.Crosshair.Gap,
        Min = 0,
        Max = 10,
        Rounding = 0,
        Compact = true,
        Callback = function(val)
            Config.Visuals.Crosshair.Gap = val
        end,
    })
    
    crossGroup:AddToggle("CrosshairDot", {
        Text = "Dot",
        Default = Config.Visuals.Crosshair.Dot,
        Callback = function(val)
            Config.Visuals.Crosshair.Dot = val
        end,
    })
    
    crossGroup:AddToggle("CrosshairAmmo", {
        Text = "Show Ammo",
        Default = Config.Visuals.Crosshair.ShowAmmo,
        Callback = function(val)
            Config.Visuals.Crosshair.ShowAmmo = val
        end,
    })
    
    crossGroup:AddToggle("CrosshairWatermark", {
        Text = "Show Watermark",
        Default = Config.Visuals.Crosshair.ShowWatermark,
        Callback = function(val)
            Config.Visuals.Crosshair.ShowWatermark = val
        end,
    })
end

function Visuals:StartFOVLoop()
    Utils.RunService.RenderStepped:Connect(function()
        if not Config.Visuals.FOV.Enabled then
            self:ClearFOV()
            return
        end
        
        self:DrawFOV()
    end)
end

function Visuals:DrawFOV()
    local cam = Utils.Workspace.CurrentCamera
    if not cam then return end
    
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local radius = Config.Aimbot.FOV or 150
    local color = Config.Visuals.FOV.Color
    local thickness = Config.Visuals.FOV.Thickness
    
    -- Create or update circle
    if not self.FOVObjects.circle then
        self.FOVObjects.circle = Drawing.new("Circle")
        self.FOVObjects.circle.NumSides = 36
        self.FOVObjects.circle.Filled = false
        self.FOVObjects.circle.Transparency = 1
    end
    
    local circle = self.FOVObjects.circle
    circle.Visible = true
    circle.Position = center
    circle.Radius = radius
    circle.Color = color
    circle.Thickness = thickness
    
    -- Filled FOV
    if Config.Visuals.FOV.Filled then
        if not self.FOVObjects.fill then
            self.FOVObjects.fill = Drawing.new("Circle")
            self.FOVObjects.fill.NumSides = 36
            self.FOVObjects.fill.Filled = true
            self.FOVObjects.fill.Thickness = 0
        end
        
        local fill = self.FOVObjects.fill
        fill.Visible = true
        fill.Position = center
        fill.Radius = radius
        fill.Color = color
        fill.Transparency = Config.Visuals.FOV.FillTransparency
    elseif self.FOVObjects.fill then
        self.FOVObjects.fill.Visible = false
    end
end

function Visuals:ClearFOV()
    if self.FOVObjects.circle then
        self.FOVObjects.circle.Visible = false
    end
    if self.FOVObjects.fill then
        self.FOVObjects.fill.Visible = false
    end
end

function Visuals:SetupCrosshair()
    self.CrosshairObjects = {}
    
    Utils.RunService.RenderStepped:Connect(function()
        if not Config.Visuals.Crosshair.Enabled then
            self:ClearCrosshair()
            return
        end
        
        self:DrawCrosshair()
    end)
end

function Visuals:DrawCrosshair()
    local cam = Utils.Workspace.CurrentCamera
    if not cam then return end
    
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local color = Config.Visuals.Crosshair.Color
    local size = Config.Visuals.Crosshair.Size
    local gap = Config.Visuals.Crosshair.Gap
    local thickness = 1.5
    
    local positions = {
        {center + Vector2.new(0, -(size + gap)), center + Vector2.new(0, -gap)}, -- Top
        {center + Vector2.new(0, size + gap), center + Vector2.new(0, gap)},      -- Bottom
        {center + Vector2.new(-(size + gap), 0), center + Vector2.new(-gap, 0)},  -- Left
        {center + Vector2.new(size + gap, 0), center + Vector2.new(gap, 0)},      -- Right
    }
    
    for i, pos in ipairs(positions) do
        local line = self.CrosshairObjects[i]
        if not line then
            line = Drawing.new("Line")
            line.Thickness = thickness
            self.CrosshairObjects[i] = line
        end
        
        line.Visible = true
        line.From = pos[1]
        line.To = pos[2]
        line.Color = color
        line.Thickness = thickness
    end
    
    -- Dot
    if Config.Visuals.Crosshair.Dot then
        local dot = self.CrosshairObjects.dot
        if not dot then
            dot = Drawing.new("Square")
            dot.Filled = true
            dot.Thickness = 0
            dot.Size = Vector2.new(3, 3)
            self.CrosshairObjects.dot = dot
        end
        
        dot.Visible = true
        dot.Position = center - Vector2.new(1.5, 1.5)
        dot.Size = Vector2.new(3, 3)
        dot.Color = color
    elseif self.CrosshairObjects.dot then
        self.CrosshairObjects.dot.Visible = false
    end
end

function Visuals:ClearCrosshair()
    for _, obj in pairs(self.CrosshairObjects) do
        obj.Visible = false
    end
end

return Visuals