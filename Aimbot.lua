local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

_G.AimbotEnabled = false -- Start with aimbot disabled
_G.TeamCheck = false
_G.AimPart = "Head"
_G.Sensitivity = 0

_G.CircleSides = 64
_G.CircleColor = Color3.fromRGB(255, 255, 255)
_G.CircleTransparency = 0.7
_G.CircleRadius = 80
_G.CircleFilled = false
_G.CircleVisible = false -- Start with FOV circle hidden
_G.CircleThickness = 0

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = _G.CircleRadius
FOVCircle.Filled = _G.CircleFilled
FOVCircle.Color = _G.CircleColor
FOVCircle.Visible = _G.CircleVisible
FOVCircle.Radius = _G.CircleRadius
FOVCircle.Transparency = _G.CircleTransparency
FOVCircle.NumSides = _G.CircleSides
FOVCircle.Thickness = _G.CircleThickness

-- Create GUI elements
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 250, 0, 200)
MenuFrame.Position = UDim2.new(0, 10, 0, 10)
MenuFrame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
MenuFrame.BackgroundTransparency = 0.7
MenuFrame.BorderSizePixel = 0
MenuFrame.Active = true
MenuFrame.Selectable = true

-- Make the frame draggable
local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	MenuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MenuFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MenuFrame.Position
		input.Changed:Connect(function()
			if dragging == false then
				return
			end
		end)
	end
end)

MenuFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

RunService.Heartbeat:Connect(function()
	if dragging then
		updateDrag(UserInputService:GetMouseLocation())
	end
end)

-- Create Title for the Menu
local Title = Instance.new("TextLabel", MenuFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "Aimbot & FOV Settings"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.BackgroundTransparency = 0.5
Title.TextSize = 18
Title.TextAlign = Enum.TextAlign.Center

-- Create Show FOV Circle button
local ShowFovButton = Instance.new("TextButton", MenuFrame)
ShowFovButton.Size = UDim2.new(1, 0, 0.4, 0)
ShowFovButton.Position = UDim2.new(0, 0, 0.25, 0)
ShowFovButton.Text = "Show FOV Circle"
ShowFovButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ShowFovButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowFovButton.TextSize = 14
ShowFovButton.TextButtonMode = Enum.ButtonMode.Toggle
ShowFovButton.MouseButton1Click:Connect(function()
    _G.CircleVisible = not _G.CircleVisible -- Toggle visibility of the FOV circle
    FOVCircle.Visible = _G.CircleVisible
end)
ShowFovButton.MouseEnter:Connect(function()
    ShowFovButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)
ShowFovButton.MouseLeave:Connect(function()
    ShowFovButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

-- Create Toggle Aimbot button
local ToggleAimbotButton = Instance.new("TextButton", MenuFrame)
ToggleAimbotButton.Size = UDim2.new(1, 0, 0.4, 0)
ToggleAimbotButton.Position = UDim2.new(0, 0, 0.65, 0)
ToggleAimbotButton.Text = "Toggle Aimbot"
ToggleAimbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleAimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleAimbotButton.TextSize = 14
ToggleAimbotButton.TextButtonMode = Enum.ButtonMode.Toggle
ToggleAimbotButton.MouseButton1Click:Connect(function()
    _G.AimbotEnabled = not _G.AimbotEnabled -- Toggle the aimbot functionality
end)
ToggleAimbotButton.MouseEnter:Connect(function()
    ToggleAimbotButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)
ToggleAimbotButton.MouseLeave:Connect(function()
    ToggleAimbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

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

    if Holding == true and _G.AimbotEnabled == true then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(_G.AimPart) then
            TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, target.Character[_G.AimPart].Position)}):Play()
        end
    end
end)
