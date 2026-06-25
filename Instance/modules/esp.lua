--[[
    esp.lua - ESP Module
]]

local ESP = {}
local Config, Utils, UI

function ESP:Init(uiModule, configModule, utilsModule)
    Config = configModule
    Utils = utilsModule
    UI = uiModule
    
    self.Objects = {}
    self:SetupUI()
    self:StartLoop()
    self:SetupEvents()
end

function ESP:SetupUI()
    local group = UI:GetVisualsGroup("ESP")
    
    group:AddToggle("ESPEnabled", {
        Text = "Enable ESP",
        Default = Config.ESP.Enabled,
        Callback = function(val)
            Config.ESP.Enabled = val
            if not val then self:ClearAll() end
        end,
    })
    
    group:AddToggle("BoxESP", {
        Text = "Box ESP",
        Default = Config.ESP.Box,
        Callback = function(val)
            Config.ESP.Box = val
        end,
    }):AddColorPicker("BoxColor", {
        Default = Config.ESP.BoxColor,
        Title = "Box Color",
        Callback = function(val)
            Config.ESP.BoxColor = val
        end,
    })
    
    group:AddToggle("HealthBar", {
        Text = "Health Bar",
        Default = Config.ESP.HealthBar,
        Callback = function(val)
            Config.ESP.HealthBar = val
        end,
    })
    
    group:AddToggle("NameESP", {
        Text = "Name ESP",
        Default = Config.ESP.Name,
        Callback = function(val)
            Config.ESP.Name = val
        end,
    }):AddColorPicker("NameColor", {
        Default = Config.ESP.NameColor,
        Title = "Name Color",
        Callback = function(val)
            Config.ESP.NameColor = val
        end,
    })
    
    group:AddToggle("DistanceESP", {
        Text = "Distance",
        Default = Config.ESP.Distance,
        Callback = function(val)
            Config.ESP.Distance = val
        end,
    })
    
    group:AddToggle("SkeletonESP", {
        Text = "Skeleton",
        Default = Config.ESP.Skeleton,
        Callback = function(val)
            Config.ESP.Skeleton = val
        end,
    }):AddColorPicker("SkeletonColor", {
        Default = Config.ESP.SkeletonColor,
        Title = "Skeleton Color",
        Callback = function(val)
            Config.ESP.SkeletonColor = val
        end,
    })
    
    group:AddToggle("Tracers", {
        Text = "Tracers",
        Default = Config.ESP.Tracers,
        Callback = function(val)
            Config.ESP.Tracers = val
        end,
    }):AddColorPicker("TracerColor", {
        Default = Config.ESP.TracerColor,
        Title = "Tracer Color",
        Callback = function(val)
            Config.ESP.TracerColor = val
        end,
    })
    
    group:AddToggle("Chams", {
        Text = "Chams",
        Default = Config.ESP.Chams,
        Callback = function(val)
            Config.ESP.Chams = val
        end,
    }):AddColorPicker("ChamsColor", {
        Default = Config.ESP.ChamsColor,
        Title = "Chams Color",
        Callback = function(val)
            Config.ESP.ChamsColor = val
        end,
    })
    
    group:AddSlider("ChamsTransparency", {
        Text = "Chams Transparency",
        Default = Config.ESP.ChamsTransparency,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Compact = true,
        Callback = function(val)
            Config.ESP.ChamsTransparency = val
        end,
    })
end

function ESP:StartLoop()
    Utils.RunService.RenderStepped:Connect(function()
        if not Config.ESP.Enabled then return end
        self:UpdateESP()
    end)
end

function ESP:SetupEvents()
    Utils.Players.PlayerAdded:Connect(function(player)
        if player ~= Utils.LocalPlayer then
            self:CreateESP(player)
        end
    end)
    
    Utils.Players.PlayerRemoving:Connect(function(player)
        self:RemoveESP(player)
    end)
end

