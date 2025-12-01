-- Bionics UI Library
-- A clean, dark, glass-themed UI library for Roblox

local Bionics = {}
Bionics.__index = Bionics

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Create new window
function Bionics.new(title)
    local self = setmetatable({}, Bionics)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "BionicsUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 450, 0, 500)
    self.MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    self.MainFrame.BackgroundTransparency = 0.3
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    -- Main Frame Corner
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = self.MainFrame
    
    -- Glass Effect (Stroke)
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(60, 60, 80)
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.5
    mainStroke.Parent = self.MainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    titleBar.BackgroundTransparency = 0.4
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar
    
    -- Title Text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Bionics"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Container for elements
    self.Container = Instance.new("ScrollingFrame")
    self.Container.Name = "Container"
    self.Container.Size = UDim2.new(1, -30, 1, -80)
    self.Container.Position = UDim2.new(0, 15, 0, 65)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.ScrollBarThickness = 4
    self.Container.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
    self.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Container.Parent = self.MainFrame
    
    -- UIListLayout for Container
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = self.Container
    
    -- Auto-resize canvas
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Make draggable
    self:MakeDraggable(self.MainFrame, titleBar)
    
    return self
end

-- Make frame draggable
function Bionics:MakeDraggable(frame, dragBar)
    local dragging, dragInput, dragStart, startPos
    
    dragBar.InputBegan:Connect(function(input)
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
    
    dragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create Dropdown
function Bionics:Dropdown(name, options, default, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    dropdownFrame.BackgroundTransparency = 0.3
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = self.Container
    
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 10)
    dropCorner.Parent = dropdownFrame
    
    local dropStroke = Instance.new("UIStroke")
    dropStroke.Color = Color3.fromRGB(50, 50, 70)
    dropStroke.Thickness = 1
    dropStroke.Transparency = 0.6
    dropStroke.Parent = dropdownFrame
    
    -- Dropdown Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame
    
    -- Selected Option Button
    local selectedBtn = Instance.new("TextButton")
    selectedBtn.Size = UDim2.new(0.45, 0, 0, 30)
    selectedBtn.Position = UDim2.new(0.53, 0, 0.5, -15)
    selectedBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    selectedBtn.BackgroundTransparency = 0.2
    selectedBtn.Text = default or options[1]
    selectedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectedBtn.TextSize = 13
    selectedBtn.Font = Enum.Font.Gotham
    selectedBtn.BorderSizePixel = 0
    selectedBtn.Parent = dropdownFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = selectedBtn
    
    -- Dropdown Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 20, 1, 0)
    icon.Position = UDim2.new(1, -25, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "▼"
    icon.TextColor3 = Color3.fromRGB(180, 180, 180)
    icon.TextSize = 10
    icon.Font = Enum.Font.Gotham
    icon.Parent = selectedBtn
    
    -- Options Container
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "Options"
    optionsContainer.Size = UDim2.new(0.45, 0, 0, #options * 35)
    optionsContainer.Position = UDim2.new(0.53, 0, 1, 5)
    optionsContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    optionsContainer.BackgroundTransparency = 0.1
    optionsContainer.BorderSizePixel = 0
    optionsContainer.Visible = false
    optionsContainer.ZIndex = 10
    optionsContainer.Parent = dropdownFrame
    
    local optCorner = Instance.new("UICorner")
    optCorner.CornerRadius = UDim.new(0, 8)
    optCorner.Parent = optionsContainer
    
    local optStroke = Instance.new("UIStroke")
    optStroke.Color = Color3.fromRGB(60, 60, 90)
    optStroke.Thickness = 1
    optStroke.Transparency = 0.5
    optStroke.Parent = optionsContainer
    
    local optList = Instance.new("UIListLayout")
    optList.Padding = UDim.new(0, 2)
    optList.Parent = optionsContainer
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, -6, 0, 33)
        optBtn.Position = UDim2.new(0, 3, 0, 0)
        optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        optBtn.BackgroundTransparency = 0.5
        optBtn.Text = option
        optBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.BorderSizePixel = 0
        optBtn.ZIndex = 11
        optBtn.Parent = optionsContainer
        
        local optBtnCorner = Instance.new("UICorner")
        optBtnCorner.CornerRadius = UDim.new(0, 6)
        optBtnCorner.Parent = optBtn
        
        optBtn.MouseButton1Click:Connect(function()
            selectedBtn.Text = option
            optionsContainer.Visible = false
            icon.Text = "▼"
            if callback then
                callback(option)
            end
        end)
        
        optBtn.MouseEnter:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        end)
        
        optBtn.MouseLeave:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        end)
    end
    
    -- Toggle dropdown
    selectedBtn.MouseButton1Click:Connect(function()
        optionsContainer.Visible = not optionsContainer.Visible
        icon.Text = optionsContainer.Visible and "▲" or "▼"
        dropdownFrame.Size = optionsContainer.Visible and 
            UDim2.new(1, 0, 0, 40 + #options * 35 + 5) or 
            UDim2.new(1, 0, 0, 40)
    end)
    
    return dropdownFrame
end

-- Create Toggle
function Bionics:Toggle(name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    toggleFrame.BackgroundTransparency = 0.3
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = self.Container
    
    local togCorner = Instance.new("UICorner")
    togCorner.CornerRadius = UDim.new(0, 10)
    togCorner.Parent = toggleFrame
    
    local togStroke = Instance.new("UIStroke")
    togStroke.Color = Color3.fromRGB(50, 50, 70)
    togStroke.Thickness = 1
    togStroke.Transparency = 0.6
    togStroke.Parent = toggleFrame
    
    -- Toggle Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    -- Toggle Switch Background
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 46, 0, 24)
    switchBg.Position = UDim2.new(1, -60, 0.5, -12)
    switchBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    switchBg.BorderSizePixel = 0
    switchBg.Parent = toggleFrame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg
    
    local switchStroke = Instance.new("UIStroke")
    switchStroke.Color = Color3.fromRGB(60, 60, 80)
    switchStroke.Thickness = 1
    switchStroke.Transparency = 0.5
    switchStroke.Parent = switchBg
    
    -- Toggle Switch Circle
    local switchCircle = Instance.new("Frame")
    switchCircle.Size = UDim2.new(0, 18, 0, 18)
    switchCircle.Position = UDim2.new(0, 3, 0.5, -9)
    switchCircle.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
    switchCircle.BorderSizePixel = 0
    switchCircle.Parent = switchBg
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = switchCircle
    
    local toggled = default or false
    
    -- Update toggle appearance
    local function updateToggle()
        if toggled then
            TweenService:Create(switchCircle, TweenInfo.new(0.3), {
                Position = UDim2.new(1, -21, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(120, 180, 255)
            }):Play()
            TweenService:Create(switchBg, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(60, 100, 180)
            }):Play()
        else
            TweenService:Create(switchCircle, TweenInfo.new(0.3), {
                Position = UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(180, 180, 200)
            }):Play()
            TweenService:Create(switchBg, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            }):Play()
        end
    end
    
    updateToggle()
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = toggleFrame
    
    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
        if callback then
            callback(toggled)
        end
    end)
    
    return toggleFrame
