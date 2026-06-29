-- Voidrane.cc - LINORIA LIBRARY VERSION (FULLY FIXED)
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Voidrane.cc',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    World = Window:AddTab('World'),
    Exploit = Window:AddTab('Exploit'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local cachedChar = LocalPlayer.Character
local cachedHumanoid = cachedChar and cachedChar:FindFirstChildWhichIsA("Humanoid")
LocalPlayer.CharacterAdded:Connect(function(char)
    cachedChar = char
    cachedHumanoid = char:WaitForChild("Humanoid")
end)

-- Disable problematic game scripts
pcall(function()
    local ohd = LocalPlayer.PlayerScripts:FindFirstChild("ObjectHealthDisplayer")
    if ohd then ohd.Enabled = false end
end)

-- ========== FOV CIRCLE SETTINGS ==========
local FOVCircleSettings = {
    Color = Color3.fromRGB(255, 0, 255), Filled = false, FilledTransparency = 0.5,
    OutlineThickness = 1, Sides = 100, Radius = 130, Visible = false
}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false; FOVCircle.Radius = 130; FOVCircle.Color = Color3.fromRGB(255, 0, 255)
FOVCircle.Thickness = 1; FOVCircle.NumSides = 100; FOVCircle.Filled = false

-- ========== SILENT AIM (RAYCAST) + TRACERS (FIRE RAY ONLY) ==========
local SilentAimSettings = { Enabled = false, TargetPart = "Head", FOVRadius = 130, FOVVisible = false, HitChance = 100 }
local ValidTargetParts = {"Head", "HumanoidRootPart"}
local TracerSettings = { Enabled = false, Color = Color3.fromRGB(255,255,255), TextureID = "rbxassetid://12781852245", Width = 1.5, Transparency = 0, LifeTime = 0.5 }
local trPool, trSize = {}, 0

local _AimTarget = nil

function CalculateChance(Percentage)
    Percentage = math.floor(Percentage)
    return math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100 <= Percentage / 100
end

local function updateAimTarget()
    if not SilentAimSettings.Enabled then _AimTarget = nil; return end
    local mousePos = UserInputService:GetMouseLocation()
    local closest, closestDist = nil, SilentAimSettings.FOVRadius or 2000
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LocalPlayer then continue end
        local char = pl.Character; if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then continue end
        local part = char:FindFirstChild(SilentAimSettings.TargetPart); if not part then continue end
        local pos = Camera:WorldToScreenPoint(part.Position)
        if pos then
            local d = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
            if d < closestDist then closestDist = d; closest = part end
        end
    end
    _AimTarget = closest
end

local function getTr()
    if trSize > 0 then local p = trPool[trSize]; trPool[trSize] = nil; trSize = trSize - 1; return p end
    local p = Instance.new("Part"); p.Anchored = true; p.CanCollide = false; p.Transparency = 1; p.Size = Vector3.new(0.1,0.1,0.1)
    local a0 = Instance.new("Attachment", p); a0.Name = "A0"; local a1 = Instance.new("Attachment", p); a1.Name = "A1"
    local b = Instance.new("Beam"); b.Name = "B"; b.Attachment0 = a0; b.Attachment1 = a1
    b.FaceCamera = true; b.LightEmission = 1; b.LightInfluence = 0; b.TextureLength = 2; b.TextureSpeed = 2; b.Parent = p
    return p
end

local function createTrace(sp, ep)
    local p = getTr()
    pcall(function()
        p.Parent = workspace; local a0 = p:FindFirstChild("A0"); local a1 = p:FindFirstChild("A1")
        if a0 then a0.WorldPosition = sp end; if a1 then a1.WorldPosition = ep end
        local b = p:FindFirstChild("B")
        if b then b.Color = ColorSequence.new(TracerSettings.Color); b.Transparency = NumberSequence.new(TracerSettings.Transparency); b.Texture = TracerSettings.TextureID; b.Width0 = TracerSettings.Width; b.Width1 = TracerSettings.Width; b.Enabled = true end
        task.delay(TracerSettings.LifeTime, function() pcall(function() if p and p.Parent then if b then b.Enabled = false end; p.Parent = nil; trSize = trSize + 1; trPool[trSize] = p end end) end)
    end)
end

-- ========== SILENT AIM (WORKING) + TRACERS ==========
local SilentAimSettings = { Enabled = false, TargetPart = "Head", FOVRadius = 130, FOVVisible = false, HitChance = 100 }
local ValidTargetParts = {"Head", "HumanoidRootPart"}
local TracerSettings = { Enabled = false, Color = Color3.fromRGB(255,255,255), TextureID = "rbxassetid://12781852245", Width = 1.5, Transparency = 0, LifeTime = 0.5 }
local trPool, trSize = {}, 0

local GetPlayers = Players.GetPlayers
local WorldToScreen = Camera.WorldToScreenPoint
local FindFirstChild = game.FindFirstChild
local GetMouseLocation = UserInputService.GetMouseLocation

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

local function getTr()
    if trSize > 0 then local p = trPool[trSize]; trPool[trSize] = nil; trSize = trSize - 1; return p end
    local p = Instance.new("Part"); p.Anchored = true; p.CanCollide = false; p.Transparency = 1; p.Size = Vector3.new(0.1,0.1,0.1)
    local a0 = Instance.new("Attachment", p); a0.Name = "A0"; local a1 = Instance.new("Attachment", p); a1.Name = "A1"
    local b = Instance.new("Beam"); b.Name = "B"; b.Attachment0 = a0; b.Attachment1 = a1
    b.FaceCamera = true; b.LightEmission = 1; b.LightInfluence = 0; b.TextureLength = 2; b.TextureSpeed = 2; b.Parent = p
    return p
end

local function createTrace(sp, ep)
    local p = getTr()
    pcall(function()
        p.Parent = workspace; local a0 = p:FindFirstChild("A0"); local a1 = p:FindFirstChild("A1")
        if a0 then a0.WorldPosition = sp end; if a1 then a1.WorldPosition = ep end
        local b = p:FindFirstChild("B")
        if b then b.Color = ColorSequence.new(TracerSettings.Color); b.Transparency = NumberSequence.new(TracerSettings.Transparency); b.Texture = TracerSettings.TextureID; b.Width0 = TracerSettings.Width; b.Width1 = TracerSettings.Width; b.Enabled = true end
        task.delay(TracerSettings.LifeTime, function() pcall(function() if p and p.Parent then if b then b.Enabled = false end; p.Parent = nil; trSize = trSize + 1; trPool[trSize] = p end end) end)
    end)
end

-- WORKING HOOK FROM ORIGINAL + TRACERS
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]
    local chance = CalculateChance(SilentAimSettings.HitChance)
    
    if SilentAimSettings.Enabled and self == workspace and not checkcaller() and chance == true then
        if Method == "Raycast" then
            local HitPart = getClosestPlayer()
            if HitPart then
                Arguments[3] = getDirection(Arguments[2], HitPart.Position)
                local result = oldNamecall(unpack(Arguments))
                
                if TracerSettings.Enabled then
                    local ep = HitPart.Position
                    if result and typeof(result) == "Instance" then pcall(function() ep = result.Position end) end
                    task.spawn(createTrace, Arguments[2], ep)
                end
                
                return result
            end
        end
    end
    
    local result = oldNamecall(...)
    
    if TracerSettings.Enabled and Method == "Raycast" and self == workspace and not checkcaller() then
        local origin = Arguments[2]; local direction = Arguments[3]
        if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" and direction.Magnitude > 100 then
            local ep = origin + direction
            if result and typeof(result) == "Instance" then pcall(function() ep = result.Position end) end
            task.spawn(createTrace, origin, ep)
        end
    end
    
    return result
end))  
-- ========== AIMBOT (CAMERA-BASED) ==========
local AimbotSettings = { Enabled = false, Smooth = 1, FOVRadius = 130, FOVVisible = false }
local AimbotFOV = Drawing.new("Circle")
AimbotFOV.Visible = false; AimbotFOV.Radius = 130; AimbotFOV.Color = Color3.fromRGB(0, 255, 255)
AimbotFOV.Thickness = 1; AimbotFOV.NumSides = 100; AimbotFOV.Filled = false

local function getAimbotTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local closest, closestDist = nil, AimbotSettings.FOVRadius
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LocalPlayer then continue end
        local char = pl.Character; if not char then continue end
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not head or not hum or hum.Health <= 0 then continue end
        local sp, os = Camera:WorldToScreenPoint(head.Position)
        if os then
            local d = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(sp.X, sp.Y)).Magnitude
            if d < closestDist then closestDist = d; closest = head end
        end
    end
    return closest
end

task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if AimbotSettings.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getAimbotTarget()
            if target then
                local smooth = AimbotSettings.Smooth
                local camCFrame = Camera.CFrame
                local lookAt = CFrame.lookAt(camCFrame.Position, target.Position)
                Camera.CFrame = smooth > 1 and camCFrame:Lerp(lookAt, 1/smooth) or lookAt
            end
        end
    end
end)

