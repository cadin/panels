local gfx <const> = playdate.graphics

Panels.Credits = {}

local qrCode = gfx.image.new(Panels.Settings.path .. "assets/panelsRepoQR.png")
local url = "github.com/cadin/panels"

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

function Panels.Credits.new()
	
	local credits = {
		panelsImg = createPanelsCredits(),
		scrollPos = 0
	}
	
	function credits:show()
		self:redraw()
	end
	
	function credits:drawPanelsCredits() 
		gfx.drawLine(00, 162, 400, 162)
		gfx.setColor(Panels.Color.BLACK)
		gfx.fillRect(0, 162, 400, 78)
		self.panelsImg:draw(90, 174)
	end
	
	function credits:redraw()
		gfx.clear()
		self:drawPanelsCredits()
	end
	
	
	return credits
end