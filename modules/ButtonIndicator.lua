Panels.ButtonIndicator = {}

local ScreenWidth <const> = playdate.display.getWidth()
local ScreenHeight <const> = playdate.display.getHeight()

local gfx <const> = playdate.graphics

Panels.ControlSize = {
	LARGE = 40,
	MEDIUM = 30,
	SMALL = 20,
}

function Panels.ButtonIndicator.getPosititonForScrollDirection(direction, _size)
	local size = _size or Panels.ControlSize.LARGE

	local x = ScreenWidth - size - 2
		local y = (ScreenHeight - size) / 2
		if direction == Panels.ScrollDirection.RIGHT_TO_LEFT then
			x = 2
		elseif direction == Panels.ScrollDirection.TOP_DOWN then
			x = (ScreenWidth - size ) / 2
			y = ScreenHeight - size - 2
		elseif direction == Panels.ScrollDirection.BOTTOM_UP then
			x = (ScreenWidth - size ) / 2
			y = 2
		end

	return x, y
end

function Panels.ButtonIndicator.new(size)
	local button = {imageTable = nil, holdFrame = 4}
	button.currentFrame = 1
	button.step = 1
	button.state = "hidden"
	button.x = 0
	button.y = 0
	button.button = "0"
	button.size = size or Panels.ControlSize.LARGE
	
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
	
	function button:setButton(input)
		if self.button ~= input then
			local imageName = ""
			if input == Panels.Input.A then
				imageName = "buttonA"
			elseif input == Panels.Input.B then
				imageName = "buttonB"
			elseif input == Panels.Input.UP then
				imageName = "buttonUP"
			elseif input == Panels.Input.RIGHT then
				imageName = "buttonRT"
			elseif input == Panels.Input.DOWN then
				imageName = "buttonDN"
			else
				imageName = "buttonLT"
			end

			local imagePathSuffix = "-table-40-40.png"
			if self.size == Panels.ControlSize.SMALL then imagePathSuffix = "-SM-table-20-20.png" end
			if self.size == Panels.ControlSize.MEDIUM then imagePathSuffix = "-MD-table-30-30.png" end
			
			self.imageTable = gfx.imagetable.new(
				Panels.Settings.path .. "assets/images/" .. imageName .. imagePathSuffix)
		end
	end
	
	function button:setPositionForScrollDirection(direction)
		print("Setting position for scroll direction. size: " .. self.size)
		local x, y = Panels.ButtonIndicator.getPosititonForScrollDirection(direction, self.size)
		self:setPosition(x, y)
	end
	
	function button:reset() 
		self.state = "hidden"
		self.currentFrame = 1
		self.timer:pause()
		self.step = 1
	end

	function button:show()
		if self.currentFrame == 1 and self.state ~= "showing" then 
			self.state = "showing"
			self.step = 1
			self.timer:start()
		end
	end
	
	function button:hide()
		if self.currentFrame <= self.holdFrame and self.state ~= "hiding" then
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