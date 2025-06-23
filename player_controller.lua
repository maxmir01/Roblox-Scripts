local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local settings = {
    speed = 16,
    jumpPower = 50,
    fly = false,
    flySpeed = 50,
    noclip = false
}

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerControllerGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.5, -150, 0.5, -125)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "Player Controller"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Speed Control
local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "Speed: " .. settings.speed
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 40)
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = frame

local speedSlider = Instance.new("Slider")
speedSlider.Size = UDim2.new(1, -20, 0, 20)
speedSlider.Position = UDim2.new(0, 10, 0, 65)
speedSlider.MinValue = 0
speedSlider.MaxValue = 100
speedSlider.Value = settings.speed
speedSlider.Parent = frame

speedSlider.Changed:Connect(function(value)
    settings.speed = value
    speedLabel.Text = "Speed: " .. math.floor(value)
    humanoid.WalkSpeed = value
end)

-- Jump Power Control
local jumpLabel = Instance.new("TextLabel")
jumpLabel.Text = "Jump Power: " .. settings.jumpPower
jumpLabel.Size = UDim2.new(1, -20, 0, 20)
jumpLabel.Position = UDim2.new(0, 10, 0, 95)
jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpLabel.Parent = frame

local jumpSlider = Instance.new("Slider")
jumpSlider.Size = UDim2.new(1, -20, 0, 20)
jumpSlider.Position = UDim2.new(0, 10, 0, 120)
jumpSlider.MinValue = 0
jumpSlider.MaxValue = 200
jumpSlider.Value = settings.jumpPower
jumpSlider.Parent = frame

jumpSlider.Changed:Connect(function(value)
    settings.jumpPower = value
    jumpLabel.Text = "Jump Power: " .. math.floor(value)
    humanoid.JumpPower = value
end)

-- Fly Toggle
local flyButton = Instance.new("TextButton")
flyButton.Text = "Fly: OFF"
flyButton.Size = UDim2.new(1, -20, 0, 30)
flyButton.Position = UDim2.new(0, 10, 0, 150)
flyButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.GothamBold
flyButton.Parent = frame

-- Noclip Toggle
local noclipButton = Instance.new("TextButton")
noclipButton.Text = "Noclip: OFF"
noclipButton.Size = UDim2.new(1, -20, 0, 30)
noclipButton.Position = UDim2.new(0, 10, 0, 190)
noclipButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipButton.Font = Enum.Font.GothamBold
noclipButton.Parent = frame

-- Fly Logic
local flyConnection
flyButton.MouseButton1Click:Connect(function()
    settings.fly = not settings.fly
    if settings.fly then
        flyButton.Text = "Fly: ON"
        flyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
        bodyVelocity.Parent = character:FindFirstChild("HumanoidRootPart")
        
        flyConnection = RunService.Stepped:Connect(function()
            if not settings.fly then return end
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            local velocity = root.Velocity
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                bodyVelocity.Velocity = Vector3.new(velocity.X, settings.flySpeed, velocity.Z)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                bodyVelocity.Velocity = Vector3.new(velocity.X, -settings.flySpeed, velocity.Z)
            else
                bodyVelocity.Velocity = Vector3.new(velocity.X, 0, velocity.Z)
            end
        end)
    else
        flyButton.Text = "Fly: OFF"
        flyButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, v in ipairs(root:GetChildren()) do
                if v:IsA("BodyVelocity") then
                    v:Destroy()
                end
            end
        end
    end
end)

-- Noclip Logic
local noclipConnection
noclipButton.MouseButton1Click:Connect(function()
    settings.noclip = not settings.noclip
    if settings.noclip then
        noclipButton.Text = "Noclip: ON"
        noclipButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        noclipConnection = RunService.Stepped:Connect(function()
            if not settings.noclip then return end
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        noclipButton.Text = "Noclip: OFF"
        noclipButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end)

-- Apply initial settings
humanoid.WalkSpeed = settings.speed
humanoid.JumpPower = settings.jumpPower

-- Make GUI draggable
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Character handling
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    humanoid.WalkSpeed = settings.speed
    humanoid.JumpPower = settings.jumpPower
end)

print("Universal Player Controller loaded successfully!")
