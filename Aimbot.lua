local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Holding = false

_G.AimbotEnabled = true
_G.TeamCheck = false
_G.AimPart = "Head"
_G.Sensitivity = 0

_G.CircleSides = 64
_G.CircleColor = Color3.fromRGB(255, 255, 255)
_G.CircleTransparency = 0.7
_G.CircleRadius = 80
_G.CircleFilled = false
_G.CircleVisible = true
_G.CircleThickness = 0

_G.ESPEnabled = true
_G.ESPLineColor = Color3.fromRGB(255, 0, 0)
_G.ESPLineThickness = 2

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = _G.CircleRadius
FOVCircle.Filled = _G.CircleFilled
FOVCircle.Color = _G.CircleColor
FOVCircle.Visible = _G.CircleVisible
FOVCircle.Transparency = _G.CircleTransparency
FOVCircle.NumSides = _G.CircleSides
FOVCircle.Thickness = _G.CircleThickness

-- Create GUI elements
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 200, 0, 100)
MenuFrame.Position = UDim2.new(0, 10, 0, 10)
MenuFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MenuFrame.BackgroundTransparency = 0.5

local ShowFovButton = Instance.new("TextButton", MenuFrame)
ShowFovButton.Size = UDim2.new(1, 0, 0.5, 0)
ShowFovButton.Position = UDim2.new(0, 0, 0, 0)
ShowFovButton.Text = "Show FOV Circle"
ShowFovButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ShowFovButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ShowFovButton.MouseButton1Click:Connect(function()
    _G.CircleVisible = not _G.CircleVisible
end)

local ToggleAimbotButton = Instance.new("TextButton", MenuFrame)
ToggleAimbotButton.Size = UDim2.new(1, 0, 0.5, 0)
ToggleAimbotButton.Position = UDim2.new(0, 0, 0.5, 0)
ToggleAimbotButton.Text = "Toggle Aimbot"
ToggleAimbotButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleAimbotButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleAimbotButton.MouseButton1Click:Connect(function()
    _G.AimbotEnabled = not _G.AimbotEnabled
end)

-- Skeleton ESP Drawing Function
local function DrawSkeletonESP(player)
    -- Ensure player has a character and humanoid
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

        -- Ensure the humanoid and root part exist before drawing
        if humanoid and rootPart then
            -- Get the screen position of the HumanoidRootPart and other key parts
            local head = player.Character:FindFirstChild("Head")
            local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
            local leftLeg = player.Character:FindFirstChild("LeftLeg")
            local rightLeg = player.Character:FindFirstChild("RightLeg")
            local leftArm = player.Character:FindFirstChild("LeftArm")
            local rightArm = player.Character:FindFirstChild("RightArm")

            if head and torso and leftLeg and rightLeg and leftArm and rightArm then
                -- Get all the positions for the extremities
                local positions = {
                    head.Position, 
                    torso.Position, 
                    leftLeg.Position, 
                    rightLeg.Position, 
                    leftArm.Position, 
                    rightArm.Position
                }

                local screenPositions = {}
                for _, pos in ipairs(positions) do
                    table.insert(screenPositions, Camera:WorldToViewportPoint(pos))
                end

                -- Draw lines between body parts to form a skeleton
                local function drawLine(from, to)
                    local line = Drawing.new("Line")
                    line.From = from
                    line.To = to
                    line.Color = _G.ESPLineColor
                    line.Thickness = _G.ESPLineThickness
                    line.Visible = _G.ESPEnabled
                end

                -- Draw skeleton lines (torso to arms, legs, and head)
                drawLine(screenPositions[1], screenPositions[2])  -- Head to Torso
                drawLine(screenPositions[2], screenPositions[3])  -- Torso to Left Leg
                drawLine(screenPositions[2], screenPositions[4])  -- Torso to Right Leg
                drawLine(screenPositions[2], screenPositions[5])  -- Torso to Left Arm
                drawLine(screenPositions[2], screenPositions[6])  -- Torso to Right Arm
                drawLine(screenPositions[5], screenPositions[1])  -- Left Arm to Head
                drawLine(screenPositions[6], screenPositions[1])  -- Right Arm to Head
            end
        end
    end
end

-- Aimbot and FOV circle logic
local function GetClosestPlayer()
    local MaximumDistance = _G.CircleRadius
    local Target = nil

    for _, v in next, Players:GetPlayers() do
        if v.Name ~= LocalPlayer.Name then
            if _G.TeamCheck == true then
                if v.Team ~= LocalPlayer.Team then
                    if v.Character ~= nil then
                        if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                            if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
                                local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                                local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                                
                                if VectorDistance < MaximumDistance then
                                    Target = v
                                end
                            end
                        end
                    end
                end
            else
                if v.Character ~= nil then
                    if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                        if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
                            local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                            local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                            
                            if VectorDistance < MaximumDistance then
                                Target = v
                            end
                        end
                    end
                end
            end
        end
    end

    return Target
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    FOVCircle.Radius = _G.CircleRadius
    FOVCircle.Filled = _G.CircleFilled
    FOVCircle.Color = _G.CircleColor
    FOVCircle.Visible = _G.CircleVisible
    FOVCircle.Radius = _G.CircleRadius
    FOVCircle.Transparency = _G.CircleTransparency
    FOVCircle.NumSides = _G.CircleSides
    FOVCircle.Thickness = _G.CircleThickness

    -- ESP update
    if _G.ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                DrawSkeletonESP(player)
            end
        end
    end

    if Holding == true and _G.AimbotEnabled == true then
        -- Aimbot locks to the closest player’s head within the FOV circle
        local target = nil
        if _G.CircleVisible then
            target = GetClosestPlayer()
        end
        
        if target then
            local aimPart = target.Character[_G.AimPart]
            if aimPart then
                TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Linear), {CFrame = CFrame.new(aimPart.Position)}):Play()
            end
        end
    end
end)
