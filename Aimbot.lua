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
_G.AimbotFOV = 50  -- Adjust the FOV radius for aimbot targeting

-- Create GUI elements
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 200, 0, 150)  -- Adjusted size for more buttons
MenuFrame.Position = UDim2.new(1, -210, 1, -160)  -- Positioned to the bottom-right
MenuFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MenuFrame.BackgroundTransparency = 0.8

-- Show Fov Button
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
    if _G.AimbotEnabled then
        ToggleAimbotButton.Text = "Aimbot ON"
    else
        ToggleAimbotButton.Text = "Aimbot OFF"
    end
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

-- Aimbot Functionality
local function Aimbot()
    while _G.AimbotEnabled do
        local closestPlayer = nil
        local closestDistance = _G.AimbotFOV
        local targetPos = nil
        
        -- Check for all players in the game
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)).Magnitude
                        if _G.CircleVisible then
                            -- Check if player is inside FOV circle
                            local circleCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local circleRadius = _G.AimbotFOV
                            local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - circleCenter).Magnitude
                            if distanceFromCenter <= circleRadius then
                                -- This player is inside the FOV circle
                                if distance < closestDistance then
                                    closestPlayer = player
                                    closestDistance = distance
                                    targetPos = head.Position
                                end
                            end
                        else
                            if distance < closestDistance then
                                closestPlayer = player
                                closestDistance = distance
                                targetPos = head.Position
                            end
                        end
                    end
                end
            end
        end

        -- Lock onto the closest player's head
        if closestPlayer and targetPos then
            local cameraPos = Camera.CFrame.Position
            local direction = (targetPos - cameraPos).unit
            Camera.CFrame = CFrame.new(cameraPos, targetPos)
        end

        wait(0.05) -- Update every frame for smooth aimbot movement
    end
end

-- Run the Aimbot when it's enabled
RunService.Heartbeat:Connect(function()
    if _G.AimbotEnabled then
        Aimbot()
    end
end)

-- ESP Drawing - Highlight Humanoid
local function HighlightHumanoid(player)
    -- Ensure player has a character and humanoid
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid

        -- Ensure the humanoid exists before applying highlight
        if humanoid then
            -- Check if the humanoid already has a highlight
            local existingHighlight = player.Character:FindFirstChild("HumanoidHighlight")
            if not existingHighlight then
                -- Create a new highlight if it doesn't exist
                local highlight = Instance.new("Highlight")
                highlight.Name = "HumanoidHighlight"
                highlight.Parent = player.Character
                highlight.FillColor = _G.ESPBoxColor -- You can customize the highlight color
                highlight.FillTransparency = 0.5 -- Set transparency for the highlight
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0) -- Set the outline color for emphasis
                highlight.OutlineTransparency = 0.8 -- Set outline transparency
            end
        end
    end
end

-- Update ESP every frame
RunService.RenderStepped:Connect(function()
    if _G.ESPEnabled then
        -- Apply highlight to all players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                HighlightHumanoid(player)
            end
        end
    else
        -- Remove highlight if ESP is disabled
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local existingHighlight = player.Character:FindFirstChild("HumanoidHighlight")
                if existingHighlight then
                    existingHighlight:Destroy()
                end
            end
        end
    end
end)