-- ========== HIT SOUNDS ==========
local HitSoundSettings = { Enabled = false, Choice = "None", Volume = 1, OriginalSounds = {} }
local HSList = {
    None = "", Skeet = "rbxassetid://83717596220569", ["Sonic checkpoint"] = "rbxassetid://6817150445",
    ["Sonic.exe laugh"] = "rbxassetid://18379039436", ["Windows XP Error"] = "rbxassetid://9066167010",
    ["Minecraft Hit"] = "rbxassetid://8766809464", ["one sit nn dog"] = "rbxassetid://7380502345",
    ["Door Bell"] = "rbxassetid://131845870598154", Duck = "rbxassetid://1139819274",
    Mgs = "rbxassetid://81845122657643", Money = "rbxassetid://3020841054",
    Fart = "rbxassetid://4809574295", Meow = "rbxassetid://7148585764",
    byebye = "rbxassetid://70888261086432", Neverlose = "rbxassetid://8679627751"
}
local HSNames = {}; for n in pairs(HSList) do HSNames[#HSNames + 1] = n end

local function applyHS(snd, vol)
    if not snd or not snd.Parent then return end
    if not HitSoundSettings.OriginalSounds[snd] then HitSoundSettings.OriginalSounds[snd] = {SoundId = snd.SoundId, Volume = snd.Volume} end
    local id = HSList[HitSoundSettings.Choice] or ""
    if id ~= "" then snd.SoundId = id else local o = HitSoundSettings.OriginalSounds[snd]; if o then snd.SoundId = o.SoundId end end
    snd.Volume = vol
end

local function restoreHS()
    for snd, d in pairs(HitSoundSettings.OriginalSounds) do
        if snd and snd.Parent then pcall(function() snd.SoundId = d.SoundId; snd.Volume = d.Volume end) end
    end
    HitSoundSettings.OriginalSounds = {}
end

local function chkTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    task.spawn(function()
        local ba = tool:FindFirstChild("BodyAttach") or tool:WaitForChild("BodyAttach", 5)
        if ba then for _, sn in ipairs({"HitClient","HeadShotClient","HitCharacterClient"}) do
            local s = ba:FindFirstChild(sn) or ba:WaitForChild(sn, 3)
            if s and s:IsA("Sound") then applyHS(s, HitSoundSettings.Volume) end
        end end
    end)
end

local function applyHSChar(ch) if not ch then return end; for _, c in pairs(ch:GetChildren()) do if c:IsA("Tool") then chkTool(c) end end end
local hsConn = nil
local function setupHSChar(ch)
    if hsConn then pcall(function() hsConn:Disconnect() end); hsConn = nil end
    hsConn = ch.ChildAdded:Connect(function(c) if HitSoundSettings.Enabled and c:IsA("Tool") then task.delay(0.3, function() chkTool(c) end) end end)
end

-- ========== AUTO FARM ==========
local FarmSettings = { Enabled = false, Range = 20, HitDelay = 0.5 }

local function findBestTarget()
    local hrp = cachedChar and cachedChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bestDist = nil, FarmSettings.Range
    
    local treesFolder = workspace:FindFirstChild("trees")
    if treesFolder then for _, tree in ipairs(treesFolder:GetChildren()) do
        if tree:IsA("Model") then
            local cross = tree:FindFirstChild("cross")
            if cross and cross:IsA("BasePart") then
                local dist = (hrp.Position - cross.Position).Magnitude
                if dist < bestDist then bestDist = dist; best = cross end
            end
        end
    end end
    
    local oresFolder = workspace:FindFirstChild("ores")
    if oresFolder then for _, ore in ipairs(oresFolder:GetChildren()) do
        if ore:IsA("MeshPart") or ore:IsA("BasePart") then
            local star = ore:FindFirstChild("star")
            if star and star:IsA("BasePart") then
                local dist = (hrp.Position - star.Position).Magnitude
                if dist < bestDist then bestDist = dist; best = star end
            end
        end
    end end
    
    return best
end

local function hitTarget(target)
    if not target then return false end
    local tool = cachedChar and cachedChar:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local hitRemote = ReplicatedStorage:FindFirstChild("Tool") and ReplicatedStorage.Tool:FindFirstChild("Remotes") and ReplicatedStorage.Tool.Remotes:FindFirstChild("Hit")
    if hitRemote then pcall(function() hitRemote:FireServer(tool, target, target.Position) end); return true end
    local remotesFolder = ReplicatedStorage:FindFirstChild("Tool") and ReplicatedStorage.Tool:FindFirstChild("Remotes")
    if remotesFolder then for _, remote in ipairs(remotesFolder:GetChildren()) do if remote:IsA("RemoteEvent") then pcall(function() if remote.Name == "Hit" then remote:FireServer(tool, target, target.Position) else remote:FireServer(tool) end end) end end; return true end
    return false
end

local lastFarmHit = 0
task.spawn(function()
    while true do
        task.wait(0.1)
        if not FarmSettings.Enabled then continue end
        local target = findBestTarget()
        if target and tick() - lastFarmHit >= FarmSettings.HitDelay then
            hitTarget(target)
            lastFarmHit = tick()
        end
    end
end)

-- ========== MOVEMENT ==========
local SpeedSettings = { Enabled = false, Value = 30 }
local WaterSpeed = { Enabled = false, Value = 50 }
local JumpStunSettings = { Enabled = false, Height = 100 }
local SpiderSettings = { Enabled = false, Speed = 50 }
local NoJumpDelaySettings = { Enabled = false, Delay = 0.1, LastJumpTime = 0, Conn = nil }

local physConn = RunService.Heartbeat:Connect(function()
    local ch = cachedChar; if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart"); local hum = cachedHumanoid
    if not hrp or not hum or hum.Health <= 0 then return end
    if SpeedSettings.Enabled then local md = hum.MoveDirection; if md.Magnitude > 0 then hrp.AssemblyLinearVelocity = Vector3.new(md.X * SpeedSettings.Value, hrp.AssemblyLinearVelocity.Y, md.Z * SpeedSettings.Value) end end
    if WaterSpeed.Enabled and hum:GetState() == Enum.HumanoidStateType.Swimming then
        local bv = hrp:FindFirstChild("WSV"); if not bv then bv = Instance.new("BodyVelocity", hrp); bv.Name = "WSV"; bv.MaxForce = Vector3.new(1e5,1e5,1e5) end
        bv.Velocity = hum.MoveDirection * WaterSpeed.Value
    else local bv = hrp:FindFirstChild("WSV"); if bv then bv:Destroy() end end
    if SpiderSettings.Enabled and UserInputService:IsKeyDown(Enum.KeyCode.W) then
        local spRay = RaycastParams.new(); spRay.FilterType = Enum.RaycastFilterType.Exclude; spRay.IgnoreWater = true; spRay.FilterDescendantsInstances = {ch}
        local result = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 2.5, spRay)
        if result and math.abs(result.Normal.Y) < 0.5 then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, SpiderSettings.Speed, hrp.AssemblyLinearVelocity.Z) end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not JumpStunSettings.Enabled then return end
    local r = cachedChar and cachedChar:FindFirstChild("HumanoidRootPart")
    if r then r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, JumpStunSettings.Height, r.AssemblyLinearVelocity.Z) end
end)

local function toggleNoJumpDelay(v)
    NoJumpDelaySettings.Enabled = v
    if NoJumpDelaySettings.Conn then NoJumpDelaySettings.Conn:Disconnect(); NoJumpDelaySettings.Conn = nil end
    if v then NoJumpDelaySettings.Conn = RunService.RenderStepped:Connect(function()
        if not NoJumpDelaySettings.Enabled then return end
        local ch = cachedChar; if not ch then return end
        local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum or hum.Health <= 0 then return end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial ~= Enum.Material.Air then
            local now = tick()
            if now - NoJumpDelaySettings.LastJumpTime >= NoJumpDelaySettings.Delay then
                hum.Jump = true; hum:ChangeState(Enum.HumanoidStateType.Jumping); NoJumpDelaySettings.LastJumpTime = now
            end
        end
    end) end
end

-- ========== NO FALL DAMAGE ==========
local NoFallConn = nil
local function toggleNoFall(v)
    if v then
        if NoFallConn then return end
        NoFallConn = RunService.Heartbeat:Connect(function()
            local root = cachedChar and cachedChar:FindFirstChild("HumanoidRootPart")
            if root and cachedHumanoid and cachedHumanoid.Health > 0 and root.AssemblyLinearVelocity.Y < -55 then
                local rayParam = RaycastParams.new(); rayParam.FilterDescendantsInstances = {cachedChar}; rayParam.FilterType = Enum.RaycastFilterType.Exclude
                if workspace:Raycast(root.Position, Vector3.new(0,-10,0), rayParam) then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -2, root.AssemblyLinearVelocity.Z)
                end
            end
        end)
    else if NoFallConn then NoFallConn:Disconnect(); NoFallConn = nil end end
end

-- ========== GUN MODS ==========
local function disableRecoil()
    pcall(function()
        local rh = ReplicatedStorage:FindFirstChild("Gun") and ReplicatedStorage.Gun:FindFirstChild("Scripts") and ReplicatedStorage.Gun.Scripts:FindFirstChild("RecoilHandler")
        if rh then local m = require(rh); if m then if m.nextStep then m.nextStep = function() end end; if m.NextStep then m.NextStep = function() end end; if m.RecoilMultiplier then m.RecoilMultiplier = 0 end end end
    end)
end

local nospread = false
local function applyNoSpread()
    if nospread then return end
    pcall(function() local gc = require(ReplicatedStorage.Gun.Scripts.GunClient); if gc then if gc.getBulletSpread then gc.getBulletSpread = function() return 0 end end; if gc.updateSpreadMult then gc.updateSpreadMult = function() end end end end)
    pcall(function() local um = require(ReplicatedStorage.Gun.Scripts.Utils); if um then local t = um.randomUtils or um; if t.applySpreadToDirection then t.applySpreadToDirection = function(d,s) return d end end; if t.applyGaussianSpreadToDirection then t.applyGaussianSpreadToDirection = function(d,s) return d end end end end)
    nospread = true
end

