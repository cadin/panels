import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"

local gfx <const> = playdate.graphics
local ScreenHeight <const> = playdate.display.getHeight()
local ScreenWidth <const> = playdate.display.getWidth()

Panels = {}
Panels.comicData = {}
Panels.credits = {}

import "./modules/Font"

import "./modules/Settings"
import "./modules/ScrollConstants"
import "./modules/ButtonIndicator"
import "./modules/Color"
import "./modules/Effect"
import "./modules/Input"
import "./modules/Image"
import "./modules/Menus"
import "./modules/Alert"

import "./modules/Panel"
import "./modules/Audio"
import "./modules/TextAlignment"


import "./modules/Utils"
import "./modules/Credits"

local sequenceDidStart = false

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

local numMenusOpen = 0
local numMenusFullScreen = 0
local menusAreFullScreen = false
local chapterDidSelect = false

local panelTransitionAnimator = nil

Panels.maxUnlockedSequence = 1
local gameDidFinish = false

local alert = nil

local function setUpPanels(seq)
    panels = {}
    local pos = 0
	local j = 1
	
	local list = table.shallowcopy(seq.panels)
	if seq.scrollingIsReversed then 
		reverseTable(list)
	end

	for i, panel in ipairs(list) do
		if panel.frame == nil then
			panel.frame = table.shallowcopy(seq.defaultFrame) 
		end
		
		panel.axis = seq.axis
		panel.scrollingIsReversed = seq.scrollingIsReversed or false
		panel.direction = seq.direction

		if panel.advanceControl == nil then
			if panel.advanceControlSequence and #panel.advanceControlSequence == 1 then
				panel.advanceControl = panel.advanceControlSequence[1]
			else 
				panel.advanceControl = sequence.advanceControl
			end
		end

		if panel.advanceControlSequence == nil then
			panel.advanceControlSequence = {panel.advanceControl}
		end

		if panel.backControl == nil then
			panel.backControl = sequence.backControl
		end

		if panel.preventBacktracking == nil then
			panel.preventBacktracking = sequence.preventBacktracking or false
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
	buttonIndicator = Panels.ButtonIndicator.new()
end

local function drawButtonIndicator() 
	if transitionOutAnimator == nil then
		if lastPanelIsShowing() and sequenceDidStart then
			buttonIndicator:show()
		else 
			buttonIndicator:hide()
		end
	end
	if sequence.showAdvanceControl then 
		buttonIndicator:draw()
	end
end

local function getAdvanceControlForScrollDirection(dir)
	if dir == Panels.ScrollDirection.LEFT_TO_RIGHT then 
		return Panels.Input.RIGHT
	elseif dir == Panels.ScrollDirection.TOP_DOWN then
		return Panels.Input.DOWN
	elseif dir == Panels.ScrollDirection.BOTTOM_UP then
		return Panels.Input.UP
	elseif dir == Panels.ScrollDirection.NONE then
		return nil
	else
		return Panels.Input.LEFT
	end
end

local function getBackControlForScrollDirection(dir)
	if dir == Panels.ScrollDirection.LEFT_TO_RIGHT then 
		return Panels.Input.LEFT
	elseif dir == Panels.ScrollDirection.TOP_DOWN then
		return Panels.Input.UP
	elseif dir == Panels.ScrollDirection.BOTTOM_UP then
		return Panels.Input.DOWN
	elseif dir == Panels.ScrollDirection.NONE then
		return nil
	else
		return Panels.Input.RIGHT
	end
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
	if panelTransitionAnimator then 
		scrollPos = panelTransitionAnimator:currentValue()
	else
		if scrollPos > 0 then
			scrollPos = math.floor(scrollPos / snapStrength)
		elseif scrollPos < -maxScroll then
			local diff = scrollPos + maxScroll
			scrollPos = math.floor(scrollPos - (diff - (diff / snapStrength )))
		end
		
		if Panels.Settings.snapToPanels then snapScrollToPanel() end
	end
