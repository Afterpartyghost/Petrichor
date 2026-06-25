--[[
    misc.lua - Miscellaneous Module
]]

local Misc = {}
local Config, Utils, UI

function Misc:Init(uiModule, configModule, utilsModule)
    Config = configModule
    Utils = utilsModule
    UI = uiModule
    
    self:SetupUI()
    self:StartMisc()
end

function Misc:SetupUI()
    local group = UI:GetMiscGroup("Miscellaneous")
    
    -- Mod Detector
    group:AddToggle("ModDetector", {
        Text = "Mod Detector",
        Default = Config.Misc.ModDetector.Enabled,
        Callback = function(val)
            Config.Misc.ModDetector.Enabled = val
            self:UpdateModDetector(val)
        end,
    })
    
    -- Anti Flashbang
    group:AddToggle("AntiFlashbang", {
        Text = "Anti Flashbang",
        Default = Config.Misc.AntiFlashbang,
        Callback = function(val)
            Config.Misc.AntiFlashbang = val
            self:UpdateAntiFlashbang(val)
        end,
    })
    
    -- Anti Trip
    group:AddToggle("AntiTrip", {
        Text = "Anti Subspace Tripmine",
        Default = Config.Misc.AntiTrip,
        Callback = function(val)
            Config.Misc.AntiTrip = val
            self:UpdateAntiTrip(val)
        end,
    })
    
    -- Device Spoof
    local deviceGroup = UI:GetMiscRightGroup("Device Spoof")
    
    deviceGroup:AddToggle("DeviceSpoof", {
        Text = "Enable Device Spoof",
        Default = Config.Misc.DeviceSpoof.Enabled,
        Callback = function(val)
            Config.Misc.DeviceSpoof.Enabled = val
            if val then
                self:SpoofDevice()
            end
        end,
    })
    
    deviceGroup:AddDropdown("DeviceType", {
        Text = "Device",
        Default = Config.Misc.DeviceSpoof.Device,
        Values = {"Console", "Mobile", "VR", "PC"},
        Callback = function(val)
            Config.Misc.DeviceSpoof.Device = val
            if Config.Misc.DeviceSpoof.Enabled then
                self:SpoofDevice()
            end
        end,
    })
    
    -- Slide Boost
    local slideGroup = UI:GetMiscRightGroup("Slide Boost")
    
    slideGroup:AddToggle("SlideBoost", {
        Text = "Enable Slide Boost",
        Default = Config.Misc.SlideBoost.Enabled,
        Callback = function(val)
            Config.Misc.SlideBoost.Enabled = val
        end,
    })
    
    slideGroup:AddSlider("SlideBoostSpeed", {
        Text = "Boost Speed",
        Default = Config.Misc.SlideBoost.Speed,
        Min = 50,
        Max = 1000,
        Rounding = 0,
        Compact = true,
        Callback = function(val)
            Config.Misc.SlideBoost.Speed = val
        end,
    })
end

function Misc:StartMisc()
    -- Slide Boost
    Utils.RunService.RenderStepped:Connect(function()
        if not Config.Misc.SlideBoost.Enabled then return end
        
        local success, controller = pcall(function()
            return require(Utils.LocalPlayer.PlayerScripts.Controllers.MechanicsController)
        end)
        
        if success and controller and controller.IsSliding then
            pcall(function()
                controller._sliding_velocity.Velocity = 
                    controller._sliding_velocity.Velocity.Unit * Config.Misc.SlideBoost.Speed
            end)
        end
    end)
    
    -- Anti Trip
    if Config.Misc.AntiTrip then
        self:UpdateAntiTrip(true)
    end
end

function Misc:UpdateModDetector(enabled)
    if enabled then
        self:StartModDetector()
    else
        self:StopModDetector()
    end
end

function Misc:StartModDetector()
    if self.ModDetectorConnection then return end
    
    self.ModDetectorConnection = Utils.Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        if player == Utils.LocalPlayer then return end
        
        local success, role = pcall(function()
            return player:GetRoleInGroup(game.CreatorId)
        end)
        
        if success and role and (string.lower(role):find("mod") or 
                                 string.lower(role):find("staff") or
                                 string.lower(role):find("admin")) then
            Utils.LocalPlayer:Kick("Mod Detected!")
            task.wait(0.5)
            if Utils.LocalPlayer.Parent then
                game:Shutdown()
            end
        end
    end)
end

function Misc:StopModDetector()
    if self.ModDetectorConnection then
        self.ModDetectorConnection:Disconnect()
        self.ModDetectorConnection = nil
    end
end

function Misc:UpdateAntiFlashbang(enabled)
    if enabled then
        self:PatchFlashbang()
    end
end

function Misc:PatchFlashbang()
    local success, itemLibrary = pcall(function()
        return require(Utils.ReplicatedStorage.Modules.ItemLibrary)
    end)
    
    if success and itemLibrary and itemLibrary.Items and itemLibrary.Items.Flashbang then
        local flashbang = itemLibrary.Items.Flashbang
        if flashbang then
            flashbang.BlindDuration = 0
            if flashbang.Info then
                flashbang.Info.BlindDuration = 0
            end
        end
    end
end

function Misc:UpdateAntiTrip(enabled)
    if enabled then
        self:StartAntiTrip()
    else
        self:StopAntiTrip()
    end
end

function Misc:StartAntiTrip()
    if self.AntiTripConnection then return end
    
    self.AntiTripConnection = Utils.RunService.Heartbeat:Connect(function()
        local char = Utils.LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, obj in ipairs(Utils.Workspace:GetChildren()) do
            if obj.Name == "SubspaceTripmineHitbox" then
                local hitbox = obj:FindFirstChild("Hitbox")
                if hitbox then
                    pcall(function()
                        firetouchinterest(root, hitbox, 1)
                        firetouchinterest(root, hitbox, 0)
                    end)
                end
            end
        end
    end)
end

function Misc:StopAntiTrip()
    if self.AntiTripConnection then
        self.AntiTripConnection:Disconnect()
        self.AntiTripConnection = nil
    end
end

function Misc:SpoofDevice()
    local devices = {
        Console = "Gamepad",
        Mobile = "Touch",
        VR = "VR",
        PC = "MouseKeyboard",
    }
    
    local deviceCode = devices[Config.Misc.DeviceSpoof.Device]
    if not deviceCode then return end
    
    pcall(function()
        local remote = Utils.ReplicatedStorage.Remotes.Replication.Fighter.SetControls
        if remote then
            remote:FireServer(deviceCode)
        end
    end)
end

return Misc