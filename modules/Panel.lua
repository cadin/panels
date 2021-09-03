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
					layer.visible = true
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

	if panel.layers then
		for i, layer in ipairs(panel.layers) do 
			if layer.image then 
				layer.img, error = gfx.image.new(Panels.Settings.imageFolder .. layer.image)
				printError(error, "Error loading image on layer")
			end

			if layer.images then 
				layer.imgs = {}
				for j, image in ipairs(layer.images) do
					layer.imgs[j], error = gfx.image.new(Panels.Settings.imageFolder .. image)
					printError(error, "Error loading images["..j.."] on layer")
				end
			end

			if layer.imageTable then 
				local imgTable, error = gfx.imagetable.new(Panels.Settings.imageFolder .. layer.imageTable)
				printError(error, "Error loading imagetable on layer")
				
				local anim = gfx.animation.loop.new(layer.delay or 200, imgTable, layer.loop or false)
				anim.paused = true
				if layer.trigger == nil then layer.trigger = 0 end
				layer.animationLoop = anim
			end

			if layer.x == nil then layer.x = -panel.frame.margin end
			if layer.y == nil then layer.y = -panel.frame.margin end
			layer.visible = true
		end
	end
	
	if panel.audio then 
		panel.sfxPlayer = playdate.sound.sampleplayer.new(Panels.Settings.audioFolder .. panel.audio.file)
		if panel.audio.pan then 
			panel.sfxPlayer:setVolume(1 - panel.audio.pan, panel.audio.pan)
		end
		panel.sfxTrigger = panel.audio.trigger or 0
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
			if cntrlPct >= self.sfxTrigger and self.prevPct < self.sfxTrigger then
				self.sfxPlayer:play()
			end
		end
	
		if layers then
			for i, layer in ipairs(layers) do 
				local p = layer.parallax or 0
				local xPos = math.floor(layer.x + (self.parallaxDistance * pct.x - self.parallaxDistance/2) * p)
				local yPos = math.floor(layer.y + (self.parallaxDistance * pct.y - self.parallaxDistance/2) * p)
				local rotation = 0
	
				if layer.animate then 
					if layer.animate.x then xPos = math.floor(xPos + ((layer.animate.x - layer.x) * cntrlPct)) end
					if layer.animate.y then yPos = math.floor(yPos + ((layer.animate.y - layer.y) * cntrlPct)) end
					if layer.animate.rotation then rotation = layer.animate.rotation * cntrlPct end
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
				
				if layer.img then 
					if layer.visible then
						layer.img:draw(xPos, yPos)
					end

				elseif layer.imgs then
					local p = cntrlPct
					p = p + (self.transitionOffset or 0)
					local j = math.max(math.min(math.ceil(p * #layer.imgs), #layer.imgs), 1)
					if layer.visible then 
						layer.imgs[j]:draw(xPos, yPos)
					end
					
				elseif layer.text then
					if layer.visible then 
						self:drawTextLayer(layer, xPos, yPos)
					end
				elseif layer.animationLoop then
					if layer.visible then
						if cntrlPct >= layer.trigger then 
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
		for i, layer in ipairs(self.layers) do
			if layer.animationLoop then
				layer.animationLoop.frame = 1
				local f = layer.animationLoop.frame -- force frame update (bug in 1.3.1)
				layer.animationLoop.paused = true
			end
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
					playdate.timer.performAfterDelay(layer.effect.delay or 0, Panels.Audio.startTypingSound)
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
	
	function panel:drawBorder(color)
		gfx.setColor(color)
		gfx.setLineWidth(2)
		gfx.drawRoundRect(1, 1, self.frame.width- 2, self.frame.height -2, 2)
	end

	local shouldAutoAdvance = false

	function panel:shouldAutoAdvance()
		if self.advanceFunction then 
			return self:advanceFunction()
		else
			return false
		end
	end
	
	function panel:render(offset, borderColor)
		self.wasOnScreen = true
		gfx.pushContext(self.canvas)
		gfx.clear()
		
		if self.renderFunction then
			self:renderFunction(offset)	
		else 
			self:drawLayers(offset)
		end

		if not self.borderless then
			self:drawBorder(borderColor)
		end
	
		if self.panels then
			local o = {x=offset.x + self.frame.x, y=offset.y + self.frame.y}
			if offset.x == 0 then o.x = 0 end
			if offset.y == 0 then o.y = 0 end
	
			for i, subPanel in ipairs(self.panels) do
				subPanel:render(o, borderColor)
				subPanel.canvas:draw(subPanel.frame.x, subPanel.frame.y)
			end
		end

		gfx.popContext()
		
	end

	return panel
end

