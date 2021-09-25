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

local selectionSound = playdate.sound.sampleplayer.new(Panels.Settings.path .. "assets/audio/selection.wav")
local selectionRevSound = playdate.sound.sampleplayer.new(Panels.Settings.path .. "assets/audio/selection-reverse.wav")
local denialSound = playdate.sound.sampleplayer.new(Panels.Settings.path .. "assets/audio/denial.wav")
local confirmSound = playdate.sound.sampleplayer.new(Panels.Settings.path .. "assets/audio/confirm.wav")

local hideSound = playdate.sound.sampleplayer.new(Panels.Settings.path .. "assets/audio/swish-out.wav")
local showSound = playdate.sound.sampleplayer.new(Panels.Settings.path .. "assets/audio/swish-in.wav")


function Panels.Alert.new(title, text, options, callback, selection)
    local width = 320
    local height = 150
    local x = (ScreenWidth - width) / 2
    local y = (ScreenHeight - height) / 2 - 8
    local offset = 0

    gridView = playdate.ui.gridview.new((width - 32) / 2 - 8, 32)
    gridView:setNumberOfRows(1)
	gridView:setNumberOfColumns(#options)
	gridView:setCellPadding(4,4, 4, 4)
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
            gfx.fillRoundRect(x + offset, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            text = "*" .. text .. "*"
            offset = 0
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        
        gfx.setFont(listFont)
        gfx.drawTextInRect(text, x, y+8, width, height+2, nil, "...", kTextAlignment.center)
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
        animator = gfx.animator.new(200, 1, 0, playdate.easingFunctions.inOutQuad)
        playdate.inputHandlers.pop()

        if Panels.Settings.playMenuSounds then
            hideSound:play()
        end
    end

    function alert:show() 
        self.state = "showing"
        local inputHandlers = {
            rightButtonUp = function()
                local s, r, column = gridView:getSelection()
                if Panels.Settings.playMenuSounds then 
                    if column == #self.options then
                        denialSound:play()
                    else
                        selectionSound:play()
                    end
                end
                offset = 4
                gridView:selectNextColumn(false)

            end,
            
            leftButtonUp = function()
                local s, r, column = gridView:getSelection()
                if Panels.Settings.playMenuSounds then 
                    if column == 1 then
                        denialSound:play()
                    else
                        selectionRevSound:play()
                    end
                end

                offset = -4
                gridView:selectPreviousColumn(false)
            end,
            
            AButtonDown = function()
                local s, r, column = gridView:getSelection()
                self.selection = column
                self:hide()

                if Panels.Settings.playMenuSounds then
                    confirmSound:play()
                end
            end,
    
            BButtonDown = function()
                self.selection = 1
                self:hide()
            end,
    
        }

        self.isActive = true
        animator = gfx.animator.new(250, 0, 1, playdate.easingFunctions.inOutQuad)
        playdate.inputHandlers.push(inputHandlers, true)
        if Panels.Settings.playMenuSounds then
            showSound:play()
        end
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
            if self.onHide then
                self.state = "hidden"
                self:onHide()
            end
        end
    end

    return alert
end