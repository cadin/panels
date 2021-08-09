import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

Panels = {}

import "./modules/Settings"
import "./modules/ScrollConstants"
import "./modules/Effect"
import "./modules/Panel"
import "./modules/Color"


local currentSeqIndex = 1
local sequences = nil
local sequence = {}
local panels = {}

local scrollPos = 0
local acc = 0.25
local maxV = 4
local velocity = 0
local maxScroll = 0


local function setUpPanels(seq)
    panels = {}
    local pos = 0

	for i, panel in ipairs(seq.panels) do
		if panel.frame == nil then
			panel.frame = table.shallowcopy(seq.defaultFrame) 
		end

		local p = Panels.Panel.new(panel)

		if p.frame.margin then 
			pos = pos + p.frame.margin
		end

		if p.frame.gap and i > 1 then 
			pos = pos + p.frame.gap
		end
		
		if seq.axis == Panels.ScrollAxis.VERTICAL then
			p.frame.y = pos
			pos = pos + p.frame.height
			maxScroll = pos - playdate.display.getHeight() + p.frame.margin
		else 
			p.frame.x = pos
			pos = pos + p.frame.width
			maxScroll = pos - playdate.display.getWidth() + p.frame.margin
		end
		panels[i] = p
		
	end
end


local function loadSequence(num) 
	sequence = sequences[num]
	
	-- set default scroll direction for each axis if not specified
	if sequence.direction == nil then
		if sequence.axis == Panels.ScrollAxis.VERTICAL then 
			sequence.direction = Panels.ScrollDirection.TOP_DOWN
		else 
			sequence.direction = Panels.ScrollDirection.LEFT_TO_RIGHT 
		end
	end

    setUpPanels(sequence)
end

local function loadGame()
	loadSequence(currentSeqIndex)
end


local function updateComic()

end

local function drawComic()
	gfx.clear()

	local offset = {x = 0, y = 0}
	if sequence.axis == Panels.ScrollAxis.HORIZONTAL then 
		offset.x = scrollPos
	else 
		offset.y = scrollPos 
	end
	
	for i, panel in ipairs(panels) do 
		if(panel:isOnScreen(offset)) then
			panel:render(offset, sequence.foregroundColor)
			panel.canvas:draw(panel.frame.x + offset.x, panel.frame.y + offset.y)
		end
	end
end



-- Playdate update loop
function playdate.update()
	-- TODO: 
	-- trap for menu state
	
	updateComic()
	drawComic()
end

function playdate.cranked(change, accChange)
	scrollPos = scrollPos + change--accChange
end

function Panels.start()
	sequences = Panels.Settings.comicData
	loadGame();
end
