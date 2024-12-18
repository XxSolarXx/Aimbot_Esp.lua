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
_G.FOVColor = Color3.fromRGB(0, 255, 0)
_G.FOVSize = 50  -- Default FOV size
_G.AimbotTarget = "Head"  -- Default target for aimbot
_G.SpinToggle = false  -- Default spin toggle status

-- Create GUI elements
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 200, 0, 200)
MenuFrame.Position = UDim2.new(1, -210, 1, -200)
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

-- Toggle Spin Button
local ToggleSpinButton = Instance.new("TextButton", MenuFrame)
ToggleSpinButton.Size = UDim2.new(1, 0, 0.2, 0)
ToggleSpinButton.Position = UDim2.new(0, 0, 0.6, 0)
ToggleSpinButton.Text = "Toggle Spin"
ToggleSpinButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleSpinButton.BackgroundTransparency = 0.8
ToggleSpinButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleSpinButton.MouseButton1Click:Connect(function()
    _G.SpinToggle = not _G.SpinToggle
    if _G.SpinToggle then
        ToggleSpinButton.Text = "Spin ON"
    else
        ToggleSpinButton.Text = "Spin OFF"
    end
end)

-- Settings Button to open the Settings GUI
local SettingsButton = Instance.new("TextButton", MenuFrame)
SettingsButton.Size = UDim2.new(1, 0, 0.2, 0)
SettingsButton.Position = UDim2.new(0, 0, 0.8, 0)
SettingsButton.Text = "Settings"
SettingsButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SettingsButton.BackgroundTransparency = 0.8
SettingsButton.TextColor3 = Color3.fromRGB(0, 0, 0)

-- Create Settings GUI
local SettingsGui = Instance.new("Frame", ScreenGui)
SettingsGui.Size = UDim2.new(0, 250, 0, 300)
SettingsGui.Position = UDim2.new(0, 0, 0, 0)
SettingsGui.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SettingsGui.BackgroundTransparency = 0.8
SettingsGui.Visible = false

local ESPColorButton = Instance.new("TextButton", SettingsGui)
ESPColorButton.Size = UDim2.new(1, 0, 0.2, 0)
ESPColorButton.Position = UDim2.new(0, 0, 0, 0)
ESPColorButton.Text = "Change ESP Color"
ESPColorButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ESPColorButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ESPColorButton.MouseButton1Click:Connect(function()
    local colorPicker = game:GetService("ReplicatedStorage"):WaitForChild("ColorPicker") -- Placeholder for color picker
    _G.ESPBoxColor = colorPicker:GetColor() -- Get color from picker (you would need to implement a color picker)
end)

local FOVSizeButton = Instance.new("TextButton", SettingsGui)
FOVSizeButton.Size = UDim2.new(1, 0, 0.2, 0)
FOVSizeButton.Position = UDim2.new(0, 0, 0.2, 0)
FOVSizeButton.Text = "Change FOV Size"
FOVSizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVSizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
FOVSizeButton.MouseButton1Click:Connect(function()
    local newSize = math.random(30, 100)  -- Just a placeholder for testing
    _G.FOVSize = newSize
end)

local FOVColorButton = Instance.new("TextButton", SettingsGui)
FOVColorButton.Size = UDim2.new(1, 0, 0.2, 0)
FOVColorButton.Position = UDim2.new(0, 0, 0.4, 0)
FOVColorButton.Text = "Change FOV Color"
FOVColorButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVColorButton.TextColor3 = Color3.fromRGB(0, 0, 0)
FOVColorButton.MouseButton1Click:Connect(function()
    local colorPicker = game:GetService("ReplicatedStorage"):WaitForChild("ColorPicker") -- Placeholder for color picker
    _G.FOVColor = colorPicker:GetColor() -- Get color from picker (you would need to implement a color picker)
end)

local AimbotTargetButton = Instance.new("TextButton", SettingsGui)
AimbotTargetButton.Size = UDim2.new(1, 0, 0.2, 0)
AimbotTargetButton.Position = UDim2.new(0, 0, 0.6, 0)
AimbotTargetButton.Text = "Change Aimbot Target"
AimbotTargetButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AimbotTargetButton.TextColor3 = Color3.fromRGB(0, 0, 0)
AimbotTargetButton.MouseButton1Click:Connect(function()
    _G.AimbotTarget = _G.AimbotTarget == "Head" and "Torso" or "Head"  -- Toggle between Head and Torso
end)

-- Toggle settings window
SettingsButton.MouseButton1Click:Connect(function()
    SettingsGui.Visible = not SettingsGui.Visible
end)

-- ESP for humanoids with highlights
local function HighlightHumanoids()
    while _G.ESPEnabled do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    -- Add a Highlight to the humanoid if it doesn't already exist
                    local highlight = humanoid:FindFirstChild("Highlight")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Parent = humanoid
                    end
                    highlight.FillColor = _G.ESPBoxColor  -- Use the ESP box color for the highlight
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0.5
                    highlight.OutlineColor = _G.ESPBoxColor
                    highlight.Visible = true
                end
            end
        end
        wait(1)  -- small delay between checks
    end
end

-- Aimbot Functionality
local function Aimbot()
    while _G.AimbotEnabled do
        local closestTarget = nil
        local closestDistance = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local targetPart = player.Character:FindFirstChild(_G.AimbotTarget)
                if targetPart then
                    local screenPos = Camera:WorldToViewportPoint(targetPart.Position)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if distance < closestDistance then
                        closestTarget = targetPart
                        closestDistance = distance
                    end
                end
            end
        end

        if closestTarget then
            -- Aim towards the closest target
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            local targetPos = Camera:WorldToScreenPoint(closestTarget.Position)
            mouse.Move(targetPos.X, targetPos.Y)
        end
        wait(0.1)  -- small delay
    end
end

-- Start ESP and aimbot if enabled
if _G.ESPEnabled then
    HighlightHumanoids()
end

if _G.AimbotEnabled then
    Aimbot()
end
