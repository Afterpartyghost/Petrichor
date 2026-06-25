--[[
    aimbot.lua - Aimbot Module
]]

local Aimbot = {}
local Config, Utils, UI

function Aimbot:Init(uiModule, configModule, utilsModule)
    Config = configModule
    Utils = utilsModule
    UI = uiModule
    
    self:SetupUI()
    self:StartLoop()
end

function Aimbot:SetupUI()
    local group = UI:GetCombatGroup("Aimbot")
    
    -- Enable Toggle
    local toggle = group:AddToggle("AimbotEnabled", {
        Text = "Enable Aimbot",
        Default = Config.Aimbot.Enabled,
        Callback = function(val)
            Config.Aimbot.Enabled = val
        end,
    })
    toggle:AddKeyPicker("AimbotKey", {
        Text = "Aimbot Key",
        Default = "None",
        Mode = "Toggle",
    })
    
    -- Smoothness
    group:AddSlider("AimbotSmoothness", {
        Text = "Smoothness",
        Default = Config.Aimbot.Smoothness,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Compact = true,
        Callback = function(val)
            Config.Aimbot.Smoothness = val
        end,
    })
    
    -- FOV
    group:AddSlider("AimbotFOV", {
        Text = "FOV Radius",
        Default = Config.Aimbot.FOV,
        Min = 30,
        Max = 500,
        Rounding = 0,
        Compact = true,
        Callback = function(val)
            Config.Aimbot.FOV = val
        end,
    })
    
    -- Hit Part
    group:AddDropdown("AimbotHitPart", {
        Text = "Hit Part",
        Default = Config.Aimbot.HitPart,
        Values = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"},
        Callback = function(val)
            Config.Aimbot.HitPart = val
        end,
    })
end

function Aimbot:StartLoop()
    Utils.RunService.Heartbeat:Connect(function()
        if not Config.Aimbot.Enabled then return end
        
        local target = self:GetTarget()
        if target then
            self:SmoothAim(target)
        end
    end)
end

function Aimbot:GetTarget()
    local closest, closestDist = nil, Config.Aimbot.FOV
    local mousePos = Utils.UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Utils.Players:GetPlayers()) do
        if player ~= Utils.LocalPlayer and not Utils:IsTeammate(player) then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = Utils:GetPartFromName(char, Config.Aimbot.HitPart)
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
    
    local part = Utils:GetPartFromName(char, Config.Aimbot.HitPart)
    if not part then return end
    
    local cam = Utils.Workspace.CurrentCamera
    if not cam then return end
    
    local smoothness = Config.Aimbot.Smoothness / 10
    local newCF = CFrame.lookAt(cam.CFrame.Position, part.Position)
    cam.CFrame = cam.CFrame:Lerp(newCF, smoothness)
end

return Aimbot