local function applyNoSway()
    pcall(function() local gc = ReplicatedStorage:FindFirstChild("Gun") and ReplicatedStorage.Gun:FindFirstChild("Scripts") and ReplicatedStorage.Gun.Scripts:FindFirstChild("GunClient"); if gc then local m = require(gc); if m.swayIntensity then m.swayIntensity = 0 end; if m.SwayIntensity then m.SwayIntensity = 0 end end end)
end

local eokaDone = false
local function instantEoka()
    if eokaDone then return end
    pcall(function()
        if ReplicatedStorage:FindFirstChild("Guns") then
            local ef = ReplicatedStorage.Guns:FindFirstChild("EokaFolder")
            if ef and ef:FindFirstChild("Scripts") and ef.Scripts:FindFirstChild("EokaClient") then
                local m = require(ef.Scripts.EokaClient); if m.startFiring then m.startFiring = function() end end; eokaDone = true
            end
        end
    end)
end

local csp = {}
local function canShoot(v)
    if v then
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            if d:IsA("ModuleScript") and d.Name:find("Client") then
                local s, m = pcall(require, d)
                if s and type(m) == "table" then for k, val in pairs(m) do
                    if type(k) == "string" and k:lower():find("canfire") and type(val) == "function" then
                        if not m["_o_"..k] then m["_o_"..k] = val; table.insert(csp, {m,k}) end; m[k] = function() return true end
                    end
                end end
            end
        end
    else
        for _, data in ipairs(csp) do if data[1] and data[1]["_o_"..data[2]] then data[1][data[2]] = data[1]["_o_"..data[2]]; data[1]["_o_"..data[2]] = nil end end; csp = {}
    end
end

-- ========== FOV / THIRD PERSON / STRETCH ==========
local FOVSettings = { Enabled = false, Value = 70 }
local ThirdPersonSettings = { Enabled = false, Distance = 10 }
local StretchSettings = { Enabled = false, Value = 0.65 }

-- ========== FULLBRIGHT ==========
local OL = { Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient }
local FB = { Enabled = false, Conn = nil }
local function ToggleFB(st)
    FB.Enabled = st
    if st then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(178,178,178)
        if not FB.Conn then FB.Conn = Lighting.Changed:Connect(function() if FB.Enabled then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(178,178,178) end end) end
    else if FB.Conn then FB.Conn:Disconnect(); FB.Conn = nil end
        Lighting.Brightness = OL.Brightness; Lighting.ClockTime = OL.ClockTime; Lighting.FogEnd = OL.FogEnd; Lighting.GlobalShadows = OL.GlobalShadows; Lighting.Ambient = OL.Ambient end
end

-- ========== SKYBOX / SKY COLOR ==========
local SkyData = {
    ["Sky 1"] = { Bk = 271042516, Dn = 271077243, Ft = 271042556, Lf = 271042310, Rt = 271042467, Up = 271077958 },
    ["Sky 2"] = { Bk = 17279854976, Dn = 17279856318, Ft = 17279858447, Lf = 17279860360, Rt = 17279862234, Up = 17279864507 },
    ["Sky 3"] = { Bk = 12064107, Dn = 12064152, Ft = 12064121, Lf = 12063984, Rt = 12064115, Up = 12064131 }
}
local SkyColorSettings = { Enabled = false, Color = Color3.fromRGB(135,200,255) }; local skyFx = nil

-- ========== FORCEFIELD CHAMS ==========
local ForceFieldSettings = { Enabled = false, Color = Color3.fromRGB(128,128,128) }
local function UpdateFF()
    if cachedChar and ForceFieldSettings.Enabled then
        for _, p in pairs(cachedChar:GetDescendants()) do if p:IsA("BasePart") then p.Material = Enum.Material.ForceField; p.Color = ForceFieldSettings.Color end end
    end
end

-- ========== ARM/WEAPON CHAMS ==========
local armChamsColor = Color3.fromRGB(64,224,208); local weaponChamsColor = Color3.fromRGB(30,144,255)
local function applyArmChams() if cachedChar then for _, p in pairs(cachedChar:GetDescendants()) do if p:IsA("BasePart") and (p.Name:find("Arm") or p.Name:find("Hand")) then local hl = Instance.new("Highlight", p); hl.Name = "VoidArm"; hl.FillColor = armChamsColor; hl.OutlineColor = armChamsColor; hl.FillTransparency = 0.3 end end end end
local function removeArmChams() if cachedChar then for _, p in pairs(cachedChar:GetDescendants()) do local hl = p:FindFirstChild("VoidArm"); if hl then hl:Destroy() end end end end
local function applyWeaponChams()
    local function at(c) if c then for _, t in pairs(c:GetChildren()) do if t:IsA("Tool") then for _, p in pairs(t:GetDescendants()) do if p:IsA("BasePart") then local hl = Instance.new("Highlight", p); hl.Name = "VoidWep"; hl.FillColor = weaponChamsColor; hl.OutlineColor = weaponChamsColor; hl.FillTransparency = 0.3 end end end end end end
    at(LocalPlayer:FindFirstChild("Backpack")); at(cachedChar)
end
local function removeWeaponChams()
    local function rf(c) if c then for _, t in pairs(c:GetChildren()) do for _, p in pairs(t:GetDescendants()) do local hl = p:FindFirstChild("VoidWep"); if hl then hl:Destroy() end end end end end
    rf(LocalPlayer:FindFirstChild("Backpack")); rf(cachedChar)
end

-- ========== HEMP ESP ==========
local HempESPSettings = { Enabled = false, Radius = 300, Color = Color3.fromRGB(0,255,0) }; local hempHL = {}
local function updateHempESP()
    for _, hl in pairs(hempHL) do if hl and hl.Parent then hl:Destroy() end end; hempHL = {}
    if not HempESPSettings.Enabled then return end
    local hf = workspace:FindFirstChild("Hemp"); if not hf then return end
    local pp = cachedChar and cachedChar:FindFirstChild("HumanoidRootPart") and cachedChar.HumanoidRootPart.Position; if not pp then return end
    for _, obj in ipairs(hf:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local op = obj:IsA("Model") and obj:GetPivot().Position or obj.Position; local dist = (op-pp).Magnitude
            if dist <= HempESPSettings.Radius then
                local hl = Instance.new("Highlight"); hl.FillColor = HempESPSettings.Color; hl.OutlineColor = HempESPSettings.Color; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0.3; hl.Enabled = true
                hl.Adornee = obj:IsA("Model") and (obj.PrimaryPart or obj) or obj; hl.Parent = CoreGui; table.insert(hempHL, hl)
                local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0,200,0,30); bb.StudsOffset = Vector3.new(0,2,0); bb.AlwaysOnTop = true; bb.Parent = obj:IsA("Model") and (obj.PrimaryPart or obj) or obj
                local tl = Instance.new("TextLabel", bb); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = "Hemp\n"..math.floor(dist).."m"; tl.TextColor3 = HempESPSettings.Color; tl.TextSize = 14; tl.Font = Enum.Font.SourceSansBold; table.insert(hempHL, bb)
            end
        end
    end
end

-- ========== ORE ESP ==========
local StoneESPSettings = { Enabled = false, Radius = 300, Color = Color3.fromRGB(128,128,128) }
local IronESPSettings = { Enabled = false, Radius = 300, Color = Color3.fromRGB(139,69,19) }
local SulfurESPSettings = { Enabled = false, Radius = 300, Color = Color3.fromRGB(0,100,0) }; local oreHL = {}
local function updateOreESP()
    for _, hl in pairs(oreHL) do pcall(function() if hl and hl.Parent then hl:Destroy() end end) end; oreHL = {}
    local of = workspace:FindFirstChild("ores"); if not of then return end
    local pp = cachedChar and cachedChar:FindFirstChild("HumanoidRootPart") and cachedChar.HumanoidRootPart.Position; if not pp then return end
    for _, obj in ipairs(of:GetChildren()) do
        local objName = obj.Name:lower(); local settings = nil; local label = ""
        if objName:find("stone") then if not StoneESPSettings.Enabled then continue end; settings = StoneESPSettings; label = "Stone"
        elseif objName:find("iron") then if not IronESPSettings.Enabled then continue end; settings = IronESPSettings; label = "Iron"
        elseif objName:find("sulfur") then if not SulfurESPSettings.Enabled then continue end; settings = SulfurESPSettings; label = "Sulfur"
        else continue end
        local op = obj:IsA("Model") and obj:GetPivot().Position or obj.Position; local dist = (op-pp).Magnitude
        if dist <= settings.Radius then
            local hl = Instance.new("Highlight"); hl.FillColor = settings.Color; hl.OutlineColor = settings.Color; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0.3; hl.Enabled = true
            hl.Adornee = obj:IsA("Model") and (obj.PrimaryPart or obj) or obj; hl.Parent = CoreGui; table.insert(oreHL, hl)
            local attachTo = obj:IsA("Model") and (obj.PrimaryPart or obj) or obj
            if attachTo then
                local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0,200,0,30); bb.StudsOffset = Vector3.new(0,2,0); bb.AlwaysOnTop = true; bb.Parent = attachTo
                local tl = Instance.new("TextLabel", bb); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = label.."\n"..math.floor(dist).."m"; tl.TextColor3 = settings.Color; tl.TextSize = 14; tl.Font = Enum.Font.SourceSansBold; tl.TextStrokeTransparency = 0.5; table.insert(oreHL, bb)
            end
        end
    end
end

