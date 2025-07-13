local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local UIlib = {}
UIlib.__index = UIlib

local pos = nil

local function create(class, props)
	local inst = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

function UIlib.new(title)
	local self = setmetatable({}, UIlib)


	self.ScreenGui = create("ScreenGui", {
		Name = "CustomUILib",
		ResetOnSpawn = false,
		Parent = game.CoreGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	self.MainFrame = create("Frame", {
		Size = UDim2.new(0, 350, 0, 260),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(50, 20, 80),
		BorderSizePixel = 0,
		Parent = self.ScreenGui,
	})
	create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = self.MainFrame,
	})
	create("UIGradient", {
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 10)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(64, 44, 109)),
		},
		Rotation = 100,
		Parent = self.MainFrame,
	})

	self.TopBar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Parent = self.MainFrame,
	})

	self.TitleLabel = create("TextLabel", {
		Text = title or "UI Library",
		TextColor3 = Color3.fromRGB(230, 230, 230),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		Parent = self.TopBar,
	})

	self.TabBar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundTransparency = 1,
		Parent = self.MainFrame,
	})
	self.TabBarLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 5),
		Parent = self.TabBar,
	})

	self.ContentFrame = create("Frame", {
		Size = UDim2.new(1, -24, 1, -70),
		Position = UDim2.new(0, 12, 0, 64),
		BackgroundTransparency = 1,
		Parent = self.MainFrame,
		ClipsDescendants = true,
	})

	self.Tabs = {}
	self.CurrentTab = nil

	local dragging, dragInput, dragStart, startPos
	local function dragUpdate(input)
		local delta = input.Position - dragStart
		self.MainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	self.TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	self.TopBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			dragUpdate(input)
		end
	end)

	local closed = false
	local tweenDuration = 0.3
	local originalSize = self.MainFrame.Size


	local function setVisibleChildren(visible)
		for _, child in ipairs(self.MainFrame:GetChildren()) do
			if child:IsA("GuiObject") then
				child.Visible = visible
			end
		end
	end

	UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.RightAlt then
			if closed then
				self.MainFrame.ClipsDescendants = false
				

				self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
				local sizeTween = TweenService:Create(self.MainFrame, TweenInfo.new(tweenDuration), {
					Size = originalSize,
					Position = pos,
				})
				sizeTween:Play()
				task.delay(.15,function()
					setVisibleChildren(true)
				end)
				closed = false
			else
				pos = self.MainFrame.Position
				self.MainFrame.ClipsDescendants = true
				local closeTween = TweenService:Create(self.MainFrame, TweenInfo.new(tweenDuration), {
					Size = UDim2.new(0, 0, 0, 0)
				})
				closeTween:Play()
				task.delay(.05,function()
					setVisibleChildren(false)
				end)
				closed = true
			end
		end
	end)

	return self
end


