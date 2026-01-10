local Players = game:GetService("Players")
local player = Players.LocalPlayer

local activeGun = nil
local currentHRP = nil
local teleporting = false
local tpEnabled = false

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
-- LOOP TP (NO MODIFICADO)
-- =========================
task.spawn(function()
	while true do
		if tpEnabled
			and activeGun
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

-- =========================
-- BOTÓN FLOTANTE ON / OFF
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "TP_Gun_GUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(130, 40)
button.Position = UDim2.fromScale(0.05, 0.6)
button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Text = "TP GUN: OFF"
button.Parent = gui
button.Active = true
button.Draggable = true

button.MouseButton1Click:Connect(function()
	tpEnabled = not tpEnabled
	button.Text = tpEnabled and "TP GUN: ON" or "TP GUN: OFF"
end)
