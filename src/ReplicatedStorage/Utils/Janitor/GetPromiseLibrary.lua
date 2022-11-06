local UtilFolder = script.Parent.Parent
local FoundPromise = UtilFolder:FindFirstChild("Promise")

return function()
	return FoundPromise ~= nil, FoundPromise
end