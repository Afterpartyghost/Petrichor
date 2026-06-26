-- modules/aimbot.lua - Working Aimbot from InstanceSource
local Aimbot = {}
local Config, Utils, UI

local aimbot = {
    enabled = false,
    masterEnabled = false,
    keyMode = "toggle",
    showFov = false,
    targetPart = "Head",
    fovRadius = 500,
    smoothness = 2,
    aimCurve = "Linear",
    followMuzzle = false,
    lockedTarget = nil,
    smoothCF = nil,
}
local camController = nil
local aimbotConnection = nil
local aimbotUsingBind = false
local AIMBOT_RENDER_BIND = "InstanceAimbotUpdate"
local Camera = nil

-- Drawing objects for FOV
local fovScreenGui = nil
local fovObjects = {}

function Aimbot:Init(uiModule, configModule, utilsModule)
    Config = configModule
    Utils = utilsModule
    UI = uiModule
    
    -- Setup Camera
    Camera = Utils.Workspace.CurrentCamera
    
    -- Get Camera Controller
    self:GetCameraController()
    
    -- Setup UI
    self:SetupUI()
    
    -- Setup FOV GUI
    self:SetupFOV()
    
    -- Start loops
    self:StartAimbotLoop()
    self:SetupKeyHandler()
    
    print("✅ Aimbot initialized")
end

function Aimbot:GetCameraController()
    local success, ctrl = pcall(function()
        local playerScripts = Utils.LocalPlayer:FindFirstChild("PlayerScripts")
        if not playerScripts then return nil end
        local controllers = playerScripts:FindFirstChild("Controllers")
        if not controllers then return nil end
        local cm = controllers:FindFirstChild("CameraController")
        if cm and cm:IsA("ModuleScript") then
            return require(cm)
        end
        return nil
    end)
    if success and ctrl then
        camController = ctrl
        print("✅ CameraController loaded")
    else
        print("⚠️ CameraController not found")
    end
end

function Aimbot:SetupUI()
    local group = UI:GetCombatGroup("Aimbot")
    if not group then return end
    
    local toggle = group:AddToggle("AimbotEnabled", {
        Text = "Enable Aimbot",
        Default = false,
        Callback = function(val)
            aimbot.masterEnabled = val
            if not val then
                aimbot.enabled = false
                self:ClearLock()
                self:UpdateAimbot()
            end
        end
    })
    toggle:AddKeyPicker("AimbotKey", {
        Text = "Aimbot",
        Default = "None",
        Mode = "Toggle",
        NoUI = true,
        SyncToggleState = false,
        Modes = { "Toggle", "Hold" },
        Callback = function(state)
            local picker = UI.Library.Options and UI.Library.Options.AimbotKey
            if not picker or picker.Mode ~= "Toggle" or not aimbot.masterEnabled then return end
            aimbot.enabled = state
            if not state then
                self:ClearLock()
            end
            self:UpdateAimbot()
        end
    })
    
    -- Key mode handler
    Utils.RunService.RenderStepped:Connect(function()
        local picker = UI.Library.Options and UI.Library.Options.AimbotKey
        if not picker then return end
        
        local mode = picker.Mode and string.lower(picker.Mode) or "toggle"
        if mode ~= aimbot.keyMode then
            aimbot.keyMode = mode
            aimbot.enabled = false
            self:ClearLock()
            self:UpdateAimbot()
        end
        
        if mode ~= "hold" or not aimbot.masterEnabled then return end
        local held = picker:GetState()
        if held == aimbot.enabled then return end
        aimbot.enabled = held
        if not held then
            self:ClearLock()
        end
        self:UpdateAimbot()
    end)
    
    group:AddSlider("AimbotSmoothness", {
        Text = "smoothness",
        Default = 2,
        Min = 0.1,
        Max = 10,
        Rounding = 2,
        Compact = true,
        Callback = function(val)
            aimbot.smoothness = math.clamp(val, 0.1, 10)
        end
    })
    
    group:AddDropdown("AimbotCurve", {
        Text = "aim curve",
        Default = "Linear",
        Values = { "Linear", "Expo", "EaseIn", "EaseOut", "EaseInOut", "Cubic", "Instant" },
        Callback = function(val)
            aimbot.aimCurve = val
        end
    })
    
    group:AddDropdown("AimbotHitPart", {
        Text = "hit part",
        Default = "Head",
        Values = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"},
        Callback = function(val)
            aimbot.targetPart = val
        end
    })
end

