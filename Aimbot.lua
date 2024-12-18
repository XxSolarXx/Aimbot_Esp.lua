local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ESP Settings
_G.ESPEnabled = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 200, 0, 200)
MenuFrame.Position = UDim2.new(1, -210, 1, -210)
MenuFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MenuFrame.BackgroundTransparency = 0.8
MenuFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MenuFrame)
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "ESP Menu"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSans
Title.TextSize = 18

local ToggleESPButton = Instance.new("TextButton", MenuFrame)
ToggleESPButton.Size = UDim2.new(1, 0, 0.2, 0)
ToggleESPButton.Position = UDim2.new(0, 0, 0.3, 0)
ToggleESPButton.Text = "Toggle ESP"
ToggleESPButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleESPButton.BackgroundTransparency = 0.8
ToggleESPButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleESPButton.Font = Enum.Font.SourceSans
ToggleESPButton.TextSize = 16

local InfoLabel = Instance.new("TextLabel", MenuFrame)
InfoLabel.Size = UDim2.new(1, 0, 0.2, 0)
InfoLabel.Position = UDim2.new(0, 0, 0.6, 0)
InfoLabel.Text = "Join Discord: discord.gg/3SdU5hsAyJ"
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 14

-- ESP Functionality
local highlightTemplate = Instance.new("Highlight")
highlightTemplate.Name = "Highlight"
highlightTemplate.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local function AddHighlightToPlayer(player)
    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
        local highlightClone = highlightTemplate:Clone()
        highlightClone.Adornee = player.Character
        highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart")
    end
end

local function RemoveHighlightFromPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local highlight = player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight")
        if highlight then
            highlight:Destroy()
        end
    end
end

local function ToggleESP()
    if _G.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                AddHighlightToPlayer(player)
            end
        end

        Players.PlayerAdded:Connect(function(player)
            AddHighlightToPlayer(player)
        end)

        Players.PlayerRemoving:Connect(function(player)
            RemoveHighlightFromPlayer(player)
        end)

        RunService.Heartbeat:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    AddHighlightToPlayer(player)
                end
            end
        end)
    else
        for _, player in pairs(Players:GetPlayers()) do
            RemoveHighlightFromPlayer(player)
        end
    end
end

-- Toggle ESP Button Functionality
ToggleESPButton.MouseButton1Click:Connect(function()
    _G.ESPEnabled = not _G.ESPEnabled
    ToggleESP()
    ToggleESPButton.Text = _G.ESPEnabled and "ESP ON" or "ESP OFF"
end)