-- ========== HITBOX EXPANDER ==========
local HitboxSettings = { Enabled = false, Size = Vector3.new(5,5,5), Show = false, Color = Color3.fromRGB(0,100,255) }; local origSizes = {}
local function applyHitbox()
    for _, pl in ipairs(Players:GetPlayers()) do if pl ~= LocalPlayer and pl.Character then for _, p in ipairs(pl.Character:GetChildren()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then if not origSizes[p] then origSizes[p] = p.Size end; p.Size = origSizes[p] + HitboxSettings.Size; p.CanCollide = false
        if HitboxSettings.Show then local hl = p:FindFirstChild("VH"); if not hl then hl = Instance.new("Highlight", p); hl.Name = "VH"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end; hl.FillColor = HitboxSettings.Color; hl.OutlineColor = HitboxSettings.Color; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0.5; hl.Enabled = true end
    end end end end
end
local function restoreHitbox() for p, s in pairs(origSizes) do if p and p.Parent then p.Size = s; p.CanCollide = true end; local hl = p and p:FindFirstChild("VH"); if hl then hl:Destroy() end end; origSizes = {} end

-- ========== DELETE SPIKES ==========
local spikesConn = nil
local function toggleSpikes(v)
    if v then for _, o in ipairs(workspace:GetDescendants()) do if o.Name == "Spikes" then pcall(function() o:Destroy() end) end end
        if spikesConn then pcall(function() spikesConn:Disconnect() end) end
        spikesConn = workspace.DescendantAdded:Connect(function(o) if o.Name == "Spikes" then task.defer(function() pcall(function() o:Destroy() end) end) end end)
    else if spikesConn then pcall(function() spikesConn:Disconnect() end); spikesConn = nil end end
end

-- ========== MOD LIST ==========
local ModListGUI = nil
local function createModList()
    if ModListGUI then ModListGUI:Destroy() end
    local sg = Instance.new("ScreenGui", gethui()); sg.Name = "VoidModList"
    local mf = Instance.new("Frame", sg); mf.Size = UDim2.new(0,200,0,300); mf.Position = UDim2.new(1,-220,0.5,-150); mf.BackgroundTransparency = 1; mf.Active = true; mf.Draggable = true
    local t = Instance.new("TextLabel", mf); t.Size = UDim2.new(1,0,0,20); t.BackgroundTransparency = 1; t.Text = "ModList"; t.TextColor3 = Color3.fromRGB(255,255,255); t.TextSize = 14; t.Font = Enum.Font.Code
    local lc = Instance.new("Frame", mf); lc.Size = UDim2.new(1,0,1,-25); lc.Position = UDim2.new(0,0,0,25); lc.BackgroundTransparency = 1; Instance.new("UIListLayout", lc).SortOrder = Enum.SortOrder.LayoutOrder
    for _, pl in ipairs(Players:GetPlayers()) do if pl ~= LocalPlayer then local s, r = pcall(function() return pl:GetRoleInGroup(15631191) end)
        if s and r and r ~= "Guest" then local l = Instance.new("TextLabel", lc); l.Size = UDim2.new(1,0,0,16); l.BackgroundTransparency = 1; l.Text = pl.Name.." - "..r; l.TextColor3 = Color3.fromRGB(255,255,255); l.TextSize = 12; l.Font = Enum.Font.Code end
    end end
    if #lc:GetChildren() == 1 then local el = Instance.new("TextLabel", lc); el.Size = UDim2.new(1,0,0,16); el.BackgroundTransparency = 1; el.Text = "No moderators online"; el.TextColor3 = Color3.fromRGB(180,180,180); el.TextSize = 12 end
    ModListGUI = sg
end

-- ========== JUMP CIRCLES ==========
local JumpCircleSettings = { Enabled = false, Color = Color3.fromRGB(0,170,255) }
local function setupJC(ch)
    local h = ch:WaitForChild("Humanoid", 10)
    if h then h.StateChanged:Connect(function(_, new) if new == Enum.HumanoidStateType.Jumping and JumpCircleSettings.Enabled then
        local r = cachedChar and cachedChar:FindFirstChild("HumanoidRootPart")
        if r then local p = Instance.new("Part", workspace); p.Anchored = true; p.CanCollide = false; p.Material = Enum.Material.Neon; p.Color = JumpCircleSettings.Color
            p.CFrame = CFrame.new(r.Position - Vector3.new(0,2.9,0)) * CFrame.Angles(math.rad(90),0,0)
            local m = Instance.new("SpecialMesh", p); m.MeshId = "rbxassetid://3270017"; m.MeshType = Enum.MeshType.FileMesh
            TweenService:Create(p, TweenInfo.new(0.4), {Transparency = 1}):Play()
            TweenService:Create(m, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = Vector3.new(8,8,0.2)}):Play()
            task.delay(0.4, function() pcall(function() if p then p:Destroy() end end) end)
        end
    end end) end
end
if LocalPlayer.Character then setupJC(LocalPlayer.Character) end; LocalPlayer.CharacterAdded:Connect(setupJC)

