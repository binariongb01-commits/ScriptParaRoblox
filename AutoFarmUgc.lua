-- CONFIG
local TP_DELAY = 0.1

-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ESTADO
local farming = true

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 160, 0, 40)
button.Position = UDim2.new(0.05, 0, 0.5, 0)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Text = "Autofarm: ON"
button.Active = true
button.Parent = gui

-- DRAG
local dragging = false
local dragStart
local startPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
    end
end)

button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- BOTÓN ON/OFF
button.MouseButton1Click:Connect(function()
    farming = not farming
    button.Text = farming and "Autofarm: ON" or "Autofarm: OFF"
end)

-- UTIL
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function getBadges()
    local badges = {}
    local folder = workspace:FindFirstChild("obby")
        and workspace.obby:FindFirstChild("Badge")

    if not folder then return badges end

    for _, v in ipairs(folder:GetChildren()) do
        if v:IsA("Model") and v:GetAttribute("ID") and v.PrimaryPart then
            table.insert(badges, v.PrimaryPart)
        end
    end
    return badges
end

-- AUTOFARM
task.spawn(function()
    while true do
        if farming then
            local hrp = getHRP()
            for _, part in ipairs(getBadges()) do
                if not farming then break end
                if part and part.Parent then
                    hrp.CFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                    task.wait(TP_DELAY)
                end
            end
        end
        task.wait(0.1)
    end
end)
