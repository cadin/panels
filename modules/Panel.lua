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

function Panels.Panel.new(data)
	local panel = table.shallowcopy(data)
	panel.frame = createFrameFromPartialFrame(panel.frame)
	
	panel.canvas = gfx.image.new(panel.frame.width, panel.frame.height, gfx.kColorBlack)

	if not panel.parallaxDistance then
		panel.parallaxDistance = Panels.Settings.parallaxDistance
	end

	if panel.panels then
		for i, p in ipairs(panel.panels) do
			panel.panels[i] = Panels.Panel.new(p)
		end
	end

	if panel.layers then
		for i, layer in ipairs(panel.layers) do 
			if layer.image then 
				print("loading: " .. layer.image)
				layer.img = gfx.image.new(Panels.Settings.imageFolder .. layer.image)
			end

			if layer.images then 
				layer.imgs = {}
				for j, image in ipairs(layer.images) do
					layer.imgs[j] = gfx.image.new(Panels.Settings.imageFolder .. image)
				end
			end

			if layer.x == nil then layer.x = -panel.frame.margin end
			if layer.y == nil then layer.y = -panel.frame.margin end
		end
	end

	function panel:isOnScreen(offset) 
		local isOn = false
		local f = self.frame
		if f.x + offset.x <= ScreenWidth and f.x + f.width + offset.x >= 0 and 
		f.y + offset.y <= ScreenHeight and f.y + f.height+ offset.y >= 0 then
			isOn = true
		end
	
		return isOn	
	end
	
	function panel:drawLayers(offset)
		local layers = self.layers
		local frame = self.frame
		local shake
		local pct = getScrollPercentages(frame, offset, self.axis)
	
	
		if self.effect then
			if self.effect.type == Panels.Effect.SHAKE_UNISON then 
				shake = calculateShake(self.effect.strength) 
			end
		end
	
		if layers then
			for i, layer in ipairs(layers) do 
				local p = layer.parallax
				local xPos = math.floor(layer.x + (self.parallaxDistance * pct.x - self.parallaxDistance/2) * p)
				local yPos = math.floor(layer.y + (self.parallaxDistance * pct.y - self.parallaxDistance/2) * p)
				local rotation = 0
	
				if layer.animate then 
					local cntrlPct
					if self.axis == AxisHorizontal then cntrlPct = pct.x else cntrlPct = pct.y end
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
				
				if layer.img then 
					layer.img:draw(xPos, yPos)
				elseif layer.imgs then
					local p
					if self.axis == AxisHorizontal then p = pct.x else p = pct.y end
					local j = math.max(math.min(math.ceil(p * #layer.imgs), #layer.imgs), 1)
					layer.imgs[j]:draw(xPos, yPos)
				end
	
			end
		end
	end
	
	function panel:drawFrame(color)
		gfx.setColor(color)
		gfx.setLineWidth(2)
		gfx.drawRoundRect(1, 1, self.frame.width- 2, self.frame.height -2, 2)
	end
	
	function panel:render(offset, frameColor)
		gfx.pushContext(self.canvas)
		gfx.clear()
		
		self:drawLayers(offset)
		if not self.frameless then
			self:drawFrame(frameColor)
		end
	
		if self.panels then
			local o = {x=offset.x + self.frame.x, y=offset.y + self.frame.y}
			if offset.x == 0 then o.x = 0 end
			if offset.y == 0 then o.y = 0 end
	
			for i, subPanel in ipairs(self.panels) do
				subPanel:render(o, frameColor)
				subPanel.canvas:draw(subPanel.frame.x, subPanel.frame.y)
			end
		end

		gfx.popContext()
		
	end

	return panel
end

