local gfx <const> = playdate.graphics
local ScreenWidth <const> = playdate.display.getWidth()
local ScreenHeight <const> = playdate.display.getHeight()

Panels.Alert = {}

local titleFont = gfx.getSystemFont("bold")
local textFont = gfx.getSystemFont()
local listFont = gfx.getSystemFont()
local animator = nil
local dimScreen = gfx.image.new(ScreenWidth, ScreenHeight, Panels.Color.BLACK)
local gridView = nil

function Panels.Alert.new(title, text, options, callback, selection)
    local width = 320
    local height = 150
    local x = (ScreenWidth - width) / 2
    local y = (ScreenHeight - height) / 2 - 8

    gridView = playdate.ui.gridview.new((width - 32) / 2, 32)
    gridView:setNumberOfRows(1)
	gridView:setNumberOfColumns(#options)
	gridView:setCellPadding(0, 0, 4, 4)
	gridView:setSelection(1, 1, selection or 1)

    local alert = {
        isActive = false,
        title = title,
        text = text,
        options = options,
        selection = selection or 1,
        state = "hidden"
    }

    function alert:getSelection()
        return self.selection
    end

    function gridView:drawCell(section, row, column, selected, x, y, width, height)
        gfx.pushContext()
        local text = alert.options[column]
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
        gfx.popContext()
    end

    function alert:drawBG(progress) 
        local w = width * progress
        local h = height * progress

        local _x = x + (width - w) / 2
        local _y =  y + (height - h) / 2

        gfx.pushContext()
        gfx.setColor(Panels.Color.WHITE)
        gfx.setLineWidth(6)
        gfx.drawRoundRect(_x, _y, w, h, 10)
        gfx.fillRoundRect(_x, _y, w, h, 8)
        gfx.setColor(Panels.Color.BLACK)
        gfx.setLineWidth(2)
        gfx.drawRoundRect(_x, _y, w, h, 8)
        gfx.popContext()
    end

    function alert:drawText()
        gfx.setFont(titleFont)
        gfx.drawTextInRect(self.title, x + 16, y + 16, width - 32, 32, nil, "...", kTextAlignment.center)
        gfx.setFont(textFont)
        gfx.drawTextInRect(self.text, x + 16, y + 48, width - 32, height - 128, nil, "...", kTextAlignment.center)
    end

    function alert:hide()
        self.state = "hiding"
        animator = gfx.animator.new(250, 1, 0, playdate.easingFunctions.inOutQuad)
        playdate.inputHandlers.pop()

    end

    function alert:show() 
        self.state = "showing"
        local inputHandlers = {
            rightButtonUp = function()
                gridView:selectNextColumn(false)
            end,
            
            leftButtonUp = function()
                gridView:selectPreviousColumn(false)
            end,
            
            AButtonDown = function()
                local s, r, column = gridView:getSelection()
                self.selection = column
                self:hide()
            end,
    
            BButtonDown = function()
                self.selection = 1
                self:hide()
            end,
    
        }

        self.isActive = true
        animator = gfx.animator.new(250, 0, 1, playdate.easingFunctions.inOutQuad)
        playdate.inputHandlers.push(inputHandlers, true)
    end

    function alert:udpate()
        local progress = animator:currentValue()

        dimScreen:drawFaded(0, 0, 0.5 * progress, gfx.image.kDitherTypeBayer8x8)
        self:drawBG(progress)
        if progress >= 1 then 
            self:drawText()
            gridView:drawInRect(x + 16, y + height - 42 - 8, width - 32, 42)
            self.state = "visible"
        end

        if self.state ~= "hidden" and progress <= 0 and animator:ended() then
            print(self.state)
            if self.onHide then
                self.state = "hidden"
                self:onHide()
            end
        end
    end

    return alert
end