function Aimbot:SetupFOV()
    fovScreenGui = Instance.new("ScreenGui")
    fovScreenGui.Name = "AimbotFOV"
    fovScreenGui.DisplayOrder = 10
    fovScreenGui.ResetOnSpawn = false
    fovScreenGui.IgnoreGuiInset = true
    fovScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    fovScreenGui.Parent = game.CoreGui
    
    -- FOV Circle
    fovObjects.container = Instance.new("Frame")
    fovObjects.container.Name = "FOVContainer"
    fovObjects.container.BackgroundTransparency = 1
    fovObjects.container.BorderSizePixel = 0
    fovObjects.container.Visible = false
    fovObjects.container.Parent = fovScreenGui
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BackgroundTransparency = 0.5
    fill.BorderSizePixel = 0
    fill.Visible = false
    fill.ZIndex = 1
    fill.Parent = fovObjects.container
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local outline = Instance.new("Frame")
    outline.Size = UDim2.new(1, 0, 1, 0)
    outline.BackgroundTransparency = 1
    outline.BorderSizePixel = 0
    outline.ZIndex = 2
    outline.Parent = fovObjects.container
    
    local outlineCorner = Instance.new("UICorner")
    outlineCorner.CornerRadius = UDim.new(1, 0)
    outlineCorner.Parent = outline
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = outline
    
    fovObjects.fill = fill
    fovObjects.outline = outline
    fovObjects.stroke = stroke
    
    -- Add FOV toggle to customization tab
    local customGroup = UI:GetCombatRightGroup("Aimbot Customization")
    if customGroup then
        customGroup:AddToggle("ShowAimbotFOV", {
            Text = "show fov",
            Default = false,
            Callback = function(val)
                aimbot.showFov = val
                fovObjects.container.Visible = val
            end
        })
        
        customGroup:AddSlider("AimbotFOVRadius", {
            Text = "fov radius",
            Default = 500,
            Min = 10,
            Max = 1000,
            Rounding = 0,
            Compact = true,
            Callback = function(val)
                aimbot.fovRadius = val
            end
        })
        
        customGroup:AddToggle("AimbotFOVFollowMuzzle", {
            Text = "follow muzzle",
            Default = false,
            Callback = function(val)
                aimbot.followMuzzle = val
            end
        })
    end
end

function Aimbot:ClearLock()
    aimbot.lockedTarget = nil
    aimbot.smoothCF = nil
end

function Aimbot:GetAimbotScreenPoint()
    if aimbot.followMuzzle then
        local muzzlePos = Utils:GetMuzzlePosition()
        if muzzlePos then
            local screenPos, onScreen = Utils:WorldToScreen(muzzlePos)
            if onScreen then
                return Vector2.new(screenPos.X, screenPos.Y)
            end
        end
    end
    local loc = Utils.UserInputService:GetMouseLocation()
    return Vector2.new(loc.X, loc.Y)
end

function Aimbot:ClosestToCursor()
    local best, bestDist = nil, aimbot.fovRadius
    local mp = self:GetAimbotScreenPoint()
    if not mp then return nil end
    
    local cam = Utils.Workspace.CurrentCamera or Camera
    for _, p in ipairs(Utils.Players:GetPlayers()) do
        if p ~= Utils.LocalPlayer and p.Character then
            local part = p.Character:FindFirstChild(aimbot.targetPart)
            if part and part:IsDescendantOf(Utils.Workspace) then
                local scr, on = Utils:WorldToScreen(part.Position, cam)
                if on then
                    local dx = scr.X - mp.X
                    local dy = scr.Y - mp.Y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < bestDist then
                        bestDist = dist
                        best = part
                    end
                end
            end
        end
    end
    return best
end

function Aimbot:GetLerpAlpha(dt)
    local smoothness = math.clamp(tonumber(aimbot.smoothness) or 2, 0.1, 10)
    local curve = aimbot.aimCurve or "Linear"
    local speed = 6 / smoothness
    
    if curve == "Instant" then
        return 1
    elseif curve == "Expo" then
        return 1 - math.exp(-(4 / smoothness) * dt)
    elseif curve == "EaseIn" then
        local t = math.clamp(speed * dt, 0, 1)
        return t * t
    elseif curve == "EaseOut" then
        local t = math.clamp(speed * dt, 0, 1)
        return 1 - (1 - t) * (1 - t)
    elseif curve == "EaseInOut" then
        local t = math.clamp(speed * dt, 0, 1)
        if t < 0.5 then
            return 2 * t * t
        end
        return 1 - ((-2 * t + 2) ^ 2) / 2
    elseif curve == "Cubic" then
        local t = math.clamp(speed * dt, 0, 1)
        return t * t * t
    end
    
    return math.clamp(speed * dt, 0, 1)
end