end

-- Create Keybind
function Bionics:Keybind(name, default, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "Keybind"
    keybindFrame.Size = UDim2.new(1, 0, 0, 40)
    keybindFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    keybindFrame.BackgroundTransparency = 0.3
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Parent = self.Container
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 10)
    keyCorner.Parent = keybindFrame
    
    local keyStroke = Instance.new("UIStroke")
    keyStroke.Color = Color3.fromRGB(50, 50, 70)
    keyStroke.Thickness = 1
    keyStroke.Transparency = 0.6
    keyStroke.Parent = keybindFrame
    
    -- Keybind Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybindFrame
    
    -- Keybind Button
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 80, 0, 30)
    keyBtn.Position = UDim2.new(1, -95, 0.5, -15)
    keyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    keyBtn.BackgroundTransparency = 0.2
    keyBtn.Text = default or "..."
    keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBtn.TextSize = 13
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.BorderSizePixel = 0
    keyBtn.Parent = keybindFrame
    
    local keyBtnCorner = Instance.new("UICorner")
    keyBtnCorner.CornerRadius = UDim.new(0, 8)
    keyBtnCorner.Parent = keyBtn
    
    local listening = false
    local currentKey = default
    
    keyBtn.MouseButton1Click:Connect(function()
        if not listening then
            listening = true
            keyBtn.Text = "..."
            TweenService:Create(keyBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            }):Play()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local key = input.KeyCode.Name
                currentKey = key
                keyBtn.Text = key
                listening = false
                TweenService:Create(keyBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                }):Play()
                
                if callback then
                    callback(key)
                end
            end
        end
    end)
    
    return keybindFrame
end

return Bionics
