local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ESP Settings
_G.ESPEnabled = false
_G.ESPBoxColor = Color3.fromRGB(255, 0, 0)
_G.ESPBoxThickness = 2

-- Create GUI elements
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 200, 0, 150) -- Adjusted size for more buttons
MenuFrame.Position = UDim2.new(1, -210, 1, -160) -- Positioned to the bottom-right
MenuFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MenuFrame.BackgroundTransparency = 0.8

-- Show FOV Circle Button
local ShowFovButton = Instance.new("TextButton", MenuFrame)
ShowFovButton.Size = UDim2.new(1, 0, 0.3, 0)
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
ToggleAimbotButton.Size = UDim2.new(1, 0, 0.3, 0)
ToggleAimbotButton.Position = UDim2.new(0, 0, 0.3, 0)
ToggleAimbotButton.Text = "Toggle Aimbot"
ToggleAimbotButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleAimbotButton.BackgroundTransparency = 0.8
ToggleAimbotButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleAimbotButton.MouseButton1Click:Connect(function()
    _G.AimbotEnabled = not _G.AimbotEnabled
end)

-- Toggle ESP Button
local ToggleESPButton = Instance.new("TextButton", MenuFrame)
ToggleESPButton.Size = UDim2.new(1, 0, 0.3, 0)
ToggleESPButton.Position = UDim2.new(0, 0, 0.6, 0)
ToggleESPButton.Text = "Toggle ESP"
ToggleESPButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleESPButton.BackgroundTransparency = 0.8
ToggleESPButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleESPButton.MouseButton1Click:Connect(function()
    _G.ESPEnabled = not _G.ESPEnabled
end)

-- ESP Drawing
local function DrawESPBox(player)
    -- Ensure player has a character and it's alive
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

        if onScreen then
            local size = rootPart.Size
            local topLeft = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(-size.X / 2, size.Y / 2, 0))
            local bottomRight = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(size.X / 2, -size.Y / 2, 0))

            -- Draw the ESP Box
            local box = Drawing.new("Line")
            box.From = Vector2.new(topLeft.X, topLeft.Y)
            box.To = Vector2.new(topLeft.X, bottomRight.Y)
            box.Color = _G.ESPBoxColor
            box.Thickness = _G.ESPBoxThickness
            box.Visible = _G.ESPEnabled

            local box2 = Drawing.new("Line")
            box2.From = Vector2.new(topLeft.X, bottomRight.Y)
            box2.To = Vector2.new(bottomRight.X, bottomRight.Y)
            box2.Color = _G.ESPBoxColor
            box2.Thickness = _G.ESPBoxThickness
            box2.Visible = _G.ESPEnabled

            local box3 = Drawing.new("Line")
            box3.From = Vector2.new(bottomRight.X, bottomRight.Y)
            box3.To = Vector2.new(bottomRight.X, topLeft.Y)
            box3.Color = _G.ESPBoxColor
            box3.Thickness = _G.ESPBoxThickness
            box3.Visible = _G.ESPEnabled

            local box4 = Drawing.new("Line")
            box4.From = Vector2.new(bottomRight.X, topLeft.Y)
            box4.To = Vector2.new(topLeft.X, topLeft.Y)
            box4.Color = _G.ESPBoxColor
            box4.Thickness = _G.ESPBoxThickness
            box4.Visible = _G.ESPEnabled
        end
    end
end

-- Update ESP every frame
RunService.RenderStepped:Connect(function()
    if _G.ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                DrawESPBox(player)
            end
        end
    end
end)