function Aimbot:GetUnstretchedCameraCFrame(cam)
    cam = cam or Utils.Workspace.CurrentCamera
    if not cam then return nil end
    local cf = cam.CFrame
    local pos = cf.Position
    local look = cf.LookVector
    local right = cf.RightVector
    local up = right:Cross(look).Unit
    return CFrame.fromMatrix(pos, right, up, -look)
end

function Aimbot:StepAimbot(dt)
    dt = dt or (1 / 240)
    if not aimbot.enabled then
        self:ClearLock()
        return
    end
    
    local cam = Utils.Workspace.CurrentCamera
    if not cam then return end
    Camera = cam
    
    if not aimbot.lockedTarget then
        aimbot.lockedTarget = self:ClosestToCursor()
        aimbot.smoothCF = self:GetUnstretchedCameraCFrame(cam)
        if not aimbot.lockedTarget then return end
    end
    
    if not aimbot.lockedTarget.Parent or not aimbot.lockedTarget:IsDescendantOf(Utils.Workspace) then
        self:ClearLock()
        return
    end
    
    local myChar = Utils.LocalPlayer.Character
    if not myChar then return end
    local myHead = myChar:FindFirstChild("Head")
    if not myHead then
        self:ClearLock()
        return
    end
    
    if not aimbot.smoothCF then
        aimbot.smoothCF = self:GetUnstretchedCameraCFrame(cam)
    end
    
    local lookCF = CFrame.lookAt(cam.CFrame.Position, aimbot.lockedTarget.Position)
    local alpha = self:GetLerpAlpha(dt)
    aimbot.smoothCF = aimbot.smoothCF:Lerp(lookCF, alpha)
    
    -- Use MimicRotation if available
    if camController and camController.MimicRotation then
        pcall(function()
            camController:MimicRotation(aimbot.smoothCF)
        end)
    end
end

function Aimbot:UpdateAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    if aimbotUsingBind then
        pcall(function()
            Utils.RunService:UnbindFromRenderStep(AIMBOT_RENDER_BIND)
        end)
        aimbotUsingBind = false
    end
    
    -- Update FOV visibility
    if fovObjects.container then
        fovObjects.container.Visible = aimbot.showFov
    end
    
    if not aimbot.enabled then
        self:ClearLock()
        return
    end
    
    -- Try bind to render step first
    local ok = pcall(function()
        Utils.RunService:UnbindFromRenderStep(AIMBOT_RENDER_BIND)
        Utils.RunService:BindToRenderStep(AIMBOT_RENDER_BIND, Enum.RenderPriority.Camera.Value + 1, function(dt)
            self:StepAimbot(dt)
        end)
    end)
    if ok then
        aimbotUsingBind = true
    else
        aimbotConnection = Utils.RunService.RenderStepped:Connect(function(dt)
            self:StepAimbot(dt)
        end)
    end
end

function Aimbot:StartAimbotLoop()
    -- Update FOV position every frame
    Utils.RunService.RenderStepped:Connect(function()
        if not aimbot.showFov or not fovObjects.container then return end
        local cam = Utils.Workspace.CurrentCamera
        if not cam then return end
        
        local center = self:GetAimbotScreenPoint()
        local r = aimbot.fovRadius or 500
        
        fovObjects.container.Size = UDim2.fromOffset(r * 2, r * 2)
        fovObjects.container.Position = UDim2.fromOffset(center.X - r, center.Y - r)
    end)
end

function Aimbot:SetupKeyHandler()
    -- Handle Hold mode
    Utils.RunService.RenderStepped:Connect(function()
        local picker = UI.Library.Options and UI.Library.Options.AimbotKey
        if not picker then return end
        
        local mode = picker.Mode and string.lower(picker.Mode) or "toggle"
        if mode ~= aimbot.keyMode then
            aimbot.keyMode = mode
            aimbot.enabled = false
            self:ClearLock()
            self:UpdateAimbot()
        end
        
        if mode ~= "hold" or not aimbot.masterEnabled then return end
        local held = picker:GetState()
        if held == aimbot.enabled then return end
        aimbot.enabled = held
        if not held then
            self:ClearLock()
        end
        self:UpdateAimbot()
    end)
end

function Aimbot:Cleanup()
    self:ClearLock()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    pcall(function()
        Utils.RunService:UnbindFromRenderStep(AIMBOT_RENDER_BIND)
    end)
    aimbotUsingBind = false
    aimbot.enabled = false
    aimbot.masterEnabled = false
    
    if fovScreenGui then
        pcall(function() fovScreenGui:Destroy() end)
        fovScreenGui = nil
    end
    fovObjects = {}
end

return Aimbot
