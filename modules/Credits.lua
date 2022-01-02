local gfx <const> = playdate.graphics
local ScreenWidth <const> = playdate.display.getWidth()
local ScreenHeight <const> = playdate.display.getHeight()

Panels.Credits = {}

local qrCode = gfx.image.new(Panels.Settings.path .. "assets/images/panelsPagesQR.png")
local url = "cadin.github.io/panels"


local maxScroll = 0
local scrollAcceleration = 0.25
local maxScrollVelocity = 6
local scrollVelocity = 0
local snapStrength = 1.5

local headerHeight = 48
local bottomPadding = 24
local panelsCreditHeight = 78

local function createPanelsCredits()
	local img = gfx.image.new(244, 54, Panels.Color.BLACK)
	gfx.pushContext(img)
	gfx.setImageDrawMode(gfx.kDrawModeInverted)
	
	qrCode:draw(0, 0)
	gfx.drawText("*Built with Panels*", 64, 7)
	gfx.drawText(url, 64, 29)
	
	gfx.popContext()
	return img
end

local function measureCreditsHeight(credits)
	local height = 1
	if credits.lines == nil then return height end

	for i, line in ipairs(credits.lines) do
		if line.text then 
			local w, h = gfx.getTextSize(line.text)
			height = height + h + (line.spacing or 0)
		elseif line.image then
			local img = gfx.image.new(Panels.Settings.imageFolder .. line.image)
			local w, h = img:getSize()
			height = height + h + (line.spacing or 0)
		end
	end
	
	return height
end

local function getPositionForAlignment(alignment)
	local x = 32
	if alignment == kTextAlignment.center then
		x = ScreenWidth / 2
	elseif alignment == kTextAlignment.right then
		x = ScreenWidth - 32
	end

	return x
end

local function getAnchorForAlignment(alignment)
	local anchor = 0
	if alignment == kTextAlignment.center then
		anchor = 0.5
	elseif alignment == kTextAlignment.right then
		anchor = 1
		
	end
	return anchor
end

local function createGameCredits(credits)
	
	local textAlignment = credits.alignment or kTextAlignment.center
	local creditsHeight = measureCreditsHeight(credits)
	local img = gfx.image.new(400, creditsHeight)
	local defaultX = getPositionForAlignment(textAlignment)
	local alignment = textAlignment
	gfx.pushContext(img)

	local font = gfx.getSystemFont()
	if credits.font then 
		font = Panels.Font.get(credits.font)
	end
	local y = 0
	
	if credits.lines then 
		for i, line in ipairs(credits.lines) do
		
			local f = font
			if line.font then
				f = Panels.Font.get(line.font)
			end
			gfx.setFont(f)

			y = y +  (line.spacing or 0)
			if line.alignment then 
				alignment = line.alignment
				x = getPositionForAlignment(line.alignment)
			else
				alignment = textAlignment
				x = defaultX
			end
			
			if line.text then 
				gfx.drawTextAligned(line.text, x, y, alignment)
				local w, h = gfx.getTextSize(line.text)
				y = y + h
				
			elseif line.image then
				local img = gfx.image.new(Panels.Settings.imageFolder .. line.image)
				local w, h = img:getSize()
				local anchorX = getAnchorForAlignment(alignment)
				img:drawAnchored(x, y, anchorX, 0)
				
				y = y + h
			end
		end
	end
	gfx.popContext()
	
	return img
end

local autoScrollTimeout = nil
local isAutoScrolling = false

local function startAutoScroll()
	isAutoScrolling = true
end

local function killAutoScrolling()
	isAutoScrolling = false
	if autoScrollTimeout then 
		autoScrollTimeout:reset()
	end
end


function Panels.Credits.new()
	
	local data = Panels.credits
	if data.hideStandardHeader then headerHeight = 8 end
	
	local gameCreditsHeight = math.max(measureCreditsHeight(data), 138 - headerHeight)

	local credits = {
		gameCredits = createGameCredits(data),
		panelsImg = createPanelsCredits(),
		showHeader = not data.hideStandardHeader,
		scrollPos = 0,
		isScrollable = false,
		shouldAutoScroll = data.autoScroll or false,
		height = gameCreditsHeight + headerHeight + bottomPadding + panelsCreditHeight
	}
	
	if gameCreditsHeight > 138 - headerHeight then 
		credits.isScrollable = true
	end
	
	maxScroll = -(gameCreditsHeight + headerHeight + bottomPadding + panelsCreditHeight - ScreenHeight)


	function credits:drawPanelsCredits(x, y) 
		gfx.drawLine(0, y, 400, y)
		gfx.setColor(Panels.Color.BLACK)
		gfx.fillRect(0, y, 400, 180) -- 78
		self.panelsImg:draw(90, y + 12)
	end
	
	function credits:drawHeader(posY)
		gfx.drawTextAligned("*Credits*", 200, posY + 12, kTextAlignment.center)
		gfx.setLineWidth(1)
		gfx.drawLine(32, posY + 20, 32 + 120, posY + 20)
		gfx.drawLine(368 - 120, posY + 20, 368, posY + 20)
	end
	
	function credits:cranked(change)
		if self.isScrollable then 
			self.scrollPos += change
			killAutoScrolling()
		end
	end
	
	function credits:onDidShow()
		if self.shouldAutoScroll then 
			autoScrollTimeout = playdate.timer.new(1500, startAutoScroll)
			autoScrollTimeout.discardOnCompletion = false
		end
	end
	
	function credits:checkForInput()
		-- button input
		if playdate.buttonIsPressed(Panels.Input.DOWN) then
			scrollVelocity = scrollVelocity - scrollAcceleration
			killAutoScrolling()
		elseif playdate.buttonIsPressed(Panels.Input.UP) then
			scrollVelocity = scrollVelocity + scrollAcceleration 
			killAutoScrolling()
		else
			scrollVelocity = scrollVelocity / 2
		end
		
		-- constrain to min/max
		if scrollVelocity > maxScrollVelocity then 	
			scrollVelocity = maxScrollVelocity 	
		elseif scrollVelocity < -maxScrollVelocity then
			scrollVelocity = -maxScrollVelocity
		end
		
		self.scrollPos = self.scrollPos + scrollVelocity
		
		-- snap to bounds
		if self.scrollPos > 0 then
			self.scrollPos = math.floor(self.scrollPos / snapStrength)		
		elseif self.scrollPos < maxScroll then
			local diff = self.scrollPos - maxScroll
			self.scrollPos = math.floor(self.scrollPos - (diff - (diff / snapStrength )))
		end
	end
	
	function credits:redraw(yPos)
		if self.isScrollable then 
			self:checkForInput()
			if isAutoScrolling then 
				self.scrollPos = self.scrollPos - 1
			end
		end
		
		if self.showHeader then 
			self:drawHeader(self.scrollPos + yPos)
		end
		self.gameCredits:draw(0, self.scrollPos + headerHeight + yPos)
		self:drawPanelsCredits(0, self.scrollPos + gameCreditsHeight + bottomPadding + headerHeight + yPos)
	end
	
	
	return credits
end