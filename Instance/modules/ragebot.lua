--[[
    ragebot.lua - Ragebot Module
]]

local Ragebot = {}
local Config, Utils, UI

function Ragebot:Init(uiModule, configModule, utilsModule)
    Config = configModule
    Utils = utilsModule
    UI = uiModule
    
    self.Target = nil
    self.LastShot = 0
    
    self:SetupUI()
    self:StartRagebot()
end

function Ragebot:SetupUI()
    local group = UI:GetCombatRightGroup("Ragebot")
    
    group:AddToggle("RagebotEnabled", {
        Text = "Enable Ragebot",
        Default = Config.Ragebot.Enabled,
        Callback = function(val)
            Config.Ragebot.Enabled = val
            if not val then
                self.Target = nil
            end
        end,
    }):AddKeyPicker("RagebotKey", {
        Text = "Ragebot Key",
        Default = "None",
        Mode = "Toggle",
        SyncToggleState = false,
    })
    
    group:AddToggle("AutoTarget", {
        Text = "Auto Target",
        Default = Config.Ragebot.AutoTarget,
        Callback = function(val)
            Config.Ragebot.AutoTarget = val
        end,
    })
    
    group:AddToggle("AutoShoot", {
        Text = "Auto Shoot",
        Default = Config.Ragebot.AutoShoot,
        Callback = function(val)
            Config.Ragebot.AutoShoot = val
        end,
    })
    
    group:AddDropdown("RagebotHitPart", {
        Text = "Hit Part",
        Default = Config.Ragebot.HitPart,
        Values = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "Closest"},
        Callback = function(val)
            Config.Ragebot.HitPart = val
        end,
    })
    
    group:AddToggle("Prediction", {
        Text = "Prediction",
        Default = Config.Ragebot.Prediction,
        Callback = function(val)
            Config.Ragebot.Prediction = val
        end,
    })
    
    group:AddSlider("PredictionMultiplier", {
        Text = "Prediction Multiplier",
        Default = Config.Ragebot.PredictionMultiplier,
        Min = 0.1,
        Max = 3,
        Rounding = 1,
        Compact = true,
        Callback = function(val)
            Config.Ragebot.PredictionMultiplier = val
        end,
    })
    
    group:AddToggle("VoidSpam", {
        Text = "Void Spam",
        Default = Config.Ragebot.VoidSpam,
        Callback = function(val)
            Config.Ragebot.VoidSpam = val
        end,
    })
end

function Ragebot:StartRagebot()
    Utils.RunService.Heartbeat:Connect(function()
        if not Config.Ragebot.Enabled then return end
        
        -- Auto Target
        if Config.Ragebot.AutoTarget then
            self:FindTarget()
        end
        
        -- Auto Shoot
        if Config.Ragebot.AutoShoot and self.Target then
            self:Shoot()
        end
    end)
end

function Ragebot:FindTarget()
    local closest, closestDist = nil, math.huge
    local mousePos = Utils.UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Utils.Players:GetPlayers()) do
        if player ~= Utils.LocalPlayer and not Utils:IsTeammate(player) then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local screenPos, onScreen = Utils:WorldToScreen(root.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < closestDist then
                                closest = player
                                closestDist = dist
                            end
                        end
                    end
                end
            end
        end
    end
    
    if closest then
        self.Target = closest
    end
end

function Ragebot:Shoot()
    if not self.Target then return end
    
    local char = self.Target.Character
    if not char then
        self.Target = nil
        return
    end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        self.Target = nil
        return
    end
    
    -- Get hit part
    local part = self:GetHitPart(char)
    if not part then return end
    
    -- Get weapon
    local weapon = Utils:GetWeapon()
    if not weapon then return end
    
    -- Get muzzle position
    local muzzlePos = Utils:GetMuzzlePosition()
    if not muzzlePos then
        muzzlePos = Utils.LocalPlayer.Character and 
                    Utils.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if muzzlePos then
            muzzlePos = muzzlePos.Position
        else
            return
        end
    end
    
    -- Predict target position
    local targetPos = part.Position
    if Config.Ragebot.Prediction then
        targetPos = self:PredictPosition(part, muzzlePos)
    end
    
    -- Fire
    local now = tick()
    if now - self.LastShot < 0.1 then return end
    self.LastShot = now
    
    -- Create shot data
    local data = {
        [utf8.char(1)] = {
            [utf8.char(0)] = CFrame.new(muzzlePos, targetPos),
            [utf8.char(1)] = CFrame.new(muzzlePos, targetPos),
            [utf8.char(2)] = part,
            [utf8.char(3)] = CFrame.new(0.43, 0.25, 0.42),
        },
    }
    
    -- Fire
    pcall(function()
        local remote = Utils.ReplicatedStorage.Remotes.Replication.Fighter.UseItem
        local objID = self:GetWeaponID()
        if objID then
            remote:FireServer(objID, "StartShooting", data, nil)
        end
    end)
end

function Ragebot:GetHitPart(char)
    local partName = Config.Ragebot.HitPart
    
    if partName == "Closest" then
        local closest, closestDist = nil, math.huge
        local myPos = Utils.LocalPlayer.Character and 
                     Utils.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myPos then
            myPos = myPos.Position
        else
            return char:FindFirstChild("Head")
        end
        
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                local dist = (part.Position - myPos).Magnitude
                if dist < closestDist then
                    closest = part
                    closestDist = dist
                end
            end
        end
        return closest or char:FindFirstChild("Head")
    end
    
    return Utils:GetPartFromName(char, partName)
end

function Ragebot:PredictPosition(part, origin)
    local basePos = part.Position
    local velocity = part.AssemblyLinearVelocity or Vector3.new()
    local distance = (basePos - origin).Magnitude
    local ping = 0
    
    pcall(function()
        ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    
    local travelTime = distance / 3000
    local totalTime = (travelTime + ping) * Config.Ragebot.PredictionMultiplier
    
    return basePos + (velocity * totalTime)
end

function Ragebot:GetWeaponID()
    local success, controller = pcall(function()
        return require(Utils.LocalPlayer.PlayerScripts.Controllers.FighterController)
    end)
    
    if success and controller and controller.LocalFighter and controller.LocalFighter.EquippedItem then
        return controller.LocalFighter.EquippedItem:Get("ObjectID")
    end
    return nil
end

return Ragebot