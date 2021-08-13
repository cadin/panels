import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"

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
import "./modules/ButtonIndicator"


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
local transitionOutAnimator = nil
local transitionInAnimator = nil

local buttonA

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

local function startTransitionIn(direction) 
	local target = scrollPos
	local start

	if direction == Panels.ScrollDirection.BOTTOM_UP then
		start = scrollPos - ScreenHeight
	elseif direction == Panels.ScrollDirection.TOP_DOWN then 
		start = scrollPos + ScreenHeight
	elseif direction == Panels.ScrollDirection.LEFT_TO_RIGHT then
		start = scrollPos + ScreenWidth
	else 
		start = scrollPos - ScreenWidth
	end

	scrollPos = start
	transitionInAnimator = playdate.graphics.animator.new(
		Panels.Settings.sequenceTransitionDuration, start, target, playdate.easingFunctions.inOutQuart)
end

local function startTransitionOut(direction)
	local target
	local start = scrollPos
	
	if direction == Panels.ScrollDirection.TOP_DOWN then
		target = maxScroll - ScreenHeight
	elseif direction == Panels.ScrollDirection.BOTTOM_UP then 
		target = maxScroll + ScreenHeight
	elseif direction == Panels.ScrollDirection.RIGHT_TO_LEFT then
		target = maxScroll + ScreenWidth
	else 
		target = -maxScroll - ScreenWidth
	end
	
	transitionOutAnimator = playdate.graphics.animator.new(
		Panels.Settings.sequenceTransitionDuration, start, target, playdate.easingFunctions.inOutQuart)
end

local function prepareScrolling(reversed) 
	if reversed then
		panelNum = #panels
		scrollPos = -maxScroll
	else
		scrollPos = 0
		panelNum = 1
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
	elseif sequence.direction == Panels.ScrollDirection.RIGHT_TO_LEFT 
	or sequence.direction == Panels.ScrollDirection.BOTTOM_UP then
		sequence.scrollingIsReversed = true
	end
	
	if sequence.defaultFrame == nil then
		sequence.defaultFrame = Panels.Settings.defaultFrame
	end
	
	if sequence.advanceControl == nil then 
		sequence.advanceControl = Panels.Input.A
	end

    setUpPanels(sequence)
	prepareScrolling(sequence.scrollingIsReversed)
	startTransitionIn(sequence.direction)
end

local function loadGame()
	loadSequence(currentSeqIndex)
end

local function unloadSequence()
	for i, p in ipairs(panels) do
		for j, l in ipairs(p.layers) do
			if l.timer then
				l.timer:remove()
				l.timer = nil
			end
		end
	end
end

local function nextSequence()
	unloadSequence()
	-- TODO: detect the last sequence in the game
	currentSeqIndex = currentSeqIndex + 1
	loadSequence(currentSeqIndex)
end

local function updateSequenceTransition() 
	if transitionOutAnimator then 
		scrollPos = transitionOutAnimator:currentValue()
		if transitionOutAnimator:ended() then
			transitionOutAnimator = nil
			nextSequence()
		end
	else
		scrollPos = transitionInAnimator:currentValue()
		if transitionInAnimator:ended() then
			transitionInAnimator = nil
		end
	end
end

local function finishSequence() 
	startTransitionOut(sequence.direction)
end

local function snapScrollToPanel() 
	for i, b in ipairs(panelBoundaries) do
		if scrollPos > b - 20 and scrollPos < b + 20 then
			local diff = scrollPos - b
			scrollPos = round(scrollPos - (diff - (diff / 1.25) ), 2)
		end
	end
end

local function lastPanelIsShowing() 
	local threshold = 24
	if (sequence.scrollingIsReversed and scrollPos >= -threshold) 
	or (not sequence.scrollingIsReversed and scrollPos <= -(maxScroll - threshold) ) then
		return true
	end
	
	return false
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
	if lastPanelIsShowing() then
		if playdate.buttonJustPressed(sequence.advanceControl) then 
			buttonA:press()
			finishSequence()
		end
	end
end

local function updateComic()
	if transitionInAnimator or transitionOutAnimator then
		updateSequenceTransition()
	else
		updateScroll()
		checkInputs()
	end
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
	
	if transitionOutAnimator == nil and transitionOutAnimator == nil then
		if lastPanelIsShowing() then
			buttonA:show()
		else 
			buttonA:hide()
		end
	end
	buttonA:draw(ScreenWidth - 42, ScreenHeight / 2 -20)
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
	buttonATable = gfx.imagetable.new(Panels.Settings.path .. "assets/buttonA-table-40-40.png")
	buttonA = Panels.ButtonIndicator.new(buttonATable, 4)
	buttonA:show()

	validateSettings()
	
	sequences = Panels.Settings.comicData
	loadGame();

end
