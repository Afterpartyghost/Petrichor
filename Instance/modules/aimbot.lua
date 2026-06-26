-- modules/aimbot.lua - Works without config
local Aimbot = {}
local Utils, UI
local Enabled = false
local LoopConnection = nil

-- Default settings
local Settings = {
    Enabled = false,
    Smoothness = 2,
    FOV = 150,
    HitPart = "Head",
}

function Aimbot:Init(uiModule, configModule, utilsModule)
    UI = uiModule
    Utils = utilsModule
    
    self:SetupUI()
    self:StartLoop()
end

function Aimbot:SetupUI()
    local group = UI:GetCombatGroup("Aimbot")
    if not group then return end
    
    local toggle = group:AddToggle("AimbotEnabled", {
        Text = "Enable Aimbot",
        Default = false,
        Callback = function(val)
            Settings.Enabled = val
            Enabled = val
            if not val then
                self:Cleanup()
            end
        end,
    })
    toggle:AddKeyPicker("AimbotKey", {
        Text = "Aimbot Key",
        Default = "None",
        Mode = "Toggle",
    })
    
    group:AddSlider("AimbotSmoothness", {
        Text = "Smoothness",
        Default = Settings.Smoothness,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Compact = true,
        Callback = function(val)
            Settings.Smoothness = val
        end,
    })
    
    group:AddSlider("AimbotFOV", {
        Text = "FOV Radius",
        Default = Settings.FOV,
        Min = 30,
        Max = 500,
        Rounding = 0,
        Compact = true,
        Callback = function(val)
            Settings.FOV = val
        end,
    })
    
    group:AddDropdown("AimbotHitPart", {
        Text = "Hit Part",
        Default = Settings.HitPart,
        Values = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"},
        Callback = function(val)
            Settings.HitPart = val
        end,
    })
end

function Aimbot:StartLoop()
    LoopConnection = Utils.RunService.Heartbeat:Connect(function()
        if not Settings.Enabled then return end
        
        local target = self:GetTarget()
        if target then
            self:SmoothAim(target)
        end
    end)
end

function Aimbot:GetTarget()
    local closest, closestDist = nil, Settings.FOV
    local mousePos = Utils.UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Utils.Players:GetPlayers()) do
        if player ~= Utils.LocalPlayer and not Utils:IsTeammate(player) then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = Utils:GetPartFromName(char, Settings.HitPart)
                    if part then
                        local screenPos, onScreen = Utils:WorldToScreen(part.Position)
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
    return closest
end

function Aimbot:SmoothAim(target)
    local char = target.Character
    if not char then return end
    
    local part = Utils:GetPartFromName(char, Settings.HitPart)
    if not part then return end
    
    local cam = Utils.Workspace.CurrentCamera
    if not cam then return end
    
    local smoothness = Settings.Smoothness / 10
    local newCF = CFrame.lookAt(cam.CFrame.Position, part.Position)
    cam.CFrame = cam.CFrame:Lerp(newCF, smoothness)
end

function Aimbot:Cleanup()
    Enabled = false
    if LoopConnection then
        LoopConnection:Disconnect()
        LoopConnection = nil
    end
end

return Aimbot
