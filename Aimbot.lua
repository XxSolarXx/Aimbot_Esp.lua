local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Settings = {
    ESPEnabled = false,
    AimbotEnabled = false,
    FOVRadius = 100,
    FOVCircleVisible = true,
    ShowNameTags = true,
    ShowHealthBars = true,
    ShowDistance = true,
    ESPColor = Color3.fromRGB(0, 255, 0),
}

local ExcludedPlayers = {
    "Player1", -- Replace with the player names you want to exclude from the aimbot
    "Player2", -- Add more player names here as needed
}

local highlightTemplate = Instance.new("Highlight")
highlightTemplate.Name = "Highlight"
highlightTemplate.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local activeHighlights = {}

local function AddESPToPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not activeHighlights[player] then
        local highlightClone = highlightTemplate:Clone()
        highlightClone.Adornee = player.Character
        highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart")
        activeHighlights[player] = highlightClone

        if Settings.ShowNameTags then
            local nameTag = Instance.new("TextLabel")
            nameTag.Size = UDim2.new(0, 100, 0, 50)
            nameTag.Position = UDim2.new(0, -50, 0, -50)
            nameTag.Text = player.Name
            nameTag.BackgroundTransparency = 1
            nameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameTag.Font = Enum.Font.SourceSans
            nameTag.TextSize = 16
            nameTag.Parent = Camera:FindFirstChild("PlayerGui")
        end

        if Settings.ShowHealthBars then
            local healthBar = Instance.new("Frame")
            healthBar.Size = UDim2.new(0, 100, 0, 10)
            healthBar.Position = UDim2.new(0, -50, 0, -40)
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            healthBar.Parent = Camera:FindFirstChild("PlayerGui")

            local healthBarOutline = Instance.new("Frame")
            healthBarOutline.Size = UDim2.new(0, 100, 0, 10)
            healthBarOutline.Position = UDim2.new(0, -50, 0, -40)
            healthBarOutline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            healthBarOutline.Parent = Camera:FindFirstChild("PlayerGui")

            player.Character:WaitForChild("Humanoid").HealthChanged:Connect(function(health)
                healthBar.Size = UDim2.new(0, 100 * (health / player.Character.Humanoid.Health), 0, 10)
                if health < player.Character.Humanoid.Health / 2 then
                    healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
            end)
        end

        if Settings.ShowDistance then
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(0, 100, 0, 50)
            distanceLabel.Position = UDim2.new(0, -50, 0, -60)
            distanceLabel.Text = math.floor((player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m"
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            distanceLabel.Font = Enum.Font.SourceSans
            distanceLabel.TextSize = 16
            distanceLabel.Parent = Camera:FindFirstChild("PlayerGui")
        end
    end
end

local function RemoveESPFromPlayer(player)
    if activeHighlights[player] then
        activeHighlights[player]:Destroy()
        activeHighlights[player] = nil
    end
end

local function UpdateESP()
    if Settings.ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                AddESPToPlayer(player)
            end
        end
    else
        for player, highlight in pairs(activeHighlights) do
            RemoveESPFromPlayer(player)
        end
    end
end

local function GetClosestPlayerToCursor()
    local closestPlayer, shortestDistance = nil, Settings.FOVRadius
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen and not table.find(ExcludedPlayers, player.Name) then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if distance < shortestDistance then
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

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = Settings.FOVCircleVisible
FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Visible = Settings.FOVCircleVisible
end)

local aimbotMessage = nil

local function ShowAimbotMessage()
    if not aimbotMessage then
        aimbotMessage = Instance.new("TextLabel")
        aimbotMessage.Size = UDim2.new(0, 300, 0, 50)
        aimbotMessage.Position = UDim2.new(0.5, -150, 0, 20)
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

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.AimbotEnabled = true
        ShowAimbotMessage()
    end

    if input.KeyCode == Enum.KeyCode.F2 then
        screenGui.Enabled = false
    elseif input.KeyCode == Enum.KeyCode.F1 then
        screenGui.Enabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.AimbotEnabled = false
        RemoveAimbotMessage()
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled then
        local target = GetClosestPlayerToCursor()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetHead = target.Character.Head
            local targetPos = targetHead.Position
            local cameraPos = Camera.CFrame.Position
            local direction = (targetPos - cameraPos).unit
            local newCFrame = CFrame.lookAt(cameraPos, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.2)  -- Increased speed of lock-on
        end
    end
end)

-- GUI and Moveable Code Start Here

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui")
screenGui.Enabled = true

local ToggleESPButton = Instance.new("TextButton")
ToggleESPButton.Size = UDim2.new(0, 200, 0, 50)
ToggleESPButton.Position = UDim2.new(0, 10, 0, 10)
ToggleESPButton.Text = "Toggle ESP - Off"
ToggleESPButton.Parent = screenGui

local ToggleAimbotButton = Instance.new("TextButton")
ToggleAimbotButton.Size = UDim2.new(0, 200, 0, 50)
ToggleAimbotButton.Position = UDim2.new(0, 10, 0, 70)
ToggleAimbotButton.Text = "Toggle Aimbot - Off"
ToggleAimbotButton.Parent = screenGui

local ToggleFOVButton = Instance.new("TextButton")
ToggleFOVButton.Size = UDim2.new(0, 200, 0, 50)
ToggleFOVButton.Position = UDim2.new(0, 10, 0, 130)
ToggleFOVButton.Text = "Toggle FOV Circle - Off"
ToggleFOVButton.Parent = screenGui

-- Add drag feature to GUI
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    screenGui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ToggleESPButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = screenGui.Position
        input.Changed:Connect(function()
            if dragging then
                update(input)
            end
        end)
    end
end)

ToggleESPButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
