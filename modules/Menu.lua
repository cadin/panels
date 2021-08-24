import 'CoreLibs/ui/gridview.lua'
local gfx <const> = playdate.graphics

local menuAnimationDuration <const> = 200

local chapterList = playdate.ui.gridview.new(0, 32)
local menuList = playdate.ui.gridview.new(128, 32)
local sections = {}
local headerFont = gfx.getSystemFont("bold")
local listFont = gfx.getSystemFont()
local coverImage = gfx.image.new(Panels.Settings.imageFolder .. Panels.Settings.menuImage)

local chapterAnimator = nil
local mainAnimator = nil
local isMainMenu = false
local state = "showing"


local function drawMenuBG(yPos)
	gfx.setColor(Panels.Color.WHITE)
	gfx.fillRoundRect(0, yPos, 400, 245, 4)
	gfx.setColor(Panels.Color.BLACK)
	gfx.setLineWidth(2)
	gfx.drawRoundRect(0, yPos, 400, 245, 4)
end


-- -------------------------------------------------
-- MAIN MENU

local menuOptions = { "Restart", "Chapters",  "Continue", }

local function startShowingMainMenu(animated)
	state = "showing"
	Panels.onMenuWillShow()
	local startVal = 0
	if animated then startVal = 0 end
	mainAnimator = gfx.animator.new(menuAnimationDuration, startVal, 1, playdate.easingFunctions.inOutQuad)
end

local function startHidingMainMenu()
	state = "hiding"
	Panels.onMenuWillHide()
	mainAnimator = gfx.animator.new(menuAnimationDuration, 1, 0, playdate.easingFunctions.inOutQuad)
end

local function hideMainMenu()
	playdate.inputHandlers.pop()
	startHidingMainMenu()
	isMainMenu = false
end

function createMainMenu()
	menuList:setNumberOfRows(1)
	menuList:setNumberOfColumns(#menuOptions)
	menuList:setCellPadding(0, 0, 4, 4)
	
	menuList:setSelection(1, 1,3)
end

function menuList:drawCell(section, row, column, selected, x, y, width, height)
	local text = menuOptions[column]
	if selected then
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(x, y, width, height, 4)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		text = "*" .. text .. "*"
	else
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end
	
	gfx.setFont(listFont)
	gfx.drawTextInRect(text, x + 8, y+8, width -16, height+2, nil, "...", kTextAlignment.center)
end

function showMainMenu(animated)
	isMainMenu = true	
	startShowingMainMenu(animated)
	
	local inputHandlers = {
		rightButtonUp = function()
			menuList:selectNextColumn(false)
		end,
		
		leftButtonUp = function()
			menuList:selectPreviousColumn(false)
		end,
		
		AButtonDown = function()
			local s, r, column = menuList:getSelection()
			if column == 3 then     -- Continue
				hideMainMenu()
			elseif column == 2 then -- Chapters
				showChapterMenu()
			else                 -- Start Over
				-- TODO: 
				-- confirm before resetting game data
				Panels.onGameDidStartOver()
				hideMainMenu()
			end	
			
		end,
	}
	-- menuList:setSelectedRow(1)
	playdate.inputHandlers.push(inputHandlers)
end


-- -------------------------------------------------
-- CHAPTER MENU

local function createSectionsFromData(data)
	sections = {}
	for i, seq in ipairs(data) do
		if (seq.title or Panels.Settings.listUnnamedSequences) 
		and (i <= Panels.maxUnlockedSequence or Panels.Settings.listLockedSequences) then
			local title = seq.title or "--"
			if i <= Panels.maxUnlockedSequence then title = "*" .. title .. "*" end
			sections[#sections + 1] = {title = title, index = i}
		end
	end
end

function createChapterMenu(data)
	createSectionsFromData(data)
	chapterList:setNumberOfRows(#sections)
	chapterList:setSectionHeaderHeight(48)
	chapterList:setCellPadding(0, 0, 0, 8)

end

function chapterList:drawCell(section, row, column, selected, x, y, width, height)
	if selected then
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(x, y, width, height, 4)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	else
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end
	
	gfx.setFont(listFont)
	gfx.drawTextInRect("" .. sections[row].title.. "", x + 16, y+8, width -32, height+2, nil, "...", kTextAlignment.left)
end

function chapterList:drawSectionHeader(section, x, y, width, height)
	gfx.setFont(headerFont)
	gfx.drawTextInRect("Chapters", x, y+12, width, height, nil, "...", kTextAlignment.center)
	gfx.setLineWidth(1)
	gfx.drawLine(x, y + 20, x + 120, y + 20)
	gfx.drawLine(x + width - 120, y + 20, x + width, y + 20)
end

local function drawMainMenu(yPos)
	drawMenuBG(yPos)
	menuList:drawInRect(8, yPos + 3, 384, 42)
end

local function drawChapterMenu(yPos)
	drawMenuBG(yPos)
	chapterList:drawInRect(32, yPos + 3, 336, 240)
end

function drawMenu()
	local chapterValue = 0
	if chapterAnimator then chapterValue = chapterAnimator:currentValue() end
	local mainValue = mainAnimator:currentValue()
	local coverOffset = 400 - mainValue * 400
	local menuOffset = 240 - mainValue * 45
	
	coverImage:draw(coverOffset, 0)
	
	if chapterValue < 1 then 
		drawMainMenu(menuOffset)
	end
	
	if chapterValue > 0 then 
		local chapterOffset = (240 - chapterValue * 240) 
		drawChapterMenu(chapterOffset)
	end
	
	if state == "showing" and mainValue >= 1 then
		Panels.onMenuDidShow()
		state = "none"
	elseif state == "hiding" and mainValue <= 0 then
		Panels.onMenuDidHide()
		state = "none"
	end 
end

function hideChapterMenu()
	playdate.inputHandlers.pop()
	chapterAnimator = gfx.animator.new(menuAnimationDuration, 1, 0, playdate.easingFunctions.inOutQuad)
	
	if not isMainMenu then
		startHidingMainMenu()
	end
end

function showChapterMenu()
	
	if not isMainMenu then
		startShowingMainMenu(true)
	end
	
	chapterAnimator = gfx.animator.new(menuAnimationDuration, 0, 1, playdate.easingFunctions.inOutQuad)
	
	chapterList:setSelectedRow(1)
	chapterList:selectPreviousRow() -- forces list to scroll into view

	local inputHandlers = {
		downButtonUp = function()
			if chapterList:getSelectedRow() < Panels.maxUnlockedSequence then 
				chapterList:selectNextRow(false)
			end
		end,
		
		upButtonUp = function()
			chapterList:selectPreviousRow(false)
		end,
		
		AButtonDown = function()
			local item = sections[chapterList:getSelectedRow()] 
			Panels.onChapterSelected( item.index )
			hideChapterMenu()
			if isMainMenu then 
				hideMainMenu()
			end
		end,
		
		BButtonDown = function()
			hideChapterMenu()
		end
	}
	
	playdate.inputHandlers.push(inputHandlers)
end
