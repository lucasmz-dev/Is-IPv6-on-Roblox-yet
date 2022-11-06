local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RemoteService = require(ReplicatedStorage.Utils.RemoteService)

local TestResultLoaded = RemoteService.GetRemoteEvent("TestResultLoaded")

local IPv4TestServer = "https://ipv4.icanhazip.com/"
local IPv6TestServer = "https://ipv6.icanhazip.com/"

local function GetResponseAsync(url: string): (boolean, any)
	local success, tries = false, 0
	local response = nil
	while success == false and tries < 3 do
		success, response = pcall(
			HttpService.GetAsync, HttpService,
			url
		)

		tries += 1
	end

	return success, response
end

local function OnPlayerAdded(player: Player)
	local ipv4OnlyResponse do
		local response = table.pack(GetResponseAsync(IPv4TestServer))
		ipv4OnlyResponse = {
			WasSuccessful = response[1] :: boolean,
			Response = response[2] :: string | nil
		}
	end

	if ipv4OnlyResponse.WasSuccessful == false then
		TestResultLoaded:FireClient(player, nil)
		return
	end

	local ipv6OnlyResponse do
		local response = table.pack(GetResponseAsync(IPv6TestServer))
		ipv6OnlyResponse = {
			WasSuccessful = response[1] :: boolean,
			Response = response[2] :: string | nil
		}
	end

	TestResultLoaded:FireClient(player, ipv6OnlyResponse.WasSuccessful)
end

Players.PlayerAdded:Connect(OnPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	task.defer(OnPlayerAdded, player)
end