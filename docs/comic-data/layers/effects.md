---
layout: default
nav_order: 3
title: Effects
parent: Layers
grand_parent: Comic Data
---

# Layer Effects
{: .no_toc}

Apply simple animation effects to a single layer.

The currently available effects are: Blink, Shake, and Type On (for text layers).
Each layer can only have a single effect applied. Specify the effect using the `type` property.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Shake

Panels.Effect.SHAKE
{: .prop-required}

Shake a layer randomly in both the x and y directions.

If you want to shake every layer in a panel, use the [panel effect]({{site.baseurl}}/docs/comic-data/panels/#effect) instead.

### strength

default: 2
{: .prop-default}

The shake effect calculates a random x and y offset each frame ranging from `-strength` to `strength`. The magnitude of the shake effect may be affected by the layer's parallax setting.

Example:
{: .text-delta}

```
{ image = "ship.png",
    effect = { type = Panels.Effect.SHAKE, strength = 3 }
},
```

This layer will shake randomly approximately 3 pixels in each frame.

## Blink

Panels.Effect.BLINK
{: .prop-required}

Blink a layer on and off (with no fading).

### durations

required
{: .prop-required}

A table that defines the duration (in milliseconds) for which a layer should be visible (`on`) and invisible (`off`).

### delay

default: 0
{: .prop-default}

Set a delay (in milliseconds) to wait before the blinking effect starts.
The layer will remain **invisible** until the delay times out.

Example:
{: .text-delta}

```
{ image = "beacon.png",
    effect = { type = Panels.Effect.BLINK, durations = {on = 500, off = 200} }
}
```

This layer remains visible for 500 milliseconds, then turns off for 200 milliseconds before repeating.

### reduceFlashingDurations

default: nil
{: .prop-default}

Define an alternate set of blink durations to be used when the user has Playdate's "Reduce Flashing" accessibility setting enabled.

## Type On

Panels.Effect.TYPE_ON
{: .prop-required}

FOR TEXT LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Reveal a line of text character by character.

### duration

default: 500
{: .prop-default}

Set the total length of time (in milliseconds) to take to animate the full line of text.

### delay

default: 0
{: .prop-default}

Set a delay (in milliseconds) to wait before the typing effect starts.
The layer will remain **invisible** until the delay times out.

This property is useful for coordinating multiple lines of animated text.

### scrollTrigger

default: 0
{: .prop-default}

Set a scroll value at which the type-on effect will be triggered. Scroll values go from `0` (just before the panel enters the screen) to `1` (just after the panel leaves the screen). A scroll trigger of `0.5` will trigger at the halfway point, which for a full-screen panel will be when the panel is fully centered on screen.

Example:
{: .text-delta}

```
{ text = "Hello World!",
    effect = { type = Panels.Effect.TYPE_ON, duration = 500 }
},
```

This line of text types on character by character over 500 milliseconds.
