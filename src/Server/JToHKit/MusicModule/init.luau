return function(mainf)
	local scr = script.NewMusicScript
	scr.Parent = game.StarterPlayer.StarterPlayerScripts

	local zones = mainf:FindFirstChild("BackgroundMusicZones") or Instance.new("Folder", mainf)
	zones.Name = "BackgroundMusicZones"
	local glob = mainf:FindFirstChild("GlobalBackgroundMusic") or Instance.new("Folder", mainf)
	glob.Name = "GlobalBackgroundMusic"

	local musf = Instance.new("Folder")
	musf.Name = "Background Music"

	zones.Parent = musf
	glob.Parent = musf

	for _, s in pairs(musf:GetDescendants()) do
		if s:IsA("Sound") then
			s.Looped = true
			s.SoundGroup = game:GetService("SoundService"):WaitForChild("MusicGroup")
			local nv = Instance.new("NumberValue")
			nv.Name = "OriginalVolume"
			nv.Value = s.Volume
			nv.Parent = s
		end
	end

	musf.Parent = game.ReplicatedStorage
end
