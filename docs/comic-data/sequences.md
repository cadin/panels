---
layout: default

nav_order: 1
parent: Comic Data
---

# Sequences
{: .no_toc}

A comic contains one or more sequences. In most cases, a sequence acts like a separate chapter of your comic.

Each sequence can define different settings for scroll direction and background color. Sequences can scroll manually (with the crank or arrows), or they can animate between panels automatically by pressing a button.

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

### panels

required
{: .prop-required}

A list of tables that define each [panel]({{site.baseurl}}/docs/comic-data/panels) in the sequence.

Usage:
{: .text-delta}

```lua
panels = {
    {
        -- data for panel 1
    }, {
        -- data for panel 2
    }, {
        -- data for panel 3
    }
},
```

### title

default: nil
{: .prop-default}

The sequence title is the text that will appear in the Chapters menu. Sequences without a title will not appear in the Chapters menu. This can be used as a method for having multiple sequences appear as a single chapter.

### axis

default: Panels.ScrollAxis.HORIZONTAL
{: .prop-default}

On which axis should this sequence scroll?

OPTIONS:
{: .text-delta}

-   `Panels.ScrollAxis.HORIZONTAL`
-   `Panels.ScrollAxis.VERTICAL`

### direction

default: Panels.ScrollDirection.LEFT_TO_RIGHT or TOP_DOWN
{: .prop-default}

In which direction does this sequence scroll?
By default horizontal sequences scroll left to right, vertical sequences scroll from top to bottom.

Setting the direction to `NONE` creates a sequence where panels appear directly on top of each other with no animated transition.

OPTIONS:
{: .text-delta}

-   `Panels.ScrollDirection.LEFT_TO_RIGHT`
-   `Panels.ScrollDirection.RIGHT_TO_LEFT`
-   `Panels.ScrollDirection.TOP_DOWN`
-   `Panels.ScrollDirection.BOTTOM_UP`
-   `Panels.ScrollDirection.NONE`

### scrollType

default: Panels.ScrollType.MANUAL
{: .prop-default}

A _manually_ scrolling sequence moves incrementally as the user turns the crank or presses the d-pad.

