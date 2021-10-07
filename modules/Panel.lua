Panels.Panel = {}

local gfx <const> = playdate.graphics
local ScreenHeight <const> = playdate.display.getHeight()
local ScreenWidth <const> = playdate.display.getWidth()

local AxisHorizontal = Panels.ScrollAxis.HORIZONTAL


local function createFrameFromPartialFrame(frame) 
	if frame.margin == nil then frame.margin = 0 end

	if frame.width == nil then
		frame.width = ScreenWidth - frame.margin * 2
	end

	if frame.height == nil then
		frame.height = ScreenHeight - frame.margin * 2
	end

	if frame.x == nil then 
		frame.x = frame.margin
	end

	if frame.y == nil then
		frame.y = frame.margin
	end

	return frame
end

local function getScrollPercentages(frame, offset, axis)
	local xPct = 1 - (frame.x - frame.margin + frame.width + offset.x) / (ScreenWidth + frame.width)
	local yPct = 1 - (frame.y - frame.margin + frame.height + offset.y) / (ScreenHeight + frame.height)
	
	local pct = {x = xPct, y = yPct}
	if axis == AxisHorizontal then pct.y = 0.5 else pct.x = 0.5 end

	return pct
end

local function calculateShake(strength) 
	return {
		x = math.random(-strength, strength), 
		y = math.random(-strength, strength) 
	}
end

local function doLayerEffect(layer)
	if layer.effect.type == Panels.Effect.BLINK then
		if layer.timer == nil then
			if layer.effect.delay then 
				layer.visible = false
				layer.timer = playdate.timer.new(layer.effect.delay)
				layer.timer.repeats = false
			else
				layer.timer = playdate.timer.new(layer.effect.durations.on  + layer.effect.durations.off)
				layer.timer.repeats = true
			end
			
		else
			if layer.effect.delay then 
				if layer.timer.currentTime >= layer.effect.delay then 
					layer.effect.delay = false
					layer.timer = playdate.timer.new(layer.effect.durations.on  + layer.effect.durations.off)
					layer.timer.repeats = true
				end
			else 
				if layer.timer.currentTime < layer.effect.durations.on then
					if layer.visible == false then 
						layer.visible = true
						if layer.sfxPlayer then 
							layer.sfxPlayer:play()
						end
					end
				else 
					layer.visible = false
				end
			end
			
		end
	end
end

