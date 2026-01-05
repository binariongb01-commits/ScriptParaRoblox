local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local enabled = false
local highlights = {}
local heartbeatConn = nil

-- ======================
-- DETECTAR ROL POR TOOLS
-- ======================
local function getRoleColor(plr)
	local function hasTool(name)
		if plr.Backpack:FindFirstChild(name) then return true end
		if plr.Character and plr.Character:FindFirstChild(name) then return true end
		return false
	end

	if hasTool("Knife") then
		return Color3.fromRGB(255, 0, 0) -- Asesino
	elseif hasTool("Gun") then
		return Color3.fromRGB(0, 150, 255) -- Sheriff
	else
		return Color3.fromRGB(0, 255, 0) -- Inocente
	end
end

-- ======================
-- LIMPIAR HIGHLIGHTS
-- ======================
local function clearHighlights()
	for _, hl in pairs(highlights) do
		if hl then hl:Destroy() end
	end
	highlights = {}
end

-- ======================
-- ACTUALIZAR HIGHLIGHTS
-- ======================
local function updateHighlights()
	for _, plr in pairs(Players:GetPlayers()) do
		local char = plr.Character

		if not char then
			if highlights[plr] then
				highlights[plr]:Destroy()
				highlights[plr] = nil
			end
			continue
		end

		local color = getRoleColor(plr)

		if highlights[plr] and highlights[plr].Adornee ~= char then
			highlights[plr]:Destroy()
			highlights[plr] = nil
		end

		if highlights[plr] then
			highlights[plr].OutlineColor = color
		else
			local hl = Instance.new("Highlight")
			hl.Name = "RoleHighlight"
			hl.Adornee = char
			hl.FillTransparency = 1
			hl.OutlineTransparency = 0
			hl.OutlineColor = color
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = char

			highlights[plr] = hl
		end
	end
end

-- ======================
-- RE-SINCRONIZAR RESPAWN
-- ======================
local function hookPlayer(plr)
	plr.CharacterAdded:Connect(function()
		if enabled then
			task.wait(0.2)
			updateHighlights()
		end
	end)
end

for _, plr in pairs(Players:GetPlayers()) do
	hookPlayer(plr)
end

Players.PlayerAdded:Connect(hookPlayer)

-- ======================
-- TOGGLE GENERAL
-- ======================
local function toggle(button)
	enabled = not enabled

	if enabled then
		if button then button.Text = "ON" end
		updateHighlights()

		heartbeatConn = RunService.Heartbeat:Connect(function()
			updateHighlights()
		end)
	else
		if button then button.Text = "OFF" end
		if heartbeatConn then
			heartbeatConn:Disconnect()
			heartbeatConn = nil
		end
		clearHighlights()
	end
end

-- ======================
-- TECLA PC (R)
-- ======================
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.R then
		toggle()
	end
end)

-- ======================
-- BOTÓN FLOTANTE
-- ======================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.AutoLocalize = false -- 👈 evita NO / EN
gui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 120, 0, 50)
btn.Position = UDim2.new(0.7, 0, 0.6, 0)
btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextScaled = true
btn.Text = "OFF"
btn.Parent = gui

-- ======================
-- ARRASTRAR BOTÓN
-- ======================
local dragging = false
local dragStart, startPos

btn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = btn.Position
	end
end)

btn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - dragStart
		btn.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- ======================
-- CLICK BOTÓN
-- ======================
btn.MouseButton1Click:Connect(function()
	toggle(btn)
end)
