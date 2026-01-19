
local gfx<const> = playdate.graphics
Panels.ChoiceList = {}

local function renderChoiceButton(text, x, y, w, h, radius, fontFamily, selected)
	if selected then text = "*" .. text .. "*" end

	gfx.pushContext()
		-- draw button background with inverted color
		if gfx.getColor() == Panels.Color.WHITE then 
			gfx.setColor(Panels.Color.BLACK)
		else
			gfx.setColor(Panels.Color.WHITE)
		end
		gfx.fillRoundRect(x + 3, y + 3, w - 6, h - 6, radius)
	gfx.popContext()

	gfx.pushContext()
		gfx.setLineWidth(1)
		gfx.drawRoundRect(x + 3, y + 3, w - 6, h - 6, radius)

		local _tw, textHeight = gfx.getTextSizeForMaxWidth(text, w -6)

		gfx.drawTextAligned(text, x + (w /2), y + (h / 2) - textHeight/2, Panels.TextAlignment.CENTER)
		
		if selected then 
			gfx.setLineWidth(2)
			gfx.drawRoundRect(x, y, w, h, radius + 2)
		end
	gfx.popContext()
end

local function getDefaultSelection(buttons)
	for i, button in ipairs(buttons) do
		if button.selected then
			return i
		end
	end
	return 1
end

local function getButtonAutoSize(buttons, maxWidth, fontFamily	)
	local buttonW = 0
	local buttonH = 0

	gfx.pushContext()
		if(fontFamily) then
			gfx.setFontFamily(Panels.Font.getFamily(fontFamily))
		end
	for i, button in ipairs(buttons) do
		-- we have to test both normal and selected sizes
		-- because sometimes bold is wider and sometimes normal is wider
		local tw, th = gfx.getTextSize(button.label)
		local bw, bh = gfx.getTextSize("*" .. button.label .. "*")
		local w = math.max(tw, bw)
		local h = math.max(th, bh)

		if w > buttonW then
			buttonW = w
		end
		if h > buttonH then
			buttonH = h
		end
	end
	gfx.popContext()
	return math.min(buttonW + 40, maxWidth), buttonH + 30
end

function createPointerTimer(choiceList)
	pointerTimer = playdate.timer.new(600, 0, 8, playdate.easingFunctions.inOutSine)
	pointerTimer.reverses = true
	pointerTimer.repeats = true
	pointerTimer.updateCallback = function(timer)
		choiceList.pointerX = timer.value
	end
end


function Panels.ChoiceList.new(data, frame, selectionCallback)

	local choiceList = {
		buttons = data.buttons,
		selectedIndex = getDefaultSelection(data.buttons),
		fontFamily = data.fontFamily,
		onSelectionChangePanelCallback = selectionCallback,
		onSelectionChangeUserCallback = data.onSelectionChange,
		renderButton = data.buttonRenderFunction or renderChoiceButton,
		didInit = false
	}

	choiceList.pointer = gfx.image.new(Panels.Settings.path .. "assets/images/pointer.png")
	choiceList.pointerX = 0

	local color = data.color or Panels.Color.BLACK
	local autoW, autoH = getButtonAutoSize(choiceList.buttons, math.min(frame.width, 380), choiceList.fontFamily)

	local w = data.width or autoW
	local h = data.height or autoH
	local spacing = data.spacing or 6
	local borderRadius = data.borderRadius or 4
	
	local x = data.x or (frame.width - w) / 2

	local totalHeight = (#choiceList.buttons * h) + ((#choiceList.buttons -1) * (spacing))
	local y = data.y or (frame.height - totalHeight) / 2


	function choiceList:render()
		if(pointerTimer == nil) then
			createPointerTimer(self)
		end

		if not self.didInit then
			self.didInit = true
			self.onSelectionChangePanelCallback(self.selectedIndex, self.buttons[self.selectedIndex])
		end

		self:checkInput()

		gfx.pushContext()
			if(self.fontFamily) then
				gfx.setFontFamily(Panels.Font.getFamily(self.fontFamily))
			end

			gfx.setColor(color)
			if color == Panels.Color.WHITE then 
				gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			else
				gfx.setImageDrawMode(gfx.kDrawModeCopy)
			end
		
			for i, button in ipairs(self.buttons) do
				self.renderButton(button.label, x, y + (h + spacing) * (i-1), w, h, borderRadius, self.fontFamily, self.selectedIndex == i)
			end
		gfx.popContext()
		
		local pointerY = y + (self.selectedIndex -1) * (h + spacing) + (h -self.pointer.height )/2
		self.pointer:draw(x + w - 16 + self.pointerX, pointerY)
	end


	function choiceList:checkInput()
		if playdate.buttonJustPressed(Panels.Input.UP) then
			if self.selectedIndex > 1 then 
				self.selectedIndex = self.selectedIndex - 1

				self.onSelectionChangePanelCallback(self.selectedIndex, self.buttons[self.selectedIndex])
			end

		elseif playdate.buttonJustPressed(Panels.Input.DOWN) then
			if self.selectedIndex < #self.buttons then 
				self.selectedIndex = self.selectedIndex + 1
				self.onSelectionChangePanelCallback(self.selectedIndex, self.buttons[self.selectedIndex])
			end
		end
	end

	function choiceList:reset() 
		pointerTimer:remove()
		pointerTimer = nil
	end

	return choiceList

end

