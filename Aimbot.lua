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
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            AddESPToPlayer(player)
        end
    end
end

-- GUI (For toggling ESP settings)
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 250, 0, 300)
MenuFrame.Position = UDim2.new(1, -260, 0.5, -150)
MenuFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MenuFrame.BackgroundTransparency = 0.8

local Title = Instance.new("TextLabel", MenuFrame)
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.Text = "ESP & Aimbot Settings"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSans
Title.TextSize = 18

local ToggleESPButton = Instance.new("TextButton", MenuFrame)
ToggleESPButton.Size = UDim2.new(1, 0, 0.2, 0)
ToggleESPButton.Position = UDim2.new(0, 0, 0.25, 0)
ToggleESPButton.Text = "Toggle ESP"
ToggleESPButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleESPButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleESPButton.Font = Enum.Font.SourceSans
ToggleESPButton.TextSize = 16

local ToggleAimbotButton = Instance.new("TextButton", MenuFrame)
ToggleAimbotButton.Size = UDim2.new(1, 0, 0.2, 0)
ToggleAimbotButton.Position = UDim2.new(0, 0, 0.5, 0)
ToggleAimbotButton.Text = "Toggle Aimbot"
ToggleAimbotButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleAimbotButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleAimbotButton.Font = Enum.Font.SourceSans
ToggleAimbotButton.TextSize = 16

-- Button to toggle ESP
ToggleESPButton.MouseButton1Click:Connect(function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    if Settings.ESPEnabled then
        UpdateESP()
    end
end)

-- Button to toggle Aimbot
ToggleAimbotButton.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    if Settings.AimbotEnabled then
        ShowAimbotMessage()
    else
        RemoveAimbotMessage()
    end
end)
