-- Bionics UI Library (ImGui Style)
-- Clean, functional UI library for Roblox

local Bionics = {}
Bionics.__index = Bionics

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Create new window
function Bionics.new(title)
    local self = setmetatable({}, Bionics)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "BionicsUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success = pcall(function()
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        self.ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Frame (ImGui dark theme)
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 380, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -190, 0.5, -200)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.MainFrame.BorderSizePixel = 1
    self.MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    self.MainFrame.Parent = self.ScreenGui
    
    -- Title Bar (ImGui style)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.MainFrame
    
    -- Title Bar Bottom Border
    local titleBorder = Instance.new("Frame")
    titleBorder.Size = UDim2.new(1, 0, 0, 1)
    titleBorder.Position = UDim2.new(0, 0, 1, -1)
    titleBorder.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleBorder.BorderSizePixel = 0
    titleBorder.Parent = titleBar
    
    -- Title Text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 8, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Bionics"
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.Code
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Container for elements
    self.Container = Instance.new("ScrollingFrame")
    self.Container.Name = "Container"
    self.Container.Size = UDim2.new(1, -12, 1, -33)
    self.Container.Position = UDim2.new(0, 6, 0, 29)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.ScrollBarThickness = 4
    self.Container.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    self.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Container.Parent = self.MainFrame
    
    -- UIListLayout for Container
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 3)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = self.Container
    
    -- Auto-resize canvas
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 6)
    end)
    
    -- Make draggable
    self:MakeDraggable(self.MainFrame, titleBar)
    
    return self
end

-- Make frame draggable
function Bionics:MakeDraggable(frame, dragBar)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
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
            update(input)
        end
    end)
end

