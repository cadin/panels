---
layout: default
title: Variables
parent: Comic Data
---

# Global Variables
{: .no_toc}

You can set and retrieve custom global variables from any [custom function]({{site.baseurl}}/docs/comic-data/custom-functions) in your comic by adding them to the `Panels.vars` table.

Any global variable will be accessible in custom functions. Variables stored in `Panels.vars` will be saved to disk, so users can retain collectible items, character properties, or any other values between sessions.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Example

In this example, a custom `hasKey` variable is set on `Panels.vars` in an [update function]() when the user presses the A button.

In a later panel, we can read the variable in a custom render function to conditionally render layers, or to the direct user to a different path in a nonlinear comic.

Example:
{: .text-delta}

```lua
local function updatePanel2A()
    if playdate.buttonJustPressed(Panels.Input.A) then
        Panels.vars.hasKey = true
    end
end
```

```lua
local function renderPanel6B(panel, offset)
    for i, layer in ipairs(panel.layers) do
        -- conditionally render the "key" layer
        if layer.name == 'key' or Panels.vars.hasKey == false then 
            Panels.renderLayerInPanel(layer, panel, offset)	
        end
    end
end
```

```lua
local function getTargetSequence(panel, offset)
    if Panels.vars.hasKey then
        return 4
    else 
        return 2
    end
end
```

## Example Project
You can see a full example using global variables for collectible items in the [Collectible Item Example Project](https://github.com/cadin/panels-item-example) on GitHub.

A rough walkthrough of this project is available on YouTube: [Panels Item Example Walkthrough](https://www.youtube.com/watch?v=VNswT0y0VP8)