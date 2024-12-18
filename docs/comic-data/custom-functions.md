---
layout: default
title: Custom Functions
nav_order: 4
parent: Comic Data
---

# Custom Panel Functions
{: .no_toc}

Any panel can assign a custom function to render the panel, determine when an auto-advance conditions is met, or reset custom properties when the panel leaves the screen.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Render

Assign a custom render function to a panel's [`renderFunction`]({{site.baseurl}}/docs/comic-data/panels#renderfunction) property.
This function will be called every frame while your panel is on screen.

A render function should accept two parameters. The first is a table that represents the panel being rendered. The second parameter is a table with the current x and y scroll offset. The function returns nothing.

Example:
{: .text-delta}

```lua
local function renderPanel6B(panel, offset)
 -- render the panel
end
```

### Render Individual Layers

Setting a render function for a panel ejects it from the framework's normal rendering flow. This means your function becomes responsible for _all_ the logic and drawing in your panel.

Normally this would mean you need to calculate parallax and layer positions manually before drawing images to the screen (see below).

You can bypass those requirements by using the `Panels.renderLayerInPanel()` function. This allows you to intercept panel rendering with a custom function, alter layer data or toggle layers based on [global variables]({{site.baseurl}}/docs/comic-data/variables), then hand them over to Panels to render for you.

The function accepts the layer data, the panel data, and the scroll offset.

Example:
{: .text-delta}

```lua
local function renderPanel6B(panel, offset)
    for i, layer in ipairs(panel.layers) do
        if layer.name ~= 'hiddenLayer' then
            Panels.renderLayerInPanel(layer, panel, offset)
        end
    end
end
```

### Drawing Layers Manually

If you choose not to use `Panels.renderLayerInPanel()`, then you'll need to draw everything in your panel manually.

You can access your panel's layers with the `panel.layers` property. Loop through them to draw the contents of your panel. An image layer will have the `playdate.graphics.image` stored in its `img` property.

Example:
{: .text-delta}

```lua
local function renderPanel6B(panel, offset)
    for i, layer in ipairs(panel.layers) do
        layer.img:draw(layer.x, layer.y)
    end
end
```

### Calculating Parallax

Since your panel has been taken out of the render flow, if you're not using `Panels.renderLayerInPanel()` you'll need to calculate layer position yourself if you want parallax scrolling.

The example below shows how you might calculate x position for layers in a horizontally-scrolling sequence. A vertical sequence would be the same, substituting `y` for `x` and `height` for `width`.

Example:
{: .text-delta}

```lua
local ScreenWidth <const> = playdate.display.getWidth()

local function renderPanel6B(panel, offset)
    local frame = panel.frame

    -- calculate a percentage (0 - 1) that represents how far
    -- the panel has scrolled onto screen
    -- 0 == just entering, 1 == just leaving
    local scrollPct = 1 - (frame.x - frame.margin + frame.width + offset.x) / (ScreenWidth + frame.width)

    for i, layer in ipairs(panel.layers) do
        -- calculate the  x position based on the panel's scroll percentage
        -- and the layer's parallax property
        local p = layer.parallax or 0
        local xPos = math.floor(layer.x + (panel.parallaxDistance * scrollPct - panel.parallaxDistance/2) * p)

        layer.img:draw(xPos, layer.y)
    end
end


```

## Advance

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Assign a custom advance function to a panel's [`advanceFunction`]({{site.baseurl}}/docs/comic-data/panels#advancefunction) property. This function will be called every frame until your panel advances.

In an auto-scrolling sequence, you can use this to determine whether the panel should advance or not. Simply return true or false to indicate whether the advance condition has been met.

Example:
{: .text-delta}

```lua
local function advancePanel06B()
    -- this condition is often based on
    -- things happening in a custom render function
    if zoomLevel > 6.75 then
        return true  -- ready to advance
    else
        return false -- stay on this panel
    end
end

```

## Setup

Assign a custom setup function to a panel's [`setupFunction`]({{site.baseurl}}/docs/comic-data/panels#setupfunction) property.
This function will be called once when your panel first enters the screen.

This function can be used to initial values, audio players, or otherwise prepare for a custom rendered panel.

Example:
{: .text-delta}

```lua
local function setupPanel06B()
    zoomLevel = 0 -- set the initial value for the var that determines the advance condition
    playdate.startAccelerometer() -- start the accelerometer
end
```

## Reset

Assign a custom reset function to a panel's [`resetFunction`]({{site.baseurl}}/docs/comic-data/panels#resetfunction) property.
This function will be called once when your panel leaves the screen.

If the user navigates back to a panel with an advance function, the advance condition will still be true, so they’ll immediately advance again. To avoid this, you can reset the panel state here. This is also a good place to kill any sound effects, timers or handle any other cleanup (like turning off the accelerometer) that may have been initiated in the render function.

Example:
{: .text-delta}

```lua
local function resetPanel06B()
    zoomLevel = 0 -- reset the var that determines the advance condition
    playdate.stopAccelerometer() -- clean up
end
```

## Target Sequence

FOR NONLINEAR COMICS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Assign a custom function to a panel's [`targetSequenceFunction`]({{site.baseurl}}/docs/comic-data/panels#targetsequencefunction) property.
This function will be called once when your panel leaves the screen.

In a comic with a [branching storyline]({{site.baseurl}}/docs/nonlinear-comics.html), you can define the next sequence to present by returning the [sequence `id`](/docs/comic-data/sequences.html#id) from this function.

Example:
{: .text-delta}

```lua
local function targetSequenceForS02()
    if didWinMinigame then
        return "game-won"
    else 
        return "game-lost"
    end
end
```

## Update 

Assign a custom function to a panel's [`updateFunction`]({{site.baseurl}}/docs/comic-data/panels#updatefunction) property.
This function will be called every frame while your panel is on screen.

Update functions allow you to intercept user input or perform other custom logic without having to take over rendering the panel as you would with a custom render function.

Example:
{: .text-delta}

```lua
local function updatePanel6B(panel, offset)
 -- handle input or perform other custom logic
end
```