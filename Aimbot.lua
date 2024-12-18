local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ESP and Aimbot Settings
_G.ESPEnabled = false
_G.AimbotEnabled = false
_G.CircleVisible = false
_G.ESPBoxColor = Color3.fromRGB(255, 0, 0)
_G.ESPBoxThickness = 2
_G.AimbotFOV = 50  -- Default FOV radius for aimbot targeting
_G.FOVCircleColor = Color3.fromRGB(0, 255, 0) -- Default FOV color
_G.AimbotTarget = "Head"  -- Default aimbot target

-- Create GUI elements
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 200, 0, 250)  -- Adjusted size for more buttons
MenuFrame.Position = UDim2.new(1, -210, 1, -160)  -- Positioned to the bottom-right
MenuFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MenuFrame.BackgroundTransparency = 0.8

-- Show Fov Button
local ShowFovButton = Instance.new("TextButton", MenuFrame)
ShowFovButton.Size = UDim2.new(1, 0, 0.2, 0)
ShowFovButton.Position = UDim2.new(0, 0, 0, 0)
ShowFovButton.Text = "Show FOV Circle"
ShowFovButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ShowFovButton.BackgroundTransparency = 0.8
ShowFovButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ShowFovButton.MouseButton1Click:Connect(function()
    _G.CircleVisible = not _G.CircleVisible
end)

-- Toggle Aimbot Button
local ToggleAimbotButton = Instance.new("TextButton", MenuFrame)
ToggleAimbotButton.Size = UDim2.new(1, 0, 0.2, 0)
ToggleAimbotButton.Position = UDim2.new(0, 0, 0.2, 0)
ToggleAimbotButton.Text = "Toggle Aimbot"
ToggleAimbotButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleAimbotButton.BackgroundTransparency = 0.8
ToggleAimbotButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleAimbotButton.MouseButton1Click:Connect(function()
    _G.AimbotEnabled = not _G.AimbotEnabled
    if _G.AimbotEnabled then
        ToggleAimbotButton.Text = "Aimbot ON"
    else
        ToggleAimbotButton.Text = "Aimbot OFF"
    end
end)

-- Toggle ESP Button
local ToggleESPButton = Instance.new("TextButton", MenuFrame)
ToggleESPButton.Size = UDim2.new(1, 0, 0.2, 0)
ToggleESPButton.Position = UDim2.new(0, 0, 0.4, 0)
ToggleESPButton.Text = "Toggle ESP"
ToggleESPButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleESPButton.BackgroundTransparency = 0.8
ToggleESPButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleESPButton.MouseButton1Click:Connect(function()
    _G.ESPEnabled = not _G.ESPEnabled
end)

-- Settings Button
local SettingsButton = Instance.new("TextButton", MenuFrame)
SettingsButton.Size = UDim2.new(1, 0, 0.2, 0)
SettingsButton.Position = UDim2.new(0, 0, 0.6, 0)
SettingsButton.Text = "Settings"
SettingsButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SettingsButton.BackgroundTransparency = 0.8
SettingsButton.TextColor3 = Color3.fromRGB(0, 0, 0)

-- Settings GUI
local SettingsFrame = Instance.new("Frame", ScreenGui)
SettingsFrame.Size = UDim2.new(0, 200, 0, 300)
SettingsFrame.Position = UDim2.new(0, 0, 1, -300)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SettingsFrame.BackgroundTransparency = 0.8
SettingsFrame.Visible = false

local CloseSettingsButton = Instance.new("TextButton", SettingsFrame)
CloseSettingsButton.Size = UDim2.new(1, 0, 0.1, 0)
CloseSettingsButton.Position = UDim2.new(0, 0, 0, 0)
CloseSettingsButton.Text = "Close Settings"
CloseSettingsButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseSettingsButton.BackgroundTransparency = 0.8
CloseSettingsButton.TextColor3 = Color3.fromRGB(0, 0, 0)
CloseSettingsButton.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = false
end)

