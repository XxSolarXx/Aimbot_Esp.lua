local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings for FOV circle and aimbot
_G.AimbotEnabled = false -- Start with aimbot disabled
_G.CircleVisible = false -- Start with FOV circle hidden
_G.CircleRadius = 80
_G.CircleColor = Color3.fromRGB(255, 255, 255)
_G.CircleTransparency = 0.7
_G.CircleSides = 64
_G.CircleFilled = false
_G.CircleThickness = 1

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = _G.CircleRadius
FOVCircle.Filled = _G.CircleFilled
FOVCircle.Color = _G.CircleColor
FOVCircle.Visible = _G.CircleVisible
FOVCircle.Transparency = _G.CircleTransparency
FOVCircle.NumSides = _G.CircleSides
FOVCircle.Thickness = _G.CircleThickness

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Create a frame for the buttons
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 200, 0, 150)
MenuFrame.Position = UDim2.new(0.5, -100, 0.5, -75) -- Center the frame
MenuFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MenuFrame.BackgroundTransparency = 0.5
MenuFrame.Parent = ScreenGui

-- Create "Show FOV Circle" button
local ShowFovButton = Instance.new("TextButton")
ShowFovButton.Size = UDim2.new(1, 0, 0.5, 0)  -- Make button fill half of the frame
ShowFovButton.Position = UDim2.new(0, 0, 0, 0)
ShowFovButton.Text = "Show FOV Circle"
ShowFovButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ShowFovButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ShowFovButton.Parent = MenuFrame
ShowFovButton.MouseButton1Click:Connect(function()
    _G.CircleVisible = not _G.CircleVisible -- Toggle visibility of the FOV circle
    FOVCircle.Visible = _G.CircleVisible
end)

-- Create "Toggle Aimbot" button
local ToggleAimbotButton = Instance.new("TextButton")
ToggleAimbotButton.Size = UDim2.new(1, 0, 0.5, 0)  -- Make button fill the second half of the frame
ToggleAimbotButton.Position = UDim2.new(0, 0, 0.5, 0)
ToggleAimbotButton.Text = "Toggle Aimbot"
ToggleAimbotButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleAimbotButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleAimbotButton.Parent = MenuFrame
ToggleAimbotButton.MouseButton1Click:Connect(function()
    _G.AimbotEnabled = not _G.AimbotEnabled -- Toggle the aimbot functionality
end)

-- Moveable GUI functionality
local dragging = false
local dragInput, mousePos, framePos

MenuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragInput = input
        mousePos = input.Position
        framePos = MenuFrame.Position
    end
end)

MenuFrame.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MenuFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

MenuFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Aimbot Logic
local function GetClosestPlayer()
    local target = nil
    local maxDist = _G.CircleRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position) - Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)).Magnitude
            if dist < maxDist then
                target = player
            end
        end
    end

    return target
end

local function aimAtTarget(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = target.Character.HumanoidRootPart.Position
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
        Camera.CFrame = targetCFrame
    end
end

-- Aimbot and FOV circle update logic
RunService.RenderStepped:Connect(function()
    -- Update the FOV Circle
    FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    FOVCircle.Radius = _G.CircleRadius
    FOVCircle.Filled = _G.CircleFilled
    FOVCircle.Color = _G.CircleColor
    FOVCircle.Transparency = _G.CircleTransparency
    FOVCircle.NumSides = _G.CircleSides
    FOVCircle.Thickness = _G.CircleThickness

    -- Aimbot Logic
    if _G.AimbotEnabled then
        local target = GetClosestPlayer()
        if target then
            aimAtTarget(target)
        end
    end
end)
