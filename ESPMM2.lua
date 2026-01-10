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
		return Color3.fromRGB(255, 0, 0)
	elseif hasTool("Gun") then
		return Color3.fromRGB(0, 150, 255)
	else
		return Color3.fromRGB(0, 255, 0)
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
-- RESPAWN
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
-- TOGGLE (NO TOCADO)
-- ======================
local function toggle(button)
	enabled = not enabled

	if enabled then
		if button then button.Text = "ROLE ESP: ON" end
		updateHighlights()
		heartbeatConn = RunService.Heartbeat:Connect(updateHighlights)
	else
		if button then button.Text = "ROLE ESP: OFF" end
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
-- BOTÓN NUEVO (IGUAL A LOS OTROS)
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "RoleESP_GUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(150, 40)
button.Position = UDim2.fromScale(0.05, 0.7)
button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Text = "ROLE ESP: OFF"
button.Parent = gui
button.Active = true
button.Draggable = true

button.MouseButton1Click:Connect(function()
	toggle(button)
end)
