local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local WaitForChild = require(ReplicatedStorage.Utils.BetterWaitForChild)
local IsServer = RunService:IsServer()

local Remotes: Folder do
	if IsServer then
		Remotes = Instance.new("Folder")
		Remotes.Name = "Remotes"

		for _, folderName in ipairs({"Events", "Functions"}) do
			local folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Parent = Remotes
		end

		Remotes.Parent = script
	else
		Remotes = WaitForChild(script, "Remotes")
	end
end

local RemoteService = {}

local function FindOrCreateNewInstanceFrom(
	folder: Folder,
	class: string,
	name: string
): Instance

	if IsServer then
		local remote = folder:FindFirstChild(name)
		if remote then
			return remote
		end

		remote = Instance.new(class)
		remote.Name = name
		remote.Parent = folder

		return remote
	else
		return WaitForChild(folder, name)
	end
end

-- (yields) Gets a RemoteEvent
function RemoteService.GetRemoteEvent(
	name: string
): RemoteEvent

	assert(
		typeof(name) == 'string',
		"Must be string"
	)

	return FindOrCreateNewInstanceFrom(
		Remotes.Events,
		"RemoteEvent",
		name
	)
end

-- (yields) Gets a RemoteFunction
function RemoteService.GetRemoteFunction(
	name: string
): RemoteFunction

	assert(
		typeof(name) == 'string',
		"Must be string"
	)

	return FindOrCreateNewInstanceFrom(
		Remotes.Functions,
		"RemoteFunction",
		name
	)
end

return RemoteService