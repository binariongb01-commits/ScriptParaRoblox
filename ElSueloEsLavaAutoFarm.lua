-- ================== SERVICIOS ==================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ================== LIMITES (COORDENADAS) ==================
local X_MIN, X_MAX = -102.92, 98.67
local Y_MIN, Y_MAX = 0.06, 271.77
local Z_MIN, Z_MAX = -98.94, 104.41

local SAFE_DELAY = 2 -- segundos antes de subir

-- ================== GUI ==================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 180, 0, 45)
btn.Position = UDim2.new(0, 20, 0, 20)
btn.TextScaled = true
btn.Text = "OFF"
btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.BorderSizePixel = 0
btn.Parent = gui

-- ================== DRAG ==================
local dragging = false
local dragStart
local startPos

btn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = btn.Position
	end
end)

btn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		local delta = input.Position - dragStart
		btn.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- ================== ESTADO ==================
local running = false
local frozen = false

-- ================== UTILS ==================
local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
	return getChar():WaitForChild("HumanoidRootPart")
end

local function insideBox(pos)
	return pos.X >= X_MIN and pos.X <= X_MAX
	   and pos.Y >= Y_MIN and pos.Y <= Y_MAX
	   and pos.Z >= Z_MIN and pos.Z <= Z_MAX
end

-- ================== MAPA ACTIVO ==================
local function mapIsActive()
	local map = workspace:FindFirstChild("CurrentMap")
	if not map then return false end
	for _, obj in ipairs(map:GetDescendants()) do
		if obj:IsA("BasePart") then
			return true
		end
	end
	return false
end

-- ================== COINS ==================
local function getCoins()
	local coins = {}
	local map = workspace:FindFirstChild("CurrentMap")
	if not map then return coins end

	for _, obj in ipairs(map:GetDescendants()) do
		if obj.Name == "Coins" then
			for _, c in ipairs(obj:GetChildren()) do
				if c:IsA("BasePart") and insideBox(c.Position) then
					table.insert(coins, c)
				end
			end
		end
	end
	return coins
end

-- ================== PARTE MAS ALTA (CORREGIDA) ==================
local function getHighestPartInBox()
	local map = workspace:FindFirstChild("CurrentMap")
	if not map then return nil end

	local highestPart = nil
	local highestTopY = -math.huge

	for _, obj in ipairs(map:GetDescendants()) do
		if obj:IsA("BasePart")
			and obj.CanCollide
			and obj.Transparency < 0.9
			and insideBox(obj.Position)
			and not obj:IsDescendantOf(getChar())
		then
			-- ALTURA REAL (parte superior)
			local topY = obj.Position.Y + (obj.Size.Y / 2)
			if topY > highestTopY then
				highestTopY = topY
				highestPart = obj
			end
		end
	end

	return highestPart
end

-- ================== POSTURA NATURAL ==================
local function placeCharacterStandingOnFloor()
	local char = getChar()
	local hrp = getHRP()

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {char}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(hrp.Position, Vector3.new(0, -50, 0), params)
	if result then
		local floorY = result.Position.Y
		local look = hrp.CFrame.LookVector
		local flatLook = Vector3.new(look.X, 0, look.Z)
		if flatLook.Magnitude < 0.1 then
			flatLook = Vector3.new(0, 0, -1)
		end

		local pos = Vector3.new(hrp.Position.X, floorY + 3, hrp.Position.Z)
		hrp.CFrame = CFrame.new(pos, pos + flatLook)
	end
end

-- ================== CONGELAR ==================
local function freezeCharacter()
	if frozen then return end
	local hrp = getHRP()
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	hrp.Anchored = true
	frozen = true
end

local function unfreezeCharacter()
	if not frozen then return end
	getHRP().Anchored = false
	frozen = false
end

-- ================== LOOP PRINCIPAL ==================
local function mainLoop()
	while running do
		if not mapIsActive() then
			unfreezeCharacter()
			task.wait(0.5)
			continue
		end

		local hrp = getHRP()
		local coins = getCoins()

		if #coins > 0 then
			unfreezeCharacter()
			for _, coin in ipairs(coins) do
				if not running or not mapIsActive() then break end
				if coin and coin.Parent then
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.CFrame = coin.CFrame + Vector3.new(0, 3, 0)
					task.wait(0.1)
				end
			end
		else
			task.wait(SAFE_DELAY)
			if not running or not mapIsActive() then continue end

			if #getCoins() == 0 then
				local high = getHighestPartInBox()
				if high then
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.CFrame = high.CFrame + Vector3.new(0, (high.Size.Y/2) + 3, 0)
					task.wait(0.15)
					placeCharacterStandingOnFloor()
					task.wait(0.05)
					freezeCharacter()
				end
			end
		end

		task.wait(0.2)
	end
end

-- ================== BOTON ==================
btn.Activated:Connect(function()
	running = not running
	btn.Text = running and "ON" or "OFF"

	if not running then
		unfreezeCharacter()
	else
		task.spawn(mainLoop)
	end
end)
