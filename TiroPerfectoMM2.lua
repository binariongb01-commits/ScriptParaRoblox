local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- =========================
-- UTILIDADES
-- =========================
local function getTool(plr, name)
	if plr.Character and plr.Character:FindFirstChild(name) then
		return plr.Character[name]
	end
	if plr.Backpack:FindFirstChild(name) then
		return plr.Backpack[name]
	end
	return nil
end

local function getMurderer()
	for _, plr in ipairs(Players:GetPlayers()) do
		if getTool(plr, "Knife") then
			return plr
		end
	end
end

-- =========================
-- CONFIG
-- =========================
local COOLDOWN = 0.4
local lastShot = 0

-- =========================
-- TIRO PERFECTO MEJORADO
-- =========================
local function perfectShot()
	if tick() - lastShot < COOLDOWN then return end
	lastShot = tick()

	local gun = getTool(player, "Gun")
	if not gun then return end

	local remote = gun:FindFirstChild("Shoot")
	if not remote then return end

	local murderer = getMurderer()
	if not murderer or not murderer.Character then return end

	local hrp = murderer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Predicción ligera
	local predictedPos = hrp.Position + (hrp.AssemblyLinearVelocity * 0.08)

	local originCF = camera.CFrame
	local targetCF = CFrame.new(predictedPos)

	-- Disparo doble (anti-lag)
	remote:FireServer(originCF, targetCF)
	task.wait(0.05)
	remote:FireServer(originCF, targetCF)

	print("Perfect Shot HIT →", murderer.Name)
end

-- =========================
-- BOTÓN SEGURO (NO JOYSTICK)
-- =========================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 180, 0, 55)
btn.Position = UDim2.new(1, -200, 0.6, 0) -- derecha, arriba del salto
btn.AnchorPoint = Vector2.new(0, 0)
btn.Text = "PERFECT SHOT"
btn.TextScaled = true
btn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
btn.TextColor3 = Color3.new(1,1,1)
btn.BorderSizePixel = 0
btn.Parent = gui

btn.Activated:Connect(perfectShot)
