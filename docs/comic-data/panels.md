---
layout: default

nav_order: 2
parent: Comic Data
---

# Panels
{: .no_toc}

Each [sequence]({{site.baseurl}}/docs/comic-data/sequences) in your comic contains one or more panels. These are the rectangular frames that you scroll through as you read the comic. Each panel typically depicts a single scene.

A panel's data defines the look and behavior of this individual scene. It lists all the layers that make up the scene, and can also define audio, shake effects, and control schemes for advancing to the next panel. You can even define [custom Lua functions]({{site.baseurl}}/docs/comic-data/custom-functions) that completely take over and handle all the rendering of the panel.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

---

## Properties
{: .no_toc}

### layers

required
{: .prop-required}

A list of tables that define each [layer]({{site.baseurl}}/docs/comic-data/layers) in the sequence.

Usage:
{: .text-delta}

```lua
layers = {
    {
        -- data for layer 1
    }, {
        -- data for layer 2
    }, {
        -- data for layer 3
    }
},
```

### audio

default: nil
{: .prop-default}

Audio to play for this panel. This can be a looping background sound, or a momentary sound effect to be played at a specific scroll offset.

Properties:
{: .text-delta}

-   `file` (string)
-   `loop` (boolean)
-   `scrollTrigger` (float [0-1])
-   `pan` (float [0-1])
-   `volume` (float [0-1])
-   `triggerSequence` (list of one or more inputs)
-   `repeats` (integer)

**Note:** the `file` path should be relative to your comic's [`audioFolder` setting]({{site.baseurl}}/docs/settings#audiofolder).

Examples:
{: .text-delta}

##### Set a looping background sound:
{: .no_toc}

```
audio = { file = "sequence1/panel1BG.wav", loop = true },
```

The sound will loop continuously while this panel is on screen. Panels sounds fade slightly in and out as the panel enters and leaves the screen.

##### Play a sound at a specific scroll point:
{: .no_toc}

```
audio = { file = "sequence1/panel1SFX.wav", scrollTrigger = 0.5 },
```

This sound is triggered at 50% scroll. Scroll values go from `0` (just before the panel enters the screen) to `1` (just after the panel leaves the screen). A scroll trigger of `0.5` will trigger at the halfway point, which for a full-screen panel will be when the panel is fully centered on screen.

Triggering a sound at a specific scroll point can be useful for syncing sound effects with layer animations or transitions.

##### Pan a sound effect:
{: .no_toc}

```
audio = { file = "sequence1/panel1SFX.wav", pan = 0.8 },
```

Pan a sound from the far left (`pan = 0`) to the far right (`pan = 1`), or anywhere in between.

