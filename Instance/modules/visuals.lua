-- modules/visuals.lua - Works without config
local Visuals = {}
local Utils, UI
local FOVObjects = {}
local CrosshairObjects = {}

-- Default settings
local Settings = {
    FOV = {
        Enabled = false,
        Color = Color3.fromRGB(0, 200, 255),
        Thickness = 1.5,
        Filled = false,
        FillTransparency = 0.5,
    },
    Crosshair = {
        Enabled = false,
        Color = Color3.fromRGB(0, 200, 255),
        Size = 10,
        Gap = 5,
        Dot = true,
    },
}

function Visuals:Init(uiModule, configModule, utilsModule)
    UI = uiModule
    Utils = utilsModule
    
    self:SetupUI()
    self:StartFOVLoop()
    self:SetupCrosshair()
end

function Visuals:SetupUI()
    -- FOV Circle
    local fovGroup = UI:GetVisualsRightGroup("FOV Circle")
    if not fovGroup then return end
    
    fovGroup:AddToggle("FOVEnabled", {
        Text = "Show FOV",
        Default = false,
        Callback = function(val)
            Settings.FOV.Enabled = val
        end,
    }):AddColorPicker("FOVColor", {
        Default = Settings.FOV.Color,
        Title = "FOV Color",
        Callback = function(val)
            Settings.FOV.Color = val
        end,
    })
    
    fovGroup:AddSlider("FOVThickness", {
        Text = "Thickness",
        Default = Settings.FOV.Thickness,
        Min = 0.5,
        Max = 5,
        Rounding = 1,
        Compact = true,
        Callback = function(val)
            Settings.FOV.Thickness = val
        end,
    })
    
    fovGroup:AddToggle("FOVFilled", {
        Text = "Filled FOV",
        Default = false,
        Callback = function(val)
            Settings.FOV.Filled = val
        end,
    })
    
    fovGroup:AddSlider("FOVFillTransparency", {
        Text = "Fill Transparency",
        Default = Settings.FOV.FillTransparency,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Compact = true,
        Callback = function(val)
            Settings.FOV.FillTransparency = val
        end,
    })
    
    -- Crosshair
    local crossGroup = UI:GetVisualsRightGroup("Crosshair")
    if not crossGroup then return end
    
    crossGroup:AddToggle("CrosshairEnabled", {
        Text = "Enable Crosshair",
        Default = false,
        Callback = function(val)
            Settings.Crosshair.Enabled = val
        end,
    }):AddColorPicker("CrosshairColor", {
        Default = Settings.Crosshair.Color,
        Title = "Crosshair Color",
        Callback = function(val)
            Settings.Crosshair.Color = val
        end,
    })
    
    crossGroup:AddSlider("CrosshairSize", {
        Text = "Size",
        Default = Settings.Crosshair.Size,
        Min = 4,
        Max = 20,
        Rounding = 0,
        Compact = true,
        Callback = function(val)
            Settings.Crosshair.Size = val
        end,
    })
    
    crossGroup:AddSlider("CrosshairGap", {
        Text = "Gap",
        Default = Settings.Crosshair.Gap,
        Min = 0,
        Max = 10,
        Rounding = 0,
        Compact = true,
        Callback = function(val)
            Settings.Crosshair.Gap = val
        end,
    })
    
    crossGroup:AddToggle("CrosshairDot", {
        Text = "Dot",
        Default = true,
        Callback = function(val)
            Settings.Crosshair.Dot = val
        end,
    })
end

function Visuals:StartFOVLoop()
    Utils.RunService.RenderStepped:Connect(function()
        if not Settings.FOV.Enabled then
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
    local radius = 150 -- Default FOV radius
    local color = Settings.FOV.Color
    local thickness = Settings.FOV.Thickness
    
    if not FOVObjects.circle then
        FOVObjects.circle = Drawing.new("Circle")
        FOVObjects.circle.NumSides = 36
        FOVObjects.circle.Filled = false
        FOVObjects.circle.Transparency = 1
    end
    
    local circle = FOVObjects.circle
    circle.Visible = true
    circle.Position = center
    circle.Radius = radius
    circle.Color = color
    circle.Thickness = thickness
    
    if Settings.FOV.Filled then
        if not FOVObjects.fill then
            FOVObjects.fill = Drawing.new("Circle")
            FOVObjects.fill.NumSides = 36
            FOVObjects.fill.Filled = true
            FOVObjects.fill.Thickness = 0
        end
        
        local fill = FOVObjects.fill
        fill.Visible = true
        fill.Position = center
        fill.Radius = radius
        fill.Color = color
        fill.Transparency = Settings.FOV.FillTransparency
    elseif FOVObjects.fill then
        FOVObjects.fill.Visible = false
    end
end

function Visuals:ClearFOV()
    if FOVObjects.circle then
        FOVObjects.circle.Visible = false
    end
    if FOVObjects.fill then
        FOVObjects.fill.Visible = false
    end
end

function Visuals:SetupCrosshair()
    Utils.RunService.RenderStepped:Connect(function()
        if not Settings.Crosshair.Enabled then
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
    local color = Settings.Crosshair.Color
    local size = Settings.Crosshair.Size
    local gap = Settings.Crosshair.Gap
    local thickness = 1.5
    
    local positions = {
        {center + Vector2.new(0, -(size + gap)), center + Vector2.new(0, -gap)},
        {center + Vector2.new(0, size + gap), center + Vector2.new(0, gap)},
        {center + Vector2.new(-(size + gap), 0), center + Vector2.new(-gap, 0)},
        {center + Vector2.new(size + gap, 0), center + Vector2.new(gap, 0)},
    }
    
    for i, pos in ipairs(positions) do
        local line = CrosshairObjects[i]
        if not line then
            line = Drawing.new("Line")
            line.Thickness = thickness
            CrosshairObjects[i] = line
        end
        
        line.Visible = true
        line.From = pos[1]
        line.To = pos[2]
        line.Color = color
        line.Thickness = thickness
    end
    
    if Settings.Crosshair.Dot then
        local dot = CrosshairObjects.dot
        if not dot then
            dot = Drawing.new("Square")
            dot.Filled = true
            dot.Thickness = 0
            dot.Size = Vector2.new(3, 3)
            CrosshairObjects.dot = dot
        end
        
        dot.Visible = true
        dot.Position = center - Vector2.new(1.5, 1.5)
        dot.Size = Vector2.new(3, 3)
        dot.Color = color
    elseif CrosshairObjects.dot then
        CrosshairObjects.dot.Visible = false
    end
end

function Visuals:ClearCrosshair()
    for _, obj in pairs(CrosshairObjects) do
        if obj then
            obj.Visible = false
        end
    end
end

function Visuals:Cleanup()
    self:ClearFOV()
    self:ClearCrosshair()
end

return Visuals