function UIlib:addTab(name)
	local tab = {}

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 80, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(180, 180, 180)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.AutoButtonColor = false
	btn.Parent = self.TabBar

	btn.MouseEnter:Connect(function()
		if self.CurrentTab ~= tab then
			btn.TextColor3 = Color3.fromRGB(210, 210, 210)
		end
	end)
	btn.MouseLeave:Connect(function()
		if self.CurrentTab ~= tab then
			btn.TextColor3 = Color3.fromRGB(180, 180, 180)
		end
	end)

	tab.Button = btn

	tab.Content = Instance.new("Frame")
	tab.Content.Size = UDim2.new(1, 0, 1, 0)
	tab.Content.BackgroundTransparency = 1
	tab.Content.Visible = false
	tab.Content.Parent = self.ContentFrame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 12)
	layout.Parent = tab.Content

	tab.Elements = {}

	function tab:show()
		for _, t in pairs(self.Parent.Tabs) do
			t.Content.Visible = false
			t.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
		end
		self.Content.Visible = true
		self.Button.TextColor3 = Color3.fromRGB(130, 90, 220)
		self.Parent.CurrentTab = self
	end

	tab.Parent = self

	btn.MouseButton1Click:Connect(function()
		tab:show()
	end)

	table.insert(self.Tabs, tab)

	if #self.Tabs == 1 then
		tab:show()
	end


	function tab:addToggle(text, default, callback)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 28)
		frame.BackgroundTransparency = 1
		frame.Parent = tab.Content

		local label = Instance.new("TextLabel")
		label.Text = text
		label.TextColor3 = Color3.fromRGB(230, 230, 230)
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, -50, 1, 0)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = frame

		local toggleFrame = Instance.new("Frame")
		toggleFrame.Size = UDim2.new(0, 36, 0, 20)
		toggleFrame.Position = UDim2.new(1, -36, 0, 4)
		toggleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)  
		toggleFrame.Parent = frame
		create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleFrame})

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.Position = UDim2.new(0, 2, 0, 2)
		knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
		knob.Parent = toggleFrame
		create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

		local toggled = default

		local function update()
			if toggled then
				toggleFrame.BackgroundColor3 = Color3.fromRGB(90, 60, 160) 
				knob:TweenPosition(UDim2.new(1, -18, 0, 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
				knob.BackgroundColor3 = Color3.fromRGB(230, 230, 230) 
			else
				toggleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60) 
				knob:TweenPosition(UDim2.new(0, 2, 0, 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
				knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
			end
		end


		toggleFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				toggled = not toggled
				update()
				if callback then callback(toggled) end
			end
		end)

		update()
		table.insert(tab.Elements, frame)
		return toggleFrame, knob
	end
	
	function tab:addKeyToggle(text, defaultKey, callback)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 40)
		frame.BackgroundTransparency = 1
		frame.Parent = tab.Content

		local label = Instance.new("TextLabel")
		label.Text = text
		label.TextColor3 = Color3.fromRGB(230, 230, 230)
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(0.6, 0, 1, 0)
		label.Position = UDim2.new(0, 0, 0, 0)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = frame

		local keyButton = Instance.new("TextButton")
		keyButton.Text = defaultKey.Name
		keyButton.TextColor3 = Color3.fromRGB(180, 180, 180)
		keyButton.Font = Enum.Font.Gotham
		keyButton.TextSize = 14
		keyButton.AutoButtonColor = false
		keyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		keyButton.Size = UDim2.new(0, 80, 0, 24)
		keyButton.Position = UDim2.new(0.6, 10, 0.5, -12)
		keyButton.Parent = frame
		create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = keyButton})

		local toggleCircle = Instance.new("Frame")
		toggleCircle.Size = UDim2.new(0, 16, 0, 16)
		toggleCircle.Position = UDim2.new(1, -24, 0.5, -8)
		toggleCircle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		toggleCircle.BorderSizePixel = 0
		toggleCircle.Parent = frame
		create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleCircle})

		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local onColor = Color3.fromRGB(130, 90, 220)
		local offColor = Color3.fromRGB(100, 100, 100)

		local listeningForKey = false
		local boundKey = defaultKey
		local toggled = false

		local function updateVisual(state)
			local color = state and onColor or offColor
			TweenService:Create(toggleCircle, tweenInfo, {BackgroundColor3 = color}):Play()
		end

		updateVisual(toggled)

		keyButton.MouseButton1Click:Connect(function()
			if listeningForKey then return end
			listeningForKey = true
			keyButton.Text = "..."
		end)

		UIS.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end

			if listeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
				boundKey = input.KeyCode
				keyButton.Text = boundKey.Name
				listeningForKey = false
			elseif input.KeyCode == boundKey then
				toggled = not toggled
				updateVisual(toggled)
				if callback then callback(toggled) end
			end
		end)

		table.insert(tab.Elements, frame)

		return {
			SetState = function(state)
				toggled = state
				updateVisual(state)
				if callback then callback(state) end
			end,
			GetState = function() return toggled end,
			GetKey = function() return boundKey end
		}
	end

	
	function tab:addSlider(text, min, max, default, callback)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 40)
		frame.BackgroundTransparency = 1
		frame.Parent = tab.Content

		local label = Instance.new("TextLabel")
		label.Text = text
		label.TextColor3 = Color3.fromRGB(230, 230, 230)
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(0.6, 0, 0, 20)
		label.Position = UDim2.new(0, 0, 0, 0)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = frame

		local valueLabel = Instance.new("TextLabel")
		valueLabel.Text = tostring(default)
		valueLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		valueLabel.Font = Enum.Font.Gotham
		valueLabel.TextSize = 14
		valueLabel.BackgroundTransparency = 1
		valueLabel.Size = UDim2.new(0.35, 0, 0, 20)
		valueLabel.Position = UDim2.new(0.65, 0, 0, 0)
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		valueLabel.Parent = frame

		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(1, 0, 0, 6)
		sliderFrame.Position = UDim2.new(0, 0, 0, 24)
		sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		sliderFrame.Parent = frame
		create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = sliderFrame})

		local sliderFill = Instance.new("Frame")
		sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		sliderFill.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
		sliderFill.Parent = sliderFrame
		create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = sliderFill})

		local dragging = false

		local function updateSlider(pos)
			local relX = math.clamp(pos.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
			local pct = relX / sliderFrame.AbsoluteSize.X
			local rawValue = min + (max - min) * pct

			local precision = 2
			local factor = 10 ^ precision
			local value = math.floor(rawValue * factor + 0.5) / factor

			sliderFill.Size = UDim2.new(pct, 0, 1, 0)
			valueLabel.Text = tostring(value)
			if callback then callback(value) end
		end


		sliderFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				updateSlider(input.Position)
			end
		end)

		sliderFrame.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		UIS.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				updateSlider(input.Position)
			end
		end)

		table.insert(tab.Elements, frame)
		return sliderFill, valueLabel
	end

	return tab
end

return UIlib
