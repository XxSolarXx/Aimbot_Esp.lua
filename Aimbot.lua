print("Aimbot And Esp Loading...")
print("Aimbot And Esp Loaded! Have fun.")
print("This was made by ytz_solar on discord add him!")
print("join the discord: discord.gg/getpluto")
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
    AimbotSmoothness = 0.18,
}

local ExcludedPlayers = {
    "PlutoExecutor94_UNC",
    "Player2",
}

local highlightTemplate = Instance.new("Highlight")
highlightTemplate.Name = "Highlight"
highlightTemplate.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local activeHighlights = {}

local function calculateDistance(player)
    return math.floor((player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
end

local function createPlayerBox(player)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 100, 0, 100)
    box.Position = UDim2.new(0.5, -50, 0, -50)
    box.BackgroundTransparency = 0.5
    box.BorderColor3 = Color3.fromRGB(255, 255, 255)
    box.BorderSizePixel = 2
    box.Parent = Camera:FindFirstChild("PlayerGui")
    return box
end

local function AddESPToPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not activeHighlights[player] then
        local highlightClone = highlightTemplate:Clone()
        highlightClone.Adornee = player.Character
        highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart")
        highlightClone.FillColor = Settings.ESPColor
        highlightClone.OutlineColor = Color3.fromRGB(255, 255, 255)
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
            distanceLabel.Text = calculateDistance(player) .. "m"
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

-- Get closest player to cursor
local function GetClosestPlayerToCursor()
    local closestPlayer, shortestDistance = nil, Settings.FOVRadius
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen and not table.find(ExcludedPlayers, player.Name) then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

Settings.FOVRadius = Settings.FOVRadius * 0.65

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = Settings.FOVCircleVisible
FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 50)
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
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Settings.AimbotSmoothness)  -- Increased smoothness
        end
    end
end)

-- Screen GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui")
screenGui.Enabled = true

-- Button styling
local function createButton(text, posX, posY)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(1, -220, 0, posY)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 18
    button.TextStrokeTransparency = 0.8
    button.Parent = screenGui

    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    return button
end

local ToggleESPButton = createButton("Toggle ESP - Off", 10, 10)
local ToggleAimbotButton = createButton("Toggle Aimbot - Off", 10, 70)
local ToggleFOVButton = createButton("Toggle FOV - On", 10, 130)
local KillGUIButton = createButton("Kill GUI", 10, 190)

ToggleESPButton.MouseButton1Click:Connect(function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    ToggleESPButton.Text = Settings.ESPEnabled and "Toggle ESP - On" or "Toggle ESP - Off"
    UpdateESP()
end)

ToggleAimbotButton.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    ToggleAimbotButton.Text = Settings.AimbotEnabled and "Toggle Aimbot - On" or "Toggle Aimbot - Off"
end)

ToggleFOVButton.MouseButton1Click:Connect(function()
    Settings.FOVCircleVisible = not Settings.FOVCircleVisible
    ToggleFOVButton.Text = Settings.FOVCircleVisible and "Toggle FOV - On" or "Toggle FOV - Off"
end)

KillGUIButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)
