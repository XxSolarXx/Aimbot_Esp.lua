local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Settings
local Settings = {
    ESPEnabled = false,
    AimbotEnabled = false,
    FOVRadius = 100,  -- Smaller FOV circle radius
    FOVCircleVisible = true,  -- Start with FOV Circle visible
    ShowNameTags = true,  -- Option to show name tags
    ShowHealthBars = true,  -- Option to show health bars
    ShowDistance = true,  -- Option to show distance
    ESPColor = Color3.fromRGB(0, 255, 0),  -- Green ESP color
}

-- ESP elements template
local highlightTemplate = Instance.new("Highlight")
highlightTemplate.Name = "Highlight"
highlightTemplate.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local activeHighlights = {}

-- Function to add ESP to a player
local function AddESPToPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not activeHighlights[player] then
        -- Highlight
        local highlightClone = highlightTemplate:Clone()
        highlightClone.Adornee = player.Character
        highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart")
        activeHighlights[player] = highlightClone

        -- Name tag
        if Settings.ShowNameTags then
            local nameTag = Instance.new("TextLabel")
            nameTag.Size = UDim2.new(0, 100, 0, 50)
            nameTag.Position = UDim2.new(0, -50, 0, -50)  -- Adjust to appear above the player
            nameTag.Text = player.Name
            nameTag.BackgroundTransparency = 1
            nameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameTag.Font = Enum.Font.SourceSans
            nameTag.TextSize = 16
            nameTag.Parent = Camera:FindFirstChild("PlayerGui")
        end

        -- Health bar
        if Settings.ShowHealthBars then
            local healthBar = Instance.new("Frame")
            healthBar.Size = UDim2.new(0, 100, 0, 10)
            healthBar.Position = UDim2.new(0, -50, 0, -40)  -- Position above the character
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            healthBar.Parent = Camera:FindFirstChild("PlayerGui")

            local healthBarOutline = Instance.new("Frame")
            healthBarOutline.Size = UDim2.new(0, 100, 0, 10)
            healthBarOutline.Position = UDim2.new(0, -50, 0, -40)
            healthBarOutline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            healthBarOutline.Parent = Camera:FindFirstChild("PlayerGui")

            -- Update health bar
            player.Character:WaitForChild("Humanoid").HealthChanged:Connect(function(health)
                healthBar.Size = UDim2.new(0, 100 * (health / player.Character.Humanoid.Health), 0, 10)
                if health < player.Character.Humanoid.Health / 2 then
                    healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Change to red if low health
                end
            end)
        end

        -- Distance
        if Settings.ShowDistance then
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(0, 100, 0, 50)
            distanceLabel.Position = UDim2.new(0, -50, 0, -60)  -- Adjust to appear below health bar
            distanceLabel.Text = math.floor((player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m"
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            distanceLabel.Font = Enum.Font.SourceSans
            distanceLabel.TextSize = 16
            distanceLabel.Parent = Camera:FindFirstChild("PlayerGui")
        end
    end
end

-- Function to remove ESP from a player
local function RemoveESPFromPlayer(player)
    if activeHighlights[player] then
        activeHighlights[player]:Destroy()
        activeHighlights[player] = nil
    end
end

-- Function to update ESP
local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            AddESPToPlayer(player)
        end
    end
end

-- Aimbot
local function GetClosestPlayerToCursor()
    local closestPlayer, shortestDistance = nil, Settings.FOVRadius
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            -- Check if the player is on screen and not occluded by walls
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if distance < shortestDistance then
                    -- Check if the player is within the FOV circle
                    local playerPos = Vector2.new(screenPos.X, screenPos.Y)
                    if (playerPos - Vector2.new(Mouse.X, Mouse.Y)).Magnitude <= Settings.FOVRadius then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- FOV Circle (Hollow White Ring)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1  -- Thin white circle
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)  -- White color
FOVCircle.Visible = Settings.FOVCircleVisible  -- Toggle visibility based on the setting
FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)  -- Position at the mouse cursor
FOVCircle.Filled = false  -- Set this to false to make the circle hollow

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)  -- Keep updating the position based on mouse
    FOVCircle.Visible = Settings.FOVCircleVisible  -- Toggle visibility based on the setting
end)

-- Aimbot when right mouse button is pressed
local aimbotMessage = nil  -- Message display object

local function ShowAimbotMessage()
    if not aimbotMessage then
        aimbotMessage = Instance.new("TextLabel")
        aimbotMessage.Size = UDim2.new(0, 300, 0, 50)
        aimbotMessage.Position = UDim2.new(0.5, -150, 0, 20)  -- Position at the top of the screen
        aimbotMessage.Text = "Aimbot locked onto players."
        aimbotMessage.BackgroundTransparency = 1
        aimbotMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
        aimbotMessage.Font = Enum.Font.SourceSansBold
        aimbotMessage.TextSize = 18
        aimbotMessage.TextStrokeTransparency = 0.8
        aimbotMessage.Parent = game:GetService("CoreGui")
    end
end

local function RemoveAimbotMessage()
    if aimbotMessage then
        aimbotMessage:Destroy()
        aimbotMessage = nil
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right Mouse Button
        Settings.AimbotEnabled = true
        ShowAimbotMessage()  -- Show message when aimbot is activated
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right Mouse Button
        Settings.AimbotEnabled = false
        RemoveAimbotMessage()  -- Hide message when aimbot is deactivated
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled then
        local target = GetClosestPlayerToCursor()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- Lock onto the player's head instead of their root part
            local targetHead = target.Character.Head
            Mouse.TargetFilter = target.Character
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)

-- ESP Logic
local function UpdateESP()
    if Settings.ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                AddESPToPlayer(player)
            end
        end
    else
        -- Remove ESP when disabled
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                RemoveESPFromPlayer(player)
            end
        end
    end
end

-- Toggle buttons for ESP, Aimbot, and FOV circle
local ToggleESPButton = Instance.new("TextButton")
ToggleESPButton.Size = UDim2.new(0, 200, 0, 50)
ToggleESPButton.Position = UDim2.new(0, 10, 0, 10)
ToggleESPButton.Text = "Toggle ESP"
ToggleESPButton.Parent = game:GetService("CoreGui")

local ToggleAimbotButton = Instance.new("TextButton")
ToggleAimbotButton.Size = UDim2.new(0, 200, 0, 50)
ToggleAimbotButton.Position = UDim2.new(0, 10, 0, 70)
ToggleAimbotButton.Text = "Toggle Aimbot"
ToggleAimbotButton.Parent = game:GetService("CoreGui")

local ToggleFOVButton = Instance.new("TextButton")
ToggleFOVButton.Size = UDim2.new(0, 200, 0, 50)
ToggleFOVButton.Position = UDim2.new(0, 10, 0, 130)
ToggleFOVButton.Text = "Toggle FOV Circle"
ToggleFOVButton.Parent = game:GetService("CoreGui")

-- Button functionality
ToggleESPButton.MouseButton1Click:Connect(function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    UpdateESP()  -- Update ESP after toggle
end)

ToggleAimbotButton.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    if Settings.AimbotEnabled then
        ShowAimbotMessage()
    else
        RemoveAimbotMessage()
    end
end)

ToggleFOVButton.MouseButton1Click:Connect(function()
    Settings.FOVCircleVisible = not Settings.FOVCircleVisible
end)

-- Call to initial setup
UpdateESP()  -- Initialize ESP for existing players
