--[[
    antiaim.lua - Anti-Aim Module
]]

local AntiAim = {}
local Config, Utils, UI

function AntiAim:Init(uiModule, configModule, utilsModule)
    Config = configModule
    Utils = utilsModule
    UI = uiModule
    
    self:SetupUI()
    self:StartAntiAim()
end

function AntiAim:SetupUI()
    local group = UI:GetCharacterRightGroup("Anti-Aim")
    
    group:AddToggle("AntiAimEnabled", {
        Text = "Enable Anti-Aim",
        Default = Config.AntiAim.Enabled,
        Callback = function(val)
            Config.AntiAim.Enabled = val
        end,
    })
    
    group:AddDropdown("AntiAimYaw", {
        Text = "Yaw",
        Default = Config.AntiAim.Yaw,
        Values = {"none", "jitter", "spinbot", "random"},
        Callback = function(val)
            Config.AntiAim.Yaw = val
        end,
    })
    
    group:AddDropdown("AntiAimPitch", {
        Text = "Pitch",
        Default = Config.AntiAim.Pitch,
        Values = {"none", "jitter", "spinbot", "random"},
        Callback = function(val)
            Config.AntiAim.Pitch = val
        end,
    })
    
    group:AddDropdown("AntiAimAngle", {
        Text = "Angle",
        Default = Config.AntiAim.Angle,
        Values = {"none", "tilt 45", "tilt 90", "upside down"},
        Callback = function(val)
            Config.AntiAim.Angle = val
        end,
    })
    
    group:AddSlider("AntiAimSpeed", {
        Text = "Speed",
        Default = Config.AntiAim.Speed,
        Min = 1,
        Max = 50,
        Rounding = 0,
        Compact = true,
        Callback = function(val)
            Config.AntiAim.Speed = val
        end,
    })
    
    group:AddToggle("AntiAimJitter", {
        Text = "Jitter Mode",
        Default = Config.AntiAim.Jitter,
        Callback = function(val)
            Config.AntiAim.Jitter = val
        end,
    })
    
    group:AddToggle("AntiAimRandom", {
        Text = "Random Angle",
        Default = Config.AntiAim.RandomAngle,
        Callback = function(val)
            Config.AntiAim.RandomAngle = val
        end,
    })
    
    group:AddToggle("AntiAimUnderground", {
        Text = "Underground",
        Default = Config.AntiAim.Underground,
        Callback = function(val)
            Config.AntiAim.Underground = val
            self:UpdateUnderground(val)
        end,
    })
end

function AntiAim:StartAntiAim()
    Utils.RunService.Heartbeat:Connect(function()
        if not Config.AntiAim.Enabled then return end
        
        local char = Utils.LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local yaw = self:CalculateYaw()
        local pitch = self:CalculatePitch()
        local angle = self:CalculateAngle()
        
        if yaw ~= 0 or pitch ~= 0 or angle ~= 0 then
            local rotation = CFrame.Angles(pitch, yaw, angle)
            root.CFrame = root.CFrame * rotation
        end
    end)
end

function AntiAim:CalculateYaw()
    local yawType = Config.AntiAim.Yaw
    local speed = Config.AntiAim.Speed
    local time = tick()
    
    if yawType == "none" then
        return 0
    elseif yawType == "jitter" then
        local angle = Config.AntiAim.Jitter and 90 or 45
        return math.sin(time * speed) * math.rad(angle)
    elseif yawType == "spinbot" then
        return (time * speed) % (2 * math.pi)
    elseif yawType == "random" then
        if Config.AntiAim.RandomAngle then
            return math.rad(math.random(-180, 180))
        end
        return math.rad(45)
    end
    return 0
end

function AntiAim:CalculatePitch()
    local pitchType = Config.AntiAim.Pitch
    local speed = Config.AntiAim.Speed
    local time = tick()
    
    if pitchType == "none" then
        return 0
    elseif pitchType == "jitter" then
        return math.sin(time * speed * 2) * math.rad(30)
    elseif pitchType == "spinbot" then
        return math.sin(time * speed) * math.rad(90)
    elseif pitchType == "random" then
        if Config.AntiAim.RandomAngle then
            return math.rad(math.random(-89, 89))
        end
        return math.rad(45)
    end
    return 0
end

function AntiAim:CalculateAngle()
    local angleType = Config.AntiAim.Angle
    
    if angleType == "none" then
        return 0
    elseif angleType == "tilt 45" then
        return math.rad(45)
    elseif angleType == "tilt 90" then
        return math.rad(90)
    elseif angleType == "upside down" then
        return math.rad(180)
    end
    return 0
end

function AntiAim:UpdateUnderground(enabled)
    if enabled then
        self:StartUnderground()
    else
        self:StopUnderground()
    end
end

function AntiAim:StartUnderground()
    self.UndergroundConnection = Utils.RunService.Heartbeat:Connect(function()
        if not Config.AntiAim.Underground then return end
        
        local char = Utils.LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Teleport underground
        local pos = root.Position
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local ray = Utils.Workspace:Raycast(pos, Vector3.new(0, -500, 0), rayParams)
        if ray then
            local undergroundPos = Vector3.new(pos.X, ray.Position.Y - 2, pos.Z)
            root.CFrame = CFrame.new(undergroundPos)
        end
    end)
end

function AntiAim:StopUnderground()
    if self.UndergroundConnection then
        self.UndergroundConnection:Disconnect()
        self.UndergroundConnection = nil
    end
end

return AntiAim