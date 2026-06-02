
exe_name, exe_version = identifyexecutor()
function home999() end
function home888() end

if exe_name ~= "Wave Windows" then
    hookfunction(home888, home999)
    if isfunctionhooked(home888) == false then
        game.Players.LocalPlayer:Destroy()
        return LPH_CRASH()
    end
end  

function check_env(env) 
    for _, func in env do
        if type(func) ~= "function" then continue end
        if isfunctionhooked(func) then
            game.Players.LocalPlayer:Destroy()
            return LPH_CRASH()
        end
    end
end

check_env(getgenv())
check_env(getrenv())

Lua_Fetch_Connections = getconnections
Lua_Fetch_Upvalues = getupvalues
Lua_Hook = hookfunction 
Lua_Hook_Method = hookmetamethod
Lua_Unhook = restorefunction
Lua_Replace_Function = replaceclosure
Lua_Set_Upvalue = setupvalue
Lua_Clone_Function = clonefunction

Game_RunService = game:GetService("RunService")
Game_LogService = game:GetService("LogService")
Game_LogService_MessageOut = Game_LogService.MessageOut

String_Lower = string.lower
Table_Find = table.find
Get_Type = type

Current_Connections = {}
Hooked_Connections = {}

function Test_Table(tbl, Return_Type) 
    for idx, val in tbl do
        if type(val) == String_Lower(Return_Type) then
            return val, idx
        end
    end
end

function Print_Table(tbl)
    table.foreach(tbl, print)
end

if getgenv().DEBUG then
    print("[auth.injected.live] Waiting...")
end

good_check = 0

function auth_heart()
    return true, true
end

function Lua_Common_Intercept(old, ...)
    print(...)
    return old(...)
end

function XVNP_L(CONNECTION)
    pcall(function()
        OPENAC_TABLE = Lua_Fetch_Upvalues(CONNECTION.Function)[9]
        OPENAC_FUNCTION = OPENAC_TABLE[1]
        IGNORED_INDEX = {3, 12, 1, 11, 15, 8, 20, 18, 22}

        Lua_Set_Upvalue(OPENAC_FUNCTION, 14, function(...)
            return function(...)
                args = {...}
                if type(args[1]) == "table" and args[1][1] then
                    pcall(function()
                        if type(args[1][1]) == "userdata" then 
                            args[1][1]:Disconnect()
                            args[1][2]:Disconnect()
                            args[1][3]:Disconnect()
                            args[1][4]:Disconnect()
                        end
                    end)
                end 
            end
        end)

        Lua_Set_Upvalue(OPENAC_FUNCTION, 1, function(...)
            task.wait(200)
        end)

        hookfunction(OPENAC_FUNCTION, function(...)
            return {}
        end)
    end)
end

XVNP_LASTUPDATE = 0
XVNP_UPDATEINTERVAL = 5

XVNP_CONNECTIONSNIFFER = Game_RunService.RenderStepped:Connect(function()
    if #Lua_Fetch_Connections(Game_LogService_MessageOut) >= 2 then
        XVNP_CONNECTIONSNIFFER:Disconnect()
    end

    if tick() - XVNP_LASTUPDATE >= XVNP_UPDATEINTERVAL then
        XVNP_LASTUPDATE = tick()

        OpenAc_Connections = Lua_Fetch_Connections(Game_LogService_MessageOut)
        for _, CONNECTION in OpenAc_Connections do
            if not table.find(Current_Connections, CONNECTION) then
                table.insert(Current_Connections, CONNECTION)
                table.insert(Hooked_Connections, CONNECTION)
                XVNP_L(CONNECTION)
            end
        end
    end
end)

last_beat = 0
Game_RunService.RenderStepped:Connect(function() 
    if last_beat + 1 < tick() then
        last_beat = tick() + 1 
        what, are = auth_heart() 

        if not are or not what then
            if good_check <= 0 then
                game.Players.LocalPlayer:Destroy()
                return LPH_CRASH()
            else
                good_check -= 1
            end
        else
            good_check += 1
        end
    end
end)

local function scanEnv(env)
    for _, fn in env do
        if type(fn) == "function" and isfunctionhooked(fn) then
            print("Security Check")
        end
    end
end

scanEnv(getgenv())
scanEnv(getrenv())

local activeConns, hookedConns = {}, {}

local function sniffer(conn)
    local status, err = pcall(function()
        local upvalTable = getupvalues(conn.Function)[9]
        local coreFn = upvalTable[1]

        setupvalue(coreFn, 14, function(...)
            return function(...)
                local args = {...}
                if type(args[1]) == "table" and args[1][1] then
                    pcall(function()
                        for i = 1, 4 do
                            if type(args[1][i]) == "userdata" then
                                args[1][i]:Disconnect()
                            end
                        end
                    end)
                end
            end
        end)

        setupvalue(coreFn, 1, function(...)
            task.wait(200)
        end)

        hookfunction(coreFn, function(...)
            return {}
        end)
    end)
end

local lastUpdate, updateGap = 0, 5
local ConnMonitor

ConnMonitor = game:GetService("RunService").RenderStepped:Connect(function()
    if #getconnections(game:GetService("LogService").MessageOut) >= 2 then
        ConnMonitor:Disconnect()
    end

    if tick() - lastUpdate >= updateGap then
        lastUpdate = tick()
        for _, conn in getconnections(game:GetService("LogService").MessageOut) do
            if not table.find(activeConns, conn) then
                table.insert(activeConns, conn)
                table.insert(hookedConns, conn)
                sniffer(conn)
            end
        end
    end
end)

local validateCount = 0
function pulseCheck()
    return true, true
end

local lastPulse = 0
game:GetService("RunService").RenderStepped:Connect(function()
    if lastPulse + 1 < tick() then
        lastPulse = tick() + 1
        local check1, check2 = pulseCheck()
        if not check1 or not check2 then
            if validateCount <= 0 then
                game.Players.LocalPlayer:Destroy()
                return LPH_CRASH()
            else
                validateCount -= 1
            end
        else
            validateCount += 1
        end
    end
end)
local function createProxyTable(base)
    return setmetatable({}, { __index = base })
end

local function makeWritable(tbl)
    return setreadonly(tbl, false)
end

local function overrideValue(tbl, key, value)
    return rawset(tbl, key, value)
end

local function yieldOnce(value)
    return coroutine.yield(value)
end

local Interceptor = {}

function Interceptor.Initialize()
    local garbageCollected = getgc(true)

    local function interceptKickHandler()
        for _, obj in ipairs(garbageCollected) do
            if type(obj) == "table" then
                makeWritable(obj)

                local indexInstance = rawget(obj, "indexInstance")
                if type(indexInstance) == "table" and indexInstance[1] == "kick" then
                    makeWritable(indexInstance)

                    overrideValue(obj, "Table", {
                        "kick",
                        function()
                            yieldOnce()
                        end
                    })

                    return true
                end
            end
        end

        return false
    end

    local function safeExecute()
        local success, err = pcall(interceptKickHandler)
        if not success then
            warn("[Anti-Kick] Interception failed: " .. err)
        end
    end

    local function runInterceptor()
        safeExecute()
        print("[Anti-Kick] Kick interception active.")
    end

    runInterceptor()
end

if game.PlaceId ~= 2788229376 then
    Interceptor.Initialize()
end 