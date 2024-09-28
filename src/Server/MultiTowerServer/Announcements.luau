--!strict
-- Written by fanofpixels

-- Get types
local Types = require(script.Parent.Types)

type List<T> = Types.List<T>
type Dictionary<T> = Types.Dictionary<T>
type PlayerInfo = Types.PlayerInfo
type TowerRush = Types.TowerRush
type TowerInfo = Types.TowerInfo
type EndingInfo = Types.EndingInfo
type Difficulty = Types.DifficultyInfo

type WinMessageInfo = {
	MessageID: string,

	PlayerName: string,
	EndingName: string,
	DifficultyName: string,

	Time: number,
	BoostsUsed: Dictionary<string>,
}
type ClientWinMessageInfo = {
	PlayerName: string,
	EndingName: string,
	Time: number,
	BoostsUsed: Dictionary<string>,

	Color: Color3,
	FancyFont: boolean,
}
type Message = {
	Data: any,
	Sent: number,
}

local m = {}

local RemoteEvents: Dictionary<RemoteEvent> = {}
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HTTPService = game:GetService("HttpService")
local Messaging = game:GetService("MessagingService")
local Util = require(script.Parent.Util)

local Config: Dictionary<any> = {}
local Difficulties: Dictionary<Difficulty> = {}
local KickMessages: List<string> = {}

local LatestGlobalMessageID: string = ""

function m:WinAnnouncement(Player: PlayerInfo, EndingName: string, DifficultyName: string)
	local EndingDifficulty: Difficulty = Util:GetDifficulty(DifficultyName)

	local Info: WinMessageInfo = {
		-- Unique message ID
		MessageID = HTTPService:GenerateGUID(false),

		PlayerName = Config.UseDisplayName and Player.Player.DisplayName or Player.Player.Name,
		EndingName = EndingName,
		DifficultyName = DifficultyName,

		Time = Player.TowerTimer,
		BoostsUsed = Player.BoostItemNames,
	}

	-- If this difficulty should be globally announced, message the universe
	if EndingDifficulty.GlobalAnnouncement then
		-- Set the latest global message ID, we do this so we can check later
		-- If we receive a message and it's the same one as this one, don't broadcast it
		-- This is to prevent a server from broadcasting the same win message twice
		LatestGlobalMessageID = Info.MessageID

		Messaging:PublishAsync("GlobalWin", Info)
	end

	BroadcastWinAnnouncement(Info)
end

--[[ removed this function but kept it in for future reference if needed
the reason for removal is because the client is now responsible for constructing a win message out of
the relevant info (useful for localization support in the future!)

-- Encapsulate this so that i cant accidentally create a loop with MessagingService
function BroadcastWinAnnouncement(Info:WinMessageInfo)
	local EndingDifficulty:Difficulty = Util:GetDifficulty(Info.DifficultyName)
	local BoostsUsed:List<string> = {}
	for k:string,v:string in Info.BoostsUsed do
		table.insert(BoostsUsed,v)
	end

	-- Construct the win message
	-- The {Time:???} will be substituted by the client
	local WinMessage:string = "{Player} beat {EndingName} in {Time} lol thats great"
	WinMessage = WinMessage:gsub("{Player}", Info.PlayerName)
	WinMessage = WinMessage:gsub("{EndingName}", Info.EndingName)
	WinMessage = WinMessage:gsub("{Time}","{Time:"..tostring(Info.Time).."}")

	-- If boosts were used, concatenate the list
	if #BoostsUsed > 0 then
		local BoostList:string = ""
		for k:number, v:string in BoostsUsed do
			BoostList ..= v
			if k < #BoostsUsed then
				BoostList ..= ", "
			end
		end
		WinMessage ..= " "..Config.WinBoostsUsed
		WinMessage = WinMessage:gsub("{BoostList}", BoostList)
	end

	-- Send the win message out
	m:GameAnnouncement(
		WinMessage,
		EndingDifficulty.Color,
		EndingDifficulty.FancyFont
	)
end
--]]

function BroadcastWinAnnouncement(Info: WinMessageInfo)
	local EndingDifficulty: Difficulty = Util:GetDifficulty(Info.DifficultyName)

	-- Construct an information table the client can recieve
	local ClientMsgInfo: ClientWinMessageInfo = {
		PlayerName = Info.PlayerName,
		EndingName = Info.EndingName,
		Time = Info.Time,
		BoostsUsed = Info.BoostsUsed,

		Color = EndingDifficulty.Color,
		FancyFont = EndingDifficulty.FancyFont,
	}

	RemoteEvents.GameWinAnnouncement:FireAllClients(ClientMsgInfo)
end

function m:GameAnnouncement(Message: string, Color: Color3, FancyText: boolean?)
	RemoteEvents.GameAnnouncement:FireAllClients(Message, Color, FancyText)
end

function m:AntiCheatKick(Plr: Player, Reason: string)
	local Message: string = KickMessages[math.random(1, #KickMessages)]
	Message = Message:gsub("{Player}", Config.UseDisplayNames and Plr.DisplayName or Plr.Name)

	m:GameAnnouncement(Message, Color3.new(1, 0, 0))
	Plr:Kick(Reason)
end

function GlobalWinMessage(Msg: Message)
	local Info: WinMessageInfo = Msg.Data :: WinMessageInfo

	-- Prevent double message
	if Info.MessageID == LatestGlobalMessageID then
		return
	end
	BroadcastWinAnnouncement(Info)
end

function m:Init(EventsTable: { [string]: RemoteEvent }, GameData: Folder)
	RemoteEvents = EventsTable

	-- Using ::any to make Luau shut up about "unsupported require path"
	Config = require(GameData:WaitForChild("Config")) :: any
	Difficulties = require(GameData:WaitForChild("Difficulties")) :: any
	KickMessages = require(GameData:WaitForChild("KickMessages")) :: any

	Messaging:SubscribeAsync("GlobalWin", GlobalWinMessage)
end

return m