-- FOV Size Slider
local FOVSlider = Instance.new("TextBox", SettingsFrame)
FOVSlider.Size = UDim2.new(1, 0, 0.1, 0)
FOVSlider.Position = UDim2.new(0, 0, 0.1, 0)
FOVSlider.PlaceholderText = "FOV Size: " .. _G.AimbotFOV
FOVSlider.Text = tostring(_G.AimbotFOV)
FOVSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
FOVSlider.BackgroundTransparency = 0.8
FOVSlider.TextChanged:Connect(function()
    local newValue = tonumber(FOVSlider.Text)
    if newValue then
        _G.AimbotFOV = newValue
        FOVSlider.PlaceholderText = "FOV Size: " .. _G.AimbotFOV
    end
end)

-- FOV Color Button
local FOVColorButton = Instance.new("TextButton", SettingsFrame)
FOVColorButton.Size = UDim2.new(1, 0, 0.1, 0)
FOVColorButton.Position = UDim2.new(0, 0, 0.2, 0)
FOVColorButton.Text = "FOV Color"
FOVColorButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FOVColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVColorButton.MouseButton1Click:Connect(function()
    _G.FOVCircleColor = Color3.fromRGB(0, 0, 255)  -- Change to desired color
    FOVColorButton.BackgroundColor3 = _G.FOVCircleColor
end)

-- Aimbot Target Dropdown (for Head, Torso, etc.)
local AimbotTargetLabel = Instance.new("TextLabel", SettingsFrame)
AimbotTargetLabel.Size = UDim2.new(1, 0, 0.1, 0)
AimbotTargetLabel.Position = UDim2.new(0, 0, 0.3, 0)
AimbotTargetLabel.Text = "Change Aimbot Target: (" .. _G.AimbotTarget .. ")"
AimbotTargetLabel.BackgroundTransparency = 1
AimbotTargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local AimbotTargetButton = Instance.new("TextButton", SettingsFrame)
AimbotTargetButton.Size = UDim2.new(1, 0, 0.1, 0)
AimbotTargetButton.Position = UDim2.new(0, 0, 0.4, 0)
AimbotTargetButton.Text = "Change Target"
AimbotTargetButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AimbotTargetButton.TextColor3 = Color3.fromRGB(0, 0, 0)
AimbotTargetButton.MouseButton1Click:Connect(function()
    if _G.AimbotTarget == "Head" then
        _G.AimbotTarget = "Torso"
    else
        _G.AimbotTarget = "Head"
    end
    AimbotTargetLabel.Text = "Change Aimbot Target: (" .. _G.AimbotTarget .. ")"
end)

SettingsButton.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = not SettingsFrame.Visible
end)

-- FOV Circle Drawing
local function DrawFovCircle()
    if _G.CircleVisible then
        local circle = Drawing.new("Circle")
        circle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        circle.Radius = _G.AimbotFOV
        circle.Color = _G.FOVCircleColor
        circle.Thickness = 2
        circle.Filled = false
        circle.Visible = true
    end
end

-- Aimbot Functionality
local function Aimbot()
    while _G.AimbotEnabled do
        local closestPlayer = nil
        local closestDistance = _G.AimbotFOV
        local targetPos = nil
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local targetPart = player.Character:FindFirstChild(_G.AimbotTarget)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)).magnitude
                        if distance < closestDistance then
                            closestPlayer = player
                            closestDistance = distance
                            targetPos = screenPos
                        end
                    end
                end
            end
        end
        
        if closestPlayer and targetPos then
            UserInputService.MouseMove(Vector2.new(targetPos.X, targetPos.Y))
        end
        
        RunService.RenderStepped:wait()
    end
end

-- Start Aimbot when toggled
RunService.RenderStepped:Connect(function()
    DrawFovCircle()
    if _G.AimbotEnabled then
        Aimbot()
    end
end)