-- ========== ESP SYSTEM ==========
local MiscOptions = { ["Enabled"] = true, ["Render Distance"] = 200, ["ChamsEnabled"] = false, ["Chams Fill"] = {Color = Color3.fromRGB(255,0,0), Transparency = 0.9}, ["Chams Outline"] = {Color = Color3.fromRGB(255,0,0), Transparency = 0.4}, ["Boxes"] = true, ["Healthbar"] = true, ["Name_Text"] = true, ["Distance_Text"] = true, ["Weapon_Text"] = true }
if getgenv().Esp then getgenv().Esp.Unload() end
getgenv().Esp = { Players = {}, ScreenGui = Instance.new("ScreenGui", CoreGui), Cache = Instance.new("ScreenGui", gethui()), Connections = {} }
do
    local Esp = getgenv().Esp; Esp.ScreenGui.IgnoreGuiInset = true; Esp.ScreenGui.Name = "EspObject"; Esp.Cache.Enabled = false
    function Esp:Create(i, o) local ins = Instance.new(i); for p, v in o do ins[p] = v end; return ins end
    function Esp:ConvertScreenPoint(wp) local vs = Camera.ViewportSize; local lp = Camera.CFrame:pointToObjectSpace(wp); local ar = vs.X/vs.Y; local hy = -lp.Z*math.tan(math.rad(Camera.FieldOfView/2)); local hx = ar*hy; local fc = Vector3.new(-hx,hy,lp.Z); local rp = lp-fc; local sx = rp.X/(hx*2); local sy = -rp.Y/(hy*2); local os = -lp.Z>0 and sx>=0 and sx<=1 and sy>=0 and sy<=1; return Vector3.new(sx*vs.X, sy*vs.Y, -lp.Z), os end
    function Esp:Connection(s, cb) local c = s:Connect(cb); Esp.Connections[#Esp.Connections+1] = c; return c end
    function Esp:BoxSolve(torso) if not torso then return nil,nil,nil end; local vt = torso.Position + (torso.CFrame.UpVector*1.8) + Camera.CFrame.UpVector; local vb = torso.Position - (torso.CFrame.UpVector*2.5) - Camera.CFrame.UpVector; local d = (torso.Position-Camera.CFrame.p).Magnitude; local nd = math.floor(d*0.333); local t,tir = Esp:ConvertScreenPoint(vt); local b,bir = Esp:ConvertScreenPoint(vb); if not tir or not bir then return nil,nil,false,nd end; local w = math.max(math.floor(math.abs(t.X-b.X)),8); local h = math.max(math.floor(math.max(math.abs(b.Y-t.Y),w/2)),12); return Vector2.new(math.floor(math.max(h/1.5,w)),h), Vector2.new(math.floor(t.X*0.5+b.X*0.5-math.floor(math.max(h/1.5,w))*0.5), math.floor(math.min(t.Y,b.Y))), true, nd end
    function Esp.CreateObject(player) local Data = {Items={}, Info={Character=nil, Humanoid=nil, Health=0}}; local Items = Data.Items
        Items.Holder = Esp:Create("Frame", {Parent=Esp.ScreenGui, Visible=false, BackgroundTransparency=1, Size=UDim2.new(0,100,0,100), BorderSizePixel=0})
        Items.Box = Esp:Create("Frame", {Parent=Items.Holder, BackgroundTransparency=1, Position=UDim2.new(0,1,0,1), Size=UDim2.new(1,-2,1,-2), BorderSizePixel=0})
        Esp:Create("UIStroke", {Parent=Items.Box, LineJoinMode=Enum.LineJoinMode.Miter, Color=Color3.fromRGB(255,255,255), Thickness=1.5})
        Items.Healthbar = Esp:Create("Frame", {Parent=Items.Holder, Size=UDim2.new(0,3,1,0), Position=UDim2.new(0,-5,0,0), BorderSizePixel=0, BackgroundColor3=Color3.fromRGB(30,30,30)})
        Items.HealthbarFill = Esp:Create("Frame", {Parent=Items.Healthbar, Size=UDim2.new(1,0,1,0), Position=UDim2.new(0,0,1,0), AnchorPoint=Vector2.new(0,1), BorderSizePixel=0, BackgroundColor3=Color3.fromRGB(0,255,0)})
        Items.NameText = Esp:Create("TextLabel", {Parent=Items.Holder, Text=player.Name, BackgroundTransparency=1, Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,-16), TextSize=12, TextXAlignment=Enum.TextXAlignment.Center, TextColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0})
        Items.DistanceText = Esp:Create("TextLabel", {Parent=Items.Holder, Text="0m", BackgroundTransparency=1, Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,2), TextSize=12, TextXAlignment=Enum.TextXAlignment.Center, TextColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0})
        Items.WeaponText = Esp:Create("TextLabel", {Parent=Items.Holder, Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,0,-30), TextSize=10, TextXAlignment=Enum.TextXAlignment.Center, TextColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0})
        Data.RefreshChams = function() if not Data.Highlight then Data.Highlight = Esp:Create("Highlight", {FillColor=MiscOptions["Chams Fill"].Color, Enabled=MiscOptions["ChamsEnabled"], Adornee=Data.Info.Character, FillTransparency=MiscOptions["Chams Fill"].Transparency, OutlineColor=MiscOptions["Chams Outline"].Color, OutlineTransparency=MiscOptions["Chams Outline"].Transparency, Parent=CoreGui}) else Data.Highlight.Adornee = Data.Info.Character end end
        Data.ToolAdded = function(item) if item:IsA("Tool") then Items.WeaponText.Text = "["..item.Name.."]" end end
        Data.ToolRemoved = function() if not Data.Info.Character or not Data.Info.Character:FindFirstChildOfClass("Tool") then Items.WeaponText.Text = "" end end
        Data.HealthChanged = function(Value) local m = math.clamp(Value/Data.Info.Humanoid.MaxHealth,0,1); local c = m<0.5 and Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(255,193,0),m*2) or Color3.fromRGB(255,193,0):Lerp(Color3.fromRGB(0,255,0),(m-0.5)*2); Items.HealthbarFill.Size = UDim2.new(1,0,m,0); Items.HealthbarFill.BackgroundColor3 = c end
        Data.RefreshDescendants = function() local Character = player.Character or player.CharacterAdded:Wait(); local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid"); Data.Info.Character = Character; Data.Info.Humanoid = Humanoid; Esp:Connection(Humanoid.HealthChanged, Data.HealthChanged); Esp:Connection(Character.ChildAdded, Data.ToolAdded); Esp:Connection(Character.ChildRemoved, Data.ToolRemoved); Data.HealthChanged(Humanoid.Health); Data.RefreshChams() end
        Data.Destroy = function() pcall(function() if Items["Holder"] then Items["Holder"]:Destroy() end end); pcall(function() if Data.Highlight then Data.Highlight:Destroy() end end); if Esp.Players[player.Name] then Esp.Players[player.Name] = nil end end
        Data.RefreshDescendants(); Esp:Connection(player.CharacterAdded, Data.RefreshDescendants); Esp.Players[player.Name] = Data; return Data
    end
    function Esp.Update() if not Esp or not MiscOptions.Enabled then return end; for _, Data in Esp.Players do if not Data.Info or not Data.Info.Character or not Data.Info.Humanoid then continue end; local Items = Data.Items; if not Items then continue end; local bs,bp,os,d = Esp:BoxSolve(Data.Info.Humanoid.RootPart); local h = Items["Holder"]; if not h then continue end; if d==nil or not os or d>MiscOptions["Render Distance"] then if h.Visible then h.Visible = false end; continue end; h.Visible = true; h.Position = UDim2.fromOffset(bp.X,bp.Y); h.Size = UDim2.new(0,bs.X,0,bs.Y); Items.DistanceText.Text = tostring(math.round(d)).."m"; Items.Box.Visible = MiscOptions.Boxes; Items.Healthbar.Visible = MiscOptions.Healthbar; Items.NameText.Visible = MiscOptions.Name_Text; Items.DistanceText.Visible = MiscOptions.Distance_Text; Items.WeaponText.Visible = MiscOptions.Weapon_Text end end
    function Esp.RefreshElements(k,v) for _, Data in Esp.Players do local Items = Data and Data.Items; if not Items or not Items.Holder then continue end; if k=="Enabled" then Items.Holder.Visible = v elseif k=="Boxes" then Items.Box.Visible = v elseif k=="Healthbar" then Items.Healthbar.Visible = v elseif k=="Name_Text" then Items.NameText.Visible = v elseif k=="Distance_Text" then Items.DistanceText.Visible = v elseif k=="Weapon_Text" then Items.WeaponText.Visible = v elseif k=="ChamsEnabled" and Data.Highlight then Data.Highlight.Enabled = v elseif k=="Chams Fill" and Data.Highlight then Data.Highlight.FillColor = v.Color; Data.Highlight.FillTransparency = 1-v.Transparency elseif k=="Chams Outline" and Data.Highlight then Data.Highlight.OutlineColor = v.Color; Data.Highlight.OutlineTransparency = 1-v.Transparency end end end
    function Esp.Unload() for _, pl in Players:GetPlayers() do Esp.RemovePlayer(pl) end; for _, c in Esp.Connections do c:Disconnect() end; if Esp.Loop then RunService:UnbindFromRenderStep("Run Loop"); Esp.Loop = nil end; pcall(function() Esp.Cache:Destroy() end); pcall(function() Esp.ScreenGui:Destroy() end); getgenv().Esp = nil end
    function Esp.RemovePlayer(pl) local p = Esp.Players[pl.Name]; if p then p.Destroy() end end
    Esp.Loop = RunService:BindToRenderStep("Run Loop", 400, Esp.Update)
    for _, pl in ipairs(Players:GetPlayers()) do if pl ~= LocalPlayer then Esp.CreateObject(pl) end end
    Players.PlayerAdded:Connect(function(pl) if pl == LocalPlayer then return end; pl.CharacterAdded:Connect(function() task.wait(0.2); if not Esp.Players[pl.Name] then Esp.CreateObject(pl) end end) end)
    Players.PlayerRemoving:Connect(function(pl) Esp.RemovePlayer(pl) end)
end
local function upd() if not getgenv().Esp or not getgenv().Esp.RefreshElements then return end; for k,v in pairs(MiscOptions) do getgenv().Esp.RefreshElements(k,v) end end

-- ========== RENDER LOOP ==========
task.spawn(function()
    local lastHemp, lastOre = 0, 0
    while true do
        RunService.RenderStepped:Wait()
        updateAimTarget()
        local mp = UserInputService:GetMouseLocation()
        FOVCircle.Position = mp; FOVCircle.Radius = SilentAimSettings.FOVRadius; FOVCircle.Color = FOVCircleSettings.Color; FOVCircle.Filled = FOVCircleSettings.Filled
        if FOVCircleSettings.Filled then FOVCircle.Transparency = FOVCircleSettings.FilledTransparency end
        FOVCircle.Thickness = FOVCircleSettings.OutlineThickness; FOVCircle.NumSides = FOVCircleSettings.Sides; FOVCircle.Visible = SilentAimSettings.FOVVisible
        AimbotFOV.Position = mp; AimbotFOV.Radius = AimbotSettings.FOVRadius; AimbotFOV.Visible = AimbotSettings.FOVVisible
        if FOVSettings.Enabled and Camera then Camera.FieldOfView = FOVSettings.Value end
        if StretchSettings.Enabled and Camera then Camera.CFrame = Camera.CFrame * CFrame.new(0,0,0,1,0,0,0,StretchSettings.Value,0,0,0,1) end
        if ThirdPersonSettings.Enabled and Camera and cachedChar then local hrp = cachedChar:FindFirstChild("HumanoidRootPart"); if hrp then Camera.CFrame = CFrame.new(hrp.Position - (Camera.CFrame.LookVector*ThirdPersonSettings.Distance), hrp.Position) end end
        if ForceFieldSettings.Enabled and tick()%3<0.016 then UpdateFF() end
        if HempESPSettings.Enabled and tick()-lastHemp>1 then lastHemp = tick(); updateHempESP() end
        if (StoneESPSettings.Enabled or IronESPSettings.Enabled or SulfurESPSettings.Enabled) and tick()-lastOre>1 then lastOre = tick(); updateOreESP() end
    end
end)

-- ========== UI TABS ==========
local CombatGroup = Tabs.Combat:AddLeftGroupbox('Silent Aim')
CombatGroup:AddToggle('SilentAimEnabled', {Text = 'Silent Aim', Default = false})
CombatGroup:AddDropdown('TargetPart', {Text = 'Target Part', Default = 'Head', Values = ValidTargetParts, Multi = false})
CombatGroup:AddSlider('HitChance', {Text = 'Hit Chance', Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = '%'})

local AimbotGroup = Tabs.Combat:AddLeftGroupbox('Aimbot (Legit)')
AimbotGroup:AddToggle('AimbotEnabled', {Text = 'Aimbot (Hold RMB)', Default = false})
AimbotGroup:AddSlider('AimbotSmooth', {Text = 'Smooth', Default = 1, Min = 1, Max = 20, Rounding = 1})
AimbotGroup:AddToggle('AimbotFOVVisible', {Text = 'Show Aimbot FOV', Default = false})
AimbotGroup:AddSlider('AimbotFOVRadius', {Text = 'Aimbot FOV Radius', Default = 130, Min = 30, Max = 500, Rounding = 0, Suffix = 'px'})

local FOVCircleGroup = Tabs.Combat:AddLeftGroupbox('Silent FOV Circle')
FOVCircleGroup:AddToggle('FOVVisible', {Text = 'Show FOV Circle', Default = false})
FOVCircleGroup:AddLabel('Color'):AddColorPicker('FOVCircleColor', {Default = Color3.fromRGB(255,0,255), Title = 'FOV Color'})
FOVCircleGroup:AddSlider('FOVRadius', {Text = 'Radius', Default = 130, Min = 30, Max = 500, Rounding = 0, Suffix = 'px'})
FOVCircleGroup:AddToggle('FOVFilled', {Text = 'Filled', Default = false})
FOVCircleGroup:AddSlider('FOVFilledTransparency', {Text = 'Fill Transparency', Default = 0.5, Min = 0, Max = 1, Rounding = 2})
FOVCircleGroup:AddSlider('FOVOutlineThickness', {Text = 'Outline Thickness', Default = 1, Min = 1, Max = 10, Rounding = 0})
FOVCircleGroup:AddSlider('FOVSides', {Text = 'Sides', Default = 100, Min = 3, Max = 100, Rounding = 0})

