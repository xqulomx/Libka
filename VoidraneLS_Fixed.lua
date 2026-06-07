-- [version:ls]
-- [translation:lone survival]
-- [scriptid:lonesurvival]
-- Voidrane LS - Fixed with Libka UI v2

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local Mouse = LocalPlayer:GetMouse()
local GuiInset = game:GetService("GuiService"):GetGuiInset()
local Workspace = game:GetService("Workspace")

local lone = {
    projectile_spoof = {},
}
lone.remote_event = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RemoteEvent")
function lone:fire_server(real, ...)
    local args = {real, false, ...}
    local random = Random.new(os.time() + os.clock())
    local numarg = #args - 2
    for i = #args + 1, #args + random:NextInteger(random:NextInteger(1, 5), random:NextInteger(5, 10)) do
        args[i] = random:NextInteger(1, 50)
    end
    args[#args + 1] = numarg
    lone.remote_event:FireServer(unpack(args))
end

for _, gc in getgc(true) do
    if type(gc) == "table" then
        if rawget(gc, "CurrentSlot") and rawget(gc, "ScrollSlot") then
            lone.hotbar = gc
        end
        if rawget(gc, "RecoilSpring") then
            lone.recoilspring = rawget(gc, "RecoilSpring")
        end
        if rawget(gc, "TargetImpulse") and rawget(gc, "Impulse") then
            lone.spring = gc
        end
    end
end

if not (lone.recoilspring and lone.hotbar and lone.spring) then
    return LocalPlayer:Kick("failed to get required objects")
end

local _CFramenew = CFrame.new
local _Vector2new = Vector2.new
local _Vector3new = Vector3.new
local _IsDescendantOf = game.IsDescendantOf
local _FindFirstChild = game.FindFirstChild
local _FindFirstChildOfClass = game.FindFirstChildOfClass
local _Raycast = workspace.Raycast
local _IsKeyDown = UserInputService.IsKeyDown
local _WorldToViewportPoint = Camera.WorldToViewportPoint
local _Vector3zeromin = Vector3.zero.Min
local _Vector2zeromin = Vector2.zero.Min
local _Vector3zeromax = Vector3.zero.Max
local _Vector2zeromax = Vector2.zero.Max
local _IsA = game.IsA
local tablecreate = table.create
local mathfloor = math.floor
local mathround = math.round
local tostring = tostring
local unpack = unpack
local getupvalues = debug.getupvalues
local getupvalue = debug.getupvalue
local setupvalue = debug.setupvalue
local getconstants = debug.getconstants
local getconstant = debug.getconstant
local setconstant = debug.setconstant
local getstack = debug.getstack
local setstack = debug.setstack
local getinfo = debug.getinfo
local rawget = rawget
local cloneref = cloneref or function(obj) return obj end

local Drawing = Drawing or {}
if not Drawing.new then
    Drawing = {
        new = function(t)
            return {
                Visible = false,
                Color = Color3.new(1,1,1),
                Transparency = 1,
                Thickness = 1,
                Size = 10,
                Position = Vector2.new(0,0),
                Text = "",
                From = Vector2.new(0,0),
                To = Vector2.new(0,0),
                Radius = 0,
                Filled = false,
                ZIndex = 1,
                Center = false,
                Outline = false,
                OutlineColor = Color3.new(),
                TextBounds = Vector2.new(0,0),
                Remove = function() end
            }
        end,
        Fonts = {Monospace = 0, UI = 1, System = 2, Plex = 3}
    }
end

-- ============================================================
-- LIBKA UI SETUP
-- ============================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xqulomx/Libka/refs/heads/main/Library%20(1).lua"))()

local Window = Library:Window({
    Name = "Voidrane LS",
    SubName = "Lone Survival Exploit",
    Logo = "120959262762131"
})

-- Pages
local CombatPage  = Window:Page({Name = "Combat", Icon = "138827881557940"})
local VisualsPage = Window:Page({Name = "Visuals", Icon = "100050851789190"})
local WorldPage    = Window:Page({Name = "World", Icon = "123944728972740"})
local MiscPage    = Window:Page({Name = "Misc", Icon = "103180437044643"})
local ConfigPage  = Window:Page({Name = "Config", Icon = "108839695397679"})

-- Combat sections
local AimbotLeft    = CombatPage:Section({Name = "Aimbot", Description = "Target acquisition", Icon = "100050851789190", Side = 1})
local FovRight      = CombatPage:Section({Name = "FOV", Description = "Field of view settings", Icon = "123944728972740", Side = 2})
local GunModsRight  = CombatPage:Section({Name = "Gun Mods", Description = "Weapon modifications", Icon = "103180437044643", Side = 2})
local IndicatorRight = CombatPage:Section({Name = "Indicator", Description = "Target indicator", Icon = "108839695397679", Side = 2})

-- Visuals sections
local PlayerEspLeft    = VisualsPage:Section({Name = "Player ESP", Description = "Player visuals", Icon = "100050851789190", Side = 1})
local EspSettingsRight = VisualsPage:Section({Name = "ESP Settings", Description = "Customize ESP", Icon = "123944728972740", Side = 2})

-- World sections
local WorldLighting = WorldPage:Section({Name = "Lighting", Description = "Lighting controls", Icon = "123944728972740", Side = 1})
local WorldBloom    = WorldPage:Section({Name = "Bloom", Description = "Bloom effects", Icon = "108839695397679", Side = 2})
local WorldAtmos    = WorldPage:Section({Name = "Atmosphere", Description = "Atmosphere settings", Icon = "103180437044643", Side = 2})

-- Misc sections
local MovementLeft = MiscPage:Section({Name = "Movement", Description = "Movement exploits", Icon = "103180437044643", Side = 1})
local SpiderLeft   = MiscPage:Section({Name = "Spider", Description = "Wall climbing", Icon = "100050851789190", Side = 1})
local ExploitsLeft = MiscPage:Section({Name = "Exploits", Description = "Other exploits", Icon = "108839695397679", Side = 2})

-- Config section
local ConfigLeft = ConfigPage:Section({Name = "Configuration", Description = "Script config", Icon = "108839695397679", Side = 1})

local Flags = Library.Flags

-- ============================================================
-- VECTORS
-- ============================================================
local vectors = {
    Vector3.zero,
    _Vector3new(1, 0, 0), _Vector3new(-1, 0, 0),
    _Vector3new(0, 0, 1), _Vector3new(0, 0, -1),
    _Vector3new(0, 1, 0), _Vector3new(0, -1, 0),
    _Vector3new(1/2, 0, 0), _Vector3new(-1/2, 0, 0),
    _Vector3new(0, 0, 1/2), _Vector3new(0, 0, -1/2),
    _Vector3new(0, 1/2, 0), _Vector3new(0, -1/2, 0),
    _Vector3new(1/2, 1/2, 0), _Vector3new(1/2, -1/2, 0),
    _Vector3new(-1/2, 1/2, 0), _Vector3new(-1/2, -1/2, 0),
    _Vector3new(0, 1/2, 1/2), _Vector3new(0, -1/2, 1/2),
    _Vector3new(0, 1/2, -1/2), _Vector3new(0, -1/2, -1/2),
}

-- ============================================================
-- VISCHECK
-- ============================================================
local vischeck_params = RaycastParams.new()
vischeck_params.FilterDescendantsInstances = { workspace.Ignored, Camera }
vischeck_params.FilterType = Enum.RaycastFilterType.Exclude
vischeck_params.IgnoreWater = true

-- ============================================================
-- CHEAT UTILITY
-- ============================================================
cheat = cheat or {}
cheat.utility = cheat.utility or {
    new_renderstepped = function(f)
        local conn = RunService.RenderStepped:Connect(f)
        return conn
    end,
    new_heartbeat = function(f)
        local conn = RunService.Heartbeat:Connect(f)
        return conn
    end,
    new_drawing = function(t, props)
        local obj = Drawing.new(t)
        for k, v in props do obj[k] = v end
        return obj
    end,
}

-- ============================================================
-- TRAJECTORY (quartic)
-- ============================================================
cheat.quartic = (function()
    local pi=math.pi;
    local c=math.abs;local d=math.sqrt;local e=math.acos;local f=math.cos;local g=1e-9;
    local function h(i)return i>-g and i<g end;
    local function j(k)return k>0 and k^(1/3)or-c(k)^(1/3)end;
    local function l(m,n,o)local p,q;local r,s,t;r=n/(2*m)s=o/m;t=r*r-s;if h(t)then p=-r;return p elseif t<0 then return else local u=d(t)p=u-r;q=-u-r;return p,q end end;
    local function v(m,n,o,w)local p,q,x;local y,z;local A,B,C;local D,r,s;local E,t;A=n/m;B=o/m;C=w/m;D=A*A;r=1/3*(-(1/3)*D+B)s=0.5*(2/27*A*D-1/3*A*B+C)E=r*r*r;t=s*s+E;if h(t)then if h(s)then p=0;y=1 else local F=j(-s)p=2*F;q=-F;y=2 end elseif t<0 then local G=1/3*e(-s/d(-E))local H=2*d(-r)p=H*f(G)q=-H*f(G+pi/3)x=-H*f(G-pi/3)y=3 else local u=d(t)local F=j(u-s)local I=-j(u+s)p=F+I;y=1 end;z=1/3*A;if y>0 then p=p-z end;if y>1 then q=q-z end;if y>2 then x=x-z end;return p,q,x;end;
    local function J(m,n,o,w,K)local p,q,x,L;local M={}local N,F,I,z;local A,B,C,t;local D,r,s,O;local y;A=n/m;B=o/m;C=w/m;t=K/m;D=A*A;r=-0.375*D+B;s=0.125*D*A-0.5*A*B+C;O=-(3/256)*D*D+0.0625*D*B-0.25*A*C+t;if h(O)then M[3]=s;M[2]=r;M[1]=0;M[0]=1;local P={v(M[0],M[1],M[2],M[3])}y=#P;p,q,x=P[1],P[2],P[3]else M[3]=0.5*O*r-0.125*s*s;M[2]=-O;M[1]=-0.5*r;M[0]=1;p,q,x=v(M[0],M[1],M[2],M[3])N=p;F=N*N-O;I=2*N-r;if h(F)then F=0 elseif F>0 then F=d(F)else return end;if h(I)then I=0 elseif I>0 then I=d(I)else return end;M[2]=N-F;M[1]=s<0 and-I or I;M[0]=1;do local P={l(M[0],M[1],M[2])}y=#P;p,q=P[1],P[2]end;M[2]=N+F;M[1]=s<0 and I or-I;M[0]=1;if y==0 then local P={l(M[0],M[1],M[2])}y=y+#P;p,q=P[1],P[2]end;if y==1 then local P={l(M[0],M[1],M[2])}y=y+#P;q,x=P[1],P[2]end;if y==2 then local P={l(M[0],M[1],M[2])}y=y+#P;x,L=P[1],P[2]end end;z=0.25*A;if y>0 then p=p-z end;if y>1 then q=q-z end;if y>2 then x=x-z end;if y>3 then L=L-z end;return{L,x,q,p}end;
    return J
end)();

cheat.trajectory = function(origin, projectileSpeed, targetPos, targetVelocity, pickLongest, gravity)
	local g = gravity or workspace.Gravity
	local disp = targetPos - origin
	local p, q, r = targetVelocity.X, targetVelocity.Y, targetVelocity.Z
	local h, j, k = disp.X, disp.Y, disp.Z
	local l = -.5 * g 
	local solutions = cheat.quartic(l*l, -2*q*l, q*q - 2*j*l - projectileSpeed*projectileSpeed + p*p + r*r, 2*j*q + 2*h*p + 2*k*r, j*j + h*h + k*k)
	if solutions then
		local posRoots = table.create(2)
		for _, v in solutions do
			if v > 0 then posRoots[#posRoots + 1] = v end
		end
		if posRoots[1] then
			local t = posRoots[pickLongest and 2 or 1]
			local d = (h + p*t)/t
			local e = (j + q*t - l*t*t)/t
			local f = (k + r*t)/t
			return origin + _Vector3new(d, e, f)
		end
	end
	return
end

-- ============================================================
-- GET CHARACTER
-- ============================================================
local get_character do
    local player_folder = workspace.Players
    get_character = function(player)
        if not player then return end
        return _FindFirstChild(player_folder, player.Name)
    end
end

-- ============================================================
-- VISIBILITY FUNCTIONS
-- ============================================================
local function is_visible(position, target, target_part)
    if not (target and target_part and position) then return false end
    local castresults = _Raycast(workspace, position, target_part.CFrame.p - position, vischeck_params)
    return castresults and castresults.Instance and castresults.Instance.Parent == target
end

local function is_position_visible(pos_from, pos_to)
    if not (pos_to and pos_from) then return false end
    local castresults = _Raycast(workspace, pos_from, pos_to - pos_from, vischeck_params)
    return not castresults
end

local function get_manipulation_pos(origin_pos, target, target_part, range, enabled, thruwalls)
    local final, maxmag = nil, math.huge;
    if not enabled then return nil end
    for _, vector in vectors do
        local curvector = (vector * range)
        local modified = origin_pos + curvector
        local posvisible, visible = thruwalls or is_position_visible(origin_pos, modified), is_visible(modified, target, target_part)
        if curvector.Magnitude <= maxmag and posvisible and visible then
            final = curvector
            maxmag = curvector.Magnitude
        end
    end
    return final
end

local get_closest_target = function(fov_size, aimpart)
    local ermm_part, isnpc = nil, false
    local maximum_distance = fov_size
    local mousepos = _Vector2new(Mouse.X, Mouse.Y)
    for _, player in Players:GetPlayers() do
        local character = get_character(player)
        if not (player ~= LocalPlayer and character) then continue end
        local part = _FindFirstChild(character, aimpart)
        local humanoid = _FindFirstChildOfClass(character, "Humanoid")
        if not (part and humanoid and humanoid.Health > 0) then continue end
        local position, onscreen = _WorldToViewportPoint(Camera, part.Position)
        local distance = (_Vector2new(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
        if onscreen and distance <= maximum_distance then
            ermm_part = part
            maximum_distance = distance
            isnpc = false
        end
    end
    for _, npc in workspace.AI:GetChildren() do
        local part = _FindFirstChild(npc, aimpart)
        local humanoid = _FindFirstChildOfClass(npc, "Humanoid")
        if not (part and humanoid and humanoid.Health > 0) then continue end
        local position, onscreen = _WorldToViewportPoint(Camera, part.Position)
        local distance = (_Vector2new(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
        if onscreen and distance <= maximum_distance then
            ermm_part = part
            maximum_distance = distance
            isnpc = true
        end
    end
    return ermm_part, isnpc
end

-- ============================================================
-- AIMBOT
-- ============================================================
do
    local aim_enabled, aim_part, aim_mode = false, "Head", "camera"
    local aim_predict = false
    local aim_smoothing = 0
    local manipulation, manip_range = false, 5
    local fov_show, fov_color, fov_outline, fov_size = false, Color3.new(1,1,1), false, 100
    local norecoil = false
    local target_part, is_npc
    local calculated_aimpos

    -- Gun Mods
    GunModsRight:Toggle({
        Name = "no recoil", Flag = "gunmods_norecoil", Default = false,
        Callback = function(v) norecoil = v end
    })

    -- Aimbot
    AimbotLeft:Toggle({
        Name = "aim enabled", Flag = "aim_enabled", Default = false,
        Callback = function(v) aim_enabled = v end
    })
    AimbotLeft:Dropdown({
        Name = "aim mode", Flag = "aim_mode",
        Items = {"camera", "mouse", "silent"},
        Default = "camera", Multi = false,
        Callback = function(v) aim_mode = v end
    })
    AimbotLeft:Dropdown({
        Name = "aim part", Flag = "aim_part",
        Items = {"Head","UpperTorso","LowerTorso","HumanoidRootPart"},
        Default = "Head", Multi = false,
        Callback = function(v) aim_part = v end
    })
    AimbotLeft:Toggle({
        Name = "predict target", Flag = "aim_predict", Default = false,
        Callback = function(v) aim_predict = v end
    })
    AimbotLeft:Slider({
        Name = "smoothing", Flag = "aim_smoothing",
        Min = 0, Max = 100, Default = 0, Decimals = 0,
        Callback = function(v) aim_smoothing = (100 - v) / 100 end
    })
    AimbotLeft:Toggle({
        Name = "silent manipulation", Flag = "silentaim_manipulation", Default = false,
        Callback = function(v) manipulation = v end
    })
    AimbotLeft:Slider({
        Name = "manipulation range", Flag = "silentaim_manipulation_range",
        Min = 1, Max = 5, Default = 5, Decimals = 1,
        Callback = function(v) manip_range = v end
    })

    -- FOV
    FovRight:Toggle({
        Name = "show fov", Flag = "fov_show", Default = false,
        Callback = function(v) fov_show = v end
    }):Colorpicker({
        Flag = "fov_color", Default = Color3.new(1,1,1), Alpha = 0,
        Callback = function(c) fov_color = c end
    })
    FovRight:Toggle({
        Name = "fov outline", Flag = "fov_outline", Default = false,
        Callback = function(v) fov_outline = v end
    })
    FovRight:Slider({
        Name = "target fov", Flag = "fov_size",
        Min = 10, Max = 1000, Default = 100, Decimals = 0,
        Callback = function(v) fov_size = v end
    })

    -- FOV Circle
    local CircleOutline = cheat.utility.new_drawing("Circle", {Thickness = 3, Color = Color3.new(), ZIndex = 1})
    local CircleInline = cheat.utility.new_drawing("Circle", {Transparency = 1, Thickness = 1, ZIndex = 2})
    cheat.utility.new_renderstepped(function()
        CircleInline.Position = _Vector2new(Mouse.X, Mouse.Y + GuiInset.Y)
        CircleInline.Radius = fov_size
        CircleInline.Color = fov_color
        CircleInline.Visible = fov_show
        CircleOutline.Position = _Vector2new(Mouse.X, Mouse.Y + GuiInset.Y)
        CircleOutline.Radius = fov_size
        CircleOutline.Visible = fov_show and fov_outline
    end)

    -- Indicator
    local indicator = cheat.utility.new_drawing("Text", {Visible = false, Size = 13, Color = Color3.new(1,1,1), Center = true, Outline = true})
    IndicatorRight:Toggle({
        Name = "indicator enabled", Flag = "indicator_enabled", Default = false,
        Callback = function(v) indicator.Visible = v end
    }):Colorpicker({
        Flag = "indicator_color", Default = Color3.new(1,1,1), Alpha = 0,
        Callback = function(v) indicator.Color = v end
    })

    -- Main Aimbot Loop
    RunService:BindToRenderStep(tostring(math.random()), Enum.RenderPriority.Camera.Value, function(dt)
        local indtxt = ""
        local camera_cframe = Camera.CFrame
        local camera_pos = camera_cframe.p
        calculated_aimpos = nil

        if aim_enabled then
            target_part, is_npc = get_closest_target(fov_size, aim_part)
            if target_part then
                indtxt = target_part.Parent.Name .. (is_npc and " (ai)" or "")
                local current_tool = lone.hotbar.CurrentTool
                local projectile_stats = current_tool and current_tool.Stats and current_tool.Stats.ProjectileStats
                local projectile_speed = projectile_stats and projectile_stats.Velocity

                if aim_mode == "silent" then
                    local manipulation_pos = get_manipulation_pos(camera_pos, target_part.Parent, target_part, manip_range, manipulation, false)
                    local new_origin = camera_pos + (manipulation_pos or Vector3.zero)
                    local new_pos = aim_predict and projectile_speed and cheat.trajectory(new_origin, projectile_speed, target_part.Position, target_part.Velocity, false, 0) or target_part.Position
                    calculated_aimpos = CFrame.lookAt(new_origin, new_pos)
                    indtxt = indtxt .. (manipulation_pos and " (manipulated)" or "")
                else
                    local new_pos = aim_predict and projectile_speed and cheat.trajectory(camera_pos, projectile_speed, target_part.Position, target_part.Velocity, false, 0) or target_part.Position
                    if aim_mode == "camera" then
                        Camera.CFrame = camera_cframe:Lerp(_CFramenew(camera_pos, new_pos), 1-aim_smoothing)
                    else
                        local pos = _WorldToViewportPoint(Camera, target_part.Position)
                        local mpos = UserInputService:GetMouseLocation()
                        local diff = _Vector2new((pos.X - mpos.X) * aim_smoothing, (pos.Y - mpos.Y) * aim_smoothing)
                        mousemoverel(diff.X, diff.Y)
                    end
                end
            end
        end
        indicator.Text = indtxt
        indicator.Position = _Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 + 50)
    end)

    -- Recoil Hook
    local old_impulse = lone.spring.Impulse
    lone.spring.Impulse = function(self, ...)
        if norecoil and self == lone.recoilspring then return end
        return old_impulse(self, ...)
    end

    -- Projectile Hook
    local projectile = game:GetService("ReplicatedStorage").Modules.Client.Physics.Projectile
    local oldproj = require(projectile).New
    require(projectile).New = function(self, data)
        if not (calculated_aimpos and not data.FromServer) then
            return oldproj(self, data)
        end
        local spoofdata = {
            Origin = calculated_aimpos.Position,
            HitVector = calculated_aimpos.LookVector * 10000 + calculated_aimpos.Position,
            ForceHitVector = calculated_aimpos.LookVector * 10000 + calculated_aimpos.Position
        }
        local thing = setmetatable(data, {
            __index = function(t, k)
                if spoofdata[k] then return spoofdata[k] end
            end,
            __newindex = function(t, k, v)
                if spoofdata[k] then return end
            end,
            __call = function() return data end
        })
        lone.projectile_spoof[thing] = data
        return oldproj(self, thing)
    end
end

-- ============================================================
-- PLAYER ESP (SIMPLIFIED)
-- ============================================================
do
    local esp_enabled = false
    local chams_enabled = false
    local created_highlights = {}

    local function updateESP()
        if not esp_enabled and not chams_enabled then
            for _, highlight in pairs(created_highlights) do
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end
            created_highlights = {}
            return
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = get_character(player)
            if not char then 
                if created_highlights[player] then
                    created_highlights[player]:Destroy()
                    created_highlights[player] = nil
                end
                continue 
            end
            
            local humanoid = _FindFirstChildOfClass(char, "Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                if created_highlights[player] then
                    created_highlights[player]:Destroy()
                    created_highlights[player] = nil
                end
                continue
            end

            if chams_enabled then
                if not created_highlights[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(0, 150, 255)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.4
                    highlight.Parent = char
                    created_highlights[player] = highlight
                end
            else
                if created_highlights[player] then
                    created_highlights[player]:Destroy()
                    created_highlights[player] = nil
                end
            end
        end
    end

    cheat.utility.new_renderstepped(function()
        updateESP()
    end)

    PlayerEspLeft:Toggle({
        Name = "enable esp", Flag = "espswitch", Default = false,
        Callback = function(v) esp_enabled = v end
    })
    PlayerEspLeft:Toggle({
        Name = "chams", Flag = "espchams", Default = false,
        Callback = function(v) chams_enabled = v end
    })
    PlayerEspLeft:Slider({
        Name = "chams transparency", Flag = "espchams_transparency",
        Min = 0, Max = 1, Default = 0.4, Decimals = 1,
        Callback = function(v)
            for _, highlight in pairs(created_highlights) do
                if highlight then highlight.FillTransparency = v end
            end
        end
    })

    EspSettingsRight:Dropdown({
        Name = "esp font", Flag = "espfont",
        Items = {"UI","System","Plex","Monospace"},
        Default = "UI", Multi = false,
        Callback = function(v) end
    })
    EspSettingsRight:Slider({
        Name = "esp font size", Flag = "espfontsize",
        Min = 1, Max = 30, Default = 13, Decimals = 0,
        Callback = function(v) end
    })
end

-- ============================================================
-- WORLD - LIGHTING
-- ============================================================
do
    local lighting_changer = false
    local old_lighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        ClockTime = Lighting.ClockTime,
    }

    WorldLighting:Toggle({
        Name = "lighting changer", Flag = "world_lighting_changer", Default = false,
        Callback = function(v)
            lighting_changer = v
            if not v then for k, val in old_lighting do Lighting[k] = val end end
        end
    })
    WorldLighting:Label("ambient"):Colorpicker({
        Flag = "world_lighting_ambient", Default = Color3.fromRGB(70, 70, 70), Alpha = 0,
        Callback = function(v) if lighting_changer then Lighting.Ambient = v end end
    })
    WorldLighting:Slider({
        Name = "brightness", Flag = "world_lighting_brightness",
        Min = 0, Max = 10, Default = 3, Decimals = 2,
        Callback = function(v) if lighting_changer then Lighting.Brightness = v end end
    })
    WorldLighting:Slider({
        Name = "fog end", Flag = "world_lighting_fogend",
        Min = 0, Max = 100000, Default = 10000, Decimals = 0,
        Callback = function(v) if lighting_changer then Lighting.FogEnd = v end end
    })
    WorldLighting:Slider({
        Name = "clock time", Flag = "world_lighting_clocktime",
        Min = 0, Max = 24, Default = 14.5, Decimals = 1,
        Callback = function(v) if lighting_changer then Lighting.ClockTime = v end end
    })
end

-- ============================================================
-- WORLD - BLOOM
-- ============================================================
do
    local bloomeffect = _FindFirstChildOfClass(Lighting, "BloomEffect") or Instance.new("BloomEffect", Lighting)
    local bloom_changer = false

    WorldBloom:Toggle({
        Name = "bloom changer", Flag = "world_bloom_changer", Default = false,
        Callback = function(v) bloom_changer = v end
    })
    WorldBloom:Slider({
        Name = "intensity", Flag = "world_bloom_intensity",
        Min = 0, Max = 1, Default = 1, Decimals = 2,
        Callback = function(v) if bloom_changer then bloomeffect.Intensity = v end end
    })
    WorldBloom:Slider({
        Name = "size", Flag = "world_bloom_size",
        Min = 0, Max = 56, Default = 24, Decimals = 0,
        Callback = function(v) if bloom_changer then bloomeffect.Size = v end end
    })
end

-- ============================================================
-- WORLD - ATMOSPHERE
-- ============================================================
do
    local atmosphere = _FindFirstChildOfClass(Lighting, "Atmosphere") or Instance.new("Atmosphere", Lighting)
    local atmos_changer = false

    WorldAtmos:Toggle({
        Name = "atmosphere changer", Flag = "world_atmos_changer", Default = false,
        Callback = function(v) atmos_changer = v end
    })
    WorldAtmos:Slider({
        Name = "density", Flag = "world_atmos_density",
        Min = 0, Max = 1, Default = 0.28, Decimals = 2,
        Callback = function(v) if atmos_changer then atmosphere.Density = v end end
    })
    WorldAtmos:Slider({
        Name = "glare", Flag = "world_atmos_glare",
        Min = 0, Max = 10, Default = 1, Decimals = 1,
        Callback = function(v) if atmos_changer then atmosphere.Glare = v end end
    })
end

-- ============================================================
-- MOVEMENT (SPEEDHACK)
-- ============================================================
do
    local speed_enabled = false
    local speed_amount = 1.5
    local speedKey = Enum.KeyCode.LeftShift

    MovementLeft:Label("hold LeftShift to speed")
    MovementLeft:Toggle({
        Name = "speed enabled", Flag = "speedhack_enabled", Default = false,
        Callback = function(v) speed_enabled = v end
    })
    MovementLeft:Slider({
        Name = "speed multiplier", Flag = "speedhack_amount",
        Min = 0.5, Max = 3, Default = 1.5, Decimals = 0.1,
        Callback = function(v) speed_amount = v end
    })

    local is_holding_speed = false
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == speedKey then
            is_holding_speed = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == speedKey then
            is_holding_speed = false
        end
    end)

    cheat.utility.new_renderstepped(function(delta)
        if not speed_enabled or not is_holding_speed then return end
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart then
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                rootPart.CFrame = rootPart.CFrame + (moveDirection * speed_amount * 1.2)
            end
        end
    end)
end

-- ============================================================
-- SPIDER (WALL CLIMB)
-- ============================================================
do
    local climbEnabled = false
    local climbTargetPosition = nil
    local climbWaitTime = 0
    local climbPhase = "search"
    local climbOriginalGravity = 196.2
    local climbClimbStartTime = 0
    local spiderKey = Enum.KeyCode.F

    local ignore = {Workspace.Terrain, Workspace.Camera}

    local function addChar(char)
        if not char then return end
        table.insert(ignore, char)
        for _, v in char:GetDescendants() do
            if v:IsA("BasePart") then
                table.insert(ignore, v)
            end
        end
    end

    LocalPlayer.CharacterAdded:Connect(addChar)
    if LocalPlayer.Character then addChar(LocalPlayer.Character) end

    local function rotate(v, a, ang)
        local c, s = math.cos(ang), math.sin(ang)
        return v * c + a:Cross(v) * s + a * (a:Dot(v)) * (1 - c)
    end

    SpiderLeft:Label("hold F to climb walls")
    SpiderLeft:Toggle({
        Name = "spider enabled", Flag = "spider_enabled", Default = false,
        Callback = function(v)
            if not v then
                climbEnabled = false
                climbPhase = "search"
                climbTargetPosition = nil
                Workspace.Gravity = climbOriginalGravity
            end
        end
    })

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == spiderKey and Flags["spider_enabled"] then
            climbEnabled = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == spiderKey then
            climbEnabled = false
            climbPhase = "search"
            climbTargetPosition = nil
            Workspace.Gravity = climbOriginalGravity
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not climbEnabled then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        if climbPhase == "search" then
            Workspace.Gravity = climbOriginalGravity
            local parts = {}
            for _, n in pairs({"LowerTorso", "UpperTorso", "Torso", "HumanoidRootPart", "LeftFoot", "RightFoot", "LeftLeg", "RightLeg"}) do
                local p = char:FindFirstChild(n)
                if p and p:IsA("BasePart") then table.insert(parts, p) end
            end
            if #parts == 0 then return end
            
            local len = 3.2
            local dist = 4.8
            local rays = 8
            local step = 2 * math.pi / rays
            
            for _, part in ipairs(parts) do
                local fwd = part.CFrame.LookVector * len
                local up = part.CFrame.UpVector
                for i = 0, rays - 1 do
                    local dir = rotate(fwd, up, i * step)
                    local params = RaycastParams.new()
                    params.FilterDescendantsInstances = ignore
                    params.FilterType = Enum.RaycastFilterType.Blacklist
                    local result = Workspace:Raycast(part.Position, dir, params)
                    if result and result.Distance <= dist then
                        local hitPos = result.Position
                        local direction = (hitPos - part.Position).Unit
                        climbTargetPosition = hitPos + direction * 0.02
                        climbPhase = "teleport"
                        climbWaitTime = tick()
                        return
                    end
                end
            end
        elseif climbPhase == "teleport" then
            if climbTargetPosition and root and root.Parent then
                root.CFrame = CFrame.new(climbTargetPosition)
                climbPhase = "wait"
                climbWaitTime = tick()
                Workspace.Gravity = 0
            end
        elseif climbPhase == "wait" then
            Workspace.Gravity = 0
            if climbTargetPosition and root and root.Parent then
                root.CFrame = CFrame.new(climbTargetPosition)
            end
            if tick() - climbWaitTime >= 0.5 then
                climbPhase = "climb"
                climbClimbStartTime = tick()
            end
            if root and root.Parent then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        elseif climbPhase == "climb" then
            Workspace.Gravity = 0
            
            local hasObstacle = false
            local parts = {}
            for _, n in pairs({"LowerTorso", "UpperTorso", "Torso", "HumanoidRootPart", "LeftFoot", "RightFoot", "LeftLeg", "RightLeg"}) do
                local p = char:FindFirstChild(n)
                if p and p:IsA("BasePart") then table.insert(parts, p) end
            end
            
            if #parts > 0 then
                local len = 3.2
                local dist = 4.8
                local rays = 8
                local step = 2 * math.pi / rays
                
                for _, part in ipairs(parts) do
                    local fwd = part.CFrame.LookVector * len
                    local up = part.CFrame.UpVector
                    for i = 0, rays - 1 do
                        local dir = rotate(fwd, up, i * step)
                        local params = RaycastParams.new()
                        params.FilterDescendantsInstances = ignore
                        params.FilterType = Enum.RaycastFilterType.Blacklist
                        local result = Workspace:Raycast(part.Position, dir, params)
                        if result and result.Distance <= dist then
                            hasObstacle = true
                            break
                        end
                    end
                    if hasObstacle then break end
                end
            end
            
            if not hasObstacle or tick() - climbClimbStartTime >= 1.8 then
                climbPhase = "search"
                climbTargetPosition = nil
                climbClimbStartTime = 0
                Workspace.Gravity = climbOriginalGravity
            else
                root.AssemblyLinearVelocity = Vector3.new(
                    root.AssemblyLinearVelocity.X,
                    math.max(16, root.AssemblyLinearVelocity.Y),
                    root.AssemblyLinearVelocity.Z
                )
            end
        end
    end)
end

-- ============================================================
-- NAME CALL HOOK
-- ============================================================
local __namecall; __namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if checkcaller() then return __namecall(self, ...) end
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and args[1] == "Create Projectile" then
        if lone.projectile_spoof[args[3]] then
            args[3] = args[3]()
        end
    end
    return __namecall(self, ...)
end))

-- ============================================================
-- CONFIG
-- ============================================================
ConfigLeft:Toggle({
    Name = "show keybinds", Flag = "keybindshoww", Default = false,
    Callback = function(v) end
})

-- ============================================================
-- FINALIZE
-- ============================================================
Window:Init()

print("✓ Voidrane LS loaded successfully!")
print("✓ All features ready to use")
