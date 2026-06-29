--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local ScreenGui = Instance.new("ScreenGui")

--Properties:

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Module Scripts:

local fake_module_scripts = {}

do -- nil.MainModule
	local script = Instance.new('ModuleScript', nil)
	script.Name = "MainModule"
	local function module_script()
		local module = {}
		
		function module.Vintik() 
			local diddy = script.legend:Clone()
			diddy.Parent = workspace
			diddy.Enabled = true
		end
		
		return module
		
	end
	fake_module_scripts[script] = module_script
end


-- Scripts:

local function MDCX_fake_script() -- nil.legend 
	local script = Instance.new('Script', nil)
	local req = require
	local require = function(obj)
		local fake = fake_module_scripts[obj]
		if fake then
			return fake()
		end
		return req(obj)
	end

	local Workspace = game:GetService("Workspace")
	
	function playSound(soundId, loop, pitch, volume, distortionLevel)
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. soundId
		sound.Parent = Workspace
		sound.Looped = loop
		sound.Pitch = pitch
		sound.Volume = volume
	
		if distortionLevel and distortionLevel > 1 then
			local distortionEffect = Instance.new("DistortionSoundEffect")
			distortionEffect.Level = 1 -- Set distortion level to 0.99 when applied
			distortionEffect.Parent = sound
		end
	
		sound:Play()
		return sound
	end
	
	local soundIds = {
		115198908437771,
	}
	
	local fixedPitch = 1
	local fixedVolume = 10
	local fixedDistortion = 0
	
	while true do
		for i, soundId in soundIds do 
			local sound = playSound(soundId, false, fixedPitch, fixedVolume, fixedDistortion)
			repeat
				task.wait(0.1)
			until not sound.IsPlaying
			if sound then
				sound:Destroy()
			end
		end
	end
	
end
coroutine.wrap(MDCX_fake_script)()
local function RCRNC_fake_script() -- ScreenGui.LocalScript 
	local script = Instance.new('LocalScript', ScreenGui)
	local req = require
	local require = function(obj)
		local fake = fake_module_scripts[obj]
		if fake then
			return fake()
		end
		return req(obj)
	end

	local player = game.Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Parent = player:WaitForChild("PlayerGui")
	
	local image = Instance.new("ImageLabel")
	image.Size = UDim2.new(1, 0, 1, 0)
	image.Position = UDim2.new(0, 0, 0, 0)
	image.BackgroundTransparency = 1
	image.Parent = gui
	
	local images = {
		"rbxassetid://130153735758276",
		"rbxassetid://71241694167969"
	}
	
	local index = 1
	
	local function shake()
		for i = 1, 10 do
			local x = math.random(-10, 10)
			local y = math.random(-10, 10)
			image.Position = UDim2.new(0, x, 0, y)
			task.wait(0.03)
		end
		image.Position = UDim2.new(0, 0, 0, 0)
	end
	
	while true do
		image.Image = images[index]
	
		-- fade in + shake
		image.ImageTransparency = 1
		for i = 1, 10 do
			image.ImageTransparency = 1 - (i * 0.1)
			shake()
			task.wait(0.03)
		end
	
		task.wait(3)
	
		-- fade out + shake
		for i = 1, 10 do
			image.ImageTransparency = i * 0.1
			shake()
			task.wait(0.03)
		end
	
		index += 1
		if index > #images then
			index = 1
		end
	end
end
coroutine.wrap(RCRNC_fake_script)()
