-- Bionics UI Library (ImGui Style)
-- Clean, functional UI library for Roblox

local Bionics = {}
Bionics.__index = Bionics

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

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
    self.MainFrame.Size = UDim2.new(0, 400, 0, 450)
    self.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(37, 37, 38)
    self.MainFrame.BorderSizePixel = 1
    self.MainFrame.BorderColor3 = Color3.fromRGB(62, 62, 66)
    self.MainFrame.Parent = self.ScreenGui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.MainFrame
    
    -- Title Bar Border
    local titleBorder = Instance.new("Frame")
    titleBorder.Size = UDim2.new(1, 0, 0, 1)
    titleBorder.Position = UDim2.new(0, 0, 1, 0)
    titleBorder.BackgroundColor3 = Color3.fromRGB(62, 62, 66)
    titleBorder.BorderSizePixel = 0
    titleBorder.Parent = titleBar
    
    -- Title Text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Bionics"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Container for elements
    self.Container = Instance.new("ScrollingFrame")
    self.Container.Name = "Container"
    self.Container.Size = UDim2.new(1, -16, 1, -38)
    self.Container.Position = UDim2.new(0, 8, 0, 34)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.ScrollBarThickness = 6
    self.Container.ScrollBarImageColor3 = Color3.fromRGB(158, 158, 158)
    self.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Container.Parent = self.MainFrame
    
    -- UIListLayout for Container
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = self.Container
    
    -- Auto-resize canvas
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
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
    dropdownFrame.Size = UDim2.new(1, 0, 0, 21)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = self.Container
    dropdownFrame.ClipsDescendants = false
    
    -- Dropdown Button
    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(1, 0, 0, 21)
    dropBtn.BackgroundColor3 = Color3.fromRGB(51, 51, 55)
    dropBtn.BorderSizePixel = 1
    dropBtn.BorderColor3 = Color3.fromRGB(62, 62, 66)
    dropBtn.Text = ""
    dropBtn.AutoButtonColor = false
    dropBtn.Parent = dropdownFrame
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -25, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. (default or options[1] or "")
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropBtn
    
    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrow.TextSize = 10
    arrow.Font = Enum.Font.SourceSans
    arrow.Parent = dropBtn
    
    -- Options List Container
    local listContainer = Instance.new("Frame")
    listContainer.Name = "OptionsList"
    listContainer.Size = UDim2.new(1, 0, 0, 0)
    listContainer.Position = UDim2.new(0, 0, 0, 22)
    listContainer.BackgroundColor3 = Color3.fromRGB(51, 51, 55)
    listContainer.BorderSizePixel = 1
    listContainer.BorderColor3 = Color3.fromRGB(62, 62, 66)
    listContainer.Visible = false
    listContainer.ZIndex = 100
    listContainer.ClipsDescendants = true
    listContainer.Parent = dropdownFrame
    
    -- Scrolling Frame for options
    local optionsScroll = Instance.new("ScrollingFrame")
    optionsScroll.Size = UDim2.new(1, 0, 1, 0)
    optionsScroll.BackgroundTransparency = 1
    optionsScroll.BorderSizePixel = 0
    optionsScroll.ScrollBarThickness = 6
    optionsScroll.ScrollBarImageColor3 = Color3.fromRGB(158, 158, 158)
    optionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    optionsScroll.Parent = listContainer
    
    local optList = Instance.new("UIListLayout")
    optList.SortOrder = Enum.SortOrder.LayoutOrder
    optList.Parent = optionsScroll
    
    optList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        optionsScroll.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y)
    end)
    
    local isOpen = false
    local selectedValue = default or (options[1] or "")
    
    -- Create option buttons
    local function createOptions(optionsList)
        -- Clear existing options
        for _, child in pairs(optionsScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for i, option in ipairs(optionsList) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 21)
            optBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 64)
            optBtn.BorderSizePixel = 0
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.TextSize = 14
            optBtn.Font = Enum.Font.SourceSans
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.AutoButtonColor = false
            optBtn.ZIndex = 101
            optBtn.Parent = optionsScroll
            
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 8)
            padding.Parent = optBtn
            
            optBtn.MouseEnter:Connect(function()
                optBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 84)
            end)
            
            optBtn.MouseLeave:Connect(function()
                optBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 64)
            end)
            
            optBtn.MouseButton1Click:Connect(function()
                selectedValue = option
                label.Text = name .. ": " .. option
                listContainer.Visible = false
                isOpen = false
                arrow.Text = "▼"
                dropdownFrame.Size = UDim2.new(1, 0, 0, 21)
                
                if callback then
                    callback(option)
                end
            end)
        end
        
        local numOptions = #optionsList
        local maxHeight = math.min(numOptions * 21, 150)
        listContainer.Size = UDim2.new(1, 0, 0, maxHeight)
    end
    
    createOptions(options)
    
    -- Toggle dropdown
    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listContainer.Visible = isOpen
        arrow.Text = isOpen and "▲" or "▼"
        
        if isOpen then
            local numOptions = #optionsScroll:GetChildren() - 1
            local maxHeight = math.min(numOptions * 21, 150)
            dropdownFrame.Size = UDim2.new(1, 0, 0, 21 + maxHeight + 1)
        else
            dropdownFrame.Size = UDim2.new(1, 0, 0, 21)
        end
    end)
    
    dropBtn.MouseEnter:Connect(function()
        dropBtn.BackgroundColor3 = Color3.fromRGB(62, 62, 66)
    end)
    
    dropBtn.MouseLeave:Connect(function()
        dropBtn.BackgroundColor3 = Color3.fromRGB(51, 51, 55)
    end)
    
    -- Return object with update method
    return {
        Frame = dropdownFrame,
        UpdateOptions = function(newOptions)
            options = newOptions
            createOptions(newOptions)
        end
    }
end

-- Create Player Dropdown
function Bionics:PlayerDropdown(name, callback)
    local function getPlayerList()
        local playerList = {}
        for _, player in ipairs(Players:GetPlayers()) do
            table.insert(playerList, player.Name .. " | " .. player.DisplayName)
        end
        return playerList
    end
    
    local playerList = getPlayerList()
    local dropdown = self:Dropdown(name, playerList, playerList[1], callback)
    
    -- Update when players join/leave
    Players.PlayerAdded:Connect(function()
        wait(0.1)
        dropdown.UpdateOptions(getPlayerList())
    end)
    
    Players.PlayerRemoving:Connect(function()
        wait(0.1)
        dropdown.UpdateOptions(getPlayerList())
    end)
    
    return dropdown
end

-- Create Toggle
function Bionics:Toggle(name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 21)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = self.Container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(51, 51, 55)
    toggleBtn.BorderSizePixel = 1
    toggleBtn.BorderColor3 = Color3.fromRGB(62, 62, 66)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = toggleFrame
    
    -- Checkbox
    local checkbox = Instance.new("Frame")
    checkbox.Size = UDim2.new(0, 13, 0, 13)
    checkbox.Position = UDim2.new(0, 8, 0.5, -6.5)
    checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 64)
    checkbox.BorderSizePixel = 1
    checkbox.BorderColor3 = Color3.fromRGB(100, 100, 104)
    checkbox.Parent = toggleBtn
    
    -- Checkmark
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = ""
    checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkmark.TextSize = 16
    checkmark.Font = Enum.Font.SourceSansBold
    checkmark.Parent = checkbox
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 28, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleBtn
    
    local toggled = default or false
    
    local function updateToggle()
        if toggled then
            checkmark.Text = "✓"
            checkbox.BackgroundColor3 = Color3.fromRGB(75, 110, 175)
        else
            checkmark.Text = ""
            checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 64)
        end
    end
    
    updateToggle()
    
    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
        if callback then
            callback(toggled)
        end
    end)
    
    toggleBtn.MouseEnter:Connect(function()
        toggleBtn.BackgroundColor3 = Color3.fromRGB(62, 62, 66)
    end)
    
    toggleBtn.MouseLeave:Connect(function()
        toggleBtn.BackgroundColor3 = Color3.fromRGB(51, 51, 55)
    end)
    
    return toggleFrame
end

-- Create Keybind
function Bionics:Keybind(name, default, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "Keybind"
    keybindFrame.Size = UDim2.new(1, 0, 0, 21)
    keybindFrame.BackgroundTransparency = 1
    keybindFrame.Parent = self.Container
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = Color3.fromRGB(51, 51, 55)
    container.BorderSizePixel = 1
    container.BorderColor3 = Color3.fromRGB(62, 62, 66)
    container.Parent = keybindFrame
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, -8, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Key Button
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0.4, -16, 0, 17)
    keyBtn.Position = UDim2.new(0.6, 8, 0.5, -8.5)
    keyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 64)
    keyBtn.BorderSizePixel = 1
    keyBtn.BorderColor3 = Color3.fromRGB(100, 100, 104)
    keyBtn.Text = default or "None"
    keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBtn.TextSize = 13
    keyBtn.Font = Enum.Font.SourceSans
    keyBtn.AutoButtonColor = false
    keyBtn.Parent = container
    
    local listening = false
    local currentKey = default
    
    keyBtn.MouseButton1Click:Connect(function()
        if not listening then
            listening = true
            keyBtn.Text = "..."
            keyBtn.BackgroundColor3 = Color3.fromRGB(75, 110, 175)
        end
    end)
    
    keyBtn.MouseEnter:Connect(function()
        if not listening then
            keyBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 74)
        end
    end)
    
    keyBtn.MouseLeave:Connect(function()
        if not listening then
            keyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 64)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local key = input.KeyCode.Name
                currentKey = key
                keyBtn.Text = key
                listening = false
                keyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 64)
                
                if callback then
                    callback(key)
                end
            end
        end
    end)
    
    return keybindFrame
end

return Bionics
