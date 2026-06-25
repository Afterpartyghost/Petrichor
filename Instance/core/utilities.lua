--[[
    utilities.lua - Utility functions
]]

local Utils = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

function Utils:Init()
    self.LocalPlayer = self.Players.LocalPlayer
    self.Camera = self.Workspace.CurrentCamera
end

function Utils:GetWeapon()
    local vm = self.Workspace:FindFirstChild("ViewModels")
    if not vm then return nil end
    local fp = vm:FindFirstChild("FirstPerson")
    if not fp then return nil end
    
    for _, child in ipairs(fp:GetChildren()) do
        local parts = {}
        for part in child.Name:gmatch("[^-]+") do
            table.insert(parts, part:match("^%s*(.-)%s*$"))
        end
        if #parts >= 2 then
            return parts[2]
        end
    end
    return nil
end

function Utils:WorldToScreen(worldPos)
    local cam = self.Workspace.CurrentCamera or self.Camera
    if not cam then return nil, false end
    local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
    return screenPos, onScreen
end

function Utils:GetMuzzlePosition()
    local vm = self.Workspace:FindFirstChild("ViewModels")
    if not vm then return nil end
    local fp = vm:FindFirstChild("FirstPerson")
    if not fp then return nil end
    
    for _, model in pairs(fp:GetChildren()) do
        if model:IsA("Model") and model.Name:find("^" .. self.LocalPlayer.Name) then
            local iv = model:FindFirstChild("ItemVisual")
            if iv then
                local body = iv:FindFirstChild("Body")
                if body then
                    local bp = body:FindFirstChild("BodyPrimary")
                    if bp then
                        local muzzle = bp:FindFirstChild("_muzzle")
                        if muzzle and muzzle:IsA("Attachment") then
                            return muzzle.WorldPosition
                        end
                    end
                end
            end
        end
    end
    return nil
end

function Utils:GetClosestPlayer()
    local closest, closestDist = nil, math.huge
    local mousePos = self.UserInputService:GetMouseLocation()
    
    for _, player in ipairs(self.Players:GetPlayers()) do
        if player ~= self.LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = self:WorldToScreen(root.Position)
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
    return closest
end

function Utils:IsTeammate(player)
    if not player then return false end
    local myTeam = self.LocalPlayer:GetAttribute("TeamID")
    local theirTeam = player:GetAttribute("TeamID")
    if myTeam ~= nil and theirTeam ~= nil then
        return myTeam == theirTeam
    end
    return false
end

function Utils:GetPartFromName(char, partName)
    local parts = {
        Head = "Head",
        Torso = {"UpperTorso", "Torso", "LowerTorso"},
        HumanoidRootPart = "HumanoidRootPart",
    }
    
    if type(parts[partName]) == "string" then
        return char:FindFirstChild(parts[partName])
    elseif type(parts[partName]) == "table" then
        for _, name in ipairs(parts[partName]) do
            local part = char:FindFirstChild(name)
            if part then return part end
        end
    end
    return char:FindFirstChild("Head")
end

return Utils