--Scripted by funwolf7

--Turn this to true to make the shift lock cursor thing appear at the center.
local SHOW_CENTER_CURSOR = true

------------------------------------------------------------------------
--Actual script starts here. I don't reccomend modifying anything past this point.

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer

local IsMobile = UserInputService.TouchEnabled --Is true if on mobile.

if IsMobile then --Only does things if it's on mobile.
	--Create the gui.
	local SHIFT_LOCK_OFF = "rbxasset://textures/ui/mouseLock_off.png"
	local SHIFT_LOCK_ON = "rbxasset://textures/ui/mouseLock_on.png"
	local SHIFT_LOCK_CURSOR = "rbxasset://textures/MouseLockedCursor.png"

	local frame = Instance.new("Frame")
	frame.Name = "BottomLeftControl"
	frame.Size = UDim2.new(0.1, 0, 0.1, 0)
	frame.Position = UDim2.new(1, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(1, 0.5)
	frame.BackgroundTransparency = 1
	frame.ZIndex = 10
	frame.Parent = script.Parent

	local ShiftLockIcon = Instance.new("ImageButton")
	ShiftLockIcon.Name = "MouseLockLabel"
	ShiftLockIcon.Size = UDim2.new(1, 0, 1, 0)
	ShiftLockIcon.Position = UDim2.new(0, 0, 0, 0)
	ShiftLockIcon.BackgroundTransparency = 1
	ShiftLockIcon.Image = SHIFT_LOCK_OFF
	ShiftLockIcon.Visible = true
	ShiftLockIcon.Parent = frame

	local frame2 = Instance.new("Frame")
	frame2.Name = "MiddleIcon"
	frame2.Size = UDim2.new(0.075, 0, 0.075, 0)
	frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundTransparency = 1
	frame2.ZIndex = 10
	frame2.Visible = true
	frame2.Parent = script.Parent

	local MouseLockCursor = Instance.new("ImageLabel")
	MouseLockCursor.Name = "MouseLockLabel"
	MouseLockCursor.Size = UDim2.new(1, 0, 1, 0)
	MouseLockCursor.Position = UDim2.new(0, 0, 0, 0)
	MouseLockCursor.BackgroundTransparency = 1
	MouseLockCursor.Image = SHIFT_LOCK_CURSOR
	MouseLockCursor.Visible = false
	MouseLockCursor.Parent = frame2

	local arc = Instance.new("UIAspectRatioConstraint")
	arc.AspectRatio = 1
	arc.DominantAxis = "Height"
	arc.Parent = frame
	arc:Clone().Parent = frame2

	--When the icon is pressed, change the icons and change a value that the RenderStepped below uses.
	local Activated = false
	ShiftLockIcon.Activated:connect(function()
		Activated = not Activated

		ShiftLockIcon.Image = Activated and SHIFT_LOCK_ON or SHIFT_LOCK_OFF
		MouseLockCursor.Visible = Activated and SHOW_CENTER_CURSOR
	end)

	--Will run every frame just after the default camera.
	local function OnStep()
		if Activated then
			local Camera = workspace.CurrentCamera
			if Camera then
				local Character = Player.Character
				local Humanoid = Character and Character:FindFirstChild("Humanoid")
				local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Head = Character and Character:FindFirstChild("Head")
				if Humanoid and Humanoid.Health > 0 and RootPart then
					--Rotate the player based off the camera.
					local LookVector = Camera.CFrame.LookVector
					RootPart.CFrame = CFrame.new(RootPart.Position)
						* CFrame.Angles(0, math.atan2(-LookVector.X, -LookVector.Z), 0)
				end
				--Offsets the player if they aren't in first person.
				if Head and (Head.Position - Camera.CFrame.Position).Magnitude >= 1 then
					Camera.CFrame = Camera.CFrame * CFrame.new(1.75, 0, 0)
				end
			end
		end
	end
	RunService:BindToRenderStep("MobileShiftLock", Enum.RenderPriority.Camera.Value + 1, OnStep)
end
