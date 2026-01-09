local Players = game:GetService("Players")
local player = Players.LocalPlayer

local espEnabled = true
local highlight
local trackedGun

local function clearESP()
    if highlight then
        highlight:Destroy()
        highlight = nil
    end
    trackedGun = nil
end

local function applyESP(part)
    clearESP()

    local h = Instance.new("Highlight")
    h.Adornee = part
    h.FillColor = Color3.fromRGB(0,0,255)
    h.OutlineColor = Color3.fromRGB(0,0,255)
    h.FillTransparency = 0.3
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = part

    highlight = h
    trackedGun = part
end

local function check(obj)
    if not espEnabled then return end
    if obj:IsA("BasePart") and obj.Name == "GunDrop" then
        applyESP(obj)
    end
end

-- Detectar cuando aparece el arma
workspace.DescendantAdded:Connect(check)

-- Limpiar cuando desaparece (fin de ronda)
workspace.DescendantRemoving:Connect(function(obj)
    if obj == trackedGun then
        clearESP()
    end
end)

-- Scan único inicial
for _, obj in ipairs(workspace:GetDescendants()) do
    check(obj)
end