An _auto_-scrolling sequence moves panel-by-panel as the user presses the panel's [`advanceControl`]({{site.baseurl}}/docs/comic-data/panels#advancecontrol) button or triggers the panel's [`advanceControlSequence`]({{site.baseurl}}/docs/comic-data/panels#advancecontrolsequence).

Auto-scrolling sequences can also be advanced with the crank by setting the [`autoAdvanceWithCrank`](#autoadvancewithcrank) property.

OPTIONS:
{: .text-delta}

-   `Panels.ScrollType.MANUAL`
-   `Panels.ScrollType.AUTO`

### autoAdvanceWithCrank
default: false
{: .prop-default}

When set to `true`, the crank can be used to auto-advance panels (in addition to the buttons).

`scrollType` must be set to `Panels.ScrollType.AUTO` for this property to take effect.

Note that when crank auto-advance is enabled, the panel will scroll slightly before crossing the auto-scroll detent threshold (see [autoAdvanceTicks]({#autoadvanceticks})). This can be used with or without `snapToPanel` depending on the desired effect.


### autoAdvanceTicks
default: 6
{: .prop-default}

When `autoAdvanceWithCrank` is enabled, this property sets the number of auto-advance detents per crank revolution, as used in [`playdate.getCrankTicks`](https://sdk.play.date/inside-playdate/#f-getCrankTicks). The larger the number, the less one must crank to trigger auto-scroll.

### audio

default: nil
{: .prop-default}

A table that defines background audio to play throughout all panels in this sequence.

Properties:
{: .text-delta}

-   `file` (string)
-   `loop` (boolean)
-   `continuePrevious` (boolean)
-   `volume` (number [0.0–1.0])

**Note:** the `file` path should be relative to your comic's [`audioFolder` setting]({{site.baseurl}}/docs/settings#audiofolder).

Examples:
{: .text-delta}

##### Set a looping background song:
{: .no_toc}

```
audio = { file = "sequence1/bgSong", loop = true, volume = 0.6 },
```

The `loop` property is false by default.

##### Continue audio from the previous sequence:
{: .no_toc}

```
audio = { continuePrevious = true },
```

This will give you seamless background audio between sequence transitions.

It's a good idea to define the audio file even when using `continuePrevious`. This will be the file that plays if a user skips directly to this sequence from the chapter menu:

```
audio = { continuePrevious = true, file = "sequence1/bgSong", loop = true },
```

### advanceControl

default: scroll direction (d-pad)
{: .prop-default}

Specifies which control advances to the next sequence from the last panel in this sequence. By default the advance control will be the d-pad direction button pointing in the sequence's scroll direction. Left-to-right scrolling sequence will advance with the right button, a bottom-up sequence will advance with the up button, and so on.

Options:
{: .text-delta}

-   `Panels.Input.UP`
-   `Panels.Input.RIGHT`
-   `Panels.Input.DOWN`
-   `Panels.Input.LEFT`
-   `Panels.Input.A`
-   `Panels.Input.B`

### advanceControlSize

default: Panels.ControlSize.LARGE
{: .prop-default}

Set the size of the advance control indicator.

Options:
{: .text-delta}

-   `Panels.ControlSize.LARGE` (40 × 40)
-   `Panels.ControlSize.MEDIUM` (30 × 30)
-   `Panels.ControlSize.SMALL` (20 × 20)


### showAdvanceControl

default: true
{: .prop-default}

Set this property to `false` to hide the advance control indicator on the last panel of the sequence.

Note that this might be confusing for users unless an indication of the control is included somewhere in the content of the final panel itself.



### advanceControls

default: nil
{: .prop-default}

FOR NONLINEAR COMICS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

A table that defines a list of input controls with corresponding sequence targets (and optional position coordinates). These input/target pairs can be used to create a [nonlinear branching storyline]({{site.baseurl}}/docs/nonlinear-comics.html).

Properties:
{: .text-delta}

-   `input` (Panels.Input)
-   `target` (number [sequence index])
-   `x` (number)
-   `y` (number)

Example:
{: .text-delta}

```lua
advanceControls = {
    { input = Panels.Input.A, target = 2, x = 180, y = 20},
    { input = Panels.Input.B, target = 4, x = 180, y = 180},
},
```



### showAdvanceControls

default: true
{: .prop-default}

FOR NONLINEAR COMICS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Set this property to `false` to hide the advance options in your [nonlinear comic]({{site.baseurl}}/docs/nonlinear-comics.html).

Note that this might be confusing for users unless an indication of the controls is included somewhere in the content of the final panel.


### backgroundColor

default: Panels.Color.WHITE
{: .prop-default}

The background color of the screen outside the bounds of your panels.
Changing this property also inverts the color of the panel borders.

OPTIONS:
{: .text-delta}

-   `Panels.Color.WHITE`
-   `Panels.Color.BLACK`


### endSequence

default: false
{: .prop-default}

FOR NONLINEAR COMICS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Specify that a sequence is a dead end branch in your nonlinear comic. When a user advances past this sequence they will return to the main menu even if there are subsequent sequences listed in the comic data.


### rapidAdvance

default: false
{: .prop-default}

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Normally, Panels will prevent the user from advancing to the next panel until the current panel has finished scrolling. This is helpful in preventing the user from accidentally skipping panels.

When this property is set to `true`, the user can rapidly advance through the panels in this sequence without waiting for the scroll animation to complete.
This is useful when the panels aren't serving a narrative purpose, such as for an in-game manual or credits sequence.


### transitionDuration

default: 500
{: .prop-default}

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

The duration of the panel transition animation in milliseconds. 

### transitionEase 

default: playdate.easingFunctions.inOutQuad
{: .prop-default}

FOR AUTO-SCROLLING SEQUENCES ONLY
{: .text-yellow-300 .fs-2 .lh-0}

The easing function used for the panel transition animation.
You can set this to any of the [Playdate easing functions](https://sdk.play.date/inside-playdate/#f-easingFunctions), or define your own.

### id

default: nil
{: .prop-default}

FOR NONLINEAR COMICS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Set a unique string to represent this sequence.  
You can use this id to link to this sequence from a [target sequence function]({{site.baseurl}}/docs/comic-data/custom-functions.html#target-sequence), a `target` property of an [advance control]({{site.baseurl}}/docs/comic-data/sequences.html#advancecontrols), or a sequence's [`nextSequence`]({{site.baseurl}}/docs/comic-data/sequences.html#nextSequence) property.


### nextSequence

default: nil
{: .prop-default}

FOR NONLINEAR COMICS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Set the [`id`]({{site.baseurl}}/docs/comic-data/sequences.html#id) of the sequence that should come after this one.  
You might need this in your branching comic if your sequences appear out of order in your comicData table.