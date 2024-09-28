--!strict
-- Written by fanofpixels

local m = {}

-- Important Stuff
local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Util = require(script.Parent.Util)
local TowerGui: ScreenGui = PlayerGui:WaitForChild("TowerGUI")
TowerGui.Enabled = true

-- Elements
local TowerAcronym: TextLabel? = TowerGui:FindFirstChild("TowerAcronym", true) :: TextLabel
local TowerRushProgress: TextLabel? = TowerGui:FindFirstChild("TowerRushProgress", true) :: TextLabel
local Timer: TextLabel? = TowerGui:FindFirstChild("Timer", true) :: TextLabel
local BoostsUsed: TextLabel? = TowerGui:FindFirstChild("BoostsUsed", true) :: TextLabel
local RestartLabel: TextLabel? = TowerGui:FindFirstChild("RestartLabel", true) :: TextLabel

local RestartTransparency: number = 0
local RestartStrokeTransparency: number = 1
if RestartLabel then
	RestartTransparency = RestartLabel.TextTransparency
	RestartStrokeTransparency = RestartLabel.TextStrokeTransparency
end

function m:SetTowerAcronym(Acronym: string)
	if TowerAcronym then
		TowerAcronym.Text = Acronym
		TowerAcronym.Visible = Acronym ~= ""
	end
end

function m:SetTowerRush(Progress: number, Max: number)
	if TowerRushProgress then
		TowerRushProgress.Text = tostring(Progress) .. "/" .. tostring(Max)
		TowerRushProgress.Visible = Max ~= 0
	end
end

function m:SetTowerTimer(Time: number)
	if Timer then
		Timer.Text = Util:FormatTimer(Time)
	end
end

function m:SetBoostsUsed(Val: boolean)
	if BoostsUsed then
		BoostsUsed.Visible = Val
	end
end

function m:SetRestartLabel(T: number)
	if RestartLabel then
		RestartLabel.Visible = T > 0
		RestartLabel.TextTransparency = 1 - (T * (1 - RestartTransparency))
		RestartLabel.TextStrokeTransparency = 1 - (T * (1 - RestartStrokeTransparency))
	end
end

return m
