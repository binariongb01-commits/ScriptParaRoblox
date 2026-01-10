local Players = game:GetService("Players")
local player = Players.LocalPlayer

local espEnabled = false
local highlight
local trackedGun

-- =========================
-- ESP ORIGINAL (NO TOCADO)
-- =========================
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

workspace.DescendantAdded:Connect(check)

workspace.DescendantRemoving:Connect(function(obj)
	if obj == trackedGun then
		clearESP()
	end
end)

for _, obj in ipairs(workspace:GetDescendants()) do
	check(obj)
end

-- =========================
-- BOTÓN FLOTANTE ON / OFF
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "ESP_Toggle_GUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(110, 40)
button.Position = UDim2.fromScale(0.05, 0.5)
button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Text = "ESP: OFF"
button.Parent = gui
button.Active = true
button.Draggable = true

button.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled

	if espEnabled then
		button.Text = "ESP: ON"
		for _, obj in ipairs(workspace:GetDescendants()) do
			check(obj)
		end
	else
		button.Text = "ESP: OFF"
		clearESP()
	end
end)