local GunModsGroup = Tabs.Combat:AddRightGroupbox('Gun Mods')
GunModsGroup:AddToggle('NoRecoilEnabled', {Text = 'No Recoil', Default = false})
GunModsGroup:AddToggle('NoSpreadEnabled', {Text = 'No Spread', Default = false})
GunModsGroup:AddToggle('NoSwayEnabled', {Text = 'No Sway', Default = false})
GunModsGroup:AddToggle('InstantEoka', {Text = 'Instant Eoka', Default = false})
GunModsGroup:AddToggle('CanShoot', {Text = 'Can Shoot (AW)', Default = false})

local BTG = Tabs.Combat:AddRightGroupbox('Bullet Tracers')
BTG:AddToggle('BulletTrace', {Text = 'Enabled', Default = false})
BTG:AddLabel('Color'):AddColorPicker('TraceColor', {Default = Color3.fromRGB(255,255,255), Title = 'Trace Color'})
BTG:AddDropdown('BulletTracersTexture', {Values = {"Beam","Lightning","Heartrate","Chain","Glitch","Swirl"}, Default = 1, Multi = false, Text = 'Texture'})
BTG:AddSlider('TracerWidth', {Text = 'Width', Min = 0.1, Max = 5, Default = 1.5, Rounding = 1})
BTG:AddSlider('TracerTransparency', {Text = 'Transparency', Min = 0, Max = 1, Default = 0, Rounding = 2})
BTG:AddSlider('TracerLifeTime', {Text = 'Life Time', Min = 0.1, Max = 3, Default = 0.5, Rounding = 1})

local HSGroup = Tabs.Combat:AddRightGroupbox('Hit Sounds')
HSGroup:AddToggle('HitSoundEnabled', {Text = 'Enabled', Default = false})
HSGroup:AddDropdown('HitSoundChoice', {Values = HSNames, Default = 1, Multi = false, Text = 'Sound'})
HSGroup:AddSlider('HitSoundVolume', {Text = 'Volume', Min = 0, Max = 10, Default = 1, Rounding = 1})

local MoveGroup = Tabs.Exploit:AddLeftGroupbox('Movement')
MoveGroup:AddToggle('SpeedEnabled', {Text = 'Speed', Default = false}); MoveGroup:AddSlider('SpeedValue', {Text = 'Value', Min = 0, Max = 60, Default = 30, Rounding = 0})
MoveGroup:AddToggle('WaterSpeed', {Text = 'Swim Speed', Default = false}); MoveGroup:AddSlider('SwimSpeedVal', {Text = 'Value', Min = 20, Max = 200, Default = 50, Rounding = 0})
MoveGroup:AddToggle('NoJumpDelay', {Text = 'No Jump Delay', Default = false}); MoveGroup:AddSlider('NoJumpDelayVal', {Text = 'Delay', Default = 0.1, Min = 0, Max = 0.5, Rounding = 2})
MoveGroup:AddToggle('JumpStunEnabled', {Text = 'Super Jump', Default = false}); MoveGroup:AddSlider('JumpStunHeight', {Text = 'Height', Default = 100, Min = 60, Max = 200, Rounding = 0})
MoveGroup:AddToggle('SpiderEnabled', {Text = 'Spider Climb', Default = false}); MoveGroup:AddSlider('SpiderSpeed', {Text = 'Speed', Default = 50, Min = 20, Max = 150, Rounding = 0})
MoveGroup:AddToggle('NoFallEnabled', {Text = 'No Fall Damage', Default = false})

local FarmGroup = Tabs.Exploit:AddLeftGroupbox('Auto Farm (Trees + Ores)')
FarmGroup:AddToggle('FarmEnabled', {Text = 'Auto Farm', Default = false})
FarmGroup:AddSlider('FarmRange', {Text = 'Range', Default = 20, Min = 5, Max = 50, Rounding = 0, Suffix = ' studs'})
FarmGroup:AddSlider('FarmDelay', {Text = 'Hit Delay', Default = 0.5, Min = 0.1, Max = 2, Rounding = 2, Suffix = 's'})

local HitboxGroup = Tabs.Exploit:AddRightGroupbox('Hitbox Expander')
HitboxGroup:AddToggle('HitboxEnabled', {Text = 'Hitbox Expander (Wallhack)', Default = false})
HitboxGroup:AddToggle('ShowHitbox', {Text = 'Show Hitbox', Default = false})
HitboxGroup:AddLabel('Color'):AddColorPicker('HitboxColor', {Default = Color3.fromRGB(0,100,255), Title = 'Hitbox Color'})
HitboxGroup:AddSlider('HitboxX', {Text = 'X Size', Min = 0, Max = 15, Default = 5, Rounding = 1})
HitboxGroup:AddSlider('HitboxY', {Text = 'Y Size', Min = 0, Max = 15, Default = 5, Rounding = 1})
HitboxGroup:AddSlider('HitboxZ', {Text = 'Z Size', Min = 0, Max = 15, Default = 5, Rounding = 1})

local OtherExploit = Tabs.Exploit:AddRightGroupbox('Other')
OtherExploit:AddToggle('DeleteSpikes', {Text = 'Delete Spikes', Default = false})
OtherExploit:AddToggle('ModListEnabled', {Text = 'Mod List', Default = false})

local PlayerESPGroup = Tabs.Visuals:AddLeftGroupbox('Player ESP')
PlayerESPGroup:AddToggle('ESPEnabled', {Text = 'Enabled', Default = true}); PlayerESPGroup:AddToggle('BoxesEnabled', {Text = 'Boxes', Default = true})
PlayerESPGroup:AddToggle('HealthbarEnabled', {Text = 'Healthbar', Default = true}); PlayerESPGroup:AddToggle('NameTextEnabled', {Text = 'Name', Default = true})
PlayerESPGroup:AddToggle('DistanceTextEnabled', {Text = 'Distance', Default = true}); PlayerESPGroup:AddToggle('WeaponTextEnabled', {Text = 'Weapon', Default = true})

local HempGroup = Tabs.Visuals:AddLeftGroupbox('Hemp ESP')
HempGroup:AddToggle('HempESPEnabled', {Text = 'Enabled', Default = false})
HempGroup:AddSlider('HempESPRadius', {Text = 'Radius', Default = 300, Min = 50, Max = 1000, Rounding = 0, Suffix = 'm'})
HempGroup:AddLabel('Color'):AddColorPicker('HempESPColor', {Default = Color3.fromRGB(0,255,0), Title = 'Hemp Color'})

local OreESPGroup = Tabs.Visuals:AddLeftGroupbox('Ore ESP')
OreESPGroup:AddToggle('StoneESPEnabled', {Text = 'Stone ESP', Default = false}); OreESPGroup:AddSlider('StoneESPRadius', {Text = 'Radius', Default = 300, Min = 50, Max = 1000, Rounding = 0, Suffix = 'm'})
OreESPGroup:AddToggle('IronESPEnabled', {Text = 'Iron ESP', Default = false}); OreESPGroup:AddSlider('IronESPRadius', {Text = 'Radius', Default = 300, Min = 50, Max = 1000, Rounding = 0, Suffix = 'm'})
OreESPGroup:AddToggle('SulfurESPEnabled', {Text = 'Sulfur ESP', Default = false}); OreESPGroup:AddSlider('SulfurESPRadius', {Text = 'Radius', Default = 300, Min = 50, Max = 1000, Rounding = 0, Suffix = 'm'})

local ChamsGroup = Tabs.Visuals:AddRightGroupbox('Player Chams')
ChamsGroup:AddToggle('ChamsEnabled', {Text = 'Enabled', Default = false})
ChamsGroup:AddLabel('Fill'):AddColorPicker('ChamsFillColor', {Default = Color3.fromRGB(255,0,0), Title = 'Fill Color'})
ChamsGroup:AddLabel('Outline'):AddColorPicker('ChamsOutlineColor', {Default = Color3.fromRGB(255,0,0), Title = 'Outline Color'})

local ArmChamsGroup = Tabs.Visuals:AddLeftGroupbox('Arm/Weapon Chams')
ArmChamsGroup:AddToggle('ArmChamsEnabled', {Text = 'Arm Chams', Default = false}); ArmChamsGroup:AddLabel('Color'):AddColorPicker('ArmChamsColor', {Default = Color3.fromRGB(64,224,208), Title = 'Arm Color'})
ArmChamsGroup:AddToggle('WeaponChamsEnabled', {Text = 'Weapon Chams', Default = false}); ArmChamsGroup:AddLabel('Color'):AddColorPicker('WeaponChamsColor', {Default = Color3.fromRGB(30,144,255), Title = 'Weapon Color'})

local FFGroup = Tabs.Visuals:AddLeftGroupbox('Local Player')
FFGroup:AddToggle('ForceFieldChams', {Text = 'ForceField', Default = false}); FFGroup:AddLabel('Color'):AddColorPicker('ForceFieldColor', {Default = Color3.fromRGB(128,128,128), Title = 'Color'})

