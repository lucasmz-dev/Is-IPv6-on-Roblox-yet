local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Utils.Janitor)

return function(
	parent: Instance,
	childName: string
): Instance

	assert(
		typeof(parent) == 'Instance',
		"Must be Instance"
	)

	assert(
		typeof(childName) == 'string',
		"Must be string"
	)

	do
		local child = parent:FindFirstChild(childName)
		if child then
			return child
		end
	end

	local masterJanitor = Janitor.new()
	local thread = coroutine.running()
	local wasResumed = false

	local function addListeners(child: Instance)
		local instanceJanitor = Janitor.new()
		masterJanitor:Add(instanceJanitor, "Destroy", child)

		instanceJanitor:Add(
			child:GetPropertyChangedSignal("Name"):Connect(function()
				if Janitor.Is(instanceJanitor) == false then
					return
				end

				if wasResumed then
					return
				end

				if child.Name == childName then
					masterJanitor:Cleanup()

					wasResumed = true
					task.spawn(thread, child)
				end
			end), "Disconnect"
		)
	end

	for _, child in ipairs(parent:GetChildren()) do
		addListeners(child)
	end

	masterJanitor:Add(
		parent.ChildAdded:Connect(function(child: Instance)
			if wasResumed then
				return
			end

			if child.Name == childName then
				masterJanitor:Cleanup()

				wasResumed = true
				task.spawn(thread, child)
			else
				addListeners(child)
			end
		end), "Disconnect"
	)

	masterJanitor:Add(
		parent.ChildRemoved:Connect(function(child: Instance)
			if wasResumed then
				return
			end

			masterJanitor:Remove(child)
		end), "Disconnect"
	)

	return coroutine.yield()
end