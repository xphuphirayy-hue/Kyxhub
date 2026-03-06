repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Anti AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- 🛡 กัน UI ใหม่ที่ถูกสร้าง (PlayerGui)
PlayerGui.DescendantAdded:Connect(function(v)
    if v:IsA("ScreenGui") and v.Name ~= "KyxHubUI" then
        task.wait()
        pcall(function()
            v:Destroy()
        end)
    end
end)

-- 🛡 กัน UI ใหม่จาก CoreGui
CoreGui.DescendantAdded:Connect(function(v)
    if v:IsA("ScreenGui") then
        task.wait()
        pcall(function()
            v:Destroy()
        end)
    end
end)

-- ลบ UI ที่มีอยู่ก่อน
for _,v in pairs(PlayerGui:GetChildren()) do
    if v:IsA("ScreenGui") then
        pcall(function()
            v:Destroy()
        end)
    end
end

for _,v in pairs(CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") then
        pcall(function()
            v:Destroy()
        end)
    end
end

-- Run Panda Script
task.spawn(function()
    loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/8cffffd967953fe7"))()
end)

-- Create KyxHub UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KyxHubUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundTransparency = 1
Frame.Size = UDim2.new(0,600,0,200)
Frame.Position = UDim2.new(0.5,-300,0,40)

-- Drag UI
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1,0,0,80)
Title.Text = "KyxHub"
Title.Font = Enum.Font.GothamBlack
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(255,255,255)

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Title
Stroke.Thickness = 3
Stroke.Color = Color3.fromRGB(0,0,0)

local Gradient = Instance.new("UIGradient")
Gradient.Parent = Title
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(0,255,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,255))
}

local Glow = Instance.new("UIStroke")
Glow.Parent = Title
Glow.Thickness = 8
Glow.Transparency = 0.7
Glow.Color = Color3.fromRGB(0,255,255)

-- Data Text
local Data1 = Instance.new("TextLabel")
Data1.Parent = Frame
Data1.BackgroundTransparency = 1
Data1.Size = UDim2.new(1,0,0,30)
Data1.Position = UDim2.new(0,0,0,90)
Data1.Font = Enum.Font.GothamBold
Data1.TextScaled = true
Data1.TextColor3 = Color3.new(1,1,1)

local Data2 = Instance.new("TextLabel")
Data2.Parent = Frame
Data2.BackgroundTransparency = 1
Data2.Size = UDim2.new(1,0,0,30)
Data2.Position = UDim2.new(0,0,0,120)
Data2.Font = Enum.Font.GothamBold
Data2.TextScaled = true
Data2.TextColor3 = Color3.new(1,1,1)

-- Format Number
local function Comma(n)
    local s = tostring(n)
    while true do
        s,k = string.gsub(s,"^(-?%d+)(%d%d%d)","%1,%2")
        if k==0 then break end
    end
    return s
end

RunService.RenderStepped:Connect(function()

    local Data = Player:FindFirstChild("Data")
    if Data then
        local Level = Data:FindFirstChild("Level")
        local Race = Data:FindFirstChild("Race")
        local Beli = Data:FindFirstChild("Beli")
        local Fragments = Data:FindFirstChild("Fragments")

        if Level and Race and Beli and Fragments then
            Data1.Text =
                "Level "..Level.Value..
                " | Race "..Race.Value..
                " | Beli "..Comma(Beli.Value)..
                " | Fragments "..Comma(Fragments.Value)
        end
    end

    local Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    Data2.Text = "Ping "..Ping
end)