local VOther = Tabs.Visuals:AddRightGroupbox('Features')
VOther:AddToggle('FOVChangerToggle', {Text = 'FOV Changer', Default = false}); VOther:AddSlider('FOVChangerValue', {Text = 'Value', Min = 50, Max = 120, Default = 70, Rounding = 0})
VOther:AddToggle('ThirdPersonToggle', {Text = 'Third Person', Default = false}); VOther:AddSlider('ThirdPersonDistance', {Text = 'Distance', Min = 5, Max = 50, Default = 10, Rounding = 0})
VOther:AddToggle('StretchToggle', {Text = 'Stretch', Default = false}); VOther:AddSlider('StretchValue', {Text = 'Amount', Default = 0.65, Min = 0.3, Max = 1.0, Rounding = 2})
VOther:AddToggle('JumpCircles', {Text = 'Jump Circles', Default = false}); VOther:AddLabel('Color'):AddColorPicker('JumpCircleColor', {Default = Color3.fromRGB(0,170,255), Title = 'Circle Color'})

local WorldGroup = Tabs.World:AddLeftGroupbox('World')
WorldGroup:AddToggle('Fullbright', {Text = 'Fullbright', Default = false})
WorldGroup:AddToggle('NoDecoration', {Text = 'No Decoration', Default = false})
WorldGroup:AddToggle('SkyColorToggle', {Text = 'Sky Color', Default = false}):AddColorPicker('SkyColorPicker', {Default = Color3.fromRGB(135,200,255), Title = 'Sky Color'})
WorldGroup:AddDropdown('SkyboxChanger', {Values = {"Default","Sky 1","Sky 2","Sky 3"}, Default = 1, Multi = false, Text = 'Skybox'})
WorldGroup:AddToggle('FakeGammaEnabled', {Text = 'Fake Gamma', Default = false})

-- ========== EVENT HANDLERS ==========
Toggles.SilentAimEnabled:OnChanged(function() SilentAimSettings.Enabled = Toggles.SilentAimEnabled.Value end)
Options.TargetPart:OnChanged(function() SilentAimSettings.TargetPart = Options.TargetPart.Value end)
Options.HitChance:OnChanged(function() SilentAimSettings.HitChance = Options.HitChance.Value end)

Toggles.AimbotEnabled:OnChanged(function() AimbotSettings.Enabled = Toggles.AimbotEnabled.Value end)
Options.AimbotSmooth:OnChanged(function() AimbotSettings.Smooth = Options.AimbotSmooth.Value end)
Toggles.AimbotFOVVisible:OnChanged(function() AimbotSettings.FOVVisible = Toggles.AimbotFOVVisible.Value end)
Options.AimbotFOVRadius:OnChanged(function() AimbotSettings.FOVRadius = Options.AimbotFOVRadius.Value end)

Toggles.FOVVisible:OnChanged(function() SilentAimSettings.FOVVisible = Toggles.FOVVisible.Value end)
Options.FOVCircleColor:OnChanged(function() FOVCircleSettings.Color = Options.FOVCircleColor.Value end)
Options.FOVRadius:OnChanged(function() SilentAimSettings.FOVRadius = Options.FOVRadius.Value end)
Toggles.FOVFilled:OnChanged(function() FOVCircleSettings.Filled = Toggles.FOVFilled.Value end)
Options.FOVFilledTransparency:OnChanged(function() FOVCircleSettings.FilledTransparency = Options.FOVFilledTransparency.Value end)
Options.FOVOutlineThickness:OnChanged(function() FOVCircleSettings.OutlineThickness = Options.FOVOutlineThickness.Value end)
Options.FOVSides:OnChanged(function() FOVCircleSettings.Sides = Options.FOVSides.Value end)

Toggles.NoRecoilEnabled:OnChanged(function() if Toggles.NoRecoilEnabled.Value then disableRecoil() end end)
Toggles.NoSpreadEnabled:OnChanged(function() if Toggles.NoSpreadEnabled.Value then applyNoSpread() end end)
Toggles.NoSwayEnabled:OnChanged(function() if Toggles.NoSwayEnabled.Value then applyNoSway() end end)
Toggles.InstantEoka:OnChanged(function() if Toggles.InstantEoka.Value then instantEoka() end end)
Toggles.CanShoot:OnChanged(function() canShoot(Toggles.CanShoot.Value) end)

Toggles.BulletTrace:OnChanged(function() TracerSettings.Enabled = Toggles.BulletTrace.Value end)
Options.TraceColor:OnChanged(function() TracerSettings.Color = Options.TraceColor.Value end)
Options.BulletTracersTexture:OnChanged(function(V) local m = {Beam="rbxassetid://12781852245",Lightning="rbxassetid://446111271",Heartrate="rbxassetid://5830549480",Chain="rbxassetid://9632168658",Glitch="rbxassetid://8089467613",Swirl="rbxassetid://5638168605"}; TracerSettings.TextureID = m[V] or m.Beam end)
Options.TracerWidth:OnChanged(function() TracerSettings.Width = Options.TracerWidth.Value end)
Options.TracerTransparency:OnChanged(function() TracerSettings.Transparency = Options.TracerTransparency.Value end)
Options.TracerLifeTime:OnChanged(function() TracerSettings.LifeTime = Options.TracerLifeTime.Value end)

Toggles.HitSoundEnabled:OnChanged(function() HitSoundSettings.Enabled = Toggles.HitSoundEnabled.Value; if HitSoundSettings.Enabled and cachedChar then applyHSChar(cachedChar); setupHSChar(cachedChar) else restoreHS() end end)
Options.HitSoundChoice:OnChanged(function() HitSoundSettings.Choice = Options.HitSoundChoice.Value; if HitSoundSettings.Enabled and cachedChar then applyHSChar(cachedChar) end end)
Options.HitSoundVolume:OnChanged(function() HitSoundSettings.Volume = Options.HitSoundVolume.Value; if HitSoundSettings.Enabled and cachedChar then applyHSChar(cachedChar) end end)

Toggles.FarmEnabled:OnChanged(function() FarmSettings.Enabled = Toggles.FarmEnabled.Value end)
Options.FarmRange:OnChanged(function() FarmSettings.Range = Options.FarmRange.Value end)
Options.FarmDelay:OnChanged(function() FarmSettings.HitDelay = Options.FarmDelay.Value end)

Toggles.SpeedEnabled:OnChanged(function() SpeedSettings.Enabled = Toggles.SpeedEnabled.Value end)
Options.SpeedValue:OnChanged(function() SpeedSettings.Value = Options.SpeedValue.Value end)
Toggles.WaterSpeed:OnChanged(function() WaterSpeed.Enabled = Toggles.WaterSpeed.Value end)
Options.SwimSpeedVal:OnChanged(function() WaterSpeed.Value = Options.SwimSpeedVal.Value end)
Toggles.NoJumpDelay:OnChanged(function() toggleNoJumpDelay(Toggles.NoJumpDelay.Value) end)
Options.NoJumpDelayVal:OnChanged(function() NoJumpDelaySettings.Delay = Options.NoJumpDelayVal.Value end)
Toggles.JumpStunEnabled:OnChanged(function() JumpStunSettings.Enabled = Toggles.JumpStunEnabled.Value end)
Options.JumpStunHeight:OnChanged(function() JumpStunSettings.Height = Options.JumpStunHeight.Value end)
Toggles.SpiderEnabled:OnChanged(function() SpiderSettings.Enabled = Toggles.SpiderEnabled.Value end)
Options.SpiderSpeed:OnChanged(function() SpiderSettings.Speed = Options.SpiderSpeed.Value end)
Toggles.NoFallEnabled:OnChanged(function() toggleNoFall(Toggles.NoFallEnabled.Value) end)

Toggles.HitboxEnabled:OnChanged(function() if Toggles.HitboxEnabled.Value then applyHitbox() else restoreHitbox() end end)
Options.HitboxX:OnChanged(function() HitboxSettings.Size = Vector3.new(Options.HitboxX.Value,Options.HitboxY.Value,Options.HitboxZ.Value); if Toggles.HitboxEnabled.Value then restoreHitbox(); applyHitbox() end end)
Options.HitboxY:OnChanged(function() HitboxSettings.Size = Vector3.new(Options.HitboxX.Value,Options.HitboxY.Value,Options.HitboxZ.Value); if Toggles.HitboxEnabled.Value then restoreHitbox(); applyHitbox() end end)
Options.HitboxZ:OnChanged(function() HitboxSettings.Size = Vector3.new(Options.HitboxX.Value,Options.HitboxY.Value,Options.HitboxZ.Value); if Toggles.HitboxEnabled.Value then restoreHitbox(); applyHitbox() end end)
Toggles.ShowHitbox:OnChanged(function() HitboxSettings.Show = Toggles.ShowHitbox.Value; if Toggles.HitboxEnabled.Value then restoreHitbox(); applyHitbox() end end)
Options.HitboxColor:OnChanged(function() HitboxSettings.Color = Options.HitboxColor.Value; if Toggles.HitboxEnabled.Value then restoreHitbox(); applyHitbox() end end)

Toggles.HempESPEnabled:OnChanged(function() HempESPSettings.Enabled = Toggles.HempESPEnabled.Value; updateHempESP() end)
Options.HempESPRadius:OnChanged(function() HempESPSettings.Radius = Options.HempESPRadius.Value; if HempESPSettings.Enabled then updateHempESP() end end)
Options.HempESPColor:OnChanged(function() HempESPSettings.Color = Options.HempESPColor.Value; if HempESPSettings.Enabled then updateHempESP() end end)