function ESP:CreateESP(player)
    if self.Objects[player] then return end
    
    local box = {}
    
    -- Box
    box.boxLine = Drawing.new("Square")
    box.boxLine.Thickness = 1
    box.boxLine.Filled = false
    box.boxLine.Visible = false
    
    box.boxOutline = Drawing.new("Square")
    box.boxOutline.Thickness = 1
    box.boxOutline.Color = Color3.new(0, 0, 0)
    box.boxOutline.Filled = false
    box.boxOutline.Visible = false
    
    -- Health Bar
    box.healthBar = Drawing.new("Line")
    box.healthBar.Thickness = 3
    box.healthBar.Visible = false
    
    box.healthOutline = Drawing.new("Line")
    box.healthOutline.Thickness = 1
    box.healthOutline.Color = Color3.new(0, 0, 0)
    box.healthOutline.Visible = false
    
    -- Text
    box.nameLabel = Drawing.new("Text")
    box.nameLabel.Size = 12
    box.nameLabel.Outline = true
    box.nameLabel.Center = true
    box.nameLabel.Visible = false
    box.nameLabel.Font = 2
    
    box.distanceLabel = Drawing.new("Text")
    box.distanceLabel.Size = 10
    box.distanceLabel.Outline = true
    box.distanceLabel.Center = true
    box.distanceLabel.Visible = false
    box.distanceLabel.Font = 2
    
    -- Tracer
    box.tracerLine = Drawing.new("Line")
    box.tracerLine.Thickness = 1
    box.tracerLine.Visible = false
    
    -- Chams
    box.chams = nil
    
    self.Objects[player] = box
end

function ESP:RemoveESP(player)
    local box = self.Objects[player]
    if box then
        box.boxLine:Remove()
        box.boxOutline:Remove()
        box.healthBar:Remove()
        box.healthOutline:Remove()
        box.nameLabel:Remove()
        box.distanceLabel:Remove()
        box.tracerLine:Remove()
        if box.chams then
            box.chams:Destroy()
        end
        self.Objects[player] = nil
    end
end

function ESP:ClearAll()
    for player in pairs(self.Objects) do
        self:RemoveESP(player)
    end
end

function ESP:HideESP(box)
    if not box then return end
    box.boxLine.Visible = false
    box.boxOutline.Visible = false
    box.healthBar.Visible = false
    box.healthOutline.Visible = false
    box.nameLabel.Visible = false
    box.distanceLabel.Visible = false
    box.tracerLine.Visible = false
    if box.chams then
        box.chams.Enabled = false
    end
end

function ESP:UpdateESP()
    for _, player in ipairs(Utils.Players:GetPlayers()) do
        if player ~= Utils.LocalPlayer and not Utils:IsTeammate(player) then
            self:UpdatePlayerESP(player)
        end
    end
end

function ESP:UpdatePlayerESP(player)
    local box = self.Objects[player]
    if not box then
        self:CreateESP(player)
        box = self.Objects[player]
    end
    
    local char = player.Character
    if not char then
        self:HideESP(box)
        return
    end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        self:HideESP(box)
        return
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        self:HideESP(box)
        return
    end
    
    -- Get box bounds
    local size, position = self:GetBoxBounds(char)
    if not size then
        self:HideESP(box)
        return
    end
    
    -- Update Box
    if Config.ESP.Box then
        local color = Config.ESP.BoxColor
        box.boxLine.Visible = true
        box.boxLine.Position = position
        box.boxLine.Size = size
        box.boxLine.Color = color
        
        box.boxOutline.Visible = true
        box.boxOutline.Position = position - Vector2.new(1, 1)
        box.boxOutline.Size = size + Vector2.new(2, 2)
    else
        box.boxLine.Visible = false
        box.boxOutline.Visible = false
    end
    
    -- Update Health Bar
    if Config.ESP.HealthBar then
        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local hpColor = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        local barHeight = size.Y * healthPercent
        local barX = position.X - 5
        
        box.healthBar.Visible = true
        box.healthBar.From = Vector2.new(barX, position.Y + size.Y - barHeight)
        box.healthBar.To = Vector2.new(barX, position.Y + size.Y)
        box.healthBar.Color = hpColor
        
        box.healthOutline.Visible = true
        box.healthOutline.From = Vector2.new(barX - 1, position.Y - 1)
        box.healthOutline.To = Vector2.new(barX - 1, position.Y + size.Y + 1)
    else
        box.healthBar.Visible = false
        box.healthOutline.Visible = false
    end
    
    -- Update Name
    if Config.ESP.Name then
        box.nameLabel.Visible = true
        box.nameLabel.Text = player.Name
        box.nameLabel.Color = Config.ESP.NameColor
        box.nameLabel.Position = Vector2.new(position.X + size.X / 2, position.Y - 15)
    else
        box.nameLabel.Visible = false
    end
    
    -- Update Distance
    if Config.ESP.Distance then
        local dist = self:GetDistance(player)
        box.distanceLabel.Visible = true
        box.distanceLabel.Text = string.format("%.0f studs", dist)
        box.distanceLabel.Color = Config.ESP.NameColor
        box.distanceLabel.Position = Vector2.new(position.X + size.X / 2, position.Y + size.Y + 5)
    else
        box.distanceLabel.Visible = false
    end
    
    -- Update Skeleton
    if Config.ESP.Skeleton then
        self:DrawSkeleton(box, char)
    else
        box.skeletonVisible = false
    end
    
    -- Update Tracers
    if Config.ESP.Tracers then
        self:DrawTracer(box, root)
    else
        box.tracerLine.Visible = false
    end
    
    -- Update Chams
    if Config.ESP.Chams then
        self:UpdateChams(box, char)
    else
        if box.chams then
            box.chams.Enabled = false
        end
    end