end


-- -------------------------------------------------
-- PANEL TRANSITIONS

local function isLastPanel(num)
	if (num == #panels and not sequence.scrollingIsReversed) or (sequence.scrollingIsReversed and num <= 1) then
		return true
	else
		return false
	end
end

local function isFirstPanel(num)
	if (num == 1 and not sequence.scrollingIsReversed) or (sequence.scrollingIsReversed and num == #panels) then
		return true
	else 
		return false
	end
end

function getPanelScrollLocation(panel, isTrailingEdge)
	if sequence.axis == Panels.ScrollAxis.VERTICAL then
		if isTrailingEdge == true then
			return (panel.frame.y + panel.frame.margin + panel.frame.height - ScreenHeight) * -1
		else
			return (panel.frame.y - panel.frame.margin) * -1
		end
	else 
		if isTrailingEdge == true then
			return (panel.frame.x + panel.frame.margin + panel.frame.width - ScreenWidth) * -1
		else
			return (panel.frame.x - panel.frame.margin) * -1
		end
	end
end

local function scrollToNextPanel()
	if not isLastPanel(panelNum) then
		local p = panels[panelNum]
		local target = 0
		if p.frame.height > ScreenHeight and scrollPos > p.frame.y  * -1 then
			target = getPanelScrollLocation(p, true)
		elseif p.frame.width > ScreenWidth and scrollPos > p.frame.x * -1 then
			target = getPanelScrollLocation(p, true)
		else 
			if sequence.scrollingIsReversed then
				panelNum = panelNum -1
			else
				panelNum = panelNum + 1
			end
			target = getPanelScrollLocation(panels[panelNum])
		end
		if sequence.direction == Panels.ScrollDirection.NONE then 
			scrollPos = target
		else 
			panelTransitionAnimator = gfx.animator.new(500, scrollPos, target, playdate.easingFunctions.inOutQuad)
		end
	end
end

local function scrollToPreviousPanel()
	if not isFirstPanel(panelNum) then
		local p = panels[panelNum]
		local target = 0
		if p.frame.height > ScreenHeight and scrollPos < p.frame.y * -1 then
			target = getPanelScrollLocation(p)
		elseif p.frame.width > ScreenWidth and scrollPos < p.frame.x * -1 then
			target = getPanelScrollLocation(p)
		else 
			if sequence.scrollingIsReversed then
				panelNum = panelNum + 1
			else
				panelNum = panelNum - 1
			end
			target = getPanelScrollLocation(panels[panelNum], true)
		end
		panelTransitionAnimator = gfx.animator.new(500, scrollPos, target, playdate.easingFunctions.inOutQuad)
	end
end

-- -------------------------------------------------
-- SEQUENCE TRANSITIONS

local function startTransitionIn(direction) 
	local target = scrollPos
	local start

	if direction == Panels.ScrollDirection.BOTTOM_UP then
		start = scrollPos - ScreenHeight
	elseif direction == Panels.ScrollDirection.TOP_DOWN then 
		start = scrollPos + ScreenHeight
	elseif direction == Panels.ScrollDirection.LEFT_TO_RIGHT then
		start = scrollPos + ScreenWidth
	elseif direction == Panels.ScrollDirection.NONE then 
		start = scrollPos
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
	local duration = Panels.Settings.sequenceTransitionDuration
	
	if direction == Panels.ScrollDirection.TOP_DOWN then
		target = maxScroll - ScreenHeight
	elseif direction == Panels.ScrollDirection.BOTTOM_UP then 
		target = maxScroll + ScreenHeight
	elseif direction == Panels.ScrollDirection.RIGHT_TO_LEFT then
		target = maxScroll + ScreenWidth
	elseif direction == Panels.ScrollDirection.NONE then 
		target = scrollPos
		duration = 200
	else 
		target = -maxScroll - ScreenWidth
	end
	

	transitionOutAnimator = playdate.graphics.animator.new(
		duration, start, target, playdate.easingFunctions.inOutQuart)
end


-- -------------------------------------------------
-- SEQUENCE LIFECYCLE

local function setSequenceScrollDirection()
	if sequence.axis == nil and sequence.direction == nil then
		sequence.axis = Panels.ScrollAxis.HORIZONTAL
	end

	if sequence.direction == nil then
		if sequence.axis == Panels.ScrollAxis.VERTICAL then 
			sequence.direction = Panels.ScrollDirection.TOP_DOWN
		else 
			sequence.direction = Panels.ScrollDirection.LEFT_TO_RIGHT 
		end
	elseif sequence.direction == Panels.ScrollDirection.NONE then
		sequence.axis = Panels.ScrollAxis.HORIZONTAL
	elseif sequence.direction == Panels.ScrollDirection.RIGHT_TO_LEFT 
	or sequence.direction == Panels.ScrollDirection.BOTTOM_UP then
		sequence.scrollingIsReversed = true
	end
end

local function setSequenceColors()
	if sequence.backgroundColor == nil then
		if sequence.foregroundColor then
			sequence.backgroundColor = getInverseColor(sequence.backgroundColor)
		else
			sequence.foregroundColor = Panels.Color.BLACK
			sequence.backgroundColor = Panels.Color.WHITE
		end
	end
end

local function loadSequence(num) 	
	sequence = sequences[num]
	if num > Panels.maxUnlockedSequence then Panels.maxUnlockedSequence = num end	

	-- set default scroll direction for each axis if not specified
	setSequenceScrollDirection()
	setSequenceColors()
	
	if sequence.scrollType == nil then
		sequence.scrollType = Panels.ScrollType.MANUAL
	end

	if sequence.defaultFrame == nil then
		sequence.defaultFrame = Panels.Settings.defaultFrame
	end
	
	if sequence.advanceControl == nil then 
		sequence.advanceControl = getAdvanceControlForScrollDirection(sequence.direction)
	end

	if sequence.showAdvanceControl == nil then
		sequence.showAdvanceControl = true
	end

	if sequence.backControl == nil then
		sequence.backControl = getBackControlForScrollDirection(sequence.direction)
	end
	
	if sequence.audio then
		if sequence.audio.continuePrevious and Panels.Audio.bgAudioIsPlaying() then
			
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
	buttonIndicator:setButton(sequence.advanceControl)
	if sequence.advanceControlPosition then
		buttonIndicator:setPosition(sequence.advanceControlPosition.x, sequence.advanceControlPosition.y)
	else
		buttonIndicator:setPositionForScrollDirection(sequence.direction)
	end

	startTransitionIn(sequence.direction)
end

local function unloadSequence()
	for i, p in ipairs(panels) do
		p:killTypingEffects()
		if p.layers then
			for j, l in ipairs(p.layers) do
				if l.timer then
					l.timer:remove()
					l.timer = nil
				end

				if l.animationLoop then
					l.animationLoop = nil
				end
			end
		end
	end
	panelTransitionAnimator = nil
	Panels.Image.clearCache()
	sequence.didFinish = false
end

local function nextSequence()
	unloadSequence()

	if currentSeqIndex < #sequences then
		currentSeqIndex = currentSeqIndex + 1
		loadSequence(currentSeqIndex)
		updateMenuData(sequences, gameDidFinish)
	else 
		gameDidFinish = true
		updateMenuData(sequences, gameDidFinish)
		menusAreFullScreen = true
		Panels.mainMenu:show()
	end
end

local function updateSequenceTransition() 

	if transitionOutAnimator then 
		scrollPos = transitionOutAnimator:currentValue()
		if transitionOutAnimator:ended() then
			transitionOutAnimator = nil
			sequenceDidStart = false
			playdate.timer.performAfterDelay(1, nextSequence) -- prevent flash before transition in
		end
	elseif transitionInAnimator then 
		scrollPos = transitionInAnimator:currentValue()
		if transitionInAnimator:ended() then
			sequenceDidStart = true
			transitionInAnimator = nil
		end
	end
end

local function finishSequence() 
	if not sequence.didFinish then
		sequence.didFinish = true
		startTransitionOut(sequence.direction)
	end
end


-- -------------------------------------------------
-- INPUTS
local function shouldGoBack(panel)
	local should = true
	if panel.preventBacktracking then
		if panel.frame.height > ScreenHeight and scrollPos < panel.frame.y * -1 or
		panel.frame.width > ScreenWidth and scrollPos < panel.frame.x * -1 then
			-- same frame, allow it
			should = true
		else
			should = false
		end
	end
	return should
end

function playdate.cranked(change, accChange)
	if sequence.scrollType == Panels.ScrollType.MANUAL then 
		if sequence.axis == Panels.ScrollAxis.VERTICAL then
			scrollPos = scrollPos + change
		else
			scrollPos = scrollPos - change
		end
	end
end

local function checkInputs() 
	local p = panels[panelNum]
	if lastPanelIsShowing() then
		if p.advanceFunction == nil and playdate.buttonJustPressed(sequence.advanceControl) then 
			buttonIndicator:press()
			finishSequence()
		end
	end

	if sequence.scrollType == Panels.ScrollType.AUTO then
		if p.advanceFunction == nil then
			if p.advanceControlSequence then
				local trigger = p.advanceControlSequence[#p.buttonsPressed + 1]
				if playdate.buttonJustPressed(trigger) then 
					p.buttonsPressed[#p.buttonsPressed+1] = trigger
					if #p.buttonsPressed == #p.advanceControlSequence then 
						if p.advanceDelay then 
							playdate.timer.performAfterDelay(p.advanceDelay, scrollToNextPanel)
						else 
							scrollToNextPanel()
						end
					end
				end
			else 
				if playdate.buttonJustPressed(p.advanceControl) then
					scrollToNextPanel()
				end
			end
		end
		if playdate.buttonJustPressed(p.backControl) then
			if shouldGoBack(p) then
				scrollToPreviousPanel()
			end
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

local function getScrollOffset()
	local offset = {x = 0, y = 0}
	if sequence.axis == Panels.ScrollAxis.HORIZONTAL then 
		offset.x = scrollPos
	else 
		offset.y = scrollPos 
	end

	return offset
end

local function updateComic(offset)
	if transitionInAnimator or transitionOutAnimator then
		updateSequenceTransition()
	else
		if panels and panels[panelNum]:shouldAutoAdvance() then
			if not isLastPanel(panelNum) then 
				scrollToNextPanel()
			else 
				finishSequence()
			end
		else
			updateScroll()
			if sequence.scrollType == Panels.ScrollType.MANUAL then
				updateArrowControls()
			end
			checkInputs()
		end
	end

	
end

local function drawComic(offset)
	gfx.clear()
	for i, panel in ipairs(panels) do 
		if(panel:isOnScreen(offset)) then
			panel:render(offset, sequence.foregroundColor, sequence.backgroundColor)
			panel.canvas:draw(panel.frame.x + offset.x, panel.frame.y + offset.y)
		elseif panel.wasOnScreen then
			panel:reset()
			panel.wasOnScreen = false
		end
	end

end

-- Playdate update loop
function playdate.update()

	if not menusAreFullScreen then 		
		local offset = getScrollOffset()
		updateComic(offset)
		drawComic(offset)
		drawButtonIndicator()
	end
	
	if numMenusOpen > 0 then
		updateMenus()
	end

	if alert.isActive then
		alert:udpate()
	end

	playdate.timer.updateTimers()
end

-- -------------------------------------------------
-- SAVE & LOAD GAME PROGRESS

local function loadGameData()
	local data = playdate.datastore.read()
	if data then
		Panels.maxUnlockedSequence = data.sequence
		gameDidFinish = data.gameDidFinish
	end
end

local function saveGameData() 
	playdate.datastore.write({sequence = Panels.maxUnlockedSequence, gameDidFinish = gameDidFinish})
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
	chapterDidSelect = true
	Panels.Audio.stopBGAudio()
	unloadSequence()
	currentSeqIndex = chapter
	loadSequence(currentSeqIndex)
end

function Panels.onMenuWillShow(menu)
	numMenusOpen = numMenusOpen + 1
	Panels.Audio.pauseBGAudio()
	Panels.Audio.muteTypingSounds()
end

function Panels.onMenuDidShow()
	menusAreFullScreen = true
	numMenusFullScreen = numMenusFullScreen + 1
end

function Panels.onMenuWillHide(menu)
	if menu == Panels.mainMenu then
		if not chapterDidSelect then 
			Panels.Audio.unmuteTypingSounds()
			loadSequence(currentSeqIndex)
		end
	end
	numMenusFullScreen = numMenusFullScreen - 1

	if numMenusFullScreen < 1 then 
		menusAreFullScreen = false
	end	
end

function Panels.onMenuDidHide(menu)
	numMenusOpen = numMenusOpen - 1
	if numMenusOpen < 1 then 
		Panels.Audio.resumeBGAudio()
		Panels.Audio.unmuteTypingSounds()
		chapterDidSelect = false
	end
end


function Panels.onMenuDidStartOver() 
	alert:show()
end

function onAlertDidStartOver()
	Panels.Audio.stopBGAudio()
	Panels.maxUnlockedSequence = 1
	gameDidFinish = false
	saveGameData()
	unloadSequence()
	currentSeqIndex = 1

	Panels.mainMenu:hide()
	createMenus(sequences, gameDidFinish, currentSeqIndex > 1)
end

function onAlertDidHide()
	if alert.selection == 2 then
		onAlertDidStartOver()
	end
end

function shouldShowMainMenu()
	local should = false
	if Panels.Settings.showMenuOnLaunch then
		if currentSeqIndex > 1 or Panels.Settings.skipMenuOnFirstLaunch == false then
			should = true
		end
	end
	if gameDidFinish then should = true end
	return should
end

-- -------------------------------------------------
-- START GAME

local function updateSystemMenu()
	local sysMenu = playdate.getSystemMenu()
	if Panels.Settings.useChapterMenu then 
		local chaptersMenuItem, error = sysMenu:addMenuItem("Chapters", 
			function()
				Panels.creditsMenu:hide()
				Panels.chapterMenu:show()
			end
		)
		printError(error, "Error adding Chapters to system menu")
	end
	
	
	local creditsItem, error2 = sysMenu:addMenuItem("Credits", 
		function()
			if Panels.chapterMenu then Panels.chapterMenu:hide() end
			Panels.creditsMenu:show()
		end
	)
	printError(error2, "Error adding Credits to system menu:")

end

function Panels.start(comicData)
	Panels.comicData = comicData
	alert = Panels.Alert.new("Start Over?", "All progress will be lost.", {"Cancel", "Start Over"})
	alert.onHide = onAlertDidHide

	loadGameData()
	validateSettings()
	createButtonIndicator()
	updateSystemMenu()
	
	sequences = Panels.comicData
	currentSeqIndex = math.min(Panels.maxUnlockedSequence, #sequences)
	createMenus(sequences, gameDidFinish, currentSeqIndex > 1);
	
	if shouldShowMainMenu() then 
		menusAreFullScreen = true
		Panels.mainMenu:show()
	else
		loadSequence(currentSeqIndex)
	end
end

-- -------------------------------------------------
-- DEBUG

local function unlockAll()
	Panels.maxUnlockedSequence = #sequences
	gameDidFinish = true
	saveGameData()
end

function playdate.keyPressed(key)
	if key == "0" then 
		unlockAll()
	end
end