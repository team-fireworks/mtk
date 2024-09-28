local Zones = script.Parent.BackgroundMusicZones
-- ungroup all of the zones
for k, v in pairs(Zones:GetDescendants()) do
	if v:IsA("Model") then
		if v.Parent ~= Zones then
			v.Name = v.Parent.Name .. "_" .. v.Name
			v.Parent = Zones
		end
	end
end
-- rid the zones of their empty folders, as they are no longer needed
for k, v in pairs(Zones:GetChildren()) do
	if v:IsA("Folder") then
		v:Destroy()
	end
end

require(4929117737)(script.Parent) --load the module, this is so it can be instantly updated at any time
