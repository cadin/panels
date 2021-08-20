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
import "./modules/ButtonIndicator"
import "./modules/Color"
import "./modules/Effect"
import "./modules/Input"
import "./modules/Menu"
import "./modules/Font"
import "./modules/Panel"
import "./modules/Audio"

import "./modules/Utils"
import "./modules/Credits"


local currentSeqIndex = 1
local sequences = nil
local sequence = {}
local panels = {}

local scrollPos = 0
local scrollAcceleration = 0.25
local maxScrollVelocity = 8
local scrollVelocity = 0
local maxScroll = 0

local snapStrength = 1.5

local panelBoundaries = {}
local transitionOutAnimator = nil
local transitionInAnimator = nil

local buttonIndicator = nil
local menu = nil
local menuIsActive = false
local credits = nil
local creditsAreActive = false

Panels.maxUnlockedSequence = 1

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

local function lastPanelIsShowing() 
	local threshold = 24
	if (sequence.scrollingIsReversed and scrollPos >= -threshold) 
	or (not sequence.scrollingIsReversed and scrollPos <= -(maxScroll - threshold) ) then
		return true
	end
	return false
end


-- -------------------------------------------------
-- BUTTON INDICATOR

local function createButtonIndicator()
	-- TODO: make this use different images depending on `sequence.advanceControl`
	buttonTable = gfx.imagetable.new(
		Panels.Settings.path .. "assets/images/buttonA-table-40-40.png")
	buttonIndicator = Panels.ButtonIndicator.new(buttonTable, 4)
end

local function drawButtonIndicator() 
	if transitionOutAnimator == nil and transitionOutAnimator == nil then
		if lastPanelIsShowing() then
			buttonIndicator:show()
		else 
			buttonIndicator:hide()
		end
	end
	buttonIndicator:draw()
end


-- -------------------------------------------------
-- SCROLLING

local function prepareScrolling(reversed) 
	if reversed then
		panelNum = #panels
		scrollPos = -maxScroll
	else
		scrollPos = 0
		panelNum = 1
	end
end

local function snapScrollToPanel() 
	for i, b in ipairs(panelBoundaries) do
		if scrollPos > b - 20 and scrollPos < b + 20 then
			local diff = scrollPos - b
			scrollPos = round(scrollPos - (diff - (diff / 1.25) ), 2)
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


-- -------------------------------------------------
-- TRANSITIONS

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



-- -------------------------------------------------
-- SEQUENCE LIFECYCLE

local function loadSequence(num) 
	sequence = sequences[num]
	if num > Panels.maxUnlockedSequence then Panels.maxUnlockedSequence = num end	
	-- menu.sequences = maxUnlockedSequence

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
	
	if sequence.audio then
		if sequence.audio.continuePrevious then
			
		else
			if sequence.audio.file then
				Panels.Audio.startBGAudio(
					Panels.Settings.audioFolder .. sequence.audio.file, sequence.audio.loop or false
				)
			else
				Panels.Audio.stopBGAudio()
			end
		end
	else
		Panels.Audio.stopBGAudio()
	end

    setUpPanels(sequence)
	prepareScrolling(sequence.scrollingIsReversed)
	startTransitionIn(sequence.direction)
	buttonIndicator:setPositionForScrollDirection(sequence.direction)
end

local function unloadSequence()
	for i, p in ipairs(panels) do
		if p.layers then
			for j, l in ipairs(p.layers) do
				if l.timer then
					l.timer:remove()
					l.timer = nil
				end
				
				if l.textAnimator then
					l.textAnimator = nil
				end
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


-- -------------------------------------------------
-- INPUTS

function playdate.cranked(change, accChange)
	scrollPos = scrollPos + change
end

local function checkInputs() 
	if lastPanelIsShowing() then
		if playdate.buttonJustPressed(sequence.advanceControl) then 
			buttonIndicator:press()
			finishSequence()
		end
	end
end

