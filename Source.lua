local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local baseSpeed = 16
local speed = baseSpeed
local increment = 4
local holdInterval = 0.08

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedControlGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 86)
frame.Position = UDim2.new(0, 18, 1, -140)
frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0
frame.ZIndex = 10
frame.Parent = screenGui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,14)

local outerStroke = Instance.new("UIStroke", frame)
outerStroke.Color = Color3.fromRGB(0,200,255)
outerStroke.Thickness = 2.2
outerStroke.Transparency = 0.15

TweenService:Create(outerStroke, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
	{Transparency=0.4}):Play()

local innerGradient = Instance.new("UIGradient", frame)
innerGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(20,40,60)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(5,10,15))
}
innerGradient.Rotation = 90

local valueLabel = Instance.new("TextLabel", frame)
valueLabel.Size = UDim2.new(0.6,0,0,44)
valueLabel.Position = UDim2.new(0.2,0,0,12)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = tostring(speed)
valueLabel.Font = Enum.Font.GothamBlack
valueLabel.TextSize = 34
valueLabel.TextColor3 = Color3.fromRGB(170,255,255)
valueLabel.TextStrokeColor3 = Color3.fromRGB(10,10,12)
valueLabel.TextStrokeTransparency = 0
valueLabel.ZIndex = 11

local function makeButton(symbol, colA, colB, pos)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0, 56, 0, 40)
	btn.Position = pos
	btn.BackgroundColor3 = colA
	btn.AutoButtonColor = false
	btn.Text = symbol
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 26
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.ZIndex = 12

	local c = Instance.new("UICorner", btn)
	c.CornerRadius = UDim.new(0,12)

	local grad = Instance.new("UIGradient", btn)
	grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,colA),ColorSequenceKeypoint.new(1,colB)}

	local stroke = Instance.new("UIStroke", btn)
	stroke.Color = colB
	stroke.Thickness = 2
	stroke.Transparency = 0.05

	TweenService:Create(btn, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{BackgroundColor3 = colB}):Play()

	return btn
end

local minusBtn = makeButton("−", Color3.fromRGB(255,80,80), Color3.fromRGB(255,150,150), UDim2.new(0,12,1,-52))
local plusBtn  = makeButton("+", Color3.fromRGB(70,180,255), Color3.fromRGB(120,220,255), UDim2.new(1,-68,1,-52))

local function applySpeed(val)
	speed = math.max(baseSpeed,val)
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = speed end
	valueLabel.Text = tostring(speed)
end

local function hold(btn, delta)
	local holding = false
	local function start()
		if holding then return end
		holding = true
		applySpeed(speed+delta)
		task.spawn(function()
			task.wait(0.28)
			while holding do
				applySpeed(speed+delta)
				task.wait(holdInterval)
			end
		end)
	end
	local function stop() holding = false end

	btn.MouseButton1Down:Connect(start)
	btn.MouseButton1Up:Connect(stop)
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then
			start()
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then stop() end
			end)
		end
	end)
	btn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then stop() end
	end)
end

hold(minusBtn,-increment)
hold(plusBtn,increment)

do
	local dragging=false
	local startPos,startFramePos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true
			startPos=input.Position 
			startFramePos=frame.Position
			input.Changed:Connect(function()
				if input.UserInputState==Enum.UserInputState.End then dragging=false end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			local delta=input.Position-startPos
			if dragging then
				frame.Position=UDim2.new(startFramePos.X.Scale,startFramePos.X.Offset+delta.X,startFramePos.Y.Scale,startFramePos.Y.Offset+delta.Y)
			end
		end
	end)
end

player.CharacterAdded:Connect(function()
	task.wait(0.6)
	applySpeed(speed)
end)

applySpeed(speed)