function Panels.Panel.new(data)
	local panel = table.shallowcopy(data)
	panel.prevPct = 0
	panel.frame = createFrameFromPartialFrame(panel.frame)
	panel.buttonsPressed = {}
	panel.canvas = gfx.image.new(panel.frame.width, panel.frame.height, gfx.kColorBlack)

	if not panel.parallaxDistance then
		if panel.axis == Panels.ScrollAxis.HORIZONTAL then
			panel.parallaxDistance = panel.frame.width * 1.2
		else 
			panel.parallaxDistance = panel.frame.height * 1.2
		end
	end

	if panel.panels then
		for i, p in ipairs(panel.panels) do
			panel.panels[i] = Panels.Panel.new(p)
		end
	end
	
	local imageFolder = Panels.Settings.imageFolder

	if panel.showAdvanceControl then 
		panel.advanceButton = Panels.ButtonIndicator.new()
		panel.advanceButton:setButton(panel.advanceControl)
		if panel.advanceControlPosition then 
			panel.advanceButton:setPosition(panel.advanceControlPosition.x, panel.advanceControlPosition.y)
		else 
			panel.advanceButton:setPositionForScrollDirection(panel.direction)
		end
	end

	if panel.layers then
		for i, layer in ipairs(panel.layers) do 
			if layer.image then 
				layer.img, error = Panels.Image.get(imageFolder .. layer.image)
				printError(error, "Error loading image on layer")
			end

			if layer.images then 
				layer.imgs = {}
				layer.currentImage = 1
				for j, image in ipairs(layer.images) do
					layer.imgs[j], error = Panels.Image.get(imageFolder .. image)
					printError(error, "Error loading images["..j.."] on layer")
				end
			end

			if layer.imageTable then 
				local imgTable, error = gfx.imagetable.new(Panels.Settings.imageFolder .. layer.imageTable)
				printError(error, "Error loading imagetable on layer")
				
				local anim = gfx.animation.loop.new(layer.delay or 200, imgTable, layer.loop or false)
				anim.paused = true
				if layer.scrollTrigger == nil then layer.scrollTrigger = 0 end
				layer.animationLoop = anim
			end

			if layer.x == nil then layer.x = -panel.frame.margin end
			if layer.y == nil then layer.y = -panel.frame.margin end
			if layer.visible == nil then layer.visible = true end
			layer.alpha = layer.opacity or nil

			if layer.effect then
				if layer.effect.type == Panels.Effect.BLINK and layer.effect.audio then
					layer.sfxPlayer = playdate.sound.sampleplayer.new(Panels.Settings.audioFolder .. layer.effect.audio.file)
				end
			end

			if layer.animate then 
				if layer.animate.delay == nil then layer.animate.delay = 0 end
				if layer.animate.duration and layer.animate.duration < 1 then layer.animate.duration = 1 end
				if layer.opacity == nil then layer.opacity = 1 end

				if layer.animate.audio then 
					layer.sfxPlayer = playdate.sound.sampleplayer.new(Panels.Settings.audioFolder .. layer.animate.audio.file)
				end
			end
		end
	end
	
	if panel.audio then 
		panel.sfxPlayer = playdate.sound.sampleplayer.new(Panels.Settings.audioFolder .. panel.audio.file)
		if panel.audio.pan then 
			panel.sfxPlayer:setVolume(1 - panel.audio.pan, panel.audio.pan)
		end
		panel.sfxTrigger = panel.audio.scrollTrigger or 0
	end

	function panel:isOnScreen(offset) 
		local isOn = false
		local f = self.frame
		if f.x + offset.x <= ScreenWidth and f.x + f.width + offset.x > 0 and 
		f.y + offset.y <= ScreenHeight and f.y + f.height+ offset.y > 0 then
			isOn = true	
		end

		return isOn	
	end

	function panel:fadePanelVolume(pct)
		local vol = 1
		if  pct < 0.25 then
			vol = pct / 0.25
		elseif pct > 0.75 then
			vol = (1 - pct) / 0.25 
		end

		self.sfxPlayer:setVolume(vol)
	end

	function panel:updatePanelAudio(pct)
		local count = panel.audio.repeatCount or 1
			if panel.audio.loop then count = 0 end
			if self.audio.triggerSequence then
				if self.audioTriggersPressed == nil then self.audioTriggersPressed = {} end
				local triggerButton = self.audio.triggerSequence[#self.audioTriggersPressed + 1]

				if playdate.buttonJustPressed(triggerButton) then
					self.audioTriggersPressed[#self.audioTriggersPressed+1] = triggerButton
					if #self.audioTriggersPressed == #self.audio.triggerSequence then 
						playdate.timer.performAfterDelay(self.audio.delay or 0, function () 
							self.sfxPlayer:play(count)
						end)
					end
				end

			elseif pct >= self.sfxTrigger and self.prevPct < self.sfxTrigger then
				self.sfxPlayer:play(count)
			end

			self:fadePanelVolume(pct)
	end
	
	function panel:drawLayers(offset)
		local layers = self.layers
		local frame = self.frame
		local shake
		local pct = getScrollPercentages(frame, offset, self.axis)
		local cntrlPct
		if self.axis == AxisHorizontal then cntrlPct = pct.x else cntrlPct = pct.y end
		if self.scrollingIsReversed then cntrlPct = 1-cntrlPct end
	
		if self.effect then
			if self.effect.type == Panels.Effect.SHAKE_UNISON then 
				shake = calculateShake(self.effect.strength) 
			end
		end
		
		if self.sfxPlayer then 
			self:updatePanelAudio(cntrlPct)
		end
	
		if layers then
			for i, layer in ipairs(layers) do 
				local p = layer.parallax or 0
				local xPos = math.floor(layer.x + (self.parallaxDistance * pct.x - self.parallaxDistance/2) * p)
				local yPos = math.floor(layer.y + (self.parallaxDistance * pct.y - self.parallaxDistance/2) * p)
				local rotation = 0
				
				if layer.animate then 
					local anim = layer.animate
					if (anim.triggerSequence or anim.autoStart) and not layer.animator then 

						if layer.buttonsPressed == nil then layer.buttonsPressed = {} end
						local triggerButton = nil
						if not anim.autoStart then 
							triggerButton = anim.triggerSequence[#layer.buttonsPressed + 1]
						end
						
						if anim.autoStart or playdate.buttonJustPressed(triggerButton) then
							layer.buttonsPressed[#layer.buttonsPressed+1] = triggerButton
							if anim.autoStart or #layer.buttonsPressed == #anim.triggerSequence then 
								layer.animator = gfx.animator.new((anim.duration or 200), 0, 1, anim.ease, anim.delay)
								if layer.sfxPlayer then 
									local count = anim.audio.repeatCount or 1
									if anim.audio.loop then count = 0 end
									playdate.timer.performAfterDelay(anim.delay + (anim.audio.delay or 0), function () 
										layer.sfxPlayer:play(count)
									end)
								end
							end
						end
					else
						if layer.animator then 
							cntrlPct = layer.animator:currentValue()
						end

						if anim.x then xPos = math.floor(xPos + ((anim.x - layer.x) * cntrlPct)) end
						if anim.y then yPos = math.floor(yPos + ((anim.y - layer.y) * cntrlPct)) end
						if anim.rotation then rotation = anim.rotation * cntrlPct end
						if anim.opacity then 
							local o = (anim.opacity - layer.opacity) * cntrlPct
							layer.alpha = o
							if o <= 0 then 
								layer.visible = false 
							else 
								layer.visible = true 
							end
						end
					end
				end
	
				if self.effect then
					if self.effect.type == Panels.Effect.SHAKE_UNISON or self.effect.type == Panels.Effect.SHAKE_INDIVIDUAL then
						if self.effect.type == Panels.Effect.SHAKE_INDIVIDUAL then
							shake = calculateShake(self.effect.strength)
						end
	
						xPos = xPos + shake.x * (1-p*p)
						yPos = yPos + shake.y * (1-p*p)
					end
				end
				
				if layer.effect then
					doLayerEffect(layer, xPos, yPos)
				end
				

				local img 
				if layer.img then 
					img = layer.img
				elseif layer.imgs then
					if layer.advanceControl then
						if playdate.buttonJustPressed(layer.advanceControl) then
							if layer.currentImage < #layer.imgs then 
								layer.currentImage = layer.currentImage + 1
							end
						end
						img = layer.imgs[layer.currentImage]
					else
						local p = cntrlPct
						p = p + (self.transitionOffset or 0)
						local j = math.max(math.min(math.ceil(p * #layer.imgs), #layer.imgs), 1)
						img = layer.imgs[j]
					end
				end

				if img then 
					if layer.visible then
						if layer.alpha and layer.alpha < 1 then
							img:drawFaded(xPos, yPos, layer.alpha, playdate.graphics.image.kDitherTypeBayer8x8)
						else 
							img:draw(xPos, yPos)
						end
					end
					
				elseif layer.text then
					if layer.visible then 
						if layer.alpha == nil or layer.alpha > 0.5 then
							self:drawTextLayer(layer, xPos, yPos)
						end
					end
				elseif layer.animationLoop then
					if layer.visible then
						if cntrlPct >= layer.scrollTrigger then 
							layer.animationLoop.paused = false
						end
						layer.animationLoop:draw(xPos, yPos)
					end
				end
	
			end
		end
		
		self.prevPct = cntrlPct
	end

	function panel:reset()
		if self.resetFunction then 
			self:resetFunction()
		end

		self:killTypingEffects()
		if self.sfxPlayer then 
			self.sfxPlayer:stop()
		end
		if self.layers then
			for i, layer in ipairs(self.layers) do
				if layer.animationLoop then
					layer.animationLoop.frame = 1
					-- local f = layer.animationLoop.frame -- force frame update (bug in 1.3.1)
					layer.animationLoop.paused = true
				end
				if layer.animator then
					layer.animator = nil
				end
				if layer.opacity then
					layer.alpha = layer.opacity
				else 
					layer.alpha = nil
				end
				if layer.sfxPlayer then 
					layer.sfxPlayer:stop()
				end
				if layer.textAnimator then
					layer.textAnimator = nil
				end
				if layer.images then
					layer.currentImage = 1
				end
				layer.buttonsPressed = nil
				layer.visible = true
			end
		end
		self.buttonsPressed = {}
		self.audioTriggersPressed = {}
		self.advanceControlTimerDidEnd = false
		self.advanceControlTimer = nil
	end

	function startLayerTypingSound(layer)
		if layer.isTyping then
			Panels.Audio.startTypingSound()
		end
	end
	
	function panel:drawTextLayer(layer, xPos, yPos)
		gfx.pushContext()
		if layer.font then
			gfx.setFont(Panels.Font.get(layer.font))
		elseif self.font then
			gfx.setFont(Panels.Font.get(self.font))
		end

		local txt = layer.text
		if layer.effect then
			if layer.effect.type == Panels.Effect.TYPE_ON then
				if layer.textAnimator == nil then
					layer.isTyping = true
					layer.textAnimator = gfx.animator.new(layer.effect.duration or 500, 0, string.len(txt), playdate.easingFunctions.linear, layer.effect.delay or 0)
					playdate.timer.performAfterDelay(layer.effect.delay or 0, startLayerTypingSound, layer)
				end
				
				if layer.isTyping then 
					local j = math.ceil(layer.textAnimator:currentValue())
					txt = string.sub(txt, 1, j)

					if txt == layer.text then
						layer.isTyping = false
						Panels.Audio.stopTypingSound()
					end
				end
			end
		end

		if layer.background then
			local w, h = gfx.getTextSize(txt)
			gfx.setColor(layer.background)
			if layer.background == Panels.Color.BLACK then 
				gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			end
			if w > 0 and h > 0 then
				gfx.fillRect(xPos - 4, yPos - 1, w + 8, h + 2 )
			end
		end
		if layer.color == Panels.Color.WHITE then
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		end

		
		gfx.drawText(txt, xPos, yPos)

		gfx.popContext()
	end
	
	function panel:drawBorder(color, bgColor)
		local w = Panels.Settings.borderWidth
		local b = gfx.image.new(self.frame.width, self.frame.height)
		gfx.pushContext(b)
			gfx.setColor(bgColor)
			gfx.setLineWidth(w)
			gfx.drawRect(0, 0, self.frame.width, self.frame.height)
			gfx.setColor(color)
			gfx.drawRoundRect(w/2, w/2, self.frame.width- w, self.frame.height -w, Panels.Settings.borderRadius)
		gfx.popContext()
		return b
	end

	local shouldAutoAdvance = false

	function panel:shouldAutoAdvance()
		if self.advanceFunction then 
			return self:advanceFunction()
		else
			return false
		end
	end

	function panel:killTypingEffects()
		if self.layers then 
			for i, l in ipairs(self.layers) do
				if l.isTyping then 
					l.isTyping = false
					Panels.Audio.stopTypingSound()
				end

				if l.textAnimator then
					l.textAnimator = nil
				end
			end
		end
	end

	function panel:updateAdvanceButton()
		if self.advanceButton.state == "hidden" then

			
			if self.advanceControlPosition and self.advanceControlPosition.delay and self.advanceControlTimer == nil then 
				self.advanceControlTimer = playdate.timer.new(self.advanceControlPosition.delay, nil)
			elseif self.advanceControlPosition == nil or self.advanceControlPosition.delay == nil or (self.advanceControlTimer and self.advanceControlTimer.currentTime >= self.advanceControlTimer.duration) then 
				if not self.advanceControlTimerDidEnd then 
					self.advanceButton:show()
					self.advanceControlTimerDidEnd = true
				end
			end

		else
			if playdate.buttonJustPressed(self.advanceControl) then
				self.advanceButton:press()
			end
			self.advanceButton:draw()
		end
	end
	
	function panel:render(offset, borderColor, bgColor)
		self.wasOnScreen = true
		gfx.pushContext(self.canvas)
		gfx.clear()
		
		if self.renderFunction then
			self:renderFunction(offset)	
		else 
			self:drawLayers(offset)
		end

		if not self.borderless then
			if self.borderImage then 
				self.borderImage:draw(0,0)
			else
				self.borderImage = self:drawBorder(borderColor, bgColor)
			end
		end

		if self.advanceButton then 
			self:updateAdvanceButton()
		end
	
		if self.panels then
			local o = {x=offset.x + self.frame.x, y=offset.y + self.frame.y}
			if offset.x == 0 then o.x = 0 end
			if offset.y == 0 then o.y = 0 end
	
			for i, subPanel in ipairs(self.panels) do
				subPanel:render(o, borderColor, bgColor)
				subPanel.canvas:draw(subPanel.frame.x, subPanel.frame.y)
			end
		end

		gfx.popContext()
		
	end

	return panel
end