local function updateArrowControls()
	if ( sequence.axis==Panels.ScrollAxis.VERTICAL 
		and playdate.buttonIsPressed(Panels.Input.UP) )
	or ( sequence.axis == Panels.ScrollAxis.HORIZONTAL 
		and playdate.buttonIsPressed(Panels.Input.LEFT) ) then
			scrollVelocity = scrollVelocity + scrollAcceleration
			
	elseif ( sequence.axis == Panels.ScrollAxis.VERTICAL 
		and playdate.buttonIsPressed(Panels.Input.DOWN) ) 
	or ( sequence.axis == Panels.ScrollAxis.HORIZONTAL 
		and playdate.buttonIsPressed(Panels.Input.RIGHT) ) then 
			scrollVelocity = scrollVelocity - scrollAcceleration
	else
		scrollVelocity = scrollVelocity / 2
	end
	
	if scrollVelocity > maxScrollVelocity then 	
		scrollVelocity = maxScrollVelocity 	
	elseif scrollVelocity < -maxScrollVelocity then
		scrollVelocity = -maxScrollVelocity
	end
	scrollPos = scrollPos + scrollVelocity
end

-- -------------------------------------------------
-- GAME LOOP

local function updateComic()
	if transitionInAnimator or transitionOutAnimator then
		updateSequenceTransition()
	else
		updateScroll()
		if sequence.scroll == Panels.ScrollType.MANUAL then
			updateArrowControls()
		end
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
end

-- Playdate update loop
function playdate.update()
	if not menuIsFullScreen then 	
		updateComic()
		drawComic()
		drawButtonIndicator()
	end
	-- TODO: fix credits screen
	if creditsAreActive then
		credits:redraw()
	end
	if menuIsActive then
		drawMenu()
	end
	playdate.timer.updateTimers()
end

-- -------------------------------------------------
-- SAVE & LOAD GAME PROGRESS

local function loadGameData()
	local data = playdate.datastore.read()
	if data then
		Panels.maxUnlockedSequence = data.sequence
	end
end

local function saveGameData() 
	playdate.datastore.write({sequence = Panels.maxUnlockedSequence})
end

function playdate.gameWillTerminate()
	saveGameData()
end

function playdate.deviceWillSleep()
	saveGameData()
end

function playdate.deviceWillLock()
	saveGameData()
end


-- -------------------------------------------------
-- MENU HANDLERS

function Panels.onChapterSelected(chapter)
	Panels.Audio.stopBGAudio()
	unloadSequence(currentSeqIndex)
	currentSeqIndex = chapter
	loadSequence(currentSeqIndex)
end

function Panels.onMenuWillShow()
	menuIsActive = true
	Panels.Audio.pauseBGAudio()
end

function Panels.onMenuDidShow()
	menuIsFullScreen = true
end

function Panels.onMenuWillHide()
	menuIsFullScreen = false
end

function Panels.onMenuDidHide()
	menuIsActive = false
	Panels.Audio.resumeBGAudio()
end

function Panels.onGameDidStartOver() 
	Panels.Audio.stopBGAudio()
	Panels.maxUnlockedSequence = 1
	saveGameData()
	currentSeqIndex = 1
	loadSequence(currentSeqIndex)
end


-- -------------------------------------------------
-- START GAME

local function loadGame()
	createChapterMenu(sequences)
	createMainMenu()
	credits = Panels.Credits.new()
	loadSequence(currentSeqIndex)
end

local function updateSystemMenu()
	local sysMenu = playdate.getSystemMenu()
	local chaptersMenuItem, error = sysMenu:addMenuItem("Chapters", 
		function()
			showChapterMenu()
		end
	)
	printError(error, "Error adding Chapters to system menu")
	
	
	local creditsItem, error2 = sysMenu:addMenuItem("Credits", 
		function()
			creditsAreActive = true
			credits:show()
		end
	)
	printError(error2, "Error adding Credits to system menu:")

end

function Panels.start()
	loadGameData()
	
	validateSettings()
	createButtonIndicator()
	updateSystemMenu()
	
	sequences = Panels.Settings.comicData
	currentSeqIndex = math.min(Panels.maxUnlockedSequence, #sequences)
	
	loadGame();
	
	if currentSeqIndex > 1 then 
		menuIsActive = true
		showMainMenu(false)
	end
end

-- -------------------------------------------------
-- DEBUG

local function unlockAll()
	Panels.maxUnlockedSequence = #sequences
	saveGameData()
end

function playdate.keyPressed(key)
	if key == "0" then 
		unlockAll()
	end
end