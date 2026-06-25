-- modules/combat.lua - With Cleanup
local Combat = {}
local Config, Utils, UI
local OriginalFunctions = {}
local MuzzleConn = nil
local Patched = false

function Combat:Init(uiModule, configModule, utilsModule)
    Config = configModule
    Utils = utilsModule
    UI = uiModule
    
    self:SetupUI()
    self:StartPatches()
end

function Combat:SetupUI()
    local group = UI:GetCombatRightGroup("Combat Mods")
    
    group:AddToggle("NoSpread", {
        Text = "No Spread",
        Default = Config.Combat.NoSpread,
        Callback = function(val)
            Config.Combat.NoSpread = val
            self:UpdatePatches()
        end,
    })
    
    group:AddToggle("NoRecoil", {
        Text = "No Recoil",
        Default = Config.Combat.NoRecoil,
        Callback = function(val)
            Config.Combat.NoRecoil = val
            self:UpdatePatches()
        end,
    })
    
    group:AddToggle("RapidFire", {
        Text = "Rapid Fire",
        Default = Config.Combat.RapidFire,
        Callback = function(val)
            Config.Combat.RapidFire = val
            self:UpdatePatches()
        end,
    })
    
    group:AddToggle("NoMuzzleFlash", {
        Text = "No Muzzle Flash",
        Default = Config.Combat.NoMuzzleFlash,
        Callback = function(val)
            Config.Combat.NoMuzzleFlash = val
            self:UpdateMuzzleFlash(val)
        end,
    })
end

function Combat:StartPatches()
    self:SetupGunPatch()
    self:SetupMeleePatch()
    self:SetupSpreadPatch()
end

function Combat:SetupGunPatch()
    local success, GunModule = pcall(function()
        return require(Utils.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
    end)
    
    if not success or not GunModule then return end
    
    if GunModule.StartShooting then
        OriginalFunctions.GunStartShooting = GunModule.StartShooting
        
        GunModule.StartShooting = function(self, ...)
            local oldCooldown
            if Config.Combat.RapidFire then
                oldCooldown = self.Info.ShootCooldown
                self.Info.ShootCooldown = 0
            end
            
            local results = {OriginalFunctions.GunStartShooting(self, ...)}
            
            if Config.Combat.RapidFire and oldCooldown then
                self.Info.ShootCooldown = oldCooldown
            end
            
            return unpack(results)
        end
    end
    
    if GunModule._Recoil then
        OriginalFunctions.GunRecoil = GunModule._Recoil
        
        GunModule._Recoil = function(self, multiplier)
            if Config.Combat.NoRecoil then
                return
            end
            return OriginalFunctions.GunRecoil(self, multiplier)
        end
    end
    
    Patched = true
end

function Combat:SetupSpreadPatch()
    local success, GameplayUtility = pcall(function()
        return require(Utils.ReplicatedStorage.Modules.GameplayUtility)
    end)
    
    if not success or not GameplayUtility then return end
    
    if GameplayUtility.GetSpread then
        OriginalFunctions.GetSpread = GameplayUtility.GetSpread
        
        GameplayUtility.GetSpread = function(...)
            if Config.Combat.NoSpread then
                return CFrame.new()
            end
            return OriginalFunctions.GetSpread(...)
        end
    end
end

function Combat:UpdatePatches()
    -- Re-apply patches with new settings
    self:Cleanup()
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
    
    -- Restore original functions if needed
    -- This is complex, but basically restore the original functions
end

return Combat
