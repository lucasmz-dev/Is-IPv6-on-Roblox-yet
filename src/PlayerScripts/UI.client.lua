local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local RemoteService = require(ReplicatedStorage.Utils.RemoteService)
local Janitor = require(ReplicatedStorage.Utils.Janitor)

local TestResultLoaded = RemoteService.GetRemoteEvent("TestResultLoaded")
local TweenInfo = require(ReplicatedStorage.TweenInfo)

local LocalPlayer = Players.LocalPlayer

local IPv6WorkingMessageText = "Hey there! IPv6 is working!\n This doesn't directly mean you're connected to Roblox over IPv6, however developers can reach IPv6-only resources on the web!\n This doesn't say anything about whether the website, or connectivity from player-to-server is IPv6 supported, only that developers can access it and can run their servers without paying extra.\n This is already a step, as of writing this, Roblox does not support IPv6 anywhere, meaning that IPv6 is probably being rolled out and those can be expected soon, if everything goes well."
local IPv4OnlyWorkingMessageText = "Hey... Unfortunately IPv6 is not supported.\n It's possible other Roblox services are IPv6 supported however you probably can't connect to servers over IPv6, and developers can not connect to self-hosted servers without paying for a public IPv4."
local CouldNotConcludeMessageText = "Hey... We couldn't confirm.\n We were not able to connect to test servers via IPv4, we have not tried over IPv6 because of that. If everything else is working, it's possible you're in the far future where Roblox does not allow IPv4 connections anymore and is only allowing developers to use IPv6 supported servers.\n That is amazing! However if this isn't the case, contact the game's developer."

local Fusion = require(ReplicatedStorage.Utils.Fusion)
local New = Fusion.New
local State = Fusion.State
local Computed = Fusion.Computed
local Children = Fusion.Children

local ScreenGui
local BackgroundFrame
local ResultText
local MessageText
local MessageBox

ScreenGui = New "ScreenGui" {
	Name = "GUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Global,
	IgnoreGuiInset = true,

	Parent = LocalPlayer.PlayerGui,

	[Children] = New "Frame" {
		Name = "Background",
		Size = UDim2.fromScale(1, 1),

		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,

		[Children] = {
			New "TextLabel" {
				Name = "Title",
				Size = UDim2.fromScale(0.4, 0.125),

				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.075),

				BackgroundTransparency = 1,

				Text = "Is IPv6 enabled on Roblox?",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.FredokaOne,
				TextScaled = true
			},

			New "TextLabel" {
				Name = "Result",
				Size = UDim2.fromScale(0.3, 0.3),

				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.265),

				BackgroundTransparency = 1,

				Text = "",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.FredokaOne,
				TextScaled = true,

				[Children] = {
					New "UIStroke" {
						Thickness = 2,
						Color = Color3.fromRGB(255, 0, 0)
					}
				}
			},

			New "Frame" {
				Name = "MessageBackground",

				Size = UDim2.fromScale(0.95, 0.60),

				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, -25),

				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),

				[Children] = {
					New "ScrollingFrame" {
						Name = "Message",
						Size = UDim2.fromScale(1, 1),

						BackgroundTransparency = 1,
						ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),

						CanvasSize = UDim2.fromScale(0, 0),
						AutomaticCanvasSize = Enum.AutomaticSize.Y,

						[Children] = {
							New "TextLabel" {
								Name = "Text",
								Size = UDim2.fromScale(0.85, 0.9),

								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),

								BackgroundTransparency = 1,

								Text = "",
								TextColor3 = Color3.fromRGB(255, 255, 255),
								Font = Enum.Font.FredokaOne,
								TextScaled = true,
							}
						}
					},

					New "UICorner" {
						CornerRadius = UDim.new(0, 22)
					}
				}
			}
		}
	}
}

BackgroundFrame = ScreenGui.Background
ResultText = BackgroundFrame.Result
MessageBox = BackgroundFrame.MessageBackground
MessageText = MessageBox.Message.Text

local WaitingForResponseTextJanitor = Janitor.new()
local WaitingForResponseTextsTimeSinceLastAddedDot = 0
local WaitingForResponseTextsDotCount = 0
local WaitingForResponseText = New "TextLabel" {
	Name = "WaitingForResponseText",
	Size = UDim2.fromOffset(100, 100),

	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),

	BackgroundTransparency = 1,

	Text = "",
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(0, 0, 0),
	TextScaled = true,

	Parent = BackgroundFrame,

	[Children] = {
		New "UIStroke" {
			Thickness = 2,
			Color = Color3.fromRGB(255, 255, 255)
		}
	}
}

WaitingForResponseTextJanitor:Add(WaitingForResponseText)
WaitingForResponseTextJanitor:Add(
	RunService.Heartbeat:Connect(function(deltaTime)
		WaitingForResponseTextsTimeSinceLastAddedDot += deltaTime
		if WaitingForResponseTextsTimeSinceLastAddedDot >= 0.5 then
			WaitingForResponseTextsTimeSinceLastAddedDot = 0

			WaitingForResponseTextsDotCount += 1
			if WaitingForResponseTextsDotCount > 3 then
				WaitingForResponseTextsDotCount = 1
				WaitingForResponseText.Text = "."
			else
				WaitingForResponseText.Text ..= "."
			end
		else
			return
		end
	end), "Disconnect"
)

TestResultLoaded.OnClientEvent:Connect(function(result: boolean | nil)
	local getRidOfWaitingTextTween = TweenService:Create(WaitingForResponseText, TweenInfo, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 1)
	})
	getRidOfWaitingTextTween:Play()

	WaitingForResponseTextJanitor:Add(getRidOfWaitingTextTween)

	getRidOfWaitingTextTween.Completed:Connect(function()
		WaitingForResponseTextJanitor:Destroy()

		local resultTextsRightProperties = {
			Position = ResultText.Position,
			AnchorPoint = ResultText.AnchorPoint
		}
		local messageBoxsRightProperties = {
			Position = MessageBox.Position,
			AnchorPoint = MessageBox.AnchorPoint,
			BackgroundTransparency = 0
		}

		ResultText.AnchorPoint = Vector2.new(0.5, 1)
		ResultText.Position = UDim2.fromScale(0.5, 0)

		ResultText.Text = if result == true
			then "Yes!"
			elseif result == false then "No!"
			else "???"

		ResultText.UIStroke.Color = if result == true
			then Color3.fromRGB(0, 255, 0)
			elseif result == false then Color3.fromRGB(255, 0, 0)
			else Color3.new(0.35, 0.35, 0.35)

		MessageBox.AnchorPoint = Vector2.new(0.5, 0)
		MessageBox.Position = UDim2.fromScale(0.5, 1)

		MessageText.Text = if result == true
			then IPv6WorkingMessageText
			elseif result == false then IPv4OnlyWorkingMessageText
			else CouldNotConcludeMessageText

		local resultTextTween = TweenService:Create(ResultText, TweenInfo, resultTextsRightProperties)
		local messageBoxTween = TweenService:Create(MessageBox, TweenInfo, messageBoxsRightProperties)

		resultTextTween:Play()
		messageBoxTween:Play()
	end)
end)