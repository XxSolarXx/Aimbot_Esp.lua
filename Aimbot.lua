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
_G.FOVColor = Color3.fromRGB(255, 255, 255) -- White color for the FOV circle
_G.FOVSize = 50 -- Default FOV size
_G.AimbotTarget = "Head" -- Default target for aimbot
_G.SpinToggle = false -- Default spin toggle status

-- Create GUI elements
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 200, 0, 200)
MenuFrame.Position = UDim2.new(1, -210, 1, -200)
MenuFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MenuFrame.BackgroundTransparency = 0.8

-- Show FOV Button
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

-- Create a thin hollow FOV circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1 -- Thin circle
FOVCircle.Transparency = 1 -- Fully visible
FOVCircle.Filled = false -- Hollow circle
FOVCircle.Color = _G.FOVColor -- Set to white initially
FOVCircle.Visible = false -- Start hidden

-- Update the FOV circle on every frame
RunService.RenderStepped:Connect(function()
    if _G.CircleVisible then
        local mouseLocation = UserInputService:GetMouseLocation()
        FOVCircle.Position = mouseLocation
        FOVCircle.Radius = _G.FOVSize
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
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

-- Spin toggle button
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

-- Aimbot Functionality
local function Aimbot()
    while _G.AimbotEnabled do
        local closestPlayer = nil
        local closestDistance = _G.FOVSize
        local targetPos = nil

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local bodyPart = player.Character:FindFirstChild(_G.AimbotTarget)
                if bodyPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(bodyPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if distance < closestDistance then
                            closestPlayer = player
                            closestDistance = distance
                            targetPos = bodyPart.Position
                        end
                    end
                end
            end
        end

        if closestPlayer and targetPos then
            local cameraPos = Camera.CFrame.Position
            local direction = (targetPos - cameraPos).unit
            local lockStrength = 0.3
            Camera.CFrame = CFrame.new(cameraPos, cameraPos + direction * lockStrength)
        end
        task.wait(0.03)
    end
end

RunService.Heartbeat:Connect(function()
    if _G.AimbotEnabled then
        Aimbot()
    end
end)
