--[[
    OG SABER SIMULATOR - MAXMIR HUB
    by MaxMir | v1.0
]]

local player = game.Players.LocalPlayer
local states = {autoSwing = true, autoSell = false, autoBuySabers = false, autoBuyDNA = false, bossPuller = true, heartCollector = true, bringAndKill = false, reduceLags = true}
local connections = {}
local heartCount = 0
local guiHidden = false
local sellCooldown = 0
local buySabersCooldown = 0
local buyDNACooldown = 0
local trackedBosses = {}

-- Auto Swing
local function autoSwingFunc()
    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
end

-- Auto Sell
local function autoSellFunc()
    if tick() - sellCooldown < 0.3 then return end
    sellCooldown = tick()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local zones = workspace:FindFirstChild("Zones")
    if not zones then return end
    local sellFolder = zones:FindFirstChild("Sell")
    if not sellFolder then return end
    for _, part in pairs(sellFolder:GetChildren()) do
        if part:IsA("BasePart") then
            local savedPos = root.CFrame
            root.CFrame = part.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.1)
            root.CFrame = savedPos
            return
        end
    end
end

-- Клик по вкладке
local function clickTab(btnName)
    local gui = player.PlayerGui
    local btn = gui:FindFirstChild(btnName, true)
    if btn and btn.Visible then
        pcall(function() firesignal(btn.MouseButton1Click) end)
        pcall(function() firesignal(btn.Activated) end)
        return true
    end
    return false
end

-- Клик по Buy All
local function clickBuyAll()
    local gui = player.PlayerGui
    local btn = gui:FindFirstChild("BuyAll_Btn", true)
    if btn and btn.Visible then
        local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(pos.X + 30, pos.Y + 50, 0, true, game, 1)
        task.wait(0.02)
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(pos.X + 30, pos.Y + 50, 0, false, game, 1)
        return true
    end
    return false
end

-- Auto Buy Sabers
local function autoBuySabersFunc()
    if tick() - buySabersCooldown < 2 then return end
    buySabersCooldown = tick()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local zones = workspace:FindFirstChild("Zones")
    if not zones then return end
    local shopFolder = zones:FindFirstChild("Shop")
    if not shopFolder then return end
    for _, part in pairs(shopFolder:GetChildren()) do
        if part:IsA("BasePart") then
            local savedPos = root.CFrame
            root.CFrame = part.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.3)
            clickTab("SaberList_Btn")
            task.wait(0.3)
            clickBuyAll()
            task.wait(0.2)
            root.CFrame = savedPos
            return
        end
    end
end

-- Auto Buy DNA
local function autoBuyDNAFunc()
    if tick() - buyDNACooldown < 2 then return end
    buyDNACooldown = tick()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local zones = workspace:FindFirstChild("Zones")
    if not zones then return end
    local shopFolder = zones:FindFirstChild("Shop")
    if not shopFolder then return end
    for _, part in pairs(shopFolder:GetChildren()) do
        if part:IsA("BasePart") then
            local savedPos = root.CFrame
            root.CFrame = part.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.3)
            clickTab("DNAList_Btn")
            task.wait(0.3)
            clickBuyAll()
            task.wait(0.2)
            root.CFrame = savedPos
            return
        end
    end
end

-- Boss Puller
local function bossPullerFunc()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local folder = workspace:FindFirstChild("Boss")
    if not folder then return end
    local names = {"Galactic Skeleton", "Dummy", "The Doombringer", "Noob", "Bunny", "Heart Lover", "Galactic Overload"}
    for _, obj in pairs(folder:GetDescendants()) do
        if obj:IsA("Model") then
            for _, n in pairs(names) do
                if obj.Name == n then
                    local bp = obj:FindFirstChild("HumanoidRootPart")
                    local hum = obj:FindFirstChild("Humanoid")
                    if bp and hum and hum.Health > 0 then
                        if not trackedBosses[obj] then
                            trackedBosses[obj] = true
                            root.CFrame = bp.CFrame * CFrame.new(0, 0, 5)
                        end
                        pcall(function() bp:SetNetworkOwner(player) end)
                        pcall(function() bp.CFrame = root.CFrame * CFrame.new(0, 0, 5) bp.Velocity = Vector3.zero end)
                    end
                end
            end
        end
    end
    for boss, _ in pairs(trackedBosses) do
        if not boss.Parent then trackedBosses[boss] = nil end
    end
end

-- Heart Collector
local function heartCollectorFunc()
    local char = player.Character
    if not char then return 0 end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return 0 end
    local objectives = workspace.Map:FindFirstChild("Objectives")
    if not objectives then return 0 end
    local c = 0
    for _, obj in pairs(objectives:GetChildren()) do
        if obj.Name == "Heart" and obj:IsA("BasePart") then
            pcall(function() obj.CFrame = root.CFrame c = c + 1 end)
        end
    end
    return c
end

