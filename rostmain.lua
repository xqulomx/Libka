-- xqulomx.cc rost alpha script - OPTIMIZED VERSION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ГЛАВНОЕ ГУИ
local GUI = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")

GUI.Parent = game.CoreGui
GUI.Name = "xqulomxGUI"
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Серая панель с прозрачностью
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Parent = GUI

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Верхняя панель для перемещения
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TopBar.Parent = MainFrame

Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "xqulomx.cc rost"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Информация о игроке
local PlayerInfo = Instance.new("TextLabel")
PlayerInfo.Size = UDim2.new(0, 200, 1, 0)
PlayerInfo.Position = UDim2.new(1, -210, 0, 0)
PlayerInfo.BackgroundTransparency = 1
PlayerInfo.Text = "Uid:1337 | " .. LocalPlayer.Name
PlayerInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
PlayerInfo.Font = Enum.Font.Gotham
PlayerInfo.TextSize = 12
PlayerInfo.TextXAlignment = Enum.TextXAlignment.Right
PlayerInfo.Parent = TopBar

-- Аватар
local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 30, 0, 30)
Avatar.Position = UDim2.new(1, -250, 0, 5)
Avatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Avatar.Parent = TopBar

local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, thumbType, thumbSize)
Avatar.Image = content

-- Перемещение GUI за верхнюю панель
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Кнопки вкладок
local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 30)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainFrame

local tabs = {"Combat", "Visuals", "World", "Exploit"}
local currentTab = "Combat"

