local gfx <const> = playdate.graphics

Panels.Menu = {}

function Panels.Menu.new(data, selectionCallback, hideCallback)
	local menu = { selection = 1 }
	menu.sections = {}
	
	menu.inputHandlers = {
		downButtonDown = function()
			if menu.selection < #menu.sections then
				menu.selection = menu.selection + 1
			end
			menu:redraw()
		end,
		
		upButtonDown = function()
			if menu.selection > 1 then 
				menu.selection = menu.selection - 1
			end
			menu:redraw()
		end,
		
		AButtonDown = function()
			local item = menu.sections[menu.selection] 
			selectionCallback( item.index )
		end,
		
		BButtonDown = function()
			menu:hide()
		end
	}
	
	for i, seq in ipairs(data) do
		if seq.title then
			menu.sections[#menu.sections + 1] = {title = seq.title, index = i, unlocked = false}
		end
	end
	
	function menu:show()
		-- TODO: show animation?
		playdate.inputHandlers.push(self.inputHandlers)
		self:redraw()
	end
	
	function menu:redraw()
		gfx.clear()
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(5,  5 + (self.selection - 1) * 32, 200, 26, 4 )
		
		local y = 10
		for i, sec in ipairs(self.sections) do 
			gfx.pushContext()
			
			if i == self.selection then
				-- draw selected text in white
				gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			end
			
			gfx.drawText("*"..sec.title.."*", 16, y)
			gfx.popContext()
			y += 32
		end
	end
	
	function menu:hide()
		-- TODO: hide animation
		playdate.inputHandlers.pop()
		hideCallback()
	end
	
	return menu
end