-- Bring and Kill All
local function bringAndKillFunc()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local target = root.CFrame
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherChar = otherPlayer.Character
            if otherChar then
                local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                if otherRoot then otherRoot.CFrame = target end
            end
        end
    end
end

-- Reduce Lags
local function reduceLagsFunc()
    pcall(function() game:GetService("Lighting").GlobalShadows = false end)
    pcall(function() game:GetService("Lighting").Technology = Enum.Technology.Compatibility end)
    pcall(function() settings().Rendering.QualityLevel = 1 end)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
            pcall(function() obj.Enabled = false end)
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") then pcall(function() obj.Enabled = false end) end
    end
end

-- GUI
local function createGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MaxMirHub"
    sg.Parent = player:WaitForChild("PlayerGui")
    sg.ResetOnSpawn = false

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 380)
    main.Position = UDim2.new(0.5, -250, 0.5, -190)
    main.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    main.BorderSizePixel = 0
    main.Parent = sg
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)
    local hf = Instance.new("Frame", header)
    hf.Size = UDim2.new(1, 0, 0, 10)
    hf.Position = UDim2.new(0, 0, 1, -10)
    hf.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    hf.BorderSizePixel = 0
    local line = Instance.new("Frame", header)
    line.Size = UDim2.new(1, 0, 0, 2)
    line.Position = UDim2.new(0, 0, 1, -2)
    line.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    line.BorderSizePixel = 0

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -90, 0, 25)
    title.Position = UDim2.new(0, 16, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "OG Saber Simulator"
    title.TextColor3 = Color3.fromRGB(255, 60, 60)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", header)
    sub.Size = UDim2.new(1, -90, 0, 14)
    sub.Position = UDim2.new(0, 16, 0, 27)
    sub.BackgroundTransparency = 1
    sub.Text = "by MaxMir"
    sub.TextColor3 = Color3.fromRGB(140, 140, 160)
    sub.TextSize = 10
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local hideBtn = Instance.new("TextButton", header)
    hideBtn.Size = UDim2.new(0, 24, 0, 24)
    hideBtn.Position = UDim2.new(1, -88, 0, 10)
    hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    hideBtn.Text = "👁"
    hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hideBtn.TextSize = 12
    hideBtn.Font = Enum.Font.GothamBold
    hideBtn.BorderSizePixel = 0
    Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 4)

    local minBtn = Instance.new("TextButton", header)
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(1, -56, 0, 10)
    minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    minBtn.Text = "_"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextSize = 14
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BorderSizePixel = 0
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

    local mainPage = Instance.new("ScrollingFrame", main)
    mainPage.Size = UDim2.new(1, -20, 1, -55)
    mainPage.Position = UDim2.new(0, 10, 0, 51)
    mainPage.BackgroundTransparency = 1
    mainPage.BorderSizePixel = 0
    mainPage.ScrollBarThickness = 3
    mainPage.ScrollBarImageColor3 = Color3.fromRGB(180, 25, 25)
    mainPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UIListLayout", mainPage).Padding = UDim.new(0, 5)

    local function makeToggle(parent, name, order, defaultState)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 40)
        f.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        f.BorderSizePixel = 0
        f.LayoutOrder = order
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        local bar = Instance.new("Frame", f)
        bar.Size = UDim2.new(0, 3, 1, 0)
        bar.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
        bar.BorderSizePixel = 0
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -80, 1, 0)
        l.Position = UDim2.new(0, 14, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = name
        l.TextColor3 = Color3.fromRGB(255, 255, 255)
        l.TextSize = 13
        l.Font = Enum.Font.GothamSemibold
        l.TextXAlignment = Enum.TextXAlignment.Left
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(0, 65, 0, 24)
        b.Position = UDim2.new(1, -78, 0.5, -12)
        if defaultState then
            b.BackgroundColor3 = Color3.fromRGB(46, 180, 46)
            b.Text = "ON"
        else
            b.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
            b.Text = "OFF"
        end
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        return {f = f, b = b, l = l}
    end

    local mainBtns = {}
    local names = {
        {"Auto Swing", true}, {"Auto Sell", false}, {"Auto Buy Sabers", false}, {"Auto Buy DNA", false},
        {"Boss Puller", true}, {"Heart Collector", true}, {"Bring and Kill All", false}, {"Reduce Lags", true}
    }
    for i, data in pairs(names) do mainBtns[data[1]] = makeToggle(mainPage, data[1], i, data[2]) end

    local heartLab = Instance.new("TextLabel", mainBtns["Heart Collector"].f)
    heartLab.Size = UDim2.new(0, 55, 0, 14)
    heartLab.Position = UDim2.new(1, -78, 1, -16)
    heartLab.BackgroundTransparency = 1
    heartLab.Text = "0 ❤️"
    heartLab.TextColor3 = Color3.fromRGB(255, 100, 100)
    heartLab.TextSize = 9
    heartLab.Font = Enum.Font.Gotham
    heartLab.TextXAlignment = Enum.TextXAlignment.Right

    local toggleFuncs = {
        ["Auto Swing"] = function(on)
            if on then connections[1] = game:GetService("RunService").Heartbeat:Connect(autoSwingFunc)
            else if connections[1] then connections[1]:Disconnect() end end
        end,
        ["Auto Sell"] = function(on)
            if on then connections[2] = game:GetService("RunService").Heartbeat:Connect(autoSellFunc)
            else if connections[2] then connections[2]:Disconnect() end end
        end,
        ["Auto Buy Sabers"] = function(on)
            if on then connections[3] = game:GetService("RunService").Heartbeat:Connect(autoBuySabersFunc)
            else if connections[3] then connections[3]:Disconnect() end end
        end,
        ["Auto Buy DNA"] = function(on)
            if on then connections[4] = game:GetService("RunService").Heartbeat:Connect(autoBuyDNAFunc)
            else if connections[4] then connections[4]:Disconnect() end end
        end,
        ["Boss Puller"] = function(on)
            if on then connections[5] = game:GetService("RunService").Heartbeat:Connect(bossPullerFunc)
            else if connections[5] then connections[5]:Disconnect() end end
        end,
        ["Heart Collector"] = function(on)
            if on then
                connections[6] = game:GetService("RunService").Heartbeat:Connect(function()
                    local c = heartCollectorFunc()
                    if c > 0 then heartCount = heartCount + c heartLab.Text = heartCount .. " ❤️" end
                end)
            else if connections[6] then connections[6]:Disconnect() end end
        end,
        ["Bring and Kill All"] = function(on)
            if on then connections[7] = game:GetService("RunService").Heartbeat:Connect(bringAndKillFunc)
            else if connections[7] then connections[7]:Disconnect() end end
        end,
        ["Reduce Lags"] = function(on)
            if on then reduceLagsFunc() end
        end
    }

    local stateMap = {
        ["Auto Swing"] = "autoSwing", ["Auto Sell"] = "autoSell",
        ["Auto Buy Sabers"] = "autoBuySabers", ["Auto Buy DNA"] = "autoBuyDNA",
        ["Boss Puller"] = "bossPuller", ["Heart Collector"] = "heartCollector",
        ["Bring and Kill All"] = "bringAndKill", ["Reduce Lags"] = "reduceLags"
    }

    for name, obj in pairs(mainBtns) do
        local key = stateMap[name]
        if states[key] and toggleFuncs[name] then toggleFuncs[name](true) end
    end

    for name, obj in pairs(mainBtns) do
        obj.b.MouseButton1Click:Connect(function()
            local key = stateMap[name]
            states[key] = not states[key]
            obj.b.BackgroundColor3 = states[key] and Color3.fromRGB(46, 180, 46) or Color3.fromRGB(200, 30, 30)
            obj.b.Text = states[key] and "ON" or "OFF"
            toggleFuncs[name](states[key])
        end)
    end

    hideBtn.MouseButton1Click:Connect(function()
        guiHidden = not guiHidden
        if guiHidden then
            main.Visible = false hideBtn.BackgroundColor3 = Color3.fromRGB(46, 180, 46)
            if not sg:FindFirstChild("ShowButton") then
                local showBtn = Instance.new("TextButton", sg)
                showBtn.Name = "ShowButton"
                showBtn.Size = UDim2.new(0, 30, 0, 30)
                showBtn.Position = UDim2.new(1, -40, 0, 10)
                showBtn.BackgroundColor3 = Color3.fromRGB(180, 25, 25)
                showBtn.Text = "🔴" showBtn.TextSize = 14
                showBtn.Font = Enum.Font.GothamBold showBtn.BorderSizePixel = 0
                Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0, 5)
                showBtn.MouseButton1Click:Connect(function()
                    main.Visible = true guiHidden = false hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75) showBtn:Destroy()
                end)
            end
        else
            main.Visible = true hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            if sg:FindFirstChild("ShowButton") then sg.ShowButton:Destroy() end
        end
    end)

    local min = false local saved = main.Size
    minBtn.MouseButton1Click:Connect(function()
        if not min then saved = main.Size main:TweenSize(UDim2.new(0,500,0,45),"Out","Quad",0.3) min = true minBtn.Text = "+"
        else main:TweenSize(saved,"Out","Quad",0.3) min = false minBtn.Text = "_" end
    end)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    local drag,start,pos = false,nil,nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag,start,pos = true,i.Position,main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag=false end end)
        end
    end)
    header.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position-start
            main.Position = UDim2.new(pos.X.Scale,pos.X.Offset+d.X,pos.Y.Scale,pos.Y.Offset+d.Y)
        end
    end)
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if not player.PlayerGui:FindFirstChild("MaxMirHub") then createGUI() end
end)
if player.Character then createGUI() end
print("✅ MaxMir Hub loaded!")
