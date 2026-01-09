local Players = game:GetService("Players")
local player = Players.LocalPlayer

local activeGun = nil
local currentHRP = nil
local teleporting = false

-- =========================
-- UTILIDADES
-- =========================
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function hasKnife()
    local char = player.Character
    if char and char:FindFirstChild("Knife") then return true end
    if player.Backpack:FindFirstChild("Knife") then return true end
    return false
end

-- =========================
-- ACTUALIZAR HRP
-- =========================
local function onCharacterAdded()
    currentHRP = getHRP()
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded()
end

-- =========================
-- LOOP TP REAL (NO SE TRABA)
-- =========================
task.spawn(function()
    while true do
        if activeGun
            and activeGun.Parent
            and currentHRP
            and currentHRP.Parent
            and not hasKnife()
        then
            local originalCF = currentHRP.CFrame
            currentHRP.CFrame = activeGun.CFrame
            task.wait(0.18)
            if currentHRP and currentHRP.Parent then
                currentHRP.CFrame = originalCF
            end
        end
        task.wait(0.15)
    end
end)

-- =========================
-- DETECTAR GUN DROP
-- =========================
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == "GunDrop" then
        activeGun = obj
        obj.AncestryChanged:Connect(function(_, parent)
            if not parent then
                activeGun = nil
            end
        end)
    end
end)

-- =========================
-- GUN DROP YA EXISTENTE
-- =========================
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Name == "GunDrop" then
        activeGun = obj
        break
    end
end
