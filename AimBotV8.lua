-- AimBot v7.1 by Kiệt
-- v7.0 + mini "Show AimBot" fixed to top (easy weapon switch) + high DisplayOrder

-- CONFIG
local AimEnabled = false
local AimPart = "Head"
local FOV = 200
local Smoothness = 12
local ShowFOV = true
local SelectedPlayers = {}
local Rainbow = false
local FOVColor = Color3.fromRGB(255,255,255)
local TeamCheck = true

-- SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- GUI
local guiParent = LocalPlayer:FindFirstChild("PlayerGui") or game.CoreGui
if guiParent:FindFirstChild("AimBotGui") then guiParent.AimBotGui:Destroy() end

local screenGui = Instance.new("ScreenGui", guiParent)
screenGui.Name = "AimBotGui"
screenGui.ResetOnSpawn = false
-- ensure this GUI renders on top of most other GUIs
if screenGui:IsA("ScreenGui") and screenGui:GetAttribute("DisplayOrder") == nil then
    -- Some Roblox environments use DisplayOrder property
    pcall(function() screenGui.DisplayOrder = 1000 end)
end

-- MAIN FRAME
local Frame = Instance.new("Frame", screenGui)
Frame.Size = UDim2.new(0, 340, 0, 520)
Frame.Position = UDim2.new(0.5,-170,0.5,-260)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true

-- AVATAR + NAME
local thumb = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
local AvatarImg = Instance.new("ImageLabel", Frame)
AvatarImg.Size = UDim2.new(0,40,0,40)
AvatarImg.Position = UDim2.new(0,10,0,5)
AvatarImg.Image = thumb
AvatarImg.BackgroundTransparency = 1

local PlayerName = Instance.new("TextLabel", Frame)
PlayerName.Size = UDim2.new(0,200,0,40)
PlayerName.Position = UDim2.new(0,60,0,5)
PlayerName.Text = LocalPlayer.Name
PlayerName.TextColor3 = Color3.new(1,1,1)
PlayerName.BackgroundTransparency = 1
PlayerName.TextXAlignment = Enum.TextXAlignment.Left
PlayerName.TextScaled = true

-- HIDE / SHOW MINI (mini btn placed top-center, high display order)
local HideBtn = Instance.new("TextButton", Frame)
HideBtn.Size = UDim2.new(0,50,0,30)
HideBtn.Position = UDim2.new(1,-55,0,5)
HideBtn.Text = "Hide"
HideBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)

local miniBtn -- will be created when hiding
HideBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
    if miniBtn and miniBtn.Parent then return end
    miniBtn = Instance.new("TextButton", screenGui)
    miniBtn.Name = "MiniShowAimBtn"
    miniBtn.Size = UDim2.new(0,120,0,30)
    -- put at top center (small top margin), easy to reach when switching weapons
    miniBtn.Position = UDim2.new(0.5,-60,0.02,0)
    miniBtn.Text = "Show AimBot"
    miniBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
    miniBtn.TextColor3 = Color3.new(1,1,1)
    miniBtn.AutoButtonColor = true
    -- ensure mini button draws above other UI
    pcall(function() miniBtn.ZIndex = 50 end)
    -- click to restore
    miniBtn.MouseButton1Click:Connect(function()
        Frame.Visible = true
        if miniBtn and miniBtn.Parent then
            miniBtn:Destroy()
            miniBtn = nil
        end
    end)
end)

-- TARGET LABEL
local TargetLabel = Instance.new("TextLabel", Frame)
TargetLabel.Size = UDim2.new(1, -20, 0, 25)
TargetLabel.Position = UDim2.new(0,10,0,50)
TargetLabel.Text = "Target: None"
TargetLabel.TextScaled = true
TargetLabel.BackgroundTransparency = 1
TargetLabel.TextColor3 = Color3.fromRGB(200,200,200)

-- AIM TOGGLE
local ToggleAim = Instance.new("TextButton", Frame)
ToggleAim.Size = UDim2.new(0.45,0,0,35)
ToggleAim.Position = UDim2.new(0.03,0,0.18,0)
ToggleAim.Text = "Aim: OFF"
ToggleAim.TextScaled = true
ToggleAim.BackgroundColor3 = Color3.fromRGB(150,50,50)
ToggleAim.TextColor3 = Color3.new(1,1,1)

