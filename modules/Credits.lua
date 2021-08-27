local gfx <const> = playdate.graphics
local ScreenWidth <const> = playdate.display.getWidth()
local ScreenHeight <const> = playdate.display.getHeight()

Panels.Credits = {}

local qrCode = gfx.image.new(Panels.Settings.path .. "assets/images/panelsPagesQR.png")
local url = "cadin.github.io/panels"


local maxScroll = 0
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
	
	for i, line in ipairs(credits) do
		local w, h = gfx.getTextSize(line.text)
		height = height + h + (line.spacing or 0)
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

local function createGameCredits(textAlignment)
	local credits = Panels.Settings.credits
	
	local creditsHeight = measureCreditsHeight(credits)
	local img = gfx.image.new(400, creditsHeight)
	local defaultX = getPositionForAlignment(textAlignment)
	local alignment = textAlignment
	gfx.pushContext(img)
	local y = 0
	
	for i, line in ipairs(credits) do
		y = y +  (line.spacing or 0)
		if line.alignment then 
			alignment = line.alignment
			x = getPositionForAlignment(line.alignment)
		else
			alignment = textAlignment
			x = defaultX
		end
		
		gfx.drawTextAligned(line.text, x, y, alignment)
		local w, h = gfx.getTextSize(line.text)
		y = y + h
	end
	gfx.popContext()
	
	return img
end

function Panels.Credits.new()
	
	local data = Panels.Settings.credits
	
	local credits = {
		gameCredits = createGameCredits(data.alignment or kTextAlignment.center),
		panelsImg = createPanelsCredits(),
		
		scrollPos = 0
	}
	
	local gameCreditsHeight = math.max(measureCreditsHeight(data), 90)
	
	maxScroll = -(gameCreditsHeight + headerHeight + bottomPadding + panelsCreditHeight - ScreenHeight)
	

	function credits:drawPanelsCredits(x, y) 
		gfx.drawLine(0, y, 400, y)
		gfx.setColor(Panels.Color.BLACK)
		gfx.fillRect(0, y, 400, 90) -- 78
		self.panelsImg:draw(90, y + 12)
	end
	
	function credits:drawHeader(posY)
		gfx.drawTextAligned("*Credits*", 200, posY + 12, kTextAlignment.center)
		gfx.setLineWidth(1)
		gfx.drawLine(32, posY + 20, 32 + 120, posY + 20)
		gfx.drawLine(368 - 120, posY + 20, 368, posY + 20)
	end
	
	function credits:checkForInput()
		if playdate.buttonIsPressed(Panels.Input.DOWN) then
			if self.scrollPos > maxScroll then
				self.scrollPos = self.scrollPos - 2
			end
		elseif playdate.buttonIsPressed(Panels.Input.UP) then
			if self.scrollPos < 0 then 
				self.scrollPos = self.scrollPos + 2
			end
		end
	end
	
	function credits:redraw(yPos)
		self:checkForInput()
		
		self:drawHeader(self.scrollPos + yPos)
		self.gameCredits:draw(0, self.scrollPos + headerHeight + yPos)
		self:drawPanelsCredits(0, self.scrollPos + gameCreditsHeight + bottomPadding + headerHeight + yPos)
	end
	
	
	return credits
end