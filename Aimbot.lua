local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    ESPEnabled = false,
    AimbotEnabled = false,
    FOVRadius = 100,  -- Smaller FOV circle radius
    FOVCircleVisible = true,  -- Start with FOV Circle visible
}

-- ESP
local highlightTemplate = Instance.new("Highlight")
highlightTemplate.Name = "Highlight"
highlightTemplate.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local activeHighlights = {}

local function AddHighlightToPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not activeHighlights[player] then
        local highlightClone = highlightTemplate:Clone()
        highlightClone.Adornee = player.Character
        highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart")
        activeHighlights[player] = highlightClone
    end
end

local function RemoveHighlightFromPlayer(player)
    if activeHighlights[player] then
        activeHighlights[player]:Destroy()
        activeHighlights[player] = nil
    end
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            AddHighlightToPlayer(player)
        end
    end
end

-- Aimbot
local function GetClosestPlayerToCursor()
    local closestPlayer, shortestDistance = nil, Settings.FOVRadius
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
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
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetHead.Position)
        end
    end
end)

-- ESP Logic
local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            AddHighlightToPlayer(player)
        end
    end
end

-- GUI
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

local ToggleFOVButton = Instance.new("TextButton", MenuFrame)
ToggleFOVButton.Size = UDim2.new(1, 0, 0.2, 0)
ToggleFOVButton.Position = UDim2.new(0, 0, 0.75, 0)
ToggleFOVButton.Text = "Toggle FOV Circle"
ToggleFOVButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleFOVButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleFOVButton.Font = Enum.Font.SourceSans
ToggleFOVButton.TextSize = 16

-- Button Functions
ToggleESPButton.MouseButton1Click:Connect(function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    ToggleESPButton.Text = Settings.ESPEnabled and "ESP: ON" or "ESP: OFF"
    if Settings.ESPEnabled then
        UpdateESP()
    else
        for player, _ in pairs(activeHighlights) do
            RemoveHighlightFromPlayer(player)
        end
    end
end)

ToggleAimbotButton.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    ToggleAimbotButton.Text = Settings.AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

ToggleFOVButton.MouseButton1Click:Connect(function()
    Settings.FOVCircleVisible = not Settings.FOVCircleVisible
    ToggleFOVButton.Text = Settings.FOVCircleVisible and "FOV: ON" or "FOV: OFF"
end)

-- Fix to prevent the GUI from disappearing unexpectedly
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.Enabled = true  -- Ensure the GUI is always enabled unless manually disabled
