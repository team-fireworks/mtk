--!strict
-- Written by fanofpixels

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- Folders
local RemotesFolder: Folder = ReplicatedStorage.TowerGame

-- Remotes
local RemoteEvents: { [string]: RemoteEvent } = {}
local RemoteFunctions: { [string]: RemoteFunction } = {}
local ResetEffectGui: BindableEvent = RemotesFolder:WaitForChild("ResetEffectGui") :: BindableEvent
do
	for k: number, v: Instance in RemotesFolder:GetChildren() do
		if v:IsA("RemoteEvent") then
			RemoteEvents[v.Name] = v
		elseif v:IsA("RemoteFunction") then
			RemoteFunctions[v.Name] = v
		end
	end
end

-- Modules
local ClientObjects = require(script.ClientObjects)
local GUI = require(script.GUI)
local PlayerCollision = require(script.PlayerCollision)
local Announcements = require(script.Announcements)
local Lighting = require(script.Lighting)
local Util = require(script.Util)

-- Misc Stuff
local LocalPlayer = Players.LocalPlayer
local TowerTimer: number = 0
local RestartTime: number = 0
local RestartTimeMax: number = 5
local RestartDebounce: boolean = false
local CurrentTower: string = ""

function LoadTower(Acronym: string, Purist: boolean, ResetTimer: boolean)
	CurrentTower = Acronym
	if ResetTimer then
		TowerTimer = 0
		GUI:SetBoostsUsed(false)
	end
	GUI:SetTowerAcronym(Acronym)
	ResetEffectGui:Fire()

	RestartTime = 0
	-- If the restart time is hitting the maximum, enable the debounce so that we don't accidentally restart again
	if RestartTime >= RestartTimeMax then
		RestartDebounce = true
	end

	-- If this tower is purist we can ski
	if not Purist then
		local COFolder: Instance? = LocalPlayer:WaitForChild("ClientSidedObjects", 10)
		if COFolder then
			-- Let the module dedicated to loading client objects load the client objects
			ClientObjects:LoadClientObjects(COFolder, false)
		else
			error(
				"A tower has attempted to loaded in. It wasn't marked as purist but no ClientSidedObjects folder was sent over. Bad internet connection?"
			)
		end
	end
end

function UnloadTower()
	CurrentTower = ""
	TowerTimer = 0
	RestartTime = 0

	ResetEffectGui:Fire()
	ClientObjects:UnloadClientObjects()

	GUI:SetTowerAcronym("")
	GUI:SetTowerTimer(0)
	GUI:SetTowerRush(0, 0)
	GUI:SetBoostsUsed(false)
	GUI:SetRestartLabel(0)
end

-- Should fire every ~2 or so seconds to ensure the client's timer and the server's timer aren't out of sync
-- If they are out of sync, both are using DeltaTime to increment the timer so the margin of error should be very small
function CorrectTimer(Time: number)
	TowerTimer = Time
end

function UpdateTowerRush(Index: number, End: number)
	GUI:SetTowerRush(Index, End)
end

function CharacterAdded(Character: Model)
	Character.ChildAdded:Connect(function(Ins: Instance)
		-- If item equipped:
		if Ins:IsA("Tool") then
			local BoostName: string? = Ins:GetAttribute("BoostName")

			-- If this is a boost item and the player is in a tower
			if BoostName and BoostName ~= "" and CurrentTower ~= "" then
				GUI:SetBoostsUsed(true)
			end
		end
	end)
end

function Step(DeltaTime: number)
	if CurrentTower == "" then
		TowerTimer = 0
		RestartTime = 0
	else
		TowerTimer += DeltaTime

		local PreviousRestartTime: number = RestartTime

		-- If the user is holding the restart key, and the debounce is false
		if UserInputService:IsKeyDown(Enum.KeyCode.R) then
			if not RestartDebounce then
				RestartTime = math.min(RestartTime + DeltaTime, RestartTimeMax)
				if RestartTime >= RestartTimeMax then
					-- Enable the debounce so that we don't spam the server
					RestartDebounce = true
					RemoteEvents.RestartRequested:FireServer()
				end
			end
		else
			RestartTime = math.max(RestartTime - DeltaTime, 0)
			RestartDebounce = false
		end
	end
	GUI:SetRestartLabel(RestartTime / RestartTimeMax)
	GUI:SetTowerTimer(TowerTimer)
end

RemoteEvents.UpdateTowerTimer.OnClientEvent:Connect(CorrectTimer)
RemoteEvents.UpdateTowerRush.OnClientEvent:Connect(UpdateTowerRush)
RemoteEvents.LoadTower.OnClientEvent:Connect(LoadTower)
RemoteEvents.UnloadTower.OnClientEvent:Connect(UnloadTower)
RunService.RenderStepped:Connect(Step)

do
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

	PlayerCollision:Init()
	Lighting:Init()
	Announcements:SetRemoteEvents(RemoteEvents)

	local ECOs: boolean, ECOFolder: Folder? = RemoteFunctions.RequestEverpresentCOs:InvokeServer()
	if ECOs and ECOFolder then
		ECOFolder.Parent = workspace
		ClientObjects:LoadClientObjects(ECOFolder, true)
	end

	LocalPlayer.CharacterAdded:Connect(CharacterAdded)

	GUI:SetTowerTimer(0)
	GUI:SetTowerAcronym("")
	GUI:SetTowerRush(0, 0)
end
