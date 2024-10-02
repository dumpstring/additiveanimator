--!strict

--[=[
	@class AdditiveAnimator
	by dumpstring

	AdditiveAnimator is a utility class for handling additive animations on 
	characters in Roblox. It allows the loading and manipulation of animations 
	using helpers that mimic a character's rig and animate parts in a seamless, 
	additive manner. 
	
	## WARNING
	You have to handle replication for the animator yourself!

	### Methods
	- `GetAllTracks`: Returns all animation tracks.
	- `GetPlayingTracks`: Returns all currently playing animation tracks.
	- `LoadAnimation`: Loads a new animation, attaching it to a helper rig for additive animation.
]=]

local holder = game:GetService("Workspace"):WaitForChild("Terrain"):FindFirstChild("AdditiveHolder")
if not holder then
	holder = Instance.new("Folder", game:GetService("Workspace"):WaitForChild("Terrain"))
	holder.Name = "AdditiveHolder"
end

local AdditiveAnimator = {}
AdditiveAnimator.__index = AdditiveAnimator

function AdditiveAnimator:GetAllTracks(): { AnimationTrack }
	local tracks = {}
	for _, helper in ipairs(self.__helpers) do
		table.insert(tracks, helper.track)
	end
	return tracks
end

function AdditiveAnimator:GetPlayingTracks(): { AnimationTrack }
	local tracks = {}
	for _, helper in ipairs(self.__helpers) do
		if helper.track.IsPlaying then
			table.insert(tracks, helper.track)
		end
	end
	return tracks
end

function AdditiveAnimator:LoadAnimation(Animation: Animation)
	local character = self.__character
	local humanoid = Instance.new("Humanoid")

	local newRig = {
		character = Instance.new("Model"),
		animator = Instance.new("Animator", humanoid),
		joints = {},
	}

	newRig.character.Name = "Helper"
	newRig.character.Parent = holder
	humanoid.Parent = newRig.character

	local partMap = {}

	local function createPart(originalPart: BasePart): BasePart
		if partMap[originalPart] then
			return partMap[originalPart]
		end

		local helperPart = Instance.new("Part")
		helperPart.Transparency = 1
		helperPart.Size = Vector3.new(1, 1, 1)
		helperPart.Name = originalPart.Name
		helperPart.Anchored = true
		helperPart.CanCollide = false
		helperPart.CanQuery = false
		helperPart.CanTouch = false
		helperPart.Parent = newRig.character

		partMap[originalPart] = helperPart
		return helperPart
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("Motor6D") then
			local motor6DClone = descendant:Clone()

			local part0Clone = createPart(descendant.Part0)
			local part1Clone = createPart(descendant.Part1)

			motor6DClone.Part0 = part0Clone
			motor6DClone.Part1 = part1Clone
			motor6DClone.Parent = part1Clone

			newRig.joints[motor6DClone] = descendant
		end
	end

	newRig.track = newRig.animator:LoadAnimation(Animation)
	table.insert(self.__helpers, newRig)

	return newRig.track
end

type self = {
	GetAllTracks: (self: AdditiveAnimator) -> { AnimationTrack },
	GetPlayingTracks: (self: AdditiveAnimator) -> { AnimationTrack },
	LoadAnimation: (self: AdditiveAnimator, Animation: Animation) -> AnimationTrack,
	__helpers: {
		{
			character: Model | Actor,
			animator: Animator,
			joints: { [Motor6D]: Motor6D },
			track: AnimationTrack,
		}
	},
	__character: Model,
}

export type AdditiveAnimator = typeof(setmetatable({} :: self, AdditiveAnimator))

local Module = {}

function Module.new(Character: Model | Actor): AdditiveAnimator
	local self = {
		__helpers = {},
		__character = Character,
	}

	game:GetService("RunService").Stepped:Connect(function()
		local combinedData = {}

		for _, helper in ipairs(self.__helpers) do
			for joint, originalJoint in pairs(helper.joints) do
				if combinedData[originalJoint] then
					combinedData[originalJoint] = (combinedData[originalJoint] :: CFrame) * joint.Transform
				else
					combinedData[originalJoint] = joint.Transform
				end
			end
		end

		for joint, transform in pairs(combinedData) do
			joint.Transform = transform
		end
	end)

	Character.Destroying:Connect(function()
		for i, v in ipairs(self.__helpers) do
			v.character:Destroy()
		end

		table.clear(self)
		table.freeze(self)
	end)

	return setmetatable(self :: self, AdditiveAnimator)
end

return Module
