local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Keep Mobile Buttons Visible (TouchGui Fix)
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
            local touchGui = playerGui:FindFirstChild("TouchGui")
            if touchGui then
                touchGui.Enabled = true
            end
        end)
    end
end)

-- Main UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomPCKeyboard"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 260)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Layout = Instance.new("UIGridLayout")
Layout.Parent = MainFrame
Layout.CellSize = UDim2.new(0, 42, 0, 36)
Layout.CellPadding = UDim2.new(0, 4, 0, 4)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- State Control
local pickingMode = false
local allLocked = false

-- Top Control Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.Position = UDim2.new(0, 0, 0, -50)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar)

local function createControlBtn(text, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 135, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = TopBar
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- External Key Spawner
local function spawnExternalKey(keyName)
    local cBtn = Instance.new("TextButton")
    cBtn.Name = "CustomKey"
    cBtn.Size = UDim2.new(0, 65, 0, 65)
    cBtn.Position = UDim2.new(0.5, -32, 0.3, 0)
    cBtn.Text = keyName
    cBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    cBtn.TextColor3 = Color3.new(1, 1, 1)
    cBtn.Font = Enum.Font.SourceSansBold
    cBtn.Draggable = not allLocked
    cBtn.Active = true
    cBtn.Parent = ScreenGui
    Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 12)

    cBtn.MouseButton1Down:Connect(function()
        local code = Enum.KeyCode[keyName] or Enum.KeyCode.Space
        VIM:SendKeyEvent(true, code, false, game)
        cBtn.BackgroundColor3 = Color3.new(0.7, 0, 0)
    end)
    cBtn.MouseButton1Up:Connect(function()
        local code = Enum.KeyCode[keyName] or Enum.KeyCode.Space
        VIM:SendKeyEvent(false, code, false, game)
        cBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    cBtn.TouchLongPress:Connect(function() cBtn:Destroy() end)
end

-- Top Bar Buttons
local pickBtn = createControlBtn("Choose Key", UDim2.new(0, 5, 0, 5), Color3.fromRGB(150, 130, 0), function()
    pickingMode = not pickingMode
end)

createControlBtn("Lock UI & Keys", UDim2.new(0, 150, 0, 5), Color3.fromRGB(0, 100, 150), function()
    allLocked = not allLocked
    MainFrame.Draggable = not allLocked
    for _, v in pairs(ScreenGui:GetChildren()) do
        if v.Name == "CustomKey" then v.Draggable = not allLocked end
    end
end)

createControlBtn("Destroy GUI", UDim2.new(0, 295, 0, 5), Color3.fromRGB(150, 0, 0), function()
    ScreenGui:Destroy()
end)

-- Keyboard Layout Arrays
local keys = {
    "F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
    "One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Zero",
    "Q","W","E","R","T","Y","U","I","O","P",
    "A","S","D","F","G","H","J","K","L",
    "LeftShift","Z","X","C","V","B","N","M","Backspace",
    "LeftControl","Tab","Space","Return"
}

local displayNames = {
    One="1", Two="2", Three="3", Four="4", Five="5", Six="6", Seven="7", Eight="8", Nine="9", Zero="0",
    LeftShift="Shift", LeftControl="Ctrl", Return="Enter", Backspace="Del", Space="SPACE"
}

-- Key Creation Logic
for _, k in ipairs(keys) do
    local b = Instance.new("TextButton")
    b.Text = displayNames[k] or k
    b.Parent = MainFrame
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b)

    b.MouseButton1Down:Connect(function()
        if pickingMode then
            spawnExternalKey(k)
            pickingMode = false
        else
            local code = Enum.KeyCode[k] or (k == "Space" and Enum.KeyCode.Space or Enum.KeyCode.A)
            VIM:SendKeyEvent(true, code, false, game)
            b.BackgroundColor3 = Color3.new(0.8, 0, 0)
        end
    end)
    b.MouseButton1Up:Connect(function()
        if not pickingMode then
            local code = Enum.KeyCode[k] or (k == "Space" and Enum.KeyCode.Space or Enum.KeyCode.A)
            VIM:SendKeyEvent(false, code, false, game)
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
    end)
end

-- UI State Manager (Color/Text Change)
game:GetService("RunService").RenderStepped:Connect(function()
    if pickingMode then
        pickBtn.Text = "SELECT KEY..."
        pickBtn.BackgroundColor3 = Color3.new(1, 0, 0)
    else
        pickBtn.Text = "Choose Key"
        pickBtn.BackgroundColor3 = Color3.fromRGB(150, 130, 0)
    end
end)
