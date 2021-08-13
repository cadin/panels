Panels.ButtonIndicator = {}

function Panels.ButtonIndicator.new(_imageTable, _holdFrame)
	local button = {imageTable = _imageTable, holdFrame = _holdFrame}
	button.currentFrame = 1
	button.step = 1
	button.state = "hidden"
	
	function button:show()
		if self.currentFrame == 1 then 
			self.state = "showing"
			if self.timer == nil then
				self.timer = playdate.timer.new(
					50, 
					function()
						self:updateTimer()
					end
				)
				self.timer.repeats = true
			end
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
		self.imageTable:drawImage(self.currentFrame, x, y)
	end
	
	return button
end