end

function ESP:GetBoxBounds(char)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local found = false
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            local screenPos, onScreen = Utils:WorldToScreen(part.Position)
            if onScreen then
                found = true
                minX = math.min(minX, screenPos.X)
                minY = math.min(minY, screenPos.Y)
                maxX = math.max(maxX, screenPos.X)
                maxY = math.max(maxY, screenPos.Y)
            end
        end
    end
    
    if not found then
        return nil, nil
    end
    
    local size = Vector2.new(math.max(maxX - minX, 4), math.max(maxY - minY, 8))
    local position = Vector2.new(minX, minY)
    
    return size, position
end

function ESP:GetDistance(player)
    local myChar = Utils.LocalPlayer.Character
    local char = player.Character
    if not myChar or not char then return 0 end
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not myRoot or not root then return 0 end
    
    return (myRoot.Position - root.Position).Magnitude
end

function ESP:DrawSkeleton(box, char)
    local bones = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
    }
    
    local skeletonLines = box.skeletonLines or {}
    local skeletonOutlines = box.skeletonOutlines or {}
    
    -- Create lines if they don't exist
    if #skeletonLines == 0 then
        for i = 1, 14 do
            local line = Drawing.new("Line")
            line.Thickness = 1
            line.Visible = false
            skeletonLines[i] = line
            
            local outline = Drawing.new("Line")
            outline.Thickness = 3
            outline.Color = Color3.new(0, 0, 0)
            outline.Visible = false
            skeletonOutlines[i] = outline
        end
        box.skeletonLines = skeletonLines
        box.skeletonOutlines = skeletonOutlines
    end
    
    local color = Config.ESP.SkeletonColor
    local visible = false
    
    for i, bonePair in ipairs(bones) do
        local part1 = char:FindFirstChild(bonePair[1])
        local part2 = char:FindFirstChild(bonePair[2])
        
        if part1 and part2 then
            local pos1, on1 = Utils:WorldToScreen(part1.Position)
            local pos2, on2 = Utils:WorldToScreen(part2.Position)
            
            if on1 and on2 then
                visible = true
                skeletonOutlines[i].Visible = true
                skeletonOutlines[i].From = Vector2.new(pos1.X, pos1.Y)
                skeletonOutlines[i].To = Vector2.new(pos2.X, pos2.Y)
                
                skeletonLines[i].Visible = true
                skeletonLines[i].From = Vector2.new(pos1.X, pos1.Y)
                skeletonLines[i].To = Vector2.new(pos2.X, pos2.Y)
                skeletonLines[i].Color = color
            else
                skeletonLines[i].Visible = false
                skeletonOutlines[i].Visible = false
            end
        else
            skeletonLines[i].Visible = false
            skeletonOutlines[i].Visible = false
        end
    end
    
    box.skeletonVisible = visible
end

function ESP:DrawTracer(box, root)
    local pos, onScreen = Utils:WorldToScreen(root.Position)
    if not onScreen then
        box.tracerLine.Visible = false
        return
    end
    
    local cam = Utils.Workspace.CurrentCamera
    if not cam then
        box.tracerLine.Visible = false
        return
    end
    
    local screenPos = Vector2.new(pos.X, pos.Y)
    local bottomPos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
    
    box.tracerLine.Visible = true
    box.tracerLine.From = bottomPos
    box.tracerLine.To = screenPos
    box.tracerLine.Color = Config.ESP.TracerColor
    box.tracerLine.Thickness = Config.ESP.TracerThickness or 1
end

function ESP:UpdateChams(box, char)
    if not box.chams or not box.chams.Parent then
        box.chams = Instance.new("Highlight")
        box.chams.Name = "ESPChams"
        box.chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        box.chams.Parent = char
    end
    
    box.chams.Enabled = true
    box.chams.FillColor = Config.ESP.ChamsColor
    box.chams.FillTransparency = Config.ESP.ChamsTransparency
    box.chams.OutlineColor = Config.ESP.ChamsColor
    box.chams.OutlineTransparency = Config.ESP.ChamsTransparency
    box.chams.Adornee = char
end

return ESP