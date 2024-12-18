-- Roblox Aimbot, ESP, FOV, and Settings (Full Expanded Version)

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ESPEnabled = false
local AimbotEnabled = false
local CircleVisible = false
local WallCheckEnabled = true
local FOVSize = 100
local FOVColor = Color3.fromRGB(0, 255, 0)
local ESPBoxColor = Color3.fromRGB(255, 0, 0)
local AimbotTarget = "Head" -- Default aimbot target
local FOVCircle = nil
local ESPDrawings = {}

-- Settings for GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 250, 0, 400)
MenuFrame.Position = UDim2.new(1, -270, 0, 50)
MenuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MenuFrame.BackgroundTransparency = 0.8
MenuFrame.Active = true -- Allow the menu to be draggable

-- Add drag functionality to the menu
local dragStart, dragInput, dragDelta
local function onDragStart(input)
	dragStart = input.Position
end

local function onDrag(input)
	dragDelta = input.Position - dragStart
	MenuFrame.Position = UDim2.new(MenuFrame.Position.X.Scale, MenuFrame.Position.X.Offset + dragDelta.X, MenuFrame.Position.Y.Scale, MenuFrame.Position.Y.Offset + dragDelta.Y)
end

local function onDragEnd()
	dragStart = nil
	dragInput = nil
	dragDelta = nil
end

MenuFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		onDragStart(input)
	end
end)

MenuFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		onDrag(input)
	end
end)

MenuFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		onDragEnd()
	end
end)

-- Show FOV Button
local ShowFovButton = Instance.new("TextButton", MenuFrame)
ShowFovButton.Size = UDim2.new(1, 0, 0.2, 0)
ShowFovButton.Position = UDim2.new(0, 0, 0, 0)
ShowFovButton.Text = "Toggle FOV Circle"
ShowFovButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ShowFovButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowFovButton.MouseButton1Click:Connect(function()
    CircleVisible = not CircleVisible
end)

-- Toggle Aimbot Button
local ToggleAimbotButton = Instance.new("TextButton", MenuFrame)
ToggleAimbotButton.Size = UDim2.new(1, 0, 0.2, 0)
ToggleAimbotButton.Position = UDim2.new(0, 0, 0.2, 0)
ToggleAimbotButton.Text = "Toggle Aimbot"
ToggleAimbotButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleAimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleAimbotButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        ToggleAimbotButton.Text = "Aimbot Enabled"
    else
        ToggleAimbotButton.Text = "Aimbot Disabled"
    end
end)

-- Toggle ESP Button
local ToggleESPButton = Instance.new("TextButton", MenuFrame)
ToggleESPButton.Size = UDim2.new(1, 0, 0.2, 0)
ToggleESPButton.Position = UDim2.new(0, 0, 0.4, 0)
ToggleESPButton.Text = "Toggle ESP"
ToggleESPButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleESPButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        ToggleESPButton.Text = "ESP Enabled"
    else
        ToggleESPButton.Text = "ESP Disabled"
    end
end)

-- Settings for FOV Size and Color
local FOVSizeSlider = Instance.new("TextButton", MenuFrame)
FOVSizeSlider.Size = UDim2.new(1, 0, 0.2, 0)
FOVSizeSlider.Position = UDim2.new(0, 0, 0.6, 0)
FOVSizeSlider.Text = "Increase FOV"
FOVSizeSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
FOVSizeSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVSizeSlider.MouseButton1Click:Connect(function()
    FOVSize = FOVSize + 10
    if FOVCircle then
        FOVCircle.Radius = FOVSize
    end
end)

-- Create FOV Circle for Aimbot
local function CreateFOVCircle()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Radius = FOVSize
    FOVCircle.Color = FOVColor
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
end

-- Create ESP box and highlight players
local function CreateESP(player)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return end
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    -- Create the ESP box
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESPBoxColor
    box.Thickness = 2
    box.Filled = false
    ESPDrawings[player] = box
end

-- Update ESP boxes based on player position
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local box = ESPDrawings[player]
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
            if onScreen then
                box.Visible = true
                local size = (Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, 5, 0))).Y - screenPos.Y
                box.Size = Vector2.new(50, size)
                box.Position = Vector2.new(screenPos.X - box.Size.X / 2, screenPos.Y - box.Size.Y / 2)
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end

-- Wall Check for Aimbot
local function WallCheck(targetPos)
    if WallCheckEnabled then
        local ray = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).unit * (targetPos - Camera.CFrame.Position).Magnitude)
        local hitPart = workspace:FindPartOnRay(ray, LocalPlayer.Character)
        if hitPart and not hitPart:IsDescendantOf(LocalPlayer.Character) then
            return false
        end
    end
    return true
end

-- Aimbot Logic
local function Aimbot()
    while AimbotEnabled do
        local closestPlayer = nil
        local closestDistance = FOVSize
        local targetPos = nil

        -- Find the closest player within FOV
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local bodyPart = player.Character:FindFirstChild(AimbotTarget)
                if bodyPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(bodyPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if distance < closestDistance then
                            if WallCheck(bodyPart.Position) then
                                closestPlayer = player
                                closestDistance = distance
                                targetPos = bodyPart.Position
                            end
                        end
                    end
                end
            end
        end

        -- Lock onto target if one is found
        if closestPlayer and targetPos then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end

        wait(0.05) -- Update every frame
    end
end

-- Render the FOV Circle
local function RenderFOVCircle()
    if CircleVisible and FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end

-- Event listener for ESP and Aimbot
RunService.Heartbeat:Connect(function()
    UpdateESP()
    RenderFOVCircle()

    if AimbotEnabled then
        Aimbot()
    end
end)

-- Event listener for player joining and leaving
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPDrawings[player] then
        ESPDrawings[player].Visible = false
        ESPDrawings[player] = nil
    end
end)

-- Initialize FOV Circle
CreateFOVCircle()

-- Create a simple toggle menu for settings
ScreenGui.Parent = game:GetService("CoreGui")
