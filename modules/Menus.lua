import 'CoreLibs/ui/gridview.lua'
local gfx <const> = playdate.graphics

local ScreenHeight <const> = playdate.display.getHeight()

Panels.Menu = {}

-- -------------------------------------------------
-- GENERIC MENU

local menuAnimationDuration <const> = 200

local MenuState = {
	SHOWING = 0,
	OPEN = 1,
	HIDING = 2,
	CLOSED = 3
}

function Panels.Menu.new(height, redrawContent, inputHandlers)
	local menu = {}
	
	menu.animator = nil
	menu.state = MenuState.CLOSED
	menu.isFullScreen = false
	menu.onWillShow = nil
	menu.onDidHide = nil
	
	local function drawBG(yPos)
		gfx.setColor(Panels.Color.WHITE)
		gfx.fillRoundRect(0, yPos, 400, ScreenHeight + 5, 6)
		gfx.setColor(Panels.Color.BLACK)
		gfx.setLineWidth(2)
		gfx.drawRoundRect(0, yPos, 400, ScreenHeight + 5, 6)
	end
	
	function menu:show()
		if self.state == MenuState.SHOWING or self.state == MenuState.OPEN then
			return
		end
		
		if self.onWillShow then self:onWillShow() end
		Panels.onMenuWillShow(self)
		self.state = MenuState.SHOWING
		playdate.inputHandlers.push(inputHandlers, true)
		self.animator = gfx.animator.new(menuAnimationDuration, 0, 1, playdate.easingFunctions.inOutQuad)
	end
	
	function menu:hide()
		if self.state == MenuState.HIDING or self.state == MenuState.CLOSED then
			return 
		end
		Panels.onMenuWillHide(self)
		self.state = MenuState.HIDING
		playdate.inputHandlers.pop()
		self.animator = gfx.animator.new(menuAnimationDuration, 1, 0, playdate.easingFunctions.inOutQuad)
	end
	
	function menu:isActive()
		return self.state ~= MenuState.CLOSED 
	end
	
	function menu:updateState()
		if self.animator:ended() then
			if self.state == MenuState.SHOWING then
				self.state = MenuState.OPEN
				Panels.onMenuDidShow(self)
			elseif self.state == MenuState.HIDING then
				self.state = MenuState.CLOSED
				Panels.onMenuDidHide(self)
			end
		end
	end
	
	function menu:update()		
		local animatorVal = self.animator:currentValue()
		local yPos = ScreenHeight - animatorVal * height
		
		if yPos < ScreenHeight then
			drawBG(yPos)
			redrawContent(yPos)
		end
		
		self:updateState()
	end
	
	return menu
end


-- -------------------------------------------------
-- MAIN MENU

local mainMenuList = playdate.ui.gridview.new(128, 32)
local menuOptions = { "Restart", "Chapters",  "Continue", }
local mainMenuImage = nil

local function displayMenuImage(val)
	local y = 240 - (val * ScreenHeight)
	mainMenuImage:drawFaded(0, 0, val, gfx.image.kDitherTypeBayer8x8)
end

local function loadMenuImage()
	img, error = gfx.image.new(Panels.Settings.imageFolder .. Panels.Settings.menuImage)
	printError(error, "Error loading main menu image:")
	
	return img
end

local function redrawMainMenu(yPos)
	mainMenuList:drawInRect(8, yPos + 3, 384, 42)
end

function mainMenuList:drawCell(section, row, column, selected, x, y, width, height)
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

function createMainMenu()
	mainMenuImage = loadMenuImage()
	
	mainMenuList:setNumberOfRows(1)
	mainMenuList:setNumberOfColumns(#menuOptions)
	mainMenuList:setCellPadding(0, 0, 4, 4)
	mainMenuList:setSelection(1, 1,3)
	
	local inputHandlers = {
		rightButtonUp = function()
			mainMenuList:selectNextColumn(false)
		end,
		
		leftButtonUp = function()
			mainMenuList:selectPreviousColumn(false)
		end,
		
		AButtonDown = function()
			local s, r, column = mainMenuList:getSelection()
			if column == 3 then     -- Continue
				Panels.mainMenu:hide()
			elseif column == 2 then -- Chapters
				Panels.chapterMenu:show()
			else                 -- Start Over
				-- TODO: 
				-- confirm before resetting game data
				Panels.onGameDidStartOver()
				Panels.mainMenu:hide()
			end	
		end,
	}
	
	local menu = Panels.Menu.new(45, redrawMainMenu, inputHandlers)
	return menu
end


-- -------------------------------------------------
-- CHAPTER MENU

local chapterList = playdate.ui.gridview.new(0, 32)

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

local function redrawChapterMenu(yPos)
	chapterList:drawInRect(32, yPos + 3, 336, 240)
end

local function onChapterMenuWillShow() 
	chapterList:setSelectedRow(1)
	chapterList:selectPreviousRow()
end

local function createChapterMenu(data)
	createSectionsFromData(data)
	chapterList:setNumberOfRows(#sections)
	chapterList:setSectionHeaderHeight(48)
	chapterList:setCellPadding(0, 0, 0, 8)
	
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
			Panels.chapterMenu:hide()
			Panels.mainMenu:hide()
		end,
		
		BButtonDown = function()
			Panels.chapterMenu:hide()
		end
		
	}
	
	local menu = Panels.Menu.new(ScreenHeight - 2, redrawChapterMenu, inputHandlers)
	menu.onWillShow = onChapterMenuWillShow
	return menu
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


-- -------------------------------------------------
-- CREDITS MENU

local credits = nil

local function redrawCreditsMenu(yPos)
	credits:redraw(yPos)
end

local function onCreditsMenuWillShow()
	credits.scrollPos = 0
end

local function createCreditsMenu()
	credits = Panels.Credits.new()
	
	local inputHandlers = {
		BButtonDown = function()
			Panels.creditsMenu:hide()
		end,
	}
	
	local menu = Panels.Menu.new(ScreenHeight, redrawCreditsMenu, inputHandlers)
	menu.onWillShow = onCreditsMenuWillShow
	return menu
end


-- -------------------------------------------------
-- ALL MENUS

function updateMenus()	
	if Panels.mainMenu:isActive() then 
		local val = Panels.mainMenu.animator:currentValue()
		displayMenuImage(val)	
		Panels.mainMenu:update() 
	end
	
	if Panels.chapterMenu:isActive() then
		Panels.chapterMenu:update()
	end
	
	if Panels.creditsMenu:isActive() then 
		Panels.creditsMenu:update()
	end
end

function createMenus(sequences)
	Panels.mainMenu = createMainMenu()
	Panels.chapterMenu = createChapterMenu(sequences)
	Panels.creditsMenu = createCreditsMenu()
end