for i, tabName in pairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.25, 0, 1, 0)
    tabButton.Position = UDim2.new(0.25 * (i-1), 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 12
    tabButton.Parent = TabButtons
    
    tabButton.MouseButton1Click:Connect(function()
        currentTab = tabName
        updateTabs()
    end)
end

-- ========== COMBAT TAB ==========
local combatFrame = Instance.new("Frame")
combatFrame.Size = UDim2.new(1, -20, 1, -80)
combatFrame.Position = UDim2.new(0, 10, 0, 80)
combatFrame.BackgroundTransparency = 1
combatFrame.Visible = false
combatFrame.Parent = MainFrame

-- SILENT AIM SYSTEM
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local SilentAimSettings = {
    Enabled = false,
    TargetPart = "Head",
    SilentAimMethod = "Raycast",
    FOVRadius = 130,
    FOVVisible = false,
    HitChance = 100
}

local GetPlayers = Players.GetPlayers
local WorldToScreen = Camera.WorldToScreenPoint
local FindFirstChild = game.FindFirstChild
local RenderStepped = RunService.RenderStepped
local GetMouseLocation = UserInputService.GetMouseLocation

local ValidTargetParts = {"Head", "HumanoidRootPart"}

-- Drawing objects
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = SilentAimSettings.FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 0, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false

-- UI Elements для Combat
local silentAimToggle = Instance.new("TextButton")
silentAimToggle.Size = UDim2.new(0, 120, 0, 25)
silentAimToggle.Position = UDim2.new(0, 10, 0, 10)
silentAimToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
silentAimToggle.Text = "Silent Aim: OFF"
silentAimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
silentAimToggle.Font = Enum.Font.Gotham
silentAimToggle.TextSize = 12
silentAimToggle.Parent = combatFrame

local targetPartDropdown = Instance.new("TextButton")
targetPartDropdown.Size = UDim2.new(0, 120, 0, 20)
targetPartDropdown.Position = UDim2.new(0, 140, 0, 12)
targetPartDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
targetPartDropdown.Text = "Target: Head"
targetPartDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
targetPartDropdown.Font = Enum.Font.Gotham
targetPartDropdown.TextSize = 10
targetPartDropdown.Parent = combatFrame

local methodDropdown = Instance.new("TextButton")
methodDropdown.Size = UDim2.new(0, 150, 0, 20)
methodDropdown.Position = UDim2.new(0, 270, 0, 12)
methodDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
methodDropdown.Text = "Method: Raycast"
methodDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
methodDropdown.Font = Enum.Font.Gotham
methodDropdown.TextSize = 10
methodDropdown.Parent = combatFrame

local hitChance = Instance.new("TextBox")
hitChance.Size = UDim2.new(0, 80, 0, 20)
hitChance.Position = UDim2.new(0, 10, 0, 40)
hitChance.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hitChance.Text = "100"
hitChance.TextColor3 = Color3.fromRGB(255, 255, 255)
hitChance.Font = Enum.Font.Gotham
hitChance.TextSize = 12
hitChance.PlaceholderText = "Hit Chance"
hitChance.Parent = combatFrame

local fovCircleToggle = Instance.new("TextButton")
fovCircleToggle.Size = UDim2.new(0, 120, 0, 20)
fovCircleToggle.Position = UDim2.new(0, 100, 0, 40)
fovCircleToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fovCircleToggle.Text = "Show FOV Circle: OFF"
fovCircleToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
fovCircleToggle.Font = Enum.Font.Gotham
fovCircleToggle.TextSize = 10
fovCircleToggle.Parent = combatFrame

local fovRadius = Instance.new("TextBox")
fovRadius.Size = UDim2.new(0, 80, 0, 20)
fovRadius.Position = UDim2.new(0, 230, 0, 40)
fovRadius.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
fovRadius.Text = "130"
fovRadius.TextColor3 = Color3.fromRGB(255, 255, 255)
fovRadius.Font = Enum.Font.Gotham
fovRadius.TextSize = 12
fovRadius.PlaceholderText = "FOV Radius"
fovRadius.Parent = combatFrame

-- Eoka Luck функция
local eokaLuckToggle = Instance.new("TextButton")
eokaLuckToggle.Size = UDim2.new(0, 120, 0, 25)
eokaLuckToggle.Position = UDim2.new(0, 10, 0, 70)
eokaLuckToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
eokaLuckToggle.Text = "Eoka Luck: OFF"
eokaLuckToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
eokaLuckToggle.Font = Enum.Font.Gotham
eokaLuckToggle.TextSize = 12
eokaLuckToggle.Parent = combatFrame

-- GunMods
local gunModsLabel = Instance.new("TextLabel")
gunModsLabel.Size = UDim2.new(0, 100, 0, 20)
gunModsLabel.Position = UDim2.new(0, 10, 0, 105)
gunModsLabel.BackgroundTransparency = 1
gunModsLabel.Text = "GunMods:"
gunModsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
gunModsLabel.Font = Enum.Font.GothamBold
gunModsLabel.TextSize = 12
gunModsLabel.Parent = combatFrame

local noRecoilToggle = Instance.new("TextButton")
noRecoilToggle.Size = UDim2.new(0, 120, 0, 25)
noRecoilToggle.Position = UDim2.new(0, 10, 0, 130)
noRecoilToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
noRecoilToggle.Text = "Norecoil: OFF"
noRecoilToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
noRecoilToggle.Font = Enum.Font.Gotham
noRecoilToggle.TextSize = 12
noRecoilToggle.Parent = combatFrame

-- ========== VISUALS TAB ==========
local visualsFrame = Instance.new("Frame")
visualsFrame.Size = UDim2.new(1, -20, 1, -80)
visualsFrame.Position = UDim2.new(0, 10, 0, 80)
visualsFrame.BackgroundTransparency = 1
visualsFrame.Visible = false
visualsFrame.Parent = MainFrame

-- Player ESP
local playerESPLabel = Instance.new("TextLabel")
playerESPLabel.Size = UDim2.new(0, 100, 0, 20)
playerESPLabel.Position = UDim2.new(0, 10, 0, 10)
playerESPLabel.BackgroundTransparency = 1
playerESPLabel.Text = "PlayerESP:"
playerESPLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
playerESPLabel.Font = Enum.Font.GothamBold
playerESPLabel.TextSize = 12
playerESPLabel.Parent = visualsFrame

local espToggles = {
    chams = {x = 10, y = 35, text = "Chams", enabled = false},
    nametags = {x = 10, y = 60, text = "Nametags", enabled = false},
    health = {x = 10, y = 85, text = "Health", enabled = false},
    studs = {x = 10, y = 110, text = "Studs", enabled = false},
    corner = {x = 10, y = 135, text = "Corner Boxes", enabled = false}
}

for name, data in pairs(espToggles) do
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 120, 0, 20)
    toggle.Position = UDim2.new(0, data.x, 0, data.y)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.Text = data.text .. ": OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 10
    toggle.Parent = visualsFrame
    espToggles[name].button = toggle