Toggles.StoneESPEnabled:OnChanged(function() StoneESPSettings.Enabled = Toggles.StoneESPEnabled.Value; updateOreESP() end)
Options.StoneESPRadius:OnChanged(function() StoneESPSettings.Radius = Options.StoneESPRadius.Value; if StoneESPSettings.Enabled then updateOreESP() end end)
Toggles.IronESPEnabled:OnChanged(function() IronESPSettings.Enabled = Toggles.IronESPEnabled.Value; updateOreESP() end)
Options.IronESPRadius:OnChanged(function() IronESPSettings.Radius = Options.IronESPRadius.Value; if IronESPSettings.Enabled then updateOreESP() end end)
Toggles.SulfurESPEnabled:OnChanged(function() SulfurESPSettings.Enabled = Toggles.SulfurESPEnabled.Value; updateOreESP() end)
Options.SulfurESPRadius:OnChanged(function() SulfurESPSettings.Radius = Options.SulfurESPRadius.Value; if SulfurESPSettings.Enabled then updateOreESP() end end)

Toggles.DeleteSpikes:OnChanged(function() toggleSpikes(Toggles.DeleteSpikes.Value) end)
Toggles.ModListEnabled:OnChanged(function() if Toggles.ModListEnabled.Value then createModList() else if ModListGUI then ModListGUI:Destroy(); ModListGUI = nil end end end)

Toggles.ESPEnabled:OnChanged(function() MiscOptions["Enabled"] = Toggles.ESPEnabled.Value; upd() end)
Toggles.BoxesEnabled:OnChanged(function() MiscOptions["Boxes"] = Toggles.BoxesEnabled.Value; upd() end)
Toggles.HealthbarEnabled:OnChanged(function() MiscOptions["Healthbar"] = Toggles.HealthbarEnabled.Value; upd() end)
Toggles.NameTextEnabled:OnChanged(function() MiscOptions["Name_Text"] = Toggles.NameTextEnabled.Value; upd() end)
Toggles.DistanceTextEnabled:OnChanged(function() MiscOptions["Distance_Text"] = Toggles.DistanceTextEnabled.Value; upd() end)
Toggles.WeaponTextEnabled:OnChanged(function() MiscOptions["Weapon_Text"] = Toggles.WeaponTextEnabled.Value; upd() end)
Toggles.ChamsEnabled:OnChanged(function() MiscOptions["ChamsEnabled"] = Toggles.ChamsEnabled.Value; upd() end)
Options.ChamsFillColor:OnChanged(function() MiscOptions["Chams Fill"].Color = Options.ChamsFillColor.Value; upd() end)
Options.ChamsOutlineColor:OnChanged(function() MiscOptions["Chams Outline"].Color = Options.ChamsOutlineColor.Value; upd() end)

Toggles.ArmChamsEnabled:OnChanged(function() if Toggles.ArmChamsEnabled.Value then applyArmChams() else removeArmChams() end end)
Options.ArmChamsColor:OnChanged(function() armChamsColor = Options.ArmChamsColor.Value; if Toggles.ArmChamsEnabled.Value then removeArmChams(); applyArmChams() end end)
Toggles.WeaponChamsEnabled:OnChanged(function() if Toggles.WeaponChamsEnabled.Value then applyWeaponChams() else removeWeaponChams() end end)
Options.WeaponChamsColor:OnChanged(function() weaponChamsColor = Options.WeaponChamsColor.Value; if Toggles.WeaponChamsEnabled.Value then removeWeaponChams(); applyWeaponChams() end end)

Toggles.ForceFieldChams:OnChanged(function() ForceFieldSettings.Enabled = Toggles.ForceFieldChams.Value; UpdateFF() end)
Options.ForceFieldColor:OnChanged(function() ForceFieldSettings.Color = Options.ForceFieldColor.Value; if ForceFieldSettings.Enabled then UpdateFF() end end)

Toggles.FOVChangerToggle:OnChanged(function() FOVSettings.Enabled = Toggles.FOVChangerToggle.Value end)
Options.FOVChangerValue:OnChanged(function() FOVSettings.Value = Options.FOVChangerValue.Value end)
Toggles.ThirdPersonToggle:OnChanged(function() ThirdPersonSettings.Enabled = Toggles.ThirdPersonToggle.Value end)
Options.ThirdPersonDistance:OnChanged(function() ThirdPersonSettings.Distance = Options.ThirdPersonDistance.Value end)
Toggles.StretchToggle:OnChanged(function() StretchSettings.Enabled = Toggles.StretchToggle.Value end)
Options.StretchValue:OnChanged(function() StretchSettings.Value = Options.StretchValue.Value end)

Toggles.JumpCircles:OnChanged(function() JumpCircleSettings.Enabled = Toggles.JumpCircles.Value end)
Options.JumpCircleColor:OnChanged(function() JumpCircleSettings.Color = Options.JumpCircleColor.Value end)

Toggles.Fullbright:OnChanged(function() ToggleFB(Toggles.Fullbright.Value) end)
Toggles.NoDecoration:OnChanged(function() pcall(function() local t = workspace:FindFirstChildOfClass("Terrain"); if t and sethiddenproperty then sethiddenproperty(t, "Decoration", not Toggles.NoDecoration.Value) end end) end)
Toggles.SkyColorToggle:OnChanged(function() SkyColorSettings.Enabled = Toggles.SkyColorToggle.Value; if SkyColorSettings.Enabled then if not skyFx then skyFx = Instance.new("ColorCorrectionEffect", Lighting); skyFx.Name = "VomSky" end; skyFx.TintColor = SkyColorSettings.Color else if skyFx then skyFx:Destroy(); skyFx = nil end end end)
Options.SkyColorPicker:OnChanged(function() SkyColorSettings.Color = Options.SkyColorPicker.Value; if SkyColorSettings.Enabled and skyFx then skyFx.TintColor = Options.SkyColorPicker.Value end end)
Options.SkyboxChanger:OnChanged(function(v) local sky = Lighting:FindFirstChildOfClass("Sky"); if v == "Default" then if sky then sky:Destroy() end elseif SkyData[v] then if not sky then sky = Instance.new("Sky", Lighting) end; local d = SkyData[v]; sky.SkyboxBk = "rbxassetid://"..d.Bk; sky.SkyboxDn = "rbxassetid://"..d.Dn; sky.SkyboxFt = "rbxassetid://"..d.Ft; sky.SkyboxLf = "rbxassetid://"..d.Lf; sky.SkyboxRt = "rbxassetid://"..d.Rt; sky.SkyboxUp = "rbxassetid://"..d.Up end end)

local gammaConn
Toggles.FakeGammaEnabled:OnChanged(function() if Toggles.FakeGammaEnabled.Value then gammaConn = RunService.Heartbeat:Connect(function() Lighting.Brightness = 10; Lighting.ClockTime = 14; Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.new(1,1,1) end) else if gammaConn then gammaConn:Disconnect() end; Lighting.Brightness = 1; Lighting.GlobalShadows = true; Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5) end end)

LocalPlayer.CharacterAdded:Connect(function(ch)
    cachedChar = ch; cachedHumanoid = ch:WaitForChild("Humanoid")
    if Toggles.ArmChamsEnabled.Value then task.wait(1); applyArmChams() end
    if Toggles.WeaponChamsEnabled.Value then task.wait(1); applyWeaponChams() end
    if ForceFieldSettings.Enabled then task.wait(1); UpdateFF() end
    if HempESPSettings.Enabled then task.wait(1); updateHempESP() end
    if StoneESPSettings.Enabled or IronESPSettings.Enabled or SulfurESPSettings.Enabled then task.wait(1); updateOreESP() end
    if HitSoundSettings.Enabled then task.wait(1); applyHSChar(ch); setupHSChar(ch) end
end)

-- ========== UI SETTINGS ==========
Library:SetWatermarkVisibility(true)
local FrameTimer = tick(); local FrameCounter = 0; local FPS = 60
RunService.RenderStepped:Connect(function()
    FrameCounter += 1
    if (tick() - FrameTimer) >= 1 then FPS = FrameCounter; FrameTimer = tick(); FrameCounter = 0 end
    Library:SetWatermark(('Voidrane.cc | %s fps | %s ms'):format(math.floor(FPS), math.floor(Stats.Network.ServerStatsItem['Data Ping']:GetValue())))
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {Default = 'End', NoUI = true, Text = 'Menu keybind'})
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library); SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings(); SaveManager:SetIgnoreIndexes({'MenuKeybind'})
ThemeManager:SetFolder('VoidraneHub'); SaveManager:SetFolder('VoidraneHub/rust')
SaveManager:BuildConfigSection(Tabs['UI Settings']); ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    if gammaConn then gammaConn:Disconnect() end
    if FB.Conn then FB.Conn:Disconnect() end
    if NoFallConn then NoFallConn:Disconnect() end
    if NoJumpDelaySettings.Conn then NoJumpDelaySettings.Conn:Disconnect() end
    if physConn then physConn:Disconnect() end
    if spikesConn then pcall(function() spikesConn:Disconnect() end) end
    if hsConn then pcall(function() hsConn:Disconnect() end) end
    ToggleFB(false); restoreHitbox(); canShoot(false); restoreHS()
    for _, hl in pairs(hempHL) do if hl and hl.Parent then hl:Destroy() end end
    for _, hl in pairs(oreHL) do if hl and hl.Parent then hl:Destroy() end end
    if getgenv().Esp then getgenv().Esp.Unload() end
    FOVCircle:Remove(); AimbotFOV:Remove()
    if skyFx then skyFx:Destroy() end
    if ModListGUI then ModListGUI:Destroy() end
    pcall(function() local ch = LocalPlayer.Character; if ch then local hrp = ch:FindFirstChild("HumanoidRootPart"); if hrp then local bv = hrp:FindFirstChild("WSV"); if bv then bv:Destroy() end end end end)
    print('Voidrane.cc - Unloaded!'); Library.Unloaded = true
end)

print("Voidrane.cc - FULLY FIXED! Press END to toggle GUI")
