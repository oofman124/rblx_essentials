--[[

SoundSystem.lua
Author: oofman124 (GitHub)
Published: October 3, 2024
[BETA]

--]]

local PlaySoundRE = game.ReplicatedStorage:WaitForChild("Remote").Sound.PlaySound
local RS = game:GetService("RunService")
local Player = RS:IsClient() and game.Players.LocalPlayer or nil

export type SoundProperties = {
	volume : number,
	minDistance : number,
	maxDistance : number,
}

local module = {}


function module.PlaySound(sound : Instance | number, position : Vector3, properties : SoundProperties)
	if RS:IsClient() then
		if sound ~= nil then
			local Dist = Player:DistanceFromCharacter(position)
			if Dist >= properties.minDistance and Dist <= properties.maxDistance then
				local Attachment = Instance.new("Attachment", workspace.Terrain)
				Attachment.WorldPosition = position
				Attachment.Name = "SoundAttachment"
				local Sound = (typeof(sound) == "Instance" and sound:Clone()) :: Sound or (typeof(sound) == "number" and Instance.new("Sound")) :: Sound
				Sound.Parent = Attachment
				Sound.SoundId = typeof(sound) == "number" and "rbxassetid://".. sound or Sound.SoundId
				Sound.Volume = properties.volume
				Sound.RollOffMinDistance = properties.minDistance
				Sound.RollOffMaxDistance = properties.maxDistance
				Sound:Play()
				Sound.Ended:Connect(function()
					Attachment:Destroy()
				end)
			end
		end
	else
		PlaySoundRE:FireAllClients(sound, position, properties)
	end
end

function module.HandleClientEvents() -- you need a localscript that runs this function for the server->clients to work
	if RS:IsClient() then
		PlaySoundRE.OnClientEvent:Connect(module.PlaySound)
	end
end




return module
