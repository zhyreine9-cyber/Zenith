loadstring([[
    -- // CONFIGURATION
    local Settings = {
        Enabled = true,
        Mode = "Silent", -- "Silent", "Hard", "Soft"
        FOV = 120,
        Range = 500,
        Smoothness = 0.2,
        AimAt = "Head",
        BonePriority = { "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "RightHand", "LeftHand" },
        TargetName = nil,
        DrawFOV = true,
    }

    -- // STATE
    local currentTarget = nil
    local targetPart = nil

    -- // SERVICES
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    -- // UTILITIES
    local function getTarget()
        if not LocalPlayer.Character then return nil end
        
        local players = Players:GetPlayers()
        local bestChar = nil
        local bestDist = math.huge
        local myPos = LocalPlayer:GetMouse().Hit.Position or Camera.CFrame.Position
        
        for _, plr in ipairs(players) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local dist = (root.Position - myPos).Magnitude
                        if dist < Settings.Range then
                            if Settings.TargetName and plr.Name ~= Settings.TargetName then
                                continue
                            end
                            if dist < bestDist then
                                bestDist = dist
                                bestChar = char
                            end
                        end
                    end
                end
            end
        end
        return bestChar
    end

    local function updateTargetPart(char)
        if not char then
            targetPart = nil
            return
        end
        local preferred = char:FindFirstChild(Settings.AimAt)
        local root = char:FindFirstChild("HumanoidRootPart")
        if preferred and preferred:IsA("BasePart") then
            targetPart = preferred
        elseif root then
            targetPart = root
        else
            targetPart = nil
        end
    end

    -- // DRAWING
    local DrawingLayer = Instance.new("ScreenGui")
    DrawingLayer.Name = "CheatUI"
    DrawingLayer.ResetOnSpawn = false
    DrawingLayer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    DrawingLayer.Parent = CoreGui

    local FOVCircle = Instance.new("Frame")
    FOVCircle.Name = "FOV"
    FOVCircle.Size = UDim2.new(0, Settings.FOV, 0, Settings.FOV)
    FOVCircle.Position = UDim2.new(0.5, -Settings.FOV/2, 0.5, -Settings.FOV/2)
    FOVCircle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FOVCircle.BackgroundTransparency = 0.8
    FOVCircle.BorderSizePixel = 2
    FOVCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
    FOVCircle.BorderSizePixelMode = Enum.BorderSizePixelMode.Inset
    FOVCircle.ClipsDescendants = false
    FOVCircle.Parent = DrawingLayer

    local FOVBorder = Instance.new("UICorner")
    FOVBorder.CornerRadius = UDim.new(1, 0)
    FOVBorder.Parent = FOVCircle

    local FOVText = Instance.new("TextLabel")
    FOVText.Name = "Status"
    FOVText.Size = UDim2.new(0, 100, 0, 20)
    FOVText.Position = UDim2.new(0.5, -50, 1, 10)
    FOVText.BackgroundTransparency = 1
    FOVText.TextColor3 = Color3.fromRGB(255, 255, 255)
    FOVText.TextScaled = true
    FOVText.Font = Enum.Font.GothamBold
    FOVText.Text = "Target: None"
    FOVText.Parent = FOVCircle

    -- // UI INTERFACE
    local UI = Instance.new("ScreenGui")
    UI.Name = "CheatConsole"
    UI.ResetOnSpawn = false
    UI.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.Size = UDim2.new(0, 300, 0, 450)
    mainFrame.Position = UDim2.new(1, -320, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = UI

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(8, 0)
    corner.Parent = mainFrame

    local function createButton(text, onClick)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamMedium
        btn.Size = UDim2.new(0, 130, 0, 35)
        btn.Parent = mainFrame
        btn.MouseButton1Click:Connect(onClick)
        return btn
    end

    local function createSlider(labelText, min, max, default, onChange)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 280, 0, 50)
        container.BackgroundTransparency = 1
        container.Parent = mainFrame
        
        local lbl = Instance.new("TextLabel")
        lbl.Text = labelText .. ": " .. default
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Gotham
        lbl.Size = UDim2.new(0, 280, 0, 20)
        lbl.Parent = container
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 10)
        slider.Position = UDim2.new(0, 0, 0, 25)
        slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        slider.Parent = container
        
        local handle = Instance.new("Frame")
        handle.Size = UDim2.new(0, 15, 0, 15)
        handle.Position = UDim2.new(0, 0, 0, -2.5)
        handle.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        handle.Parent = slider
        
        local dragging = false
        local value = default
        
        local function updateSlider(posX)
            local rel = (posX - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            value = min + (max - min) * rel
            handle.Position = UDim2.new(0, ((value - min) / (max - min)) * (slider.AbsoluteSize.X - 15), 0, -2.5)
            lbl.Text = labelText .. ": " .. tostring(math.floor(value * 100) / 100)
            onChange(value)
        end
        
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        handle.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)
        
        return container
    end

    local yPos = 10
    local function addWidget(w)
        w.Position = UDim2.new(0, 10, 0, yPos)
        yPos = yPos + 60
    end

    local toggleBtn = createButton("Enabled: ON", function()
        Settings.Enabled = not Settings.Enabled
        toggleBtn.Text = "Enabled: " .. (Settings.Enabled and "ON" or "OFF")
    end)
    addWidget(toggleBtn)

    local modeBtn = createButton("Mode: Silent", function()
        local modes = {"Silent", "Hard", "Soft"}
        local idx = table.find(modes, Settings.Mode)
        idx = (idx % #modes) + 1
        Settings.Mode = modes[idx]
        modeBtn.Text = "Mode: " .. Settings.Mode
    end)
    addWidget(modeBtn)

    local fovSlider = createSlider("FOV", 50, 300, Settings.FOV, function(v)
        Settings.FOV = v
    end)
    fovSlider.Position = UDim2.new(0, 10, 0, yPos)
    yPos = yPos + 60

    local rangeSlider = createSlider("Range", 100, 1000, Settings.Range, function(v)
        Settings.Range = v
    end)
    rangeSlider.Position = UDim2.new(0, 10, 0, yPos)
    yPos = yPos + 60

    local smoothSlider = createSlider("Smooth", 0.01, 1, Settings.Smoothness, function(v)
        Settings.Smoothness = v
    end)
    smoothSlider.Position = UDim2.new(0, 10, 0, yPos)
    yPos = yPos + 60

    local targetInput = Instance.new("TextBox")
    targetInput.PlaceholderText = "Target Name (Optional)"
    targetInput.Size = UDim2.new(0, 280, 0, 35)
    targetInput.Position = UDim2.new(0, 10, 0, yPos)
    targetInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    targetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetInput.Text = ""
    targetInput.Parent = mainFrame
    yPos = yPos + 45

    targetInput.FocusLost:Connect(function()
        Settings.TargetName = targetInput.Text ~= "" and targetInput.Text or nil
    end)

    local resetBtn = createButton("Reset", function()
        Settings.FOV = 120
        Settings.Range = 500
        Settings.Smoothness = 0.2
        Settings.Mode = "Silent"
        Settings.TargetName = nil
        targetInput.Text = ""
        modeBtn.Text = "Mode: Silent"
    end)
    resetBtn.Position = UDim2.new(0, 10, 0, yPos)

    -- // CORE LOGIC
    RunService:BindToRenderStep("CheatAim", Enum.RenderPriority.Camera.Value + 1, function()
        if not Settings
