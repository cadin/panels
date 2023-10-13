local gfx <const> = playdate.graphics
local ScreenHeight <const> = playdate.display.getHeight()
local ScreenWidth <const> = playdate.display.getWidth()

function Panels.renderLayerInPanel(layer, panel, offset)
	
	local pct = getScrollPercentages(panel.frame, offset, panel.axis)
	local p = layer.parallax or 0
	local startValues = table.shallow_copy(layer)
	if layer.isExiting and layer.animate then
		for k, v in pairs(layer.animate) do startValues[k] = v end
	end

	local xPos = math.floor(startValues.x + (panel.parallaxDistance * pct.x - panel.parallaxDistance / 2) * p)
	local yPos = math.floor(startValues.y + (panel.parallaxDistance * pct.y - panel.parallaxDistance / 2) * p)
	local rotation = 0

	if layer.animate or layer.isExiting then
		local anim = layer.animate

		if layer.isExiting then
			anim = layer.exit
			anim.scrollTrigger = 0
		end

		if (anim.triggerSequence or anim.scrollTrigger ~= nil) and not layer.animator then

			if layer.buttonsPressed == nil then layer.buttonsPressed = {} end
			local triggerButton = nil
			if not anim.scrollTrigger then
				triggerButton = anim.triggerSequence[#layer.buttonsPressed + 1]
			end

			if anim.scrollTrigger ~= nil or pdButtonJustPressed(triggerButton) then
				layer.buttonsPressed[#layer.buttonsPressed + 1] = triggerButton
				if (anim.scrollTrigger ~= nil and cntrlPct >= anim.scrollTrigger) or
					(anim.triggerSequence and #layer.buttonsPressed == #anim.triggerSequence) then
					layer.animator = gfx.animator.new((anim.duration or 200), 0, 1, anim.ease, anim.delay)
					if layer.sfxPlayer then
						local count = anim.audio.repeatCount or 1
						if anim.audio.loop then count = 0 end
						playdate.timer.performAfterDelay(anim.delay + (anim.audio.delay or 0), function()
							layer.sfxPlayer:play(count)
						end)
					end
				end
			end
		else
			local layerPct = cntrlPct
			if layer.animator then
				layerPct = layer.animator:currentValue()
			end

			if anim.x then xPos = math.floor(xPos + ((anim.x - startValues.x) * layerPct)) end
			if anim.y then yPos = math.floor(yPos + ((anim.y - startValues.y) * layerPct)) end
			if anim.rotation then rotation = anim.rotation * layerPct end
			if anim.opacity then
				local o = (anim.opacity - layer.opacity) * layerPct + layer.opacity
				layer.alpha = o
				if o <= 0 then
					layer.visible = false
				else
					layer.visible = true
				end
			end
		end
	end



	if panel:layerShouldShake(layer) then
		if panel.effect and panel.effect.type == Panels.Effect.SHAKE_INDIVIDUAL then
			shake = calculateShake(panel.effect.strength or 2)
		elseif layer.effect and layer.effect.type == Panels.Effect.SHAKE then
			shake = calculateShake(layer.effect.strength or 2)
		end

		xPos = xPos + shake.x * (1 - p * p)
		yPos = yPos + shake.y * (1 - p * p)
	end

	if layer.effect then
		doLayerEffect(layer, xPos, yPos)
	end


	local img
	if layer.img then
		img = layer.img
	elseif layer.imgs then
		if layer.advanceControl then
			if pdButtonJustPressed(layer.advanceControl) then
				if layer.currentImage < #layer.imgs then
					layer.currentImage = layer.currentImage + 1
				end
			end
			img = layer.imgs[layer.currentImage]
		else
			local p = cntrlPct
			p = p - (panel.transitionOffset or 0)
			p = p - (layer.transitionOffset or 0)
			local j = math.max(math.min(math.ceil(p * #layer.imgs), #layer.imgs), 1)
			img = layer.imgs[j]
		end
	end

	local globalX = xPos + offset.x + panel.frame.x
	local globalY = yPos + offset.y + panel.frame.y

	if img then
		if layer.visible then
			
			if globalX + img.width > 0 and globalX < ScreenWidth and globalY + img.height > 0 and globalY < ScreenHeight then
				
				if layer.alpha and layer.alpha < 1 then
					img:drawFaded(xPos, yPos, layer.alpha, playdate.graphics.image.kDitherTypeBayer8x8)
				else
					if layer.maskImg then
						local maskX = math.floor((panel.parallaxDistance * pct.x - panel.parallaxDistance / 2) * p) - panel.frame.margin
						local maskY = math.floor((panel.parallaxDistance * pct.y - panel.parallaxDistance / 2) * p) - panel.frame.margin

						local maskImg = gfx.image.new(ScreenWidth, ScreenHeight)
						gfx.lockFocus(maskImg)
						layer.maskImg:draw(maskX, maskY)
						gfx.unlockFocus()

						gfx.setStencilImage(maskImg)
						img:draw(xPos, yPos)
						gfx.clearStencil()
					else
						img:draw(xPos, yPos)
					end
				end
			end
		end

	elseif layer.text then
		if layer.visible then
			if globalX + ScreenWidth > 0 and globalX < ScreenWidth and globalY + ScreenHeight > 0 and globalY < ScreenHeight then
				if layer.alpha == nil or layer.alpha > 0.5 then
					panel:drawTextLayer(layer, xPos, yPos, cntrlPct)
				end
			end
		end
	elseif layer.animationLoop then
		if layer.visible then
			if layer.trigger then
				if pdButtonJustPressed(layer.trigger) then
					layer.animationLoop.paused = false
				end
			elseif layer.startDelay then
				if layer.startDelayTriggered == nil then
					playdate.timer.performAfterDelay(layer.startDelay, function()
						if layer.animationLoop then layer.animationLoop.paused = false end
					end)
					layer.startDelayTriggered = true
				end
			elseif cntrlPct >= layer.scrollTrigger then
				layer.animationLoop.paused = false
			end
			layer.animationLoop:draw(xPos, yPos)
		end
	end

end
