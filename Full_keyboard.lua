local VIM = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- [1] FORCE MOBILE CONTROLS TO STAY VISIBLE
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
            local touchGui = playerGui:FindFirstChild("TouchGui")
            if touchGui then
                touchGui.Enabled = true
                -- منع اختفاء الأزرار عند الضغط على الكيبورد
                local touchFrame = touchGui:FindFirstChild("TouchControlFrame")
                if touchFrame then touchFrame.Visible = true end
            end
        end)
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FinalMobileKeyboard_V6"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
-- هذه الخاصية تسمح بالضغط خلف الـ GUI في الأماكن الفارغة
ScreenGui.IgnoreGuiInset = true

local pickingMode = false
local guiLocked = false
local keysLocked = false

-- [2] MAIN HOLDER (Background transparency is key here)
local Holder = Instance.new("Frame")
Holder.Size = UDim2.new(0, 650, 0, 320)
Holder.Position = UDim2.new(0.5, -325, 0.5, -160)
Holder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Holder.BackgroundTransparency = 0.2 -- شفافية بسيطة لرؤية اللعبة خلفه
Holder.Active = false -- نجعله false ليمر اللمس من خلاله
Holder.Draggable = true
Holder.Parent = ScreenGui
Instance.new("UICorner", Holder)

-- [3] TOP CONTROL BAR
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.Active = true -- الشريط العلوي فقط هو الذي يمسك اللمس للتحريك
TopBar.Parent = Holder
Instance.new("UICorner", TopBar)

local function createCtrl(text, color, xPos, width, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, width or 100, 0, 32)
    b.Position = UDim2.new(0, xPos, 0, 6)
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.Parent = TopBar
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local pickBtn = createCtrl("Choose Key", Color3.fromRGB(160, 140, 0), 10, 90, function() pickingMode = not pickingMode end)
local lockGuiBtn = createCtrl("Lock GUI: OFF", Color3.fromRGB(0, 100, 160), 110, 110, function() guiLocked = not guiLocked Holder.Draggable = not guiLocked end)
local lockKeysBtn = createCtrl("Lock Keys: OFF", Color3.fromRGB(0, 140, 90), 230, 110, function() 
    keysLocked = not keysLocked 
    for _, v in pairs(ScreenGui:GetChildren()) do
        if v.Name == "CustomKey" then v.Draggable = not keysLocked end
    end
end)
createCtrl("Hide GUI", Color3.fromRGB(170, 0, 0), 350, 90, function() Holder.Visible = false end)

-- [4] KEYBOARD SYSTEM
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

local function spawnExternalKey(