ToggleAim.MouseButton1Click:Connect(function()
    AimEnabled = not AimEnabled
    ToggleAim.Text = "Aim: "..(AimEnabled and "ON" or "OFF")
    ToggleAim.BackgroundColor3 = AimEnabled and Color3.fromRGB(40,150,60) or Color3.fromRGB(150,50,50)
end)

-- FOV + COLOR + RAINBOW
local FOVLabel = Instance.new("TextLabel", Frame)
FOVLabel.Size = UDim2.new(0.9,0,0,25)
FOVLabel.Position = UDim2.new(0.05,0,0.28,0)
FOVLabel.Text = "FOV: "..FOV
FOVLabel.TextScaled = true
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.new(1,1,1)

local FOVSlider = Instance.new("TextButton", Frame)
FOVSlider.Size = UDim2.new(0.9,0,0,25)
FOVSlider.Position = UDim2.new(0.05,0,0.32,0)
FOVSlider.Text = "Drag to adjust FOV"
FOVSlider.MouseButton1Down:Connect(function()
    local mouse = LocalPlayer:GetMouse()
    local move
    move = mouse.Move:Connect(function()
        local newFOV = math.clamp((mouse.X - Frame.AbsolutePosition.X),50,500)
        FOV = newFOV
        FOVLabel.Text = "FOV: "..math.floor(FOV)
    end)
    UIS.InputEnded:Wait()
    move:Disconnect()
end)

local ColorBtn = Instance.new("TextButton", Frame)
ColorBtn.Size = UDim2.new(0.45,0,0,30)
ColorBtn.Position = UDim2.new(0.03,0,0.37,0)
ColorBtn.Text = "Color: White"
ColorBtn.BackgroundColor3 = FOVColor
ColorBtn.TextScaled = true

local RainbowBtn = Instance.new("TextButton", Frame)
RainbowBtn.Size = UDim2.new(0.45,0,0,30)
RainbowBtn.Position = UDim2.new(0.52,0,0.37,0)
RainbowBtn.Text = "Rainbow: OFF"
RainbowBtn.BackgroundColor3 = Color3.fromRGB(120,60,120)
RainbowBtn.TextScaled = true

local colors = {
    {Color3.fromRGB(255,255,255),"White"},
    {Color3.fromRGB(255,0,0),"Red"},
    {Color3.fromRGB(0,255,0),"Green"},
    {Color3.fromRGB(0,0,255),"Blue"},
    {Color3.fromRGB(255,255,0),"Yellow"},
}
local index = 1

ColorBtn.MouseButton1Click:Connect(function()
    Rainbow = false
    index = (index % #colors) + 1
    FOVColor = colors[index][1]
    ColorBtn.Text = "Color: "..colors[index][2]
    ColorBtn.BackgroundColor3 = FOVColor
end)

RainbowBtn.MouseButton1Click:Connect(function()
    Rainbow = not Rainbow
    RainbowBtn.Text = "Rainbow: "..(Rainbow and "ON" or "OFF")
end)

-- SMOOTHNESS
local SmoothLabel = Instance.new("TextLabel", Frame)
SmoothLabel.Size = UDim2.new(0.9,0,0,25)
SmoothLabel.Position = UDim2.new(0.05,0,0.42,0)
SmoothLabel.Text = "Smoothness: "..Smoothness

local SmoothSlider = Instance.new("TextButton", Frame)
SmoothSlider.Size = UDim2.new(0.9,0,0,25)
SmoothSlider.Position = UDim2.new(0.05,0,0.46,0)
SmoothSlider.Text = "Drag to adjust Smoothness"
SmoothSlider.MouseButton1Down:Connect(function()
    local mouse = LocalPlayer:GetMouse()
    local move
    move = mouse.Move:Connect(function()
        local newSmooth = math.clamp((mouse.X - Frame.AbsolutePosition.X)/10,1,30)
        Smoothness = newSmooth
        SmoothLabel.Text = "Smoothness: "..math.floor(Smoothness)
    end)
    UIS.InputEnded:Wait()
    move:Disconnect()
end)

-- PLAYER LIST
local listFrame = Instance.new("ScrollingFrame", Frame)
listFrame.Size = UDim2.new(0.94,0,0,120)
listFrame.Position = UDim2.new(0.03,0,0.52,0)
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.ScrollBarThickness = 6
listFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0,4)

