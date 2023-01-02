---
layout: default
title: Animations
nav_order: 3
parent: Layers
grand_parent: Comic Data
---

# Layer Animations
{: .no_toc}

You can animate a layer's position (x and y) and opacity over a specific amount of time, or based on the panel's scroll position on screen. Use modifiers to control the animation speed, easing, and delay, set scroll or button triggers, and add syncronized sound effeccts.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Examples

### Scroll-based animation

```
{ image = "cloud.png", x = 10, animate = {x = 200, y = -20} },
```

This layer will animate linearly from `x:10, y:0` to `x:200, y:-20` as the panel scrolls across the screen.

Since the animation progress is controlled by the panel scrolling, scrolling in reverse will cause the animation to run backward. Scroll-based animations work with manual or auto-scrolling sequences.

### Time-based animation

```
{ image = "light.png", opacity = 0,
    animate = { opacity = 1, duration = 500, scrollTrigger = 0.5 }
}
```

This layer will animate from fully transparent (`opacity:0`) to fully opaque (`opacity:1`) over 500 milliseconds, starting when the panel reaches the 50% scroll point (`scrollTrigger:0.5`).

### Animation triggered by button press

```
{ image = "door.png",
    animate = {
        x = -100,
        duration = 250,
        ease = playdate.easingFunctions.outQuint,
        trigger = Panels.Input.A
    }
}
```

This layer will animate from the default position (`x:0`) to `x:-100` over 250 milliseconds (with easing), starting when the user presses the A button.

### Synced audio

```
{ image = "door.png",
   animate = {
       x = -100,
       duration = 1000,
       ease = playdate.easingFunctions.outQuint,
       trigger = Panels.Input.A,
       audio = { file = "doorOpen.wav" },
   },
},
```

The `doorOpen.wav` sound effect will start playing when this animation is triggered. Synced sound effects work with both button- and scroll-triggered animations.

## Animatable Properties

### x

default: nil
{: .prop-default}

The horizontal position to animate the layer _to_. The animation will start _from_ the layer's [`x`]({{site.baseurl}}/docs/comic-data/layers#x) property (or `0` if not set).

### y

default: nil
{: .prop-default}

The vertical position to animate the layer _to_. The animation will start _from_ the layer's [`y`]({{site.baseurl}}/docs/comic-data/layers#y) property (or `0` if not set).

### opacity

default: nil
{: .prop-default}

The opacity value to animate the layer _to_. The animation will start _from_ the layer's [`opacity`]({{site.baseurl}}/docs/comic-data/layers#opacity) property (or `1` if not set).

Values range from `0` (fully transparent) to `1` (fully opaque).

## Animation Modifiers

### scrollTrigger

default: 0
{: .prop-default}

Set a scroll value at which a time-based animation will be triggered. Scroll values go from `0` (just before the panel enters the screen) to `1` (just after the panel leaves the screen). A scroll trigger of `0.5` will trigger at the halfway point, which for a full-screen panel will be when the panel is fully centered on screen.

### autoStart

default: false
{: .prop-default}

Set to `true` on a time-based animation to trigger the animation immediately when the panel enters the screen. This is equivalent to setting `scrollTrigger = 0`. Either is acceptable.

### trigger

default: nil
{: .prop-default}

Set a button press as the trigger for a time-based animation.

When using button triggers, be sure to coordinate with the panel's `advanceControl` setting to prevent conflicts and skipped animations. Button triggers work best in auto-scrolling sequences, otherwise a user may scroll past this panel without triggering the animation. You could use this to your advantage to encourage exploraton and discovery of hidden items.

Options:
{: .text-delta}

-   `Panels.Input.UP`
-   `Panels.Input.RIGHT`
-   `Panels.Input.DOWN`
-   `Panels.Input.LEFT`
-   `Panels.Input.A`
-   `Panels.Input.B`

### triggerSequence

default: nil
{: .prop-default}

Set a series of button presses as the trigger for a time-based animation. This can be used to coordinate a series of sequential animations in a single panel.

##### Example:

{: .no_toc}

```
{image = "light.png", opacity = 0,
    animate = { opacity = 1, trigger = Panels.Input.A }},
{image = "door.png",
    animate = { x = -100, triggerSequence = {Panels.Input.A, Panels.Input.B }}
},
```

This panel has two animated layers. The first is triggered by pressing the A button. The second is triggered by pressing the B button _after_ pressing the A button, ensuring it always happens after the first animation.

### delay

default: 0
{: .prop-default}

Set a delay (in milliseconds) between when a time-based animation is triggered and the start of the animation.

### duration

default: 250
{: .prop-default}

The duration (in milliseconds) of a time-based animation.

### ease

default: playdate.easingFunctions.linear
{: .prop-default}

The easing function to use for the layer's animation.

### audio

default: nil
{: .prop-default}

Set a sound effect to be triggered at the same time as the layer animation. A triggered sound will start playing after the layer animation's `delay` times out (if set). You may further delay the sound using the `delay` property of the `audio` table.

Properties:
{: .text-delta}

-   `file` (string)
-   `delay` (integer)
-   `loop` (boolean)

**Note:** the `file` path should be relative to your comic's [`audioFolder` setting]({{site.baseurl}}/docs/settings#audiofolder).
