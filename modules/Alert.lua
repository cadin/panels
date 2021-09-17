local gfx <const> = playdate.graphics
local ScreenWidth <const> = playdate.display.getWidth()
local ScreenHeight <const> = playdate.display.getHeight()

Panels.Alert = {}

local titleFont = gfx.getSystemFont("bold")
local textFont = gfx.getSystemFont()
local animator = nil
local dimScreen = gfx.image.new(ScreenWidth, ScreenHeight, Panels.Color.BLACK)

function Panels.Alert.new(title, text, bLabel, aLabel)
    local width = 320
    local height = 150
    local x = (ScreenWidth - width) / 2
    local y = (ScreenHeight - height) / 2 - 8

    local bButton = Panels.ButtonIndicator.new()
    bButton:setButton(Panels.Input.B)
    local bx = x + 16
    bButton:setPosition(bx, y + height - 16- 40)
    local aButton = Panels.ButtonIndicator.new()
    local ax = x + width / 2
    aButton:setButton(Panels.Input.A)
    aButton:setPosition(ax, y + height - 16 - 40)


    local alert = {
        isActive = false,
        title = title,
        text = text,
        bLabel = bLabel,
        aLabel = aLabel,
    }

    function alert:drawBG(progress) 
        local w = width * progress
        local h = height * progress

        local _x = x + (width - w) / 2
        local _y =  y + (height - h) / 2

        gfx.setColor(Panels.Color.WHITE)
        gfx.setLineWidth(6)
        gfx.drawRoundRect(_x, _y, w, h, 10)
        gfx.fillRoundRect(_x, _y, w, h, 8)
        gfx.setColor(Panels.Color.BLACK)
        gfx.setLineWidth(2)
        gfx.drawRoundRect(_x, _y, w, h, 8)
    end

    function alert:drawText()
        gfx.setFont(titleFont)
        gfx.drawTextInRect(self.title, x + 16, y + 16, width - 32, 32, nil, "...", kTextAlignment.center)
        gfx.setFont(textFont)
        gfx.drawTextInRect(self.text, x + 16, y + 48, width - 32, height - 128, nil, "...", kTextAlignment.center)
    end

    function alert:drawButtons()
        gfx.setFont(titleFont)

        gfx.drawText(bLabel, bx + 44, y + height - 16 - 28)
        bButton:draw()
        gfx.drawText(aLabel, ax + 44, y + height - 16 - 28)
        aButton:draw()
    end

    function alert:show() 
        self.isActive = true
        bButton:show()
        aButton:show()
        animator = gfx.animator.new(250, 0, 1, playdate.easingFunctions.inOutQuad)
    end

    function alert:udpate()
        local progress = animator:currentValue()

        dimScreen:drawFaded(0, 0, 0.5 * progress, gfx.image.kDitherTypeBayer8x8)
        self:drawBG(progress)
        if progress >= 1 then 
            self:drawText()
            self:drawButtons()
        end
    end

    return alert
end