---
layout: default
nav_order: 4
---

# Main Menu

Panels will create a main menu for your comic with "Start" / "Continue" / "Start Over" and "Chapters" options along with your custom `menuImage`.

The default behavior is to show the main menu on first launch, but to go straight to the user's current place in the comic on subsequent launches.  
This behavior (and other options) can be customized by changing menu [Settings]({{site.baseurl}}/docs/settings.html#menu-settings).


## Custom Menu Drawing

If you need to perform any dynamic drawing on top of your static menu image, you can use the `mainMenuDrawingCallback`. This supplied callback function will be called in the update loop after your menu image is drawn.

The callback function will receive and animation value that represents the completion percentage of the menu fade in animation (from 0 - 1).

### Example

In this example, we'll draw some text that shows the percentage of the game the user has completed at the top of the menu screen.
This code goes in the `main.lua` file, before calling `Panels.start()`


```lua
function drawPercentageIndicator(animationValue)
    -- get the percentage of the game that has been completed
    local percent = Panels.percentageComplete
    if percent == 0 then return end

    -- draw some text at the top of the menu screen
    gfx.drawTextAligned(percent .. "% COMPLETE", 200, 4, kTextAlignment.center)
end

-- set the main menu drawing callback to the above function
Panels.mainMenuDrawingCallBack = drawPercentageIndicator

-- start the comic
Panels.start(comicData)
```