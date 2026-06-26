-- modules/combat.lua - Works without config
local Combat = {}
local Utils, UI
local MuzzleConn = nil

-- Default settings
local Settings = {
    NoSpread = false,
    NoRecoil = false,
    RapidFire = false,
    NoMuzzleFlash = false,
}

function Combat:Init(uiModule, configModule, utilsModule)
    UI = uiModule
    Utils = utilsModule
    
    self:SetupUI()
    self:StartPatches()
end

function Combat:SetupUI()
    local group = UI:GetCombatRightGroup("Combat Mods")
    if not group then return end
    
    group:AddToggle("NoSpread", {
        Text = "No Spread",
        Default = false,
        Callback = function(val)
            Settings.NoSpread = val
            self:UpdatePatches()
        end,
    })
    
    group:AddToggle("NoRecoil", {
        Text = "No Recoil",
        Default = false,
        Callback = function(val)
            Settings.NoRecoil = val
            self:UpdatePatches()
        end,
    })
    
    group:AddToggle("RapidFire", {
        Text = "Rapid Fire",
        Default = false,
        Callback = function(val)
            Settings.RapidFire = val
            self:UpdatePatches()
        end,
    })
    
    group:AddToggle("NoMuzzleFlash", {
        Text = "No Muzzle Flash",
        Default = false,
        Callback = function(val)
            Settings.NoMuzzleFlash = val
            self:UpdateMuzzleFlash(val)
        end,
    })
end

function Combat:StartPatches()
    self:SetupGunPatch()
    self:SetupSpreadPatch()
end

function Combat:SetupGunPatch()
    local success, GunModule = pcall(function()
        return require(Utils.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
    end)
    
    if not success or not GunModule then return end
    
    if GunModule.StartShooting then
        local oldStart = GunModule.StartShooting
        GunModule.StartShooting = function(self, ...)
            local oldCooldown
            if Settings.RapidFire then
                oldCooldown = self.Info.ShootCooldown
                self.Info.ShootCooldown = 0
            end
            
            local results = {oldStart(self, ...)}
            
            if Settings.RapidFire and oldCooldown then
                self.Info.ShootCooldown = oldCooldown
            end
            
            return unpack(results)
        end
    end
    
    if GunModule._Recoil then
        local oldRecoil = GunModule._Recoil
        GunModule._Recoil = function(self, multiplier)
            if Settings.NoRecoil then
                return
            end
            return oldRecoil(self, multiplier)
        end
    end
end

function Combat:SetupSpreadPatch()
    local success, GameplayUtility = pcall(function()
        return require(Utils.ReplicatedStorage.Modules.GameplayUtility)
    end)
    
    if not success or not GameplayUtility then return end
    
    if GameplayUtility.GetSpread then
        local oldSpread = GameplayUtility.GetSpread
        GameplayUtility.GetSpread = function(...)
            if Settings.NoSpread then
                return CFrame.new()
            end
            return oldSpread(...)
        end
    end
end

function Combat:UpdatePatches()
    self:StartPatches()
end

function Combat:UpdateMuzzleFlash(enabled)
    if enabled then
        self:RemoveMuzzleFlash()
        MuzzleConn = Utils.RunService.RenderStepped:Connect(function()
            self:RemoveMuzzleFlash()
        end)
    else
        if MuzzleConn then
            MuzzleConn:Disconnect()
            MuzzleConn = nil
        end
    end
end

function Combat:RemoveMuzzleFlash()
    local vm = Utils.Workspace:FindFirstChild("ViewModels")
    if not vm then return end
    
    local fp = vm:FindFirstChild("FirstPerson")
    if not fp then return end
    
    for _, model in pairs(fp:GetChildren()) do
        if model:IsA("Model") then
            local iv = model:FindFirstChild("ItemVisual")
            if iv then
                local body = iv:FindFirstChild("Body")
                if body then
                    local bp = body:FindFirstChild("BodyPrimary")
                    if bp then
                        local muzzle = bp:FindFirstChild("_muzzle")
                        if muzzle then
                            local spotlight = muzzle:FindFirstChild("SpotLight")
                            if spotlight then
                                spotlight:Destroy()
                            end
                            for _, child in pairs(muzzle:GetChildren()) do
                                if child:IsA("ParticleEmitter") and child.Name == "ParticleEmiter" then
                                    child:Destroy()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function Combat:Cleanup()
    if MuzzleConn then
        MuzzleConn:Disconnect()
        MuzzleConn = nil
    end
end

return Combat
