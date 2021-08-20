Panels.ButtonIndicator = {}

local ScreenWidth <const> = playdate.display.getWidth()
local ScreenHeight <const> = playdate.display.getHeight()

function Panels.ButtonIndicator.new(_imageTable, _holdFrame)
	local button = {imageTable = _imageTable, holdFrame = _holdFrame}
	button.currentFrame = 1
	button.step = 1
	button.state = "hidden"
	button.x = 0
	button.y = 0
	
	button.timer = playdate.timer.new(
		50, 
		function()
			button:updateTimer()
		end
	)
	button.timer.repeats = true
	
	function button:setPosition(x, y)
		self.x = x
		self.y = y
	end
	
	function button:setPositionForScrollDirection(direction)
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
		self.currentFrame = self.currentFrame + self.step
		

		
		if self.currentFrame < 1 or self.currentFrame >= #self.imageTable then
			self.currentFrame = 1
			self.timer:pause()
			self.state = "hidden"
		elseif self.currentFrame == self.holdFrame then
			self.timer:pause() 
		end
	end
	
	function button:draw(x, y)
		self.imageTable:drawImage(self.currentFrame, x or self.x, y or self.y)
	end
	
	return button
end