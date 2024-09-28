local thefolder = game.ReplicatedStorage:WaitForChild("Background Music")

local zones = thefolder:WaitForChild("BackgroundMusicZones")
local glob = thefolder:WaitForChild("GlobalBackgroundMusic")

local mutebutton = script.MuteButtonGui

local p = game.Players.LocalPlayer

_G.MusicUseSmoothTransition = true --compatible with change at any time
local mute = false
mutebutton.Parent = p.PlayerGui

--this function was given to me by funwolf7

--This function will determine if a point is inside of an object
local function isPointInObject(Point, Object)
	--A variable for the size for simplicity
	local Size = Object.Size

	--The offset orientated to the object's cframe
	local PointOffset = Object.CFrame:PointToObjectSpace(Point)

	--The offset of that axis is less than or equal to half the size of the part on that axis
	--Basically, the offset on that axis will not go outside of the part
	local InsideX = math.abs(PointOffset.X) <= Size.X / 2
	local InsideY = math.abs(PointOffset.Y) <= Size.Y / 2
	local InsideZ = math.abs(PointOffset.Z) <= Size.Z / 2

	--Return whether or not it is inside all three axis
	return InsideX and InsideY and InsideZ
end

local currentlyplaying = {}
local focusedzone --this is the current zone that the player is determined to be within
--inside every single sound in the music folder is a numbervalue called OriginalVolume

function updatemutetext()
	mutebutton.Button.Text = ("Music: " .. (mute and "OFF" or "ON"))
	mutebutton.Button.TextColor3 = mute and Color3.new() or Color3.new(1, 1, 1)
	mutebutton.Button.Style = mute and Enum.ButtonStyle.RobloxRoundDropdownButton
		or Enum.ButtonStyle.RobloxRoundDefaultButton
end
updatemutetext()
mutebutton.Button.MouseButton1Click:Connect(function()
	mute = not mute
	updatemutetext()
	if currentlyplaying[focusedzone] then
		currentlyplaying[focusedzone].Volume = currentlyplaying[focusedzone].OriginalVolume.Value
	end
end)

for _, m in pairs(thefolder:GetDescendants()) do
	if m:IsA("Sound") then
		m.DidLoop:Connect(function()
			local othermusics = m.Parent:GetChildren()
			table.remove(othermusics, table.find(othermusics, m))
			if focusedzone ~= m.Parent then --if the music is already fading in, instantly set the volume to 0
				m.Volume = 0
				return
			end
			if #othermusics <= 0 then
				return
			end --do nothing if the music is by itself
			local newm = othermusics[math.random(1, #othermusics)]
			newm.Volume = newm.OriginalVolume.Value --also in extremely rare cases where the volume is insanely short, the next audio will just play at full volume
			newm:Play()
			currentlyplaying[m.Parent] = newm
			m:Stop()
		end)
	end
end

while wait(_G.MusicUseSmoothTransition and 1 / 10 or 1 / 20) do --yeah kinda weird
	--first, check if the character even exists
	if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
		local playerpos = p.Character.HumanoidRootPart.Position
		--next, check every zone and see which ones the player is in
		local BestZone = glob --highest priority zone
		for _, z in pairs(zones:GetChildren()) do
			if z:FindFirstChild("Music") then
				if not z:FindFirstChild("Priority") then --make one
					local pr = Instance.new("NumberValue", z)
					pr.Name = "Priority"
					pr.Value = 1
				end
				--check to see if it classifies as a real zone
				local active = false --false by default
				for _, pt in pairs(z:GetChildren()) do --check for every part inside
					if pt:IsA("BasePart") and isPointInObject(playerpos, pt) then
						active = true
					end --simple, ye
				end
				if active and (BestZone == glob or z.Priority.Value > BestZone.Priority.Value) then --take over the best zone if it doesn't exist or this zone has a higher priority
					BestZone = z
				end
			end
		end
		if BestZone ~= glob then
			BestZone = BestZone.Music
		end --set it to the music folder to make it not distinguished between the global music and the music zones
		focusedzone = BestZone
		local isplaying
		local allplaying = 0
		for a, b in pairs(currentlyplaying) do
			allplaying = allplaying + 1
		end
		for mz, s in pairs(currentlyplaying) do
			local increment = s.OriginalVolume.Value / 30 --this is the increment each tick to increase/decrease the volume
			if mz == BestZone then
				isplaying = true --do nothing but increase the volume
				if (_G.MusicUseSmoothTransition or s.Playing) and not mute then --here is where smooth transition comes into play
					local newvol = s.Volume + increment
					if newvol > s.OriginalVolume.Value then
						newvol = s.OriginalVolume.Value
					end --without this the audio would rapidly increase to hilariously but ear shatteringly loud
					s.Volume = newvol
				elseif not mute then
					if allplaying <= 1 then
						s.Volume = s.OriginalVolume.Value
						if not s.Playing then
							s:Play()
						end
					end
				else
					s.Volume = 0
				end
			else
				--fade out the music by an increment, and if its volume is already 0 then just stop it and remove it altogether
				s.Volume = s.Volume - increment
				if s.Volume <= 0 or mute then
					s:Stop()
					s.Volume = 0 --may not even be needed, but just to be safe
					currentlyplaying[mz] = nil
				end
			end
		end
		if not isplaying and #BestZone:GetChildren() > 0 then --do nothing if the folder is empty
			local play = BestZone:GetChildren()[math.random(1, #BestZone:GetChildren())]
			play.Volume = 0 --again may not be needed, but i gotta be safe ok
			if _G.MusicUseSmoothTransition then
				play:Play()
			end
			currentlyplaying[BestZone] = play
		end
	end
end