-- Create Dropdown
function Bionics:Dropdown(name, options, default, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 20)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.ClipsDescendants = false
    dropdownFrame.Parent = self.Container
    
    -- Main Button
    local mainButton = Instance.new("TextButton")
    mainButton.Size = UDim2.new(1, 0, 0, 20)
    mainButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainButton.BorderSizePixel = 1
    mainButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
    mainButton.Text = ""
    mainButton.AutoButtonColor = false
    mainButton.Parent = dropdownFrame
    
    -- Label Text
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default or (options[1] or "None"))
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = mainButton
    
    -- Arrow Indicator
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 14, 1, 0)
    arrow.Position = UDim2.new(1, -16, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    arrow.TextSize = 11
    arrow.Font = Enum.Font.Code
    arrow.Parent = mainButton
    
    -- Options Container
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 0, 21)
    optionsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    optionsFrame.BorderSizePixel = 1
    optionsFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10
    optionsFrame.ClipsDescendants = true
    optionsFrame.Parent = dropdownFrame
    
    -- Options List
    local optionsList = Instance.new("Frame")
    optionsList.Size = UDim2.new(1, 0, 1, 0)
    optionsList.BackgroundTransparency = 1
    optionsList.Parent = optionsFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = optionsList
    
    local isOpen = false
    local currentSelection = default or options[1]
    
    -- Function to create option buttons
    local function updateOptions(newOptions)
        -- Clear old options
        for _, child in pairs(optionsList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Create new options
        for i, option in ipairs(newOptions) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 20)
            optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            optionButton.BorderSizePixel = 0
            optionButton.Text = tostring(option)
            optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            optionButton.TextSize = 13
            optionButton.Font = Enum.Font.Code
            optionButton.TextXAlignment = Enum.TextXAlignment.Left
            optionButton.AutoButtonColor = false
            optionButton.ZIndex = 11
            optionButton.Parent = optionsList
            
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 6)
            padding.Parent = optionButton
            
            -- Hover effect
            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
            end)
            
            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end)
            
            -- Click handler
            optionButton.MouseButton1Click:Connect(function()
                currentSelection = option
                label.Text = name .. ": " .. tostring(option)
                optionsFrame.Visible = false
                isOpen = false
                arrow.Text = "v"
                dropdownFrame.Size = UDim2.new(1, 0, 0, 20)
                
                if callback then
                    callback(option)
                end
            end)
        end
        
        -- Update frame size
        local optionCount = #newOptions
        local maxVisible = math.min(optionCount, 6)
        optionsFrame.Size = UDim2.new(1, 0, 0, maxVisible * 20)
    end
    
    -- Initialize options
    updateOptions(options)
    
    -- Toggle dropdown
    mainButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsFrame.Visible = isOpen
        arrow.Text = isOpen and "^" or "v"
        
        if isOpen then
            local optionCount = #options
            local maxVisible = math.min(optionCount, 6)
            dropdownFrame.Size = UDim2.new(1, 0, 0, 20 + (maxVisible * 20) + 2)
        else
            dropdownFrame.Size = UDim2.new(1, 0, 0, 20)
        end
    end)
    
    -- Hover effect
    mainButton.MouseEnter:Connect(function()
        mainButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    mainButton.MouseLeave:Connect(function()
        mainButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    
    return {
        Frame = dropdownFrame,
        UpdateOptions = updateOptions
    }
end

-- Create Player Dropdown
function Bionics:PlayerDropdown(name, callback)
    local function getPlayerList()
        local playerList = {}
        for _, player in ipairs(Players:GetPlayers()) do
            local displayText = player.Name .. " | " .. player.DisplayName
            table.insert(playerList, displayText)
        end
        if #playerList == 0 then
            table.insert(playerList, "No players")
        end
        return playerList
    end
    
    local initialList = getPlayerList()
    local dropdown = self:Dropdown(name, initialList, initialList[1], callback)
    
    -- Update on player changes
    Players.PlayerAdded:Connect(function()
        task.wait(0.1)
        dropdown.UpdateOptions(getPlayerList())
    end)
    
    Players.PlayerRemoving:Connect(function()
        task.wait(0.1)
        dropdown.UpdateOptions(getPlayerList())
    end)
    
    return dropdown
end

-- Create Toggle
function Bionics:Toggle(name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 20)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = self.Container
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(60, 60, 60)
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = toggleFrame
    
    -- Checkbox square
    local checkbox = Instance.new("Frame")
    checkbox.Size = UDim2.new(0, 12, 0, 12)
    checkbox.Position = UDim2.new(0, 6, 0.5, -6)
    checkbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    checkbox.BorderSizePixel = 1
    checkbox.BorderColor3 = Color3.fromRGB(80, 80, 80)
    checkbox.Parent = button
    
    -- Checkmark
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.Position = UDim2.new(0, 0, 0, -2)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = ""
    checkmark.TextColor3 = Color3.fromRGB(100, 180, 255)
    checkmark.TextSize = 14
    checkmark.Font = Enum.Font.Code
    checkmark.Parent = checkbox
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -26, 1, 0)
    label.Position = UDim2.new(0, 24, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    local toggled = default or false
    
    local function updateToggle()
        if toggled then
            checkmark.Text = "X"
            checkbox.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
        else
            checkmark.Text = ""
            checkbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end
    
    updateToggle()
    
    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
        if callback then
            callback(toggled)
        end
    end)
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    
    return toggleFrame
end

-- Create Keybind
function Bionics:Keybind(name, default, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "Keybind"
    keybindFrame.Size = UDim2.new(1, 0, 0, 20)
    keybindFrame.BackgroundTransparency = 1
    keybindFrame.Parent = self.Container
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    container.BorderSizePixel = 1
    container.BorderColor3 = Color3.fromRGB(60, 60, 60)
    container.Parent = keybindFrame
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Key Button
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0.32, 0, 0, 16)
    keyButton.Position = UDim2.new(0.66, 0, 0.5, -8)
    keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    keyButton.BorderSizePixel = 1
    keyButton.BorderColor3 = Color3.fromRGB(70, 70, 70)
    keyButton.Text = default or "None"
    keyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    keyButton.TextSize = 12
    keyButton.Font = Enum.Font.Code
    keyButton.AutoButtonColor = false
    keyButton.Parent = container
    
    local listening = false
    local currentKey = default
    
    keyButton.MouseButton1Click:Connect(function()
        if not listening then
            listening = true
            keyButton.Text = "..."
            keyButton.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
        end
    end)
    
    keyButton.MouseEnter:Connect(function()
        if not listening then
            keyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end)
    
    keyButton.MouseLeave:Connect(function()
        if not listening then
            keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local key = input.KeyCode.Name
                currentKey = key
                keyButton.Text = key
                listening = false
                keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                
                if callback then
                    callback(key)
                end
            end
        end
    end)
    
    return keybindFrame
end

return Bionics