end

-- Hemp ESP
local hempESPLabel = Instance.new("TextLabel")
hempESPLabel.Size = UDim2.new(0, 100, 0, 20)
hempESPLabel.Position = UDim2.new(0, 10, 0, 170)
hempESPLabel.BackgroundTransparency = 1
hempESPLabel.Text = "HempESP:"
hempESPLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hempESPLabel.Font = Enum.Font.GothamBold
hempESPLabel.TextSize = 12
hempESPLabel.Parent = visualsFrame

local hempToggle = Instance.new("TextButton")
hempToggle.Size = UDim2.new(0, 120, 0, 20)
hempToggle.Position = UDim2.new(0, 10, 0, 195)
hempToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
hempToggle.Text = "Hemp ESP: OFF"
hempToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
hempToggle.Font = Enum.Font.Gotham
hempToggle.TextSize = 10
hempToggle.Parent = visualsFrame

-- ========== WORLD TAB ==========
local worldFrame = Instance.new("Frame")
worldFrame.Size = UDim2.new(1, -20, 1, -80)
worldFrame.Position = UDim2.new(0, 10, 0, 80)
worldFrame.BackgroundTransparency = 1
worldFrame.Visible = false
worldFrame.Parent = MainFrame

local fakeGammaToggle = Instance.new("TextButton")
fakeGammaToggle.Size = UDim2.new(0, 150, 0, 25)
fakeGammaToggle.Position = UDim2.new(0, 10, 0, 10)
fakeGammaToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fakeGammaToggle.Text = "FakeGamma: OFF"
fakeGammaToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
fakeGammaToggle.Font = Enum.Font.Gotham
fakeGammaToggle.TextSize = 12
fakeGammaToggle.Parent = worldFrame

local armChamsToggle = Instance.new("TextButton")
armChamsToggle.Size = UDim2.new(0, 150, 0, 25)
armChamsToggle.Position = UDim2.new(0, 10, 0, 40)
armChamsToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
armChamsToggle.Text = "Arm Chams: OFF"
armChamsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
armChamsToggle.Font = Enum.Font.Gotham
armChamsToggle.TextSize = 12
armChamsToggle.Parent = worldFrame

local weaponChamsToggle = Instance.new("TextButton")
weaponChamsToggle.Size = UDim2.new(0, 150, 0, 25)
weaponChamsToggle.Position = UDim2.new(0, 10, 0, 70)
weaponChamsToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
weaponChamsToggle.Text = "Weapon Chams: OFF"
weaponChamsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
weaponChamsToggle.Font = Enum.Font.Gotham
weaponChamsToggle.TextSize = 12
weaponChamsToggle.Parent = worldFrame

-- ========== EXPLOIT TAB ==========
local exploitFrame = Instance.new("Frame")
exploitFrame.Size = UDim2.new(1, -20, 1, -80)
exploitFrame.Position = UDim2.new(0, 10, 0, 80)
exploitFrame.BackgroundTransparency = 1
exploitFrame.Visible = false
exploitFrame.Parent = MainFrame

-- ========== SILENT AIM ФУНКЦИИ ==========
function CalculateChance(Percentage)
    Percentage = math.floor(Percentage)
    local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100
    return chance <= Percentage / 100
end

function getPositionOnScreen(Vector)
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

function getDirection(Origin, Position)
    return (Position - Origin).Unit * 1000
end

function getMousePosition()
    return GetMouseLocation(UserInputService)
end

