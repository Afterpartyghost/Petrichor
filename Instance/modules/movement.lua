--[[
    movement.lua - Movement Module (Walkspeed, Fly, Noclip)
]]

local Movement = {}
local Config, Utils, UI
local FlyObjects = {}

function Movement:Init(uiModule, configModule, utilsModule)
    Config = configModule
    Utils = utilsModule
    UI = uiModule
    
    self:SetupUI()
    self:StartWalkspeed()
    self:StartFly()
    self:StartNoclip()
end

function Movement:SetupUI()
    local group = UI:GetCharacterGroup("Movement")
    
    -- Walkspeed
    local wsToggle = group:AddToggle("Walkspeed", {
        Text = "Walkspeed",
        Default = Config.Movement.Walkspeed,
        Callback = function(val)
            Config.Movement.Walkspeed = val
        end,
    })
    wsToggle:AddKeyPicker("WalkspeedKey", {
        Text = "Walkspeed Key",
        Default = "None",
        Mode = "Toggle",
        SyncToggleState = false,
    })
    
    group:AddSlider("WalkspeedValue", {
        Text = "Speed",
        Default = Config.Movement.WalkspeedValue,
        Min = 16,
        Max = 250,
        Rounding = 0,
        Compact = true,
        Callback = function(val)
            Config.Movement.WalkspeedValue = val
        end,
    })
    
    -- Fly
    local flyToggle = group:AddToggle("Fly", {
        Text = "Fly",
        Default = Config.Movement.Fly,
        Callback = function(val)
            Config.Movement.Fly = val
            if not val then
                self:StopFly()
            end
        end,
    })
    flyToggle:AddKeyPicker("FlyKey", {
        Text = "Fly Key",
        Default = "None",
        Mode = "Toggle",
        SyncToggleState = false,
    })
    
    group:AddSlider("FlySpeed", {
        Text = "Fly Speed",
        Default = Config.Movement.FlySpeed,
        Min = 16,
        Max = 250,
        Rounding = 0,
        Compact = true,
        Callback = function(val)
            Config.Movement.FlySpeed = val
        end,
    })
    
    -- Noclip
    group:AddToggle("Noclip", {
        Text = "Noclip",
        Default = Config.Movement.Noclip,
        Callback = function(val)
            Config.Movement.Noclip = val
            self:UpdateNoclip(val)
        end,
    })
end

function Movement:StartWalkspeed()
    Utils.RunService.Heartbeat:Connect(function()
        if not Config.Movement.Walkspeed then return end
        
        local key = UI.Library.Options.WalkspeedKey
        if key and key.Mode == "Toggle" and not key:GetState() then return end
        
        local char = Utils.LocalPlayer.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local velocity = moveDir * Config.Movement.WalkspeedValue
                root.AssemblyLinearVelocity = Vector3.new(velocity.X, root.AssemblyLinearVelocity.Y, velocity.Z)
            end
        end
    end)
end

function Movement:StartFly()
    Utils.RunService.Heartbeat:Connect(function()
        if not Config.Movement.Fly then return end
        
        local key = UI.Library.Options.FlyKey
        if key and key.Mode == "Toggle" and not key:GetState() then return end
        
        local char = Utils.LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true        end
        
        -- Create body objects if they don't exist
        if not FlyObjects.bodyPosition then
            FlyObjects.bodyPosition = Instance.new("BodyPosition")
            FlyObjects.bodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            FlyObjects.bodyPosition.D = 1000
            FlyObjects.bodyPosition.P = 10000
            FlyObjects.bodyPosition.Parent = root
        end
        
        if not FlyObjects.bodyGyro then
            FlyObjects.bodyGyro = Instance.new("BodyGyro")
            FlyObjects.bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            FlyObjects.bodyGyro.D = 400
            FlyObjects.bodyGyro.P = 10000
            FlyObjects.bodyGyro.Parent = root
        end
        
        local cam = Utils.Workspace.CurrentCamera
        if not cam then return end
        
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local move = Vector3.new()
        
        if Utils.UserInputService:IsKeyDown(Enum.KeyCode.W) then
            move = move + look
        end
        if Utils.UserInputService:IsKeyDown(Enum.KeyCode.S) then
            move = move - look
        end
        if Utils.UserInputService:IsKeyDown(Enum.KeyCode.A) then
            move = move - right
        end
        if Utils.UserInputService:IsKeyDown(Enum.KeyCode.D) then
            move = move + right
        end
        if Utils.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            move = move + Vector3.new(0, 1, 0)
        end
        if Utils.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            move = move - Vector3.new(0, 1, 0)
        end
        
        if move.Magnitude > 0 then
            move = move.Unit
        end
        
        local speed = Config.Movement.FlySpeed
        FlyObjects.bodyPosition.Position = root.Position + (move * speed * 0.1)
        FlyObjects.bodyGyro.CFrame = CFrame.new(root.Position, root.Position + look)
        
        -- Clean up if fly is disabled
        if not Config.Movement.Fly then
            self:StopFly()
        end
    end)
end

function Movement:StopFly()
    if FlyObjects.bodyPosition then
        FlyObjects.bodyPosition:Destroy()
        FlyObjects.bodyPosition = nil
    end
    if FlyObjects.bodyGyro then
        FlyObjects.bodyGyro:Destroy()
        FlyObjects.bodyGyro = nil
    end
    
    local char = Utils.LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
end

function Movement:UpdateNoclip(enabled)
    local char = Utils.LocalPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enabled
        end
    end
end

return Movement