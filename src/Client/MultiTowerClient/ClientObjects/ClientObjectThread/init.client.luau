--!strict
-- Written by fanofpixels

local Repo: Instance = script.Repository.Value
local Context: Instance = script.Context.Value

-- The ModuleScript of the client object to be spawned, whether it be a ClientObjectScript or a RunRepoScript
local Body: ModuleScript

if Context:IsA("StringValue") then
	-- The context is a StringValue! it must be a RunRepoScript

	-- Find the script referenced in the script repository
	local RepoScript: Instance? = Repo:FindFirstChild(Context.Value)

	if RepoScript and RepoScript:IsA("ModuleScript") then
		Body = RepoScript:Clone()
		Body.Name = "RepoScriptInstantiation_" .. Body.Name
		Body.Parent = Context.Parent
	end
elseif Context:IsA("ModuleScript") then
	-- The body must be a ClientObjectScript!
	Body = Context
end

-- After the above code has happened, Body will be set to a ModuleScript to be spawned
spawn(require(Body))
