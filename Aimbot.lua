local Camera = game.Workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Initializing settings
_G.AimbotEnabled = true
_G.TeamCheck = false
_G.AimPart = "Head"
_G.Sensitivity = 0.1

_G.CircleSides = 64
_G.CircleColor = Color3.fromRGB(255, 255, 255)
_G.CircleTransparency = 0.7
_G.CircleRadius = 80
_G.CircleFilled = false
_G.CircleVisible = true
_G.CircleThickness = 0.02

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.5
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Text = "Aimbot & FOV"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.TextSize = 18
TitleLabel.TextAlignment = Enum.TextAlignment.Center
TitleLabel.Parent = MainFrame

local ToggleFOVButton = Instance.new("TextButton")
ToggleFOVButton.Size = UDim2.new(0, 180, 0, 30)
ToggleFOVButton.Position = UDim2.new(0, 10, 0, 40)
ToggleFOVButton.Text = "Show FOV Circle"
ToggleFOVButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleFOVButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleFOVButton.TextSize = 14
ToggleFOVButton.Parent = MainFrame

local ToggleAimbotButton = Instance.new("TextButton")
ToggleAimbotButton.Size = UDim2.new(0, 180, 0, 30)
ToggleAimbotButton.Position = UDim2.new(0, 10, 0, 80)
ToggleAimbotButton.Text = "Toggle Aimbot"
ToggleAimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleAimbotButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleAimbotButton.TextSize = 14
ToggleAimbotButton.Parent = MainFrame

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, _G.CircleRadius * 2, 0, _G.CircleRadius * 2)
FOVCircle.Position = UDim2.new(0.5, -_G.CircleRadius, 0.5, -_G.CircleRadius)
FOVCircle.BackgroundColor3 = _G.CircleColor
FOVCircle.BackgroundTransparency = _G.CircleTransparency
FOVCircle.Visible = _G.CircleVisible
FOVCircle.Parent = ScreenGui

-- Toggle FOV Circle
ToggleFOVButton.MouseButton1Click:Connect(function()
    _G.CircleVisible = not _G.CircleVisible
    FOVCircle.Visible = _G.CircleVisible
end)

-- Toggle Aimbot
ToggleAimbotButton.MouseButton1Click:Connect(function()
    _G.AimbotEnabled = not _G.AimbotEnabled
    if _G.AimbotEnabled then
        ToggleAimbotButton.Text = "Aimbot Enabled"
    else
        ToggleAimbotButton.Text = "Aimbot Disabled"
    end
end)

-- Make GUI movable
local dragToggle = false
local dragStart = nil
local dragPos = nil

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(dragPos.X.Scale, delta.X, dragPos.Y.Scale, delta.Y)
end

TitleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        dragPos = MainFrame.Position
    end
end)

TitleLabel.InputChanged:Connect(function(input)
    if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

TitleLabel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = false
    end
end)

-- Function to get closest player for aimbot
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = _G.CircleRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local screenPosition, onScreen = Camera:WorldToScreenPoint(character.HumanoidRootPart.Position)
                local mousePos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
                local distance = (mousePos - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end

-- Aimbot functionality (when mouse button is held)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if _G.AimbotEnabled then
            local targetPlayer = GetClosestPlayer()
            if targetPlayer then
                local targetPosition = targetPlayer.Character[_G.AimPart].Position
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
            end
        end
    end
end)

-- Update the FOV circle position to follow the mouse
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UDim2.new(0, UserInputService:GetMouseLocation().X - _G.CircleRadius, 0, UserInputService:GetMouseLocation().Y - _G.CircleRadius)
end)

