--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
--Made By @gavinrgb27
-- Converted by gavindrgb27
-- Модифицировано: добавлен автоповтор (цикл)

local plr = game:GetService("Players").LocalPlayer
local PlrGui = plr:WaitForChild("PlayerGui")
local Backpack = plr:WaitForChild("Backpack")

-- Функция, которая создаёт и запускает гифку
local function CreateGif()
    local MainAsset = game:GetObjects("rbxassetid://14752386130")[1]
    if not MainAsset then return end

    MainAsset.Parent = workspace

    local gif = MainAsset:FindFirstChild("gif")
    local clip = gif:FindFirstChild("clip")

    gif.Parent = PlrGui

    local GifDisplay = gif:FindFirstChild("GifDisplay")
    -- PATH: GifDisplay
    task.spawn(function()
        local script = GifDisplay
        getgenv().RemoteFuncs = getgenv().RemoteFuncs or {}
        --write by venuz_geforce
        s = script
        sp = s.Parent
        m = math
        ud = UDim2
        fs = ud.fromScale
        flr = m.floor
        local CF = 0 -- current frame
        local frames = 50
        local r = 7 -- [ ↓ ] rows
        local c = 8 -- [→] columns
        local fps = 10
        while true do
            task.wait(1/fps)
            sp.clip.Sprite.Size = fs(c,r)
            sp.clip.Sprite.Position = fs(
                1-(((CF+1)%c) == 0 and c or ((CF+1)%c)),
                1-((flr(((CF+c)/c))%r) == 0 and r or (flr(((CF+c)/c))%r))
            )
            CF = (CF+1)%frames
        end
    end)

    local Destroy = gif:FindFirstChild("Destroy")
    -- PATH: Destroy
    task.spawn(function()
        local script = Destroy
        getgenv().RemoteFuncs = getgenv().RemoteFuncs or {}
        wait(5.5) -- Сколько секунд до уничтожения (можешь изменить)
        script.Parent:Destroy() -- Уничтожаем гифку
    end)
end

-- ⭐ ГЛАВНЫЙ ЦИКЛ АВТОПОВТОРЕНИЯ ⭐
while true do
    CreateGif()          -- Создаём гифку
    wait(5.1)            -- Ждём чуть дольше, чем время до уничтожения (5.5 сек), чтобы гифка успела исчезнуть
    -- После этого цикл повторяется → гифка создаётся заново
end
