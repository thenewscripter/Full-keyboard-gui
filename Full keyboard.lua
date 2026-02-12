local VIM = game:GetService("VirtualInputManager")

-- Main UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMobileKeyboard"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Keyboard Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 180)
MainFrame.Position = UDim2.new(0.5, -200, 0.6, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UIListLayout = Instance.new("UIGridLayout")
UIListLayout.Parent = MainFrame
UIListLayout.CellSize = UDim2.new(0, 40, 0, 40)

-- Side Control Panel
local SidePanel = Instance.new("ScrollingFrame")
SidePanel.Size = UDim2.new(0, 120, 0, 180)
SidePanel.Position = UDim2.new(1, 10, 0, 0)
SidePanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SidePanel.CanvasSize = UDim2.new(0, 0, 2, 0)
SidePanel.Parent = MainFrame

local SideList = Instance.new("UIListLayout")
SideList.Parent = SidePanel
SideList.Padding = UDim.new(0, 5)

-- Global Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 80, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Show/Hide"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = ScreenGui
toggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Custom Buttons System
local customKeysLocked = false
local function spawnCustomKey(keyName)
    local cBtn = Instance.new("TextButton")
    cBtn.Name = "CustomKey"
    cBtn.Size = UDim2.new(0, 60, 0, 60)
    cBtn.Position = UDim2.new(0.5, 0, 0.4, 0)
    cBtn.Text = keyName
    cBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    cBtn.TextColor3 = Color3.new(1, 1, 1)
    cBtn.Font = Enum.Font.SourceSansBold
    cBtn.TextSize = 25
    cBtn.Active = true
    cBtn.Draggable = not customKeysLocked
    cBtn.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = cBtn

    cBtn.MouseButton1Down:Connect(function()
        local code = (keyName == "Space" and Enum.KeyCode.Space or keyName == "Shift" and Enum.KeyCode.LeftShift or Enum.KeyCode[keyName])
        VIM:SendKeyEvent(true, code, false, game)
        cBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end)
    cBtn.MouseButton1Up:Connect(function()
        local code = (keyName == "Space" and Enum.KeyCode.Space or keyName == "Shift" and Enum.KeyCode.LeftShift or Enum.KeyCode[keyName])
        VIM:SendKeyEvent(false, code, false, game)
        cBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    -- Hold to remove
    cBtn.TouchLongPress:Connect(function()
        cBtn:Destroy()
    end)
end

-- Menu Buttons Creator
local function createMenuBtn(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.Parent = SidePanel
    btn.MouseButton1Click:Connect(callback)
end

createMenuBtn("Lock Main UI", Color3.fromRGB(120, 120, 0), function()
    MainFrame.Draggable = not MainFrame.Draggable
end)

createMenuBtn("Lock Custom Keys", Color3.fromRGB(0, 80, 150), function()
    customKeysLocked = not customKeysLocked
    for _, obj in pairs(ScreenGui:GetChildren()) do
        if obj.Name == "CustomKey" then obj.Draggable = not customKeysLocked end
    end
end)

createMenuBtn("Destroy GUI", Color3.fromRGB(150, 0, 0), function()
    ScreenGui:Destroy()
end)

-- Spawn Section
local quickSpawn = {"W", "A", "S", "D", "Space", "E", "Shift", "F", "Q", "R", "T", "G", "V", "C", "X", "Z", "One", "Two", "Three"}
for _, k in ipairs(quickSpawn) do
    local displayName = (k == "One" and "1" or k == "Two" and "2" or k == "Three" and "3" or k)
    createMenuBtn("+ Add " .. displayName, Color3.fromRGB(50, 50, 50), function()
        spawnCustomKey(k)
    end)
end

-- Fill Keyboard
local keys = {"Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M"}
for _, letter in ipairs(keys) do
    local b = Instance.new("TextButton")
    b.Text = letter
    b.Parent = MainFrame
    b.MouseButton1Down:Connect(function() VIM:SendKeyEvent(true, Enum.KeyCode[letter], false, game) end)
    b.MouseButton1Up:Connect(function() VIM:SendKeyEvent(false, Enum.KeyCode[letter], false, game) end)
end
