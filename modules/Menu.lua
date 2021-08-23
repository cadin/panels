import 'CoreLibs/ui/gridview.lua'
local gfx <const> = playdate.graphics

local menuAnimationDuration <const> = 200

local chapterList = playdate.ui.gridview.new(0, 32)
local menuList = playdate.ui.gridview.new(0, 32)
local sections = {}
local headerFont = gfx.getSystemFont("bold")
local listFont = gfx.font.new(Panels.Settings.path .. "assets/fonts/Asheville-Narrow-14-Bold")
local coverImage = gfx.image.new(Panels.Settings.imageFolder .. Panels.Settings.menuImage)

local chapterAnimator = nil
local mainAnimator = nil
local isMainMenu = false
local state = "showing"

local function drawMenuBG(xPos)
	gfx.setColor(Panels.Color.WHITE)
	gfx.fillRect(xPos, 0,180, 240)
	gfx.setColor(Panels.Color.BLACK)
	gfx.setLineWidth(2)
	gfx.drawLine(xPos, 0, xPos, 240)
end


-- -------------------------------------------------
-- MAIN MENU

local menuOptions = { "Continue Story", "Select Chapter", "Start Over" }

local function startShowingMainMenu(animated)
	state = "showing"
	Panels.onMenuWillShow()
	local startVal = 1
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
	menuList:setNumberOfRows(#menuOptions)
	menuList:setCellPadding(0, 0, 4, 4)
end

function menuList:drawCell(section, row, column, selected, x, y, width, height)
	if selected then
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(x, y, width, height, 4)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	else
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end
	
	gfx.setFont(listFont)
	gfx.drawTextInRect("" .. menuOptions[row] .. "", x + 8, y+8, width -16, height+2, nil, "...", kTextAlignment.left)
end

function showMainMenu(animated)
	isMainMenu = true	
	startShowingMainMenu(animated)
	
	local inputHandlers = {
		downButtonUp = function()
			menuList:selectNextRow(false)
		end,
		
		upButtonUp = function()
			menuList:selectPreviousRow(false)
		end,
		
		AButtonDown = function()
			local row = menuList:getSelectedRow()
			if row == 1 then     -- Continue
				hideMainMenu()
			elseif row == 2 then -- Chapters
				showChapterMenu()
			else                 -- Start Over
				-- TODO: 
				-- confirm before resetting game data
				Panels.onGameDidStartOver()
				hideMainMenu()
			end	
			
		end,
	}
	menuList:setSelectedRow(1)
	playdate.inputHandlers.push(inputHandlers)
end


-- -------------------------------------------------
-- CHAPTER MENU

local function createSectionsFromData(data)
	for i, seq in ipairs(data) do
		if (seq.title or Panels.Settings.listUnnamedSequences) and i <= Panels.maxUnlockedSequence then
			sections[#sections + 1] = {title = seq.title or "--", index = i}
		end
	end
end

function createChapterMenu(data)
	createSectionsFromData(data)
	chapterList:setNumberOfRows(#sections)
	chapterList:setSectionHeaderHeight(32)
	chapterList:setCellPadding(0, 0, 4, 4)
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
	gfx.drawTextInRect("" .. sections[row].title.. "", x + 8, y+8, width -16, height+2, nil, "...", kTextAlignment.left)
end

function chapterList:drawSectionHeader(section, x, y, width, height)
	gfx.setFont(headerFont)
	gfx.drawTextInRect("CHAPTERS", x, y+8, width, height, nil, "...", kTextAlignment.center)
	gfx.drawLine(x + 32, y + height - 2, x + width - 32, y + height - 2)
end

local function drawMainMenu(xPos)
	drawMenuBG(xPos)
	menuList:drawInRect(xPos + 8, 100, 164, 240)
end

local function drawChapterMenu(xPos)
	drawMenuBG(xPos)
	chapterList:drawInRect(xPos + 8, 0, 164, 240)
end

function drawMenu()
	local chapterValue = 0
	if chapterAnimator then chapterValue = chapterAnimator:currentValue() end
	local mainValue = mainAnimator:currentValue()
	local coverOffset = 400 - mainValue * 400
	local menuOffset = 400 - mainValue * 180
	
	coverImage:draw(coverOffset, 0)
	
	if chapterValue < 1 then 
		drawMainMenu(menuOffset)
	end
	
	if chapterValue > 0 then 
		local chapterOffset = 400 - chapterValue * 180
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
			chapterList:selectNextRow(false)
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