local function refreshList()
    for _,c in pairs(listFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local i=0
    for _,pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            i+=1
            local b = Instance.new("TextButton", listFrame)
            b.Size = UDim2.new(1,-8,0,25)
            b.Text = SelectedPlayers[pl.Name] and "[X] "..pl.Name or pl.Name
            b.BackgroundColor3 = Color3.fromRGB(70,70,70)
            b.TextColor3 = Color3.new(1,1,1)
            b.MouseButton1Click:Connect(function()
                if SelectedPlayers[pl.Name] then SelectedPlayers[pl.Name]=nil else SelectedPlayers[pl.Name]=true end
                refreshList()
            end)
        end
    end
    listFrame.CanvasSize = UDim2.new(0,0,0,i*30)
end
refreshList()
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)

-- ESP toggle
local ESPBtn = Instance.new("TextButton", Frame)
ESPBtn.Size = UDim2.new(0.45,0,0,30)
ESPBtn.Position = UDim2.new(0.52,0,0.8,0)
ESPBtn.Text = "ESP: OFF"
local ESPOn = false
ESPBtn.MouseButton1Click:Connect(function()
    ESPOn = not ESPOn
    ESPBtn.Text = "ESP: "..(ESPOn and "ON" or "OFF")
end)

-- TEAM CHECK toggle
local TeamBtn = Instance.new("TextButton", Frame)
TeamBtn.Size = UDim2.new(0.45,0,0,30)
TeamBtn.Position = UDim2.new(0.03,0,0.8,0)
TeamBtn.Text = "Team Check: ON"
TeamBtn.BackgroundColor3 = Color3.fromRGB(50,120,200)
TeamBtn.TextScaled = true

TeamBtn.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    TeamBtn.Text = "Team Check: "..(TeamCheck and "ON" or "OFF")
end)

-- FUNCTIONS
local function setESP(char,enable)
    if not char then return end
    local hl = char:FindFirstChild("ESP_Highlight")
    if enable then
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "ESP_Highlight"
            hl.FillColor = Color3.fromRGB(0,255,0)
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 1
            hl.Parent = char
        end
    else
        if hl then hl:Destroy() end
    end
end

local function isVisible(part)
    local ray = Ray.new(Camera.CFrame.Position,(part.Position-Camera.CFrame.Position).Unit*999)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character,false,true)
    return (not hit) or hit:IsDescendantOf(part.Parent)
end

local function getClosest()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local closest,dist=nil,1e9
    for _,pl in pairs(Players:GetPlayers()) do
        if pl~=LocalPlayer and pl.Character and pl.Character:FindFirstChild(AimPart) then
            if next(SelectedPlayers)==nil or SelectedPlayers[pl.Name] then
                if TeamCheck and pl.Team == LocalPlayer.Team then
                    -- skip teammates when TeamCheck ON
                    continue
                end
                local part = pl.Character[AimPart]
                local pos,ons = Camera:WorldToViewportPoint(part.Position)
                if ons and isVisible(part) then
                    local d=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                    if d<dist and d<FOV then closest,dist=pl,d end
                end
            end
        end
    end
    return closest
end

-- DRAW FOV CIRCLE
local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.NumSides = 64
circle.Radius = FOV
circle.Filled = false
circle.Transparency = 0.7

-- RENDER LOOP
local hue=0
RunService.RenderStepped:Connect(function(dt)
    if Rainbow then
        hue=(hue+dt)%1
        FOVColor=Color3.fromHSV(hue,1,1)
    end

    circle.Visible = ShowFOV
    circle.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    circle.Radius = FOV
    circle.Color = FOVColor

    -- ESP
    for _,pl in pairs(Players:GetPlayers()) do
        if pl.Character then setESP(pl.Character,ESPOn) end
    end

    -- AIMBOT
    if AimEnabled then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local part = target.Character[AimPart]
            local desired = CFrame.new(Camera.CFrame.Position,part.Position)
            Camera.CFrame = Camera.CFrame:Lerp(desired,Smoothness/30)
            TargetLabel.Text="Target: "..target.Name
        else
            TargetLabel.Text="Target: None"
        end
    end
end)
