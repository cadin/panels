Panels.Panel = {}

local gfx <const> = playdate.graphics
local ScreenHeight <const> = playdate.display.getHeight()
local ScreenWidth <const> = playdate.display.getWidth()

local reduceFlashing = playdate.getReduceFlashing()
local pdButtonJustPressed = playdate.buttonJustPressed

local AxisHorizontal = Panels.ScrollAxis.HORIZONTAL




local function createFrameFromPartialFrame(frame)
	if frame.margin == nil then frame.margin = Panels.Settings.defaultFrame.margin end

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

	if frame.gap == nil then
		frame.gap = Panels.Settings.defaultFrame.gap
	end

	return frame
end

local function getScrollPercentages(frame, offset, axis)
	local xPct = 1 - (frame.x - frame.margin + frame.width + offset.x) / (ScreenWidth + frame.width)
	local yPct = 1 - (frame.y - frame.margin + frame.height + offset.y) / (ScreenHeight + frame.height)

	local pct = { x = xPct, y = yPct }
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
				layer.timer = playdate.timer.new(layer.effect.durations.on + layer.effect.durations.off)
				layer.timer.repeats = true
			end

		else
			if layer.effect.delay then
				if layer.timer.currentTime >= layer.effect.delay then
					layer.effect.delay = false
					layer.timer = playdate.timer.new(layer.effect.durations.on + layer.effect.durations.off)
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
	-- panel.canvas = gfx.image.new(ScreenWidth, ScreenHeight, gfx.kColorBlack)

	if not panel.backgroundColor then panel.backgroundColor = Panels.Color.WHITE end

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
					printError(error, "Error loading images[" .. j .. "] on layer")
				end
			end

			if layer.imageTable then
				local imgTable, error = gfx.imagetable.new(Panels.Settings.imageFolder .. layer.imageTable)
				printError(error, "Error loading imagetable on layer")

				local delay = layer.delay or 200
				if layer.reduceFlashingDelay and reduceFlashing then
					delay = layer.reduceFlashingDelay
				end
				local anim = gfx.animation.loop.new(delay, imgTable, layer.loop or false)
				anim.paused = true
				if layer.scrollTrigger == nil then layer.scrollTrigger = 0 end
				layer.animationLoop = anim
				layer.imgTable = imgTable
			end

			if layer.stencil then
				mask, error = Panels.Image.get(imageFolder .. layer.stencil)
				layer.maskImg = mask
				printError(error, "Error loading stencil image on layer")
			end

			if layer.x == nil then layer.x = -panel.frame.margin end
			if layer.y == nil then layer.y = -panel.frame.margin end
			if layer.visible == nil then layer.visible = true end
			layer.alpha = layer.opacity or nil

			if layer.effect then
				if layer.effect.type == Panels.Effect.BLINK and layer.effect.audio then
					layer.sfxPlayer = playdate.sound.sampleplayer.new(Panels.Settings.audioFolder .. layer.effect.audio.file)
				end

				if reduceFlashing
					and layer.effect.type == Panels.Effect.BLINK
					and layer.effect.reduceFlashingDurations ~= nil
				then
					layer.effect.durations.on = layer.effect.reduceFlashingDurations.on
					layer.effect.durations.off = layer.effect.reduceFlashingDurations.off
				end
			end

			if layer.animate then
				if layer.animate.delay == nil then layer.animate.delay = 0 end
				if layer.animate.duration then
					if layer.animate.duration < 1 then layer.animate.duration = 1 end
				end
				if layer.animate.autoStart then layer.animate.scrollTrigger = 0 end
				if layer.animate.scrollTrigger and layer.animate.duration == nil then
					layer.animate.duration = 200
				end
				if layer.opacity == nil then layer.opacity = 1 end

				if layer.animate.trigger then
					layer.animate.triggerSequence = { layer.animate.trigger }
				end

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
			f.y + offset.y <= ScreenHeight and f.y + f.height + offset.y > 0 then
			isOn = true
		end

		return isOn
	end

	function panel:fadePanelVolume(pct)
		local vol = 1
		if pct < 0.25 then
			vol = pct / 0.25
		elseif pct > 0.75 then
			vol = (1 - pct) / 0.25
		end

		local leftPan = self.audio.volume or 1
		local rightPan = self.audio.volume or 1

		if self.audio.pan then
			leftPan = 1 - self.audio.pan
			rightPan = self.audio.pan
		end

		self.sfxPlayer:setVolume(vol * leftPan, vol * rightPan)
	end

	function panel:pauseSounds()
		if self.sfxPlayer then
			self.soundIsPaused = true
			self.sfxPlayer:setPaused(true)
		end
	end

	function panel:unPauseSounds()
		if self.sfxPlayer then
			self.soundIsPaused = false
			self.sfxPlayer:setPaused(false)
		end
	end

	function panel:updatePanelAudio(pct)
		local count = panel.audio.repeatCount or 1
		if panel.audio.loop then count = 0 end
		if self.audio.triggerSequence then
			if self.audioTriggersPressed == nil then self.audioTriggersPressed = {} end
			local triggerButton = self.audio.triggerSequence[#self.audioTriggersPressed + 1]

			if pdButtonJustPressed(triggerButton) then
				self.audioTriggersPressed[#self.audioTriggersPressed + 1] = triggerButton
				if #self.audioTriggersPressed == #self.audio.triggerSequence then
					playdate.timer.performAfterDelay(self.audio.delay or 0, function()
						self.sfxPlayer:play(count)
					end)

					if self.audio.repeats ~= nil then
						if self.audioRepeats == nil then self.audioRepeats = 1 end
						if self.audio.repeats > self.audioRepeats then
							self.audioTriggersPressed = {}
							self.audioRepeats = self.audioRepeats + 1
						end
					end
				end
			end

		elseif (pct < 1 and pct >= self.sfxTrigger) and (self.prevPct <= self.sfxTrigger or self.audio.loop) then
			if not self.sfxPlayer:isPlaying() and not self.soundIsPaused then
				playdate.timer.performAfterDelay(self.audio.delay or 0, function()
					self.sfxPlayer:play(count)
				end)
			end
		end

		self:fadePanelVolume(pct)
	end

	function panel:layerShouldShake(layer)
		local result = false
		if self.effect and
			(self.effect.type == Panels.Effect.SHAKE_UNISON or self.effect.type == Panels.Effect.SHAKE_INDIVIDUAL) then
			result = true
		end

		if layer.effect and layer.effect.type == Panels.Effect.SHAKE then
			result = true
		end

		return result
	end

	function panel:exit()
		if self.layers then
			for i, layer in ipairs(self.layers) do
				if layer.exit then
					layer.isExiting = true
					layer.animator = nil
				end
			end
		end

	end

	function panel:drawLayers(offset)
		local layers = self.layers
		local frame = self.frame
		local shake
		local pct = getScrollPercentages(frame, offset, self.axis)
		local cntrlPct
		if self.axis == AxisHorizontal then cntrlPct = pct.x else cntrlPct = pct.y end
		if self.scrollingIsReversed then cntrlPct = 1 - cntrlPct end

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
				local startValues = table.shallow_copy(layer)
				if layer.isExiting and layer.animate then
					for k, v in pairs(layer.animate) do startValues[k] = v end
				end

				local xPos = math.floor(startValues.x + (self.parallaxDistance * pct.x - self.parallaxDistance / 2) * p)
				local yPos = math.floor(startValues.y + (self.parallaxDistance * pct.y - self.parallaxDistance / 2) * p)
				local rotation = 0

				if layer.animate or layer.isExiting then
					local anim = layer.animate

					if layer.isExiting then
						anim = layer.exit
						anim.scrollTrigger = 0
					end

					if (anim.triggerSequence or anim.scrollTrigger ~= nil) and not layer.animator then

						if layer.buttonsPressed == nil then layer.buttonsPressed = {} end
						local triggerButton = nil
						if not anim.scrollTrigger then
							triggerButton = anim.triggerSequence[#layer.buttonsPressed + 1]
						end

						if anim.scrollTrigger ~= nil or pdButtonJustPressed(triggerButton) then
							layer.buttonsPressed[#layer.buttonsPressed + 1] = triggerButton
							if (anim.scrollTrigger ~= nil and cntrlPct >= anim.scrollTrigger) or
								(anim.triggerSequence and #layer.buttonsPressed == #anim.triggerSequence) then
								layer.animator = gfx.animator.new((anim.duration or 200), 0, 1, anim.ease, anim.delay)
								if layer.sfxPlayer then
									local count = anim.audio.repeatCount or 1
									if anim.audio.loop then count = 0 end
									playdate.timer.performAfterDelay(anim.delay + (anim.audio.delay or 0), function()
										layer.sfxPlayer:play(count)
									end)
								end
							end
						end
					else
						local layerPct = cntrlPct
						if layer.animator then
							layerPct = layer.animator:currentValue()
						end

						if anim.x then xPos = math.floor(xPos + ((anim.x - startValues.x) * layerPct)) end
						if anim.y then yPos = math.floor(yPos + ((anim.y - startValues.y) * layerPct)) end
						if anim.rotation then rotation = anim.rotation * layerPct end
						if anim.opacity then
							local o = (anim.opacity - layer.opacity) * layerPct + layer.opacity
							layer.alpha = o
							if o <= 0 then
								layer.visible = false
							else
								layer.visible = true
							end
						end
					end
				end



				if self:layerShouldShake(layer) then
					if self.effect and self.effect.type == Panels.Effect.SHAKE_INDIVIDUAL then
						shake = calculateShake(self.effect.strength or 2)
					elseif layer.effect and layer.effect.type == Panels.Effect.SHAKE then
						shake = calculateShake(layer.effect.strength or 2)
					end

					xPos = xPos + shake.x * (1 - p * p)
					yPos = yPos + shake.y * (1 - p * p)
				end

				if layer.effect then
					doLayerEffect(layer, xPos, yPos)
				end


				local img
				if layer.img then
					img = layer.img
				elseif layer.imgs then
					if layer.advanceControl then
						if pdButtonJustPressed(layer.advanceControl) then
							if layer.currentImage < #layer.imgs then
								layer.currentImage = layer.currentImage + 1
							end
						end
						img = layer.imgs[layer.currentImage]
					else
						local p = cntrlPct
						p = p - (self.transitionOffset or 0)
						local j = math.max(math.min(math.ceil(p * #layer.imgs), #layer.imgs), 1)
						img = layer.imgs[j]
					end
				end

				local globalX = xPos + offset.x + self.frame.x
				local globalY = yPos + offset.y + self.frame.y

				if img then
					if layer.visible then
						
						if globalX + img.width > 0 and globalX < ScreenWidth and globalY + img.height > 0 and globalY < ScreenHeight then
							
							if layer.alpha and layer.alpha < 1 then
								img:drawFaded(xPos, yPos, layer.alpha, playdate.graphics.image.kDitherTypeBayer8x8)
							else
								if layer.maskImg then
									local maskX = math.floor((self.parallaxDistance * pct.x - self.parallaxDistance / 2) * p) - panel.frame.margin
									local maskY = math.floor((self.parallaxDistance * pct.y - self.parallaxDistance / 2) * p) - panel.frame.margin

									local maskImg = gfx.image.new(ScreenWidth, ScreenHeight)
									gfx.lockFocus(maskImg)
									layer.maskImg:draw(maskX, maskY)
									gfx.unlockFocus()

									gfx.setStencilImage(maskImg)
									img:draw(xPos, yPos)
									gfx.clearStencil()
								else
									img:draw(xPos, yPos)
								end
							end
						end
					end

				elseif layer.text then
					if layer.visible then
						if globalX + ScreenWidth > 0 and globalX < ScreenWidth and globalY + ScreenHeight > 0 and globalY < ScreenHeight then
							if layer.alpha == nil or layer.alpha > 0.5 then
								self:drawTextLayer(layer, xPos, yPos, cntrlPct)
							end
						end
					end
				elseif layer.animationLoop then
					if layer.visible then
						if layer.trigger then
							if pdButtonJustPressed(layer.trigger) then
								layer.animationLoop.paused = false
							end
						elseif layer.startDelay then
							if layer.startDelayTriggered == nil then
								playdate.timer.performAfterDelay(layer.startDelay, function()
									if layer.animationLoop then layer.animationLoop.paused = false end
								end)
								layer.startDelayTriggered = true
							end
						elseif cntrlPct >= layer.scrollTrigger then
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

				layer.startDelayTriggered = nil
				if layer.animationLoop then
					layer.animationLoop.frame = 1
					layer.animationLoop.paused = true
				end
				layer.isExiting = false

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
				if layer.cachedTextImg then
					if(self.prevPct < 0.5) then
						layer.cachedTextImg = nil
					end
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
		self.audioRepeats = 1
		self.advanceControlTimerDidEnd = false
		self.advanceControlTimer = nil
		if self.prevPct > 0.5 then
			self.prevPct = 1
		else
			self.prevPct = 0
		end
	end

	local function startLayerTypingSound(layer)
		if layer.isTyping then
			Panels.Audio.startTypingSound()
		end
	end


	local textMarginLeft<const> = 4
	local textMarginTop<const> = 1
	function panel:drawTextLayer(layer, xPos, yPos, cntrlPct)
		if(layer.cachedTextImg == nil) then
			layer.cachedTextImg = gfx.image.new(ScreenWidth, ScreenHeight)
			layer.needsRedraw = true
		end


		if(layer.isTyping or layer.needsRedraw) then 
			gfx.pushContext(layer.cachedTextImg)
			gfx.clear(gfx.kColorClear)

			if layer.fontFamily then
				gfx.setFontFamily(Panels.Font.getFamily(layer.fontFamily))
			elseif self.fontFamily then
				gfx.setFontFamily(Panels.Font.getFamily(self.fontFamily))
			end

			if layer.font then
				gfx.setFont(Panels.Font.get(layer.font))
			elseif self.font then
				gfx.setFont(Panels.Font.get(self.font))
			end

			local txt = layer.text
			if layer.effect then
				if layer.effect.type == Panels.Effect.TYPE_ON then

					if layer.textAnimator == nil then
						if self.prevPct == 1 then
							-- don't replay text animation (and sound) when backing into a frame
							txt = layer.text
							layer.needsRedraw = false
							layer.textAnimator = gfx.animator.new(1, string.len(layer.text), string.len(layer.text))
						elseif layer.effect.scrollTrigger == nil or cntrlPct >= layer.effect.scrollTrigger then
							layer.isTyping = true
							layer.textAnimator = gfx.animator.new(layer.effect.duration or 500, 0, string.len(layer.text),
								playdate.easingFunctions.linear, layer.effect.delay or 0)
							playdate.timer.performAfterDelay(layer.effect.delay or 0, startLayerTypingSound, layer)
						else
							txt = ""
						end
					end

					if layer.isTyping then
						local j = math.ceil(layer.textAnimator:currentValue())
						txt = string.sub(layer.text, 1, j)

						if txt == layer.text then
							layer.isTyping = false
							layer.needsRedraw = false
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
					gfx.fillRect(0, 0, w + 8, h + 2)
				end
			end
			if layer.color == Panels.Color.WHITE then
				gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			end

			if layer.rect then
				gfx.drawTextInRect(txt, textMarginLeft, textMarginTop, layer.rect.width, layer.rect.height, layer.lineHeightAdjustment or 0, "...",
					layer.alignment or Panels.TextAlignment.LEFT)
			else
				gfx.drawText(txt, textMarginLeft, textMarginTop)
			end

			gfx.popContext() 
		end
		layer.cachedTextImg:draw(xPos - textMarginLeft, yPos - textMarginTop)
	end

	function panel:drawBorder(color, bgColor)
		local frameW = self.frame.width
		local frameH = self.frame.height
		local borderW = Panels.Settings.borderWidth
		local b = gfx.image.new(frameW, frameH)
		local matte = gfx.image.new(frameW, frameH)
		gfx.pushContext(matte)
		-- create the corner matte
		gfx.setColor(bgColor)
		gfx.setLineWidth(borderW)
		gfx.fillRect(0, 0, frameW, frameH)
		gfx.setColor(Panels.Color.invert(bgColor))
		gfx.fillRoundRect(0, 0, frameW, frameH, Panels.Settings.borderRadius)
		gfx.popContext()

		gfx.pushContext(b)
		-- draw corner matte with center transparency
		if bgColor == Panels.Color.WHITE then
			gfx.setImageDrawMode(gfx.kDrawModeBlackTransparent)
		else
			gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
		end
		matte:draw(0, 0)

		gfx.setLineWidth(borderW)
		gfx.setColor(color)
		gfx.drawRoundRect(borderW / 2, borderW / 2, frameW - borderW, frameH - borderW, Panels.Settings.borderRadius)
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
			elseif self.advanceControlPosition == nil or self.advanceControlPosition.delay == nil or
				(self.advanceControlTimer and self.advanceControlTimer.currentTime >= self.advanceControlTimer.duration) then
				if not self.advanceControlTimerDidEnd then
					self.advanceButton:show()
					self.advanceControlTimerDidEnd = true
				end
			end

		else
			if pdButtonJustPressed(self.advanceControl) then
				self.advanceButton:press()
			end
			self.advanceButton:draw()
		end
	end

	function panel:render(offset, borderColor, bgColor)
		self.wasOnScreen = true
		gfx.pushContext(self.canvas)
		gfx.clear(self.backgroundColor)

		if self.renderFunction then
			self:renderFunction(offset)
		else
			self:drawLayers(offset)
		end

		if not self.borderless then
			if self.borderImage == nil then
				self.borderImage = self:drawBorder(borderColor, bgColor)
			end
			self.borderImage:draw(0, 0)
		end

		if self.advanceButton then
			self:updateAdvanceButton()
		end

		if self.panels then
			local o = { x = offset.x + self.frame.x, y = offset.y + self.frame.y }
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

function table.shallow_copy(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end
