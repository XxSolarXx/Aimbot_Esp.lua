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
    FOVCircleVisible = true
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
FOVCircle.Visible = Settings.FOVCircleVisible
FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
FOVCircle.Filled = false  -- Set this to false to make the circle hollow

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Visible = Settings.FOVCircleVisible
end)

-- Aimbot Logic (Visibility Check)
local function IsPlayerVisible(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local playerRootPart = player.Character.HumanoidRootPart
        local camera = workspace.CurrentCamera
        local _, onScreen = camera:WorldToViewportPoint(playerRootPart.Position)
        if onScreen then
            -- Raycast from camera to player's root part to check visibility
            local ray = Ray.new(camera.CFrame.Position, playerRootPart.Position - camera.CFrame.Position)
            local hit, position = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
            -- Check if the ray hit something other than the player's character
            if not hit or hit.Parent == player.Character then
                return true  -- Player is visible
            end
        end
    end
    return false  -- Player is not visible
end

-- Aimbot when right mouse button is pressed
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right Mouse Button
        Settings.AimbotEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right Mouse Button
        Settings.AimbotEnabled = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled then
        local target = GetClosestPlayerToCursor()
        if target and IsPlayerVisible(target) and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Mouse.TargetFilter = target.Character
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 300, 0, 400)
MenuFrame.Position = UDim2.new(1, -320, 0.5, -200)
MenuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MenuFrame.BackgroundTransparency = 0.8
MenuFrame.BorderSizePixel = 0
MenuFrame.ClipsDescendants = true
MenuFrame.AnchorPoint = Vector2.new(1, 0.5)

-- Title
local Title = Instance.new("TextLabel", MenuFrame)
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.Text = "ESP & Aimbot"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextStrokeTransparency = 0.6
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Button Styling
local function createStyledButton(text, size, position, callback)
    local button = Instance.new("TextButton", MenuFrame)
    button.Size = size
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.Font = Enum.Font.Gotham
    button.TextSize = 18
    button.BorderRadius = UDim.new(0, 12)
    button.BorderSizePixel = 0
    button.BackgroundTransparency = 0.2
    button.TextStrokeTransparency = 0.8
    button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    -- Hover Effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Create Buttons
local ToggleESPButton = createStyledButton("Toggle ESP", UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.25, 0), function()
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

local ToggleAimbotButton = createStyledButton("Toggle Aimbot", UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.5, 0), function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    ToggleAimbotButton.Text = Settings.AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

local ToggleFOVButton = createStyledButton("Toggle FOV Circle", UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.75, 0), function()
    Settings.FOVCircleVisible = not Settings.FOVCircleVisible
    ToggleFOVButton.Text = Settings.FOVCircleVisible and "FOV: ON" or "FOV: OFF"
end)

-- Add all elements to the GUI
ScreenGui.Parent = game.CoreGui