function getClosestPlayer()
    if not SilentAimSettings.TargetPart then return end
    local Closest
    local DistanceToMouse
    for _, Player in next, GetPlayers(Players) do
        if Player == LocalPlayer then continue end

        local Character = Player.Character
        if not Character then continue end

        local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
        local Humanoid = FindFirstChild(Character, "Humanoid")
        if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end

        local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)
        if not OnScreen then continue end

        local Distance = (getMousePosition() - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or SilentAimSettings.FOVRadius or 2000) then
            Closest = ((SilentAimSettings.TargetPart == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]) or Character[SilentAimSettings.TargetPart])
            DistanceToMouse = Distance
        end
    end
    return Closest
end

-- ========== HOOKS ==========
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]
    local chance = CalculateChance(SilentAimSettings.HitChance)
    if SilentAimSettings.Enabled and self == workspace and not checkcaller() and chance == true then
        if Method == "Raycast" and SilentAimSettings.SilentAimMethod == Method then
            local HitPart = getClosestPlayer()
            if HitPart then
                Arguments[3] = getDirection(Arguments[2], HitPart.Position)
                return oldNamecall(unpack(Arguments))
            end
        end
    end
    return oldNamecall(...)
end))

-- ========== EOKA LUCK ==========
local eokaLuckEnabled = false
local originalEokaScript

eokaLuckToggle.MouseButton1Click:Connect(function()
    eokaLuckEnabled = not eokaLuckEnabled
    eokaLuckToggle.Text = "Eoka Luck: " .. (eokaLuckEnabled and "ON" or "OFF")
    eokaLuckToggle.BackgroundColor3 = eokaLuckEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(50, 50, 50)
    
    if eokaLuckEnabled then
        -- Включаем удачу для Eoka
        enableEokaLuck()
    else
        -- Возвращаем оригинальный скрипт
        disableEokaLuck()
    end
end)

function enableEokaLuck()
    -- Находим Eoka в инвентаре игрока
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool.Name:lower():find("eoka") then
                modifyEokaScript(tool)
            end
        end
    end
    
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("eoka") then
                modifyEokaScript(tool)
            end
        end
    end
    
    -- Слушаем новые инструменты
    LocalPlayer.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(function(tool)
            if tool:IsA("Tool") and tool.Name:lower():find("eoka") then
                modifyEokaScript(tool)
            end
        end)
    end)
end

function modifyEokaScript(tool)
    local script = tool:FindFirstChildWhichIsA("LocalScript")
    if script then
        originalEokaScript = script.Source
        
        -- Модифицируем скрипт чтобы Eoka всегда стреляла
        local modifiedScript = originalEokaScript:gsub('if math.random%(%) <= v_u_22 then', 'if true then')
        modifiedScript = modifiedScript:gsub('v_u_22 = v_u_22 %* 1%.49', 'v_u_22 = 1.0')
        modifiedScript = modifiedScript:gsub('local v_u_22 = 0%.15', 'local v_u_22 = 1.0')
        
        -- Заменяем скрипт
        script.Source = modifiedScript
    end
end

function disableEokaLuck()
    if originalEokaScript then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local character = LocalPlayer.Character
        
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool.Name:lower():find("eoka") then
                    local script = tool:FindFirstChildWhichIsA("LocalScript")
                    if script then
                        script.Source = originalEokaScript
                    end
                end
            end
        end
        
        if character then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("eoka") then
                    local script = tool:FindFirstChildWhichIsA("LocalScript")
                    if script then
                        script.Source = originalEokaScript
                    end
                end
            end
        end
    end
end

-- ========== RENDER LOOP ==========
spawn(function()
    while true do
        RenderStepped:Wait()
        
        -- FOV Circle
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = SilentAimSettings.FOVRadius
        FOVCircle.Visible = SilentAimSettings.FOVVisible
        
        -- Player ESP
        UpdatePlayerESP()
        UpdateChams()
    end
end)

-- ========== PLAYER ESP ФУНКЦИИ ==========
local ESPDrawings = {}

