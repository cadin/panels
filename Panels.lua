import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local ScreenHeight <const> = playdate.display.getHeight()
local ScreenWidth <const> = playdate.display.getWidth()


Panels = {}

import "./modules/Settings"
import "./modules/ScrollConstants"
import "./modules/Effect"
import "./modules/Panel"
import "./modules/Color"
import "./modules/Utils"
import "./modules/Input"


local currentSeqIndex = 1
local sequences = nil
local sequence = {}
local panels = {}

local scrollPos = 0
local acc = 0.25
local maxV = 4
local velocity = 0
local maxScroll = 0

local snapStrength = 1.5

local panelBoundaries = {}


local function setUpPanels(seq)
    panels = {}
    local pos = 0
	local j = 1

	for i, panel in ipairs(seq.panels) do
		if panel.frame == nil then
			panel.frame = table.shallowcopy(seq.defaultFrame) 
		end
		
		panel.axis = seq.axis

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
			maxScroll = pos - ScreenHeight + p.frame.margin
			
			if i > 1 then 
				panelBoundaries[j] = - (p.frame.y - p.frame.margin)
				j = j + 1
			end 
			if p.frame.height > ScreenHeight then
				panelBoundaries[j] =  -(p.frame.y + p.frame.height - ScreenHeight + p.frame.margin)
				j = j + 1
			end
		else 
			p.frame.x = pos
			pos = pos + p.frame.width
			maxScroll = pos - ScreenWidth + p.frame.margin
			
			if i > 1 then 
				panelBoundaries[j] = - (p.frame.x - p.frame.margin)
				j = j + 1
			 end
			if p.frame.width > ScreenWidth then
				panelBoundaries[j] = -(p.frame.x + p.frame.width - ScreenWidth + p.frame.margin)
				j = j + 1
			end
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
	
	if sequence.defaultFrame == nil then
		sequence.defaultFrame = Panels.Settings.defaultFrame
	end

    setUpPanels(sequence)
end

local function loadGame()
	loadSequence(currentSeqIndex)
end


local function nextSequence() 
	currentSeqIndex = currentSeqIndex+1
	loadSequence(currentSeqIndex)
end

local function snapScrollToPanel() 
	for i, b in ipairs(panelBoundaries) do
		if scrollPos > b - 20 and scrollPos < b + 20 then
			local diff = scrollPos - b
			scrollPos = round(scrollPos - (diff - (diff / 1.25) ), 2)
			-- print(scrollPos, b, diff)
		end
	end
end


local function updateScroll() 
	if scrollPos > 0 then
		scrollPos = math.floor(scrollPos / snapStrength)
	elseif scrollPos < -maxScroll then
		local diff = scrollPos + maxScroll
		scrollPos = math.floor(scrollPos - (diff - (diff / snapStrength )))
	end
	
	if Panels.Settings.snapToPanels then snapScrollToPanel() end
end

local function checkInputs() 
	print(scrollPos, maxScroll)
	if scrollPos <= -(maxScroll - 10) then
		if playdate.buttonJustPressed(sequence.advanceControl) then 
			nextSequence()
		end
	end
end

local function updateComic()
	updateScroll()
	checkInputs()
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
	playdate.timer.updateTimers()
end

function playdate.cranked(change, accChange)
	scrollPos = scrollPos + change
end

function Panels.start()
	validateSettings()
	
	sequences = Panels.Settings.comicData
	loadGame();
end
