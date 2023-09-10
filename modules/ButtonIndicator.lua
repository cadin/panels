Panels.ButtonIndicator = {}

local ScreenWidth <const> = playdate.display.getWidth()
local ScreenHeight <const> = playdate.display.getHeight()

local gfx <const> = playdate.graphics

function Panels.ButtonIndicator.getPosititonForScrollDirection(direction)
	local x = ScreenWidth - 42
		local y = ScreenHeight / 2 -20
		if direction == Panels.ScrollDirection.RIGHT_TO_LEFT then
			x = 2
		elseif direction == Panels.ScrollDirection.TOP_DOWN then
			x = ScreenWidth / 2 - 20
			y = ScreenHeight - 42
		elseif direction == Panels.ScrollDirection.BOTTOM_UP then
			x = ScreenWidth / 2 - 20
			y = 2
		end

	return x, y
end

function Panels.ButtonIndicator.new()
	local button = {imageTable = nil, holdFrame = 4}
	button.currentFrame = 1
	button.step = 1
	button.state = "hidden"
	button.x = 0
	button.y = 0
	button.button = "0"
	
	button.timer = playdate.timer.new(
		50, 
		function()
			button:updateTimer()
		end
	)
	button.timer.repeats = true
	button.timer.paused = true
	
	function button:setPosition(x, y)
		self.x = x
		self.y = y
	end
	
	function button:setButton(button)
		if self.button ~= button then 
			local imgTable = nil
			if button == Panels.Input.A then
				imgTable = gfx.imagetable.new(
					Panels.Settings.path .. "assets/images/buttonA-table-40-40.png")
			elseif button == Panels.Input.B then
				imgTable = gfx.imagetable.new(
					Panels.Settings.path .. "assets/images/buttonB-table-40-40.png")
			elseif button == Panels.Input.UP then
				imgTable = gfx.imagetable.new(
					Panels.Settings.path .. "assets/images/buttonUP-table-40-40.png")
			elseif button == Panels.Input.RIGHT then
				imgTable = gfx.imagetable.new(
					Panels.Settings.path .. "assets/images/buttonRT-table-40-40.png")
			elseif button == Panels.Input.DOWN then
				imgTable = gfx.imagetable.new(
					Panels.Settings.path .. "assets/images/buttonDN-table-40-40.png")
			else
				imgTable = gfx.imagetable.new(
					Panels.Settings.path .. "assets/images/buttonLT-table-40-40.png")
			end
			self.imageTable = imgTable
		end
	end
	
	function button:setPositionForScrollDirection(direction)
		local x, y = Panels.ButtonIndicator.getPosititonForScrollDirection(direction)
		self:setPosition(x, y)
	end
	
	function button:show()
		if self.currentFrame == 1 then 
			self.state = "showing"
			self.step = 1
			self.timer:start()
		end
	end
	
	function button:hide()
		if self.currentFrame <= self.holdFrame then
			self.state = "hiding"
			self.step = -1
			self.timer:start()
		end
	end
	
	function button:press()
		self.state = "pressing"
		self.timer:pause()
		self.step = 1
		self.currentFrame = self.holdFrame + 1
		self.timer:start()
	end
	
	function button:updateTimer()
		if self.imageTable then 
			self.currentFrame = self.currentFrame + self.step
	
			if self.currentFrame < 1 or self.currentFrame >= #self.imageTable then
				self.currentFrame = 1
				self.timer:pause()
				self.state = "hidden"
			elseif self.currentFrame == self.holdFrame then
				self.timer:pause() 
			end
		end
	end
	
	function button:draw(x, y)
		if self.imageTable then 
			self.imageTable:drawImage(self.currentFrame, x or self.x, y or self.y)
		end
	end
	
	return button
end