function UpdatePlayerESP()
    for _, drawing in pairs(ESPDrawings) do
        if drawing then
            drawing:Remove()
        end
    end
    ESPDrawings = {}
    
    if not (espToggles.nametags.enabled or espToggles.health.enabled or espToggles.studs.enabled or espToggles.corner.enabled) then
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    -- Nametags
                    if espToggles.nametags.enabled then
                        local nameTag = Drawing.new("Text")
                        nameTag.Text = player.Name
                        nameTag.Size = 13
                        nameTag.Center = true
                        nameTag.Outline = true
                        nameTag.Position = Vector2.new(screenPoint.X, screenPoint.Y - 50)
                        nameTag.Color = Color3.fromRGB(255, 255, 255)
                        nameTag.Visible = true
                        table.insert(ESPDrawings, nameTag)
                    end
                    
                    -- Health
                    if espToggles.health.enabled then
                        local healthTag = Drawing.new("Text")
                        healthTag.Text = "HP: " .. math.floor(humanoid.Health)
                        healthTag.Size = 11
                        healthTag.Center = true
                        healthTag.Outline = true
                        healthTag.Position = Vector2.new(screenPoint.X, screenPoint.Y - 35)
                        healthTag.Color = Color3.fromRGB(0, 255, 0)
                        healthTag.Visible = true
                        table.insert(ESPDrawings, healthTag)
                    end
                    
                    -- Distance
                    if espToggles.studs.enabled and LocalPlayer.Character then
                        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if localRoot then
                            local distance = (rootPart.Position - localRoot.Position).Magnitude
                            local distanceTag = Drawing.new("Text")
                            distanceTag.Text = math.floor(distance) .. " studs"
                            distanceTag.Size = 11
                            distanceTag.Center = true
                            distanceTag.Outline = true
                            distanceTag.Position = Vector2.new(screenPoint.X, screenPoint.Y - 20)
                            distanceTag.Color = Color3.fromRGB(255, 255, 0)
                            distanceTag.Visible = true
                            table.insert(ESPDrawings, distanceTag)
                        end
                    end
                    
                    -- Corner Box
                    if espToggles.corner.enabled then
                        local head = player.Character:FindFirstChild("Head")
                        if head then
                            local headScreenPoint = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                            local boxHeight = math.abs(screenPoint.Y - headScreenPoint.Y) * 2
                            local boxWidth = boxHeight / 2
                            
                            local corners = {
                                {Vector2.new(screenPoint.X - boxWidth/2, screenPoint.Y - boxHeight/2), Vector2.new(screenPoint.X + boxWidth/2, screenPoint.Y - boxHeight/2)},
                                {Vector2.new(screenPoint.X + boxWidth/2, screenPoint.Y - boxHeight/2), Vector2.new(screenPoint.X + boxWidth/2, screenPoint.Y + boxHeight/2)},
                                {Vector2.new(screenPoint.X + boxWidth/2, screenPoint.Y + boxHeight/2), Vector2.new(screenPoint.X - boxWidth/2, screenPoint.Y + boxHeight/2)},
                                {Vector2.new(screenPoint.X - boxWidth/2, screenPoint.Y + boxHeight/2), Vector2.new(screenPoint.X - boxWidth/2, screenPoint.Y - boxHeight/2)}
                            }
                            
                            for _, corner in pairs(corners) do
                                local line = Drawing.new("Line")
                                line.From = corner[1]
                                line.To = corner[2]
                                line.Color = Color3.fromRGB(255, 0, 0)
                                line.Thickness = 1
                                line.Visible = true
                                table.insert(ESPDrawings, line)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Рабочие Chams
function UpdateChams()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    local highlight = part:FindFirstChild("xqulomxChams")
                    if espToggles.chams.enabled then
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "xqulomxChams"
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
                            highlight.FillTransparency = 0.3
                            highlight.OutlineTransparency = 0
                            highlight.Parent = part
                        end
                        highlight.Enabled = true
                    else
                        if highlight then
                            highlight.Enabled = false
                        end
                    end
                end
            end
        end
    end
end

-- Arm Chams
local armChamsEnabled = false
armChamsToggle.MouseButton1Click:Connect(function()
    armChamsEnabled = not armChamsEnabled
    armChamsToggle.Text = "Arm Chams: " .. (armChamsEnabled and "ON" or "OFF")
    armChamsToggle.BackgroundColor3 = armChamsEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(50, 50, 50)
    
    if armChamsEnabled then
        applyArmChams()
    else
        removeArmChams()
    end
end)

function applyArmChams()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:find("Arm") or part.Name:find("Hand")) then
                local highlight = Instance.new("Highlight")
                highlight.Name = "xqulomxArmChams"
                highlight.FillColor = Color3.fromRGB(64, 224, 208) -- Бирюзовый
                highlight.OutlineColor = Color3.fromRGB(32, 178, 170)
                highlight.FillTransparency = 0.2
                highlight.OutlineTransparency = 0
                highlight.Parent = part
            end
        end
    end
end

function removeArmChams()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            local highlight = part:FindFirstChild("xqulomxArmChams")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

-- Weapon Chams
local weaponChamsEnabled = false
weaponChamsToggle.MouseButton1Click:Connect(function()
    weaponChamsEnabled = not weaponChamsEnabled
    weaponChamsToggle.Text = "Weapon Chams: " .. (weaponChamsEnabled and "ON" or "OFF")
    weaponChamsToggle.BackgroundColor3 = weaponChamsEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(50, 50, 50)
    
    if weaponChamsEnabled then
        applyWeaponChams()
    else
        removeWeaponChams()
    end
end)

function applyWeaponChams()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                for _, part in pairs(tool:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "xqulomxWeaponChams"
                        highlight.FillColor = Color3.fromRGB(30, 144, 255) -- Синий
                        highlight.OutlineColor = Color3.fromRGB(0, 0, 139)
                        highlight.FillTransparency = 0.2
                        highlight.OutlineTransparency = 0
                        highlight.Parent = part
                    end
                end
            end
        end
    end
    
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                for _, part in pairs(tool:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "xqulomxWeaponChams"
                        highlight.FillColor = Color3.fromRGB(30, 144, 255)
                        highlight.OutlineColor = Color3.fromRGB(0, 0, 139)
                        highlight.FillTransparency = 0.2
                        highlight.OutlineTransparency = 0
                        highlight.Parent = part
                    end
                end
            end
        end
    end
end

function removeWeaponChams()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            for _, part in pairs(tool:GetDescendants()) do
                local highlight = part:FindFirstChild("xqulomxWeaponChams")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
    
    if character then
        for _, tool in pairs(character:GetChildren()) do
            for _, part in pairs(tool:GetDescendants()) do
                local highlight = part:FindFirstChild("xqulomxWeaponChams")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

-- Hemp ESP
local hempESPEnabled = false
hempToggle.MouseButton1Click:Connect(function()
    hempESPEnabled = not hempESPEnabled
    hempToggle.Text = "Hemp ESP: " .. (hempESPEnabled and "ON" or "OFF")
    hempToggle.BackgroundColor3 = hempESPEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(50, 50, 50)
end)

-- Fake Gamma (каждую миллисекунду)
local fakeGammaEnabled = false
fakeGammaToggle.MouseButton1Click:Connect(function()
    fakeGammaEnabled = not fakeGammaEnabled
    fakeGammaToggle.Text = "FakeGamma: " .. (fakeGammaEnabled and "ON" or "OFF")
    fakeGammaToggle.BackgroundColor3 = fakeGammaEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(50, 50, 50)
    
    if fakeGammaEnabled then
        spawn(function()
            while fakeGammaEnabled do
                RunService.Heartbeat:Wait() -- Каждый кадр
                game.Lighting.Brightness = 10
                game.Lighting.ClockTime = 14
                game.Lighting.GlobalShadows = false
                game.Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            end
        end)
    else
        game.Lighting.Brightness = 1
        game.Lighting.GlobalShadows = true
        game.Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    end
end)

-- ========== UI HANDLERS ==========
silentAimToggle.MouseButton1Click:Connect(function()
    SilentAimSettings.Enabled = not SilentAimSettings.Enabled
    silentAimToggle.Text = "Silent Aim: " .. (SilentAimSettings.Enabled and "ON" or "OFF")
    silentAimToggle.BackgroundColor3 = SilentAimSettings.Enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(50, 50, 50)
end)

targetPartDropdown.MouseButton1Click:Connect(function()
    local currentIndex = table.find(ValidTargetParts, SilentAimSettings.TargetPart) or 1
    local nextIndex = (currentIndex % #ValidTargetParts) + 1
    SilentAimSettings.TargetPart = ValidTargetParts[nextIndex]
    targetPartDropdown.Text = "Target: " .. SilentAimSettings.TargetPart
end)

methodDropdown.MouseButton1Click:Connect(function()
    local methods = {"Raycast", "FindPartOnRay", "FindPartOnRayWithWhitelist", "FindPartOnRayWithIgnoreList", "Mouse.Hit/Target"}
    local currentIndex = table.find(methods, SilentAimSettings.SilentAimMethod) or 1
    local nextIndex = (currentIndex % #methods) + 1
    SilentAimSettings.SilentAimMethod = methods[nextIndex]
    methodDropdown.Text = "Method: " .. SilentAimSettings.SilentAimMethod
end)

fovCircleToggle.MouseButton1Click:Connect(function()
    SilentAimSettings.FOVVisible = not SilentAimSettings.FOVVisible
    fovCircleToggle.Text = "Show FOV Circle: " .. (SilentAimSettings.FOVVisible and "ON" or "OFF")
    fovCircleToggle.BackgroundColor3 = SilentAimSettings.FOVVisible and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(50, 50, 50)
end)

hitChance.FocusLost:Connect(function()
    SilentAimSettings.HitChance = tonumber(hitChance.Text) or 100
end)

fovRadius.FocusLost:Connect(function()
    SilentAimSettings.FOVRadius = tonumber(fovRadius.Text) or 130
end)

-- ESP Toggles
for name, data in pairs(espToggles) do
    data.button.MouseButton1Click:Connect(function()
        data.enabled = not data.enabled
        data.button.Text = data.text .. ": " .. (data.enabled and "ON" or "OFF")
        data.button.BackgroundColor3 = data.enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(50, 50, 50)
    end)
end

-- Norecoil
local norecoilEnabled = false
noRecoilToggle.MouseButton1Click:Connect(function()
    norecoilEnabled = not norecoilEnabled
    noRecoilToggle.Text = "Norecoil: " .. (norecoilEnabled and "ON" or "OFF")
    noRecoilToggle.BackgroundColor3 = norecoilEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(50, 50, 50)
    
    if norecoilEnabled then
        disableRecoilCompletely()
    end
end)

function disableRecoilCompletely()
    local success = pcall(function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local gunFolder = replicatedStorage:FindFirstChild("Gun")
        
        if gunFolder then
            local scriptsFolder = gunFolder:FindFirstChild("Scripts")
            if scriptsFolder then
                local recoilHandler = scriptsFolder:FindFirstChild("RecoilHandler")
                if recoilHandler then
                    local recoilModule = require(recoilHandler)
                    
                    if recoilModule then
                        if recoilModule.nextStep then
                            recoilModule.nextStep = function() return nil end
                        end
                        if recoilModule.NextStep then
                            recoilModule.NextStep = function() return nil end
                        end
                        if recoilModule.RecoilMultiplier then
                            recoilModule.RecoilMultiplier = 0
                        end
                    end
                end
            end
        end
    end)
end

-- Функция обновления вкладок
function updateTabs()
    combatFrame.Visible = (currentTab == "Combat")
    visualsFrame.Visible = (currentTab == "Visuals")
    worldFrame.Visible = (currentTab == "World")
    exploitFrame.Visible = (currentTab == "Exploit")
end

-- Переключение GUI по Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Автоматическое применение чамсов при смене персонажа
LocalPlayer.CharacterAdded:Connect(function()
    if armChamsEnabled then
        wait(1)
        applyArmChams()
    end
    if weaponChamsEnabled then
        wait(1)
        applyWeaponChams()
    end
end)

updateTabs()
print("xqulomx.cc rost alpha - OPTIMIZED VERSION LOADED! Press INSERT to toggle GUI")
