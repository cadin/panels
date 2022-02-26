---
layout: default
nav_order: 5
---

# Credits
{: .no_toc}

Panels adds a "Credits" item to the Playdate system menu. Selecting this item displays a panel with a scrolling list of credits for your game.

To define your game credits, assign a table to the `Panels.credits` property before calling `start()` in your `main.lua`.



<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

---

## Example
```lua
Panels.credits = {
    autoScroll = true,
    hideStandardHeader = true,
	
    lines = {
        { image = "logo.png"},
        { text = "Based on a true story" , spacing = 16 },
        { text = "by *James Nasium*" },
    }
}
```

## Properties

### alignment
default: Panels.TextAlignment.CENTER
{: .prop-default}

Set the default text alignment for all lines.

Options:
{: .text-delta}
- `Panels.TextAlignment.LEFT`
- `Panels.TextAlignment.CENTER`
- `Panels.TextAlignment.RIGHT`

### font
default: playdate.graphics.getSystemFont()
{: .prop-default}

Set the default font for all lines of text in the credits.

### autoScroll
default: false
{: .prop-default}

When set to `true`, the credits will scroll automatically (if they are long enough to scroll). Autoscrolling will pause when the user manually scrolls, then resume a short time after manual interaction stops.

### hideStandardHeader
default: false
{: .prop-default}

The standard menu header says "Credits" in bold system text.

Set this property to true to hide the standard header. Useful if you want to display a logo or other image as the first line of your credits.

### lines
default: nil
{: .prop-default}

A list of all the lines (text and images) that should appear in your credits pane. Each line is a table made up of the properties listed below.

## Line Properties

### text
default: nil
{: .prop-default}

The text to display on this line. 

Each line should list either an image _or_ text, not both.


### font
default: nil
{: .prop-default}

Set the font for an individual line of text (overriding the font setting for the entire Credits screen).


### image
default: nil
{: .prop-default}

The path to an image to display on this line. The path here should be relative to the folder specified in the [`imageFolder`](/docs/settings/#imagefolder) setting.

Each line should list either an image _or_ text, not both.


### spacing
default: 0
{: .prop-default}

The amount of additional space (in pixels) to add between this line and the line _before_ it.

By default, lines are stacked vertically, one after another. You can use this property to add additional space between specific lines. 

### alignment
default: Panels.credits.alignment
{: .prop-default}

Use this property to override the default text alignment on a per-line basis.

Options:
{: .text-delta}
- `Panels.TextAlignment.LEFT`
- `Panels.TextAlignment.CENTER`
- `Panels.TextAlignment.RIGHT`
