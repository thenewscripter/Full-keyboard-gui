local VIM = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- [1] FORCE MOBILE CONTROLS TO STAY ACTIVE
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
            local touchGui = playerGui:FindFirstChild("TouchGui")
            if touchGui then
                touchGui.Enabled = true
                local touchFrame = touchGui:FindFirstChild("TouchControlFrame")
                if touchFrame then 
                    touchFrame.Visible = true 
                    touchFrame.Active = false -- Allows touch to pass through
                end
            end
        end)
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateKeyboard_Final_v8"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local pickingMode = false
local deleteMode = false
local guiLocked = false
local keysLocked = false

-- [2] MAIN HOLDER (The Background)
local Holder = Instance.new("Frame")
Holder.Size = UDim2.new(0, 650, 0, 320)
Holder.Position = UDim2.new(0.5, -325, 0.5, -160)
Holder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Holder.BackgroundTransparency = 0.2
Holder.Active = false -- Crucial: Background won't block the joystick
Holder.Draggable = true
Holder.Parent = ScreenGui
Instance.new("UICorner", Holder)

-- [3] TOP CONTROL BAR
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.Active = true -- Only TopBar handles dragging
TopBar.Parent = Holder
Instance.new("UICorner", TopBar)

local function createCtrl(text, color, xPos, width, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, width or 90, 0, 32)
    b.Position = UDim2.new(0, xPos, 0, 6)
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    b.Parent = TopBar
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

-- Top Bar Buttons Logic
local pickBtn = createCtrl("Choose Key", Color3.fromRGB(160, 140, 0), 5, 85, function() 
    pickingMode = not pickingMode 
    deleteMode = false 
end)

local delBtn = createCtrl("Del Mode: OFF", Color3.fromRGB(100, 0, 0), 95, 100, function() 
    deleteMode = not deleteMode 
    pickingMode = false 
end)

local lockGuiBtn = createCtrl("Lock GUI: OFF", Color3.fromRGB(0, 80, 150), 200, 100, function() 
    guiLocked = not guiLocked 
    Holder.Draggable = not guiLocked
end)

local lockKeysBtn = createCtrl("Lock Keys: OFF", Color3.fromRGB(0, 120, 80), 305, 105, function() 
    keysLocked = not keysLocked 
    for _, v in pairs(ScreenGui:GetChildren()) do
        if v.Name == "CustomKey" then v.Draggable = not keysLocked end
    end
end)

createCtrl("Hide GUI", Color3.fromRGB(170, 0, 0), 415, 80, function() Holder.Visible = false end)

-- [4] CUSTOM KEY SPAWNING (External Keys)
local function spawnExternalKey(name)
    local k = Instance.new("TextButton")
    k.Name = "CustomKey"
    k.Size = UDim2.new(0, 60, 0, 60)
    k.Position = UDim2.new(0.5, 0, 0.3, 0)
    k.Text = name
    k.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    k.BackgroundTransparency = 0.3
    k.TextColor3 = Color3.new(1, 1, 1)
    k.Draggable = not keysLocked
    k.Active = true
    k.Modal = false -- Important for joystick
    k.Parent = ScreenGui
    Instance.new("UICorner", k)
    
    k.MouseButton1Down:Connect(function()
        if deleteMode then 
            k:Destroy() 
        else
            VIM:SendKeyEvent(true, Enum.KeyCode[name] or Enum.KeyCode.Space, false, game)
            k.BackgroundColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    k.MouseButton1Up:Connect(function()
        if not deleteMode then
            VIM:SendKeyEvent(false, Enum.KeyCode[name] or Enum.KeyCode.Space, false, game)
            k.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            GuiService.SelectedObject = nil -- Release Focus back to Game
        end
    end)
end

-- [5] KEYBOARD CORE
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -65)
Container.Position = UDim2.new(0, 10, 0, 55)
Container.BackgroundTransparency = 1
Container.Parent = Holder

local function createRow()
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundTransparency = 1
    row.Parent = Container
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Horizontal
    l.Padding = UDim.new(0, 4)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.Parent = row
    return row
end

local function makeKey(name, row, width, displayName)
    local k = Instance.new("TextButton")
    k.Size = UDim2.new(0, width or 46, 1, 0)
    k.Text = displayName or name
    k.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    k.TextColor3 = Color3.new(1, 1, 1)
    k.Font = Enum.Font.SourceSansBold
    k.Parent = row
    Instance.new("UICorner", k)

    k.MouseButton1Down:Connect(function()
        if pickingMode then 
            spawnExternalKey(name) 
            pickingMode = false
        else
            VIM:SendKeyEvent(true, Enum.KeyCode[name] or Enum.KeyCode.Space, false, game)
            k.BackgroundColor3 = Color3.new(0.8, 0, 0)
        end
    end)
    
    k.MouseButton1Up:Connect(function()
        VIM:SendKeyEvent(false, Enum.KeyCode[name] or Enum.KeyCode.Space, false, game)
        k.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        GuiService.SelectedObject = nil -- Release Focus back to Game
    end)
end

-- BUILD LAYOUT
local RowLayout = Instance.new("UIListLayout")
RowLayout.Parent = Container
RowLayout.Padding = UDim.new(0, 4)

local r1=createRow() for i=1,12 do makeKey("F"..i, r1, 42) end
local r2=createRow() local nums={"One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Zero"} local nD={"1","2","3","4","5","6","7","8","9","0"} for i,v in ipairs(nums) do makeKey(v, r2, 44, nD[i]) end makeKey("Backspace", r2, 55, "Del")
local r3=createRow() for _,v in ipairs({"Q","W","E","R","T","Y","U","I","O","P"}) do makeKey(v, r3) end
local r4=createRow() for _,v in ipairs({"A","S","D","F","G","H","J","K","L"}) do makeKey(v, r4) end makeKey("Return", r4, 70, "Enter")
local r5=createRow() makeKey("LeftShift", r5, 70, "Shift") for _,v in ipairs({"Z","X","C","V","B","N","M"}) do makeKey(v, r5) end
local r6=createRow() makeKey("LeftControl", r6, 60, "Ctrl") makeKey("Tab", r6, 60) makeKey("Space", r6, 250, "SPACE")

-- [6] LOOP UPDATES
RunService.RenderStepped:Connect(function()
    pickBtn.Text = pickingMode and "SELECT..." or "Choose Key"
    delBtn.Text = deleteMode and "Del Mode: ON" or "Del Mode: OFF"
    lockGuiBtn.Text = guiLocked and "Lock GUI: ON" or "Lock GUI: OFF"
    lockKeysBtn.Text = keysLocked and "Lock Keys: ON" or "Lock Keys: OFF"
end)

-- [7] SHOW/HIDE TOGGLE
local ShowBtn = Instance.new("TextButton")
ShowBtn.Size = UDim2.new(0, 80, 0, 35)
ShowBtn.Position = UDim2.new(0, 15, 0, 15)
ShowBtn.Text = "SHOW UI"
ShowBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
ShowBtn.TextColor3 = Color3.new(1, 1, 1)
ShowBtn.Parent = ScreenGui
ShowBtn.Visible = false
ShowBtn.MouseButton1Click:Connect(function() Holder.Visible = true ShowBtn.Visible = false end)
Holder:GetPropertyChangedSignal("Visible"):Connect(function() ShowBtn.Visible = not Holder.Visible end)