**Note:** [Playdate only has a single (mono) speaker](https://play.date/#specs). Pan effects will only be evident when wearing headphones.

##### Trigger a sound effect with button press:
{: .no_toc}

```
audio = { file = "sequence1/beep", triggerSequence = { Panels.Input.A }, repeats = 3 },
```

Trigger a sound when the A button is pressed. Using the `repeats` property allows the sound to be triggered 3 times.


### font

default: playdate.graphics.getSystemFont()
{: .prop-default}

Set a default font for all text layers in this panel.

### fontFamily 

default: nil
{: .prop-default}

Set a default font family for all text layers in this panel.

Setting a font family allows text layers to use **bold** and _italic_ formatting with a custom font.

Font variants:
{: .text-delta}
- `Panels.Font.NORMAL`
- `Panels.Font.BOLD`
- `Panels.Font.ITALIC`

Example:
{: .text-delta}

```
fontFamily = {
    [Panels.Font.NORMAL] = "fonts/SasserSlab/Sasser-Slab",
    [Panels.Font.BOLD] = "fonts/SasserSlab/Sasser-Slab-Bold",
    [Panels.Font.ITALIC] = "fonts/SasserSlab/Sasser-Slab-Italic"
},
```


### frame

default: Panels.Settings.defaultFrame
{: .prop-default}

A table that defines the size of the panel.

Properties:
{: .text-delta}

-   `width` (integer)
-   `height` (integer)
-   `x` (integer)
-   `y` (integer)
-   `margin` (integer)
-   `gap` (integer)

`margin` defines the number of pixels between your panel and the edge of the screen. You can omit `width` and `height` if you want a full-screen panel with margin.

`gap` defines the amount of space between this panel and the panel immediately _before_ it.

### borderless

default: false
{: .prop-default}

By default, panels are drawn with a visible border. Set this to true to omit the border.

### backgroundColor

default: `Panels.Color.WHITE`
{: .prop-default}

Define the background fill for a panel.

### parallaxDistance

default: (panel size \* 1.2)
{: .prop-default}

This is the total distance a [layer]({{site.baseurl}}/docs/comic-data/layers) with `parallax = 1` will travel as the panel scrolls.

### effect

default: nil
{: .prop-default}

An table that defines an effect to apply to the entire panel.

To apply shake to only a single layer use the shake [layer effect]({{site.baseurl}}/docs/comic-data/layers/effects#shake).

Properties:
{: .text-delta}

-   `type` (Panels.Effect)
-   `strength` (float)

At this time there are two types of effect (two different versions of shake):

`Panels.Effect.SHAKE_INDIVIDUAL` adds shakes each layer with a different random amount and direction per frame.

`Panels.Effect.SHAKE_UNISON` applies the same shake and direction and magnitude to each layer.

For both types of effect, the amount of shake is multiplied by the [`parallax`]({{site.baseurl}}/docs/comic-data/layers#parallax) setting of the layer. Higher parallax values will shake more than lower ones.

### transitionOffset

default: 0
{: .prop-default}

A layer that lists multiple [`images`]({{site.baseurl}}/docs/comic-data/layers#images) will transition between those images as the panel scrolls. This means a layer with two images will swap them when the panel scroll reaches `0.5` (50%). If you have [`snapToPanels`]({{site.baseurl}}/docs/settings#snaptopanels) enabled, this can cause flickering as the scroll point rapidly fluctuates between values near or equal to 0.5.

Setting `transitionOffset` adjusts the points at which image transitions are triggered. Setting this to `-0.1` would cause the above example to swap images at scroll point `0.4` instead of `0.5`, thus avoiding the flickering problem.

### advanceControl

default: scroll direction (d-pad)
{: .prop-default}

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Which button advances to the next panel.

By default the advance control will be the d-pad direction button pointing in the sequence's scroll direction. Left-to-right scrolling sequence will advance with the right button, a bottom-up sequence will advance with the up button, and so on.

Options:
{: .text-delta}

-   `Panels.Input.UP`
-   `Panels.Input.RIGHT`
-   `Panels.Input.DOWN`
-   `Panels.Input.LEFT`
-   `Panels.Input.A`
-   `Panels.Input.B`

### showAdvanceControl

default: false
{: .prop-default}

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

A panel does not normally display an advance control indicator. Set this to `true` to have it appear in the panel. This is useful if you change the default control from what the user might expect.

When showing the advance control, you should also set [`advanceControlPosition`](#advancecontrolposition) to position it properly within your panel.

### advanceControlPosition

default: nil
{: .prop-default}

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Where to draw the advance control indicator when enabled (relative to the top left of the panel).  
Optionally define a delay (in milliseconds) before the indicator appears on screen.

Properties:
{: .text-delta}

-   `x` (integer)
-   `y` (integer)
-   `delay` (integer)

### advanceControlSequence

default: nil
{: .prop-default}

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

A list of buttons that must pressed in order to advance to the next panel. Use this in place of [`advanceControl`](#advancecontrol).

It might be useful to define an advance sequence if you have a panel with several animations controlled by keypress. If pressing `A` once triggers an animation and pressing it again triggers the panel transition, you can list the control sequence as:

```
advanceControlSequence = {Panels.Input.A, Panels.Input.A},
```

### advanceDelay

default: 0
{: .prop-default}

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

The time (in milliseconds) to wait before transitioning after the panel's[`advanceControl`](#advancecontrol) or [`advanceControlSequence`](#advancecontrolsequence) has been triggered.

This is useful if you want to wait for a triggered animation to complete before moving to the next panel.

### preventBacktracking

default: false
{: .prop-default}

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Prevent the user from navigating back to the previous panel with the D pad. Helpful if you have a custom render function that uses the D pad to do other things.

### renderFunction

default: nil
{: .prop-default}

A custom render function for this panel. This function gets called for every frame update and will become reponsible for all the panel behavior and drawing.

For more information see [Custom Functions]({{site.baseurl}}/docs/comic-data/custom-functions).

### advanceFunction

default: nil
{: .prop-default}

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

A function to determine whether or not an auto-scrolling panel is ready to advance. This function will be called every frame until the panel advances.

For more information see [Custom Functions]({{site.baseurl}}/docs/comic-data/custom-functions).

### resetFunction

default: nil
{: .prop-default}

A function to reset a custom-rendered panel. This function is called when the panel scrolls off screen. Use this to reset values and prepare the panel to be displayed again in the event that the user navigates back to this panel.

For more information see [Custom Functions]({{site.baseurl}}/docs/comic-data/custom-functions).

### targetSequenceFunction

default: nil
{: .prop-default}

FOR NONLINEAR COMICS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

In a comic with a [branching storyline](({{site.baseurl/docs/nonlinear-comics.html}})), this function defines the next sequence to present by returning the target sequence number. This function is called when the panel scrolls off screen (before resetting the panel).

For more information see [Custom Functions]({{site.baseurl}}/docs/comic-data/custom-functions).