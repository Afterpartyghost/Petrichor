-- modules/esp.lua - Works without config
local ESP = {}
local Utils, UI
local Objects = {}
local Enabled = false
local LoopConnection = nil

-- Default settings
local Settings = {
    Enabled = false,
    Box = false,
    BoxColor = Color3.fromRGB(0, 200, 255),
    HealthBar = false,
    Name = false,
    NameColor = Color3.fromRGB(255, 255, 255),
    Distance = false,
    Chams = false,
    ChamsColor = Color3.fromRGB(0, 200, 255),
    ChamsTransparency = 0.3,
}

function ESP:Init(uiModule, configModule, utilsModule)
    UI = uiModule
    Utils = utilsModule
    
    self:SetupUI()
    self:StartLoop()
    self:SetupEvents()
end

function ESP:SetupUI()
    local group = UI:GetVisualsGroup("ESP")
    if not group then return end
    
    local toggle = group:AddToggle("ESPEnabled", {
        Text = "Enable ESP",
        Default = false,
        Callback = function(val)
            Settings.Enabled = val
            Enabled = val
            if not val then
                self:Cleanup()
            end
        end,
    })
    
    group:AddToggle("BoxESP", {
        Text = "Box ESP",
        Default = false,
        Callback = function(val)
            Settings.Box = val
        end,
    }):AddColorPicker("BoxColor", {
        Default = Settings.BoxColor,
        Title = "Box Color",
        Callback = function(val)
            Settings.BoxColor = val
        end,
    })
    
    group:AddToggle("HealthBar", {
        Text = "Health Bar",
        Default = false,
        Callback = function(val)
            Settings.HealthBar = val
        end,
    })
    
    group:AddToggle("NameESP", {
        Text = "Name ESP",
        Default = false,
        Callback = function(val)
            Settings.Name = val
        end,
    }):AddColorPicker("NameColor", {
        Default = Settings.NameColor,
        Title = "Name Color",
        Callback = function(val)
            Settings.NameColor = val
        end,
    })
    
    group:AddToggle("Chams", {
        Text = "Chams",
        Default = false,
        Callback = function(val)
            Settings.Chams = val
        end,
    }):AddColorPicker("ChamsColor", {
        Default = Settings.ChamsColor,
        Title = "Chams Color",
        Callback = function(val)
            Settings.ChamsColor = val
        end,
    })
    
    group:AddSlider("ChamsTransparency", {
        Text = "Chams Transparency",
        Default = Settings.ChamsTransparency,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Compact = true,
        Callback = function(val)
            Settings.ChamsTransparency = val
        end,
    })
end

function ESP:StartLoop()
    LoopConnection = Utils.RunService.RenderStepped:Connect(function()
        if not Settings.Enabled then 
            self:ClearAll()
            return 
        end
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
    if Objects[player] then return end
    
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
    
    -- Name
    box.nameLabel = Drawing.new("Text")
    box.nameLabel.Size = 12
    box.nameLabel.Outline = true
    box.nameLabel.Center = true
    box.nameLabel.Visible = false
    box.nameLabel.Font = 2
    
    -- Chams
    box.chams = nil
    
    Objects[player] = box
end

function ESP:RemoveESP(player)
    local box = Objects[player]
    if box then
        box.boxLine:Remove()
        box.boxOutline:Remove()
        box.healthBar:Remove()
        box.nameLabel:Remove()
        if box.chams then
            box.chams:Destroy()
        end
        Objects[player] = nil
    end
end

function ESP:ClearAll()
    for player in pairs(Objects) do
        self:RemoveESP(player)
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
    local box = Objects[player]
    if not box then
        self:CreateESP(player)
        box = Objects[player]
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
    
    local size, position = self:GetBoxBounds(char)
    if not size then
        self:HideESP(box)
        return
    end
    
    -- Update Box
    if Settings.Box then
        box.boxLine.Visible = true
        box.boxLine.Position = position
        box.boxLine.Size = size
        box.boxLine.Color = Settings.BoxColor
        
        box.boxOutline.Visible = true
        box.boxOutline.Position = position - Vector2.new(1, 1)
        box.boxOutline.Size = size + Vector2.new(2, 2)
    else
        box.boxLine.Visible = false
        box.boxOutline.Visible = false
    end
    
    -- Update Health Bar
    if Settings.HealthBar then
        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local hpColor = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        local barHeight = size.Y * healthPercent
        local barX = position.X - 5
        
        box.healthBar.Visible = true
        box.healthBar.From = Vector2.new(barX, position.Y + size.Y - barHeight)
        box.healthBar.To = Vector2.new(barX, position.Y + size.Y)
        box.healthBar.Color = hpColor
    else
        box.healthBar.Visible = false
    end
    
    -- Update Name
    if Settings.Name then
        box.nameLabel.Visible = true
        box.nameLabel.Text = player.Name
        box.nameLabel.Color = Settings.NameColor
        box.nameLabel.Position = Vector2.new(position.X + size.X / 2, position.Y - 15)
    else
        box.nameLabel.Visible = false
    end
    
    -- Update Chams
    if Settings.Chams then
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

function ESP:UpdateChams(box, char)
    if not box.chams or not box.chams.Parent then
        box.chams = Instance.new("Highlight")
        box.chams.Name = "ESPChams"
        box.chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        box.chams.Parent = char
    end
    
    box.chams.Enabled = true
    box.chams.FillColor = Settings.ChamsColor
    box.chams.FillTransparency = Settings.ChamsTransparency
    box.chams.OutlineColor = Settings.ChamsColor
    box.chams.OutlineTransparency = Settings.ChamsTransparency
    box.chams.Adornee = char
end

function ESP:HideESP(box)
    if not box then return end
    box.boxLine.Visible = false
    box.boxOutline.Visible = false
    box.healthBar.Visible = false
    box.nameLabel.Visible = false
    if box.chams then
        box.chams.Enabled = false
    end
end

function ESP:Cleanup()
    Enabled = false
    if LoopConnection then
        LoopConnection:Disconnect()
        LoopConnection = nil
    end
    self:ClearAll()
end

return ESP
