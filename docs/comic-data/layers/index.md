---
layout: default

nav_order: 3
parent: Comic Data
has_children: true
---

# Layers
{: .no_toc}

A [panel]({{site.baseurl}}/docs/comic-data/panels) contains one or more layers. Each layer can represent **either** a static image, a set of images, an animated image table, or a string of text.

Having elements on separate layers allows Panels to simulate depth by scrolling layers at different speeds according to their parallax value. You can also set specific [animations]({{site.baseurl}}/docs/comic-data/layers/animations) and [effects]({{site.baseurl}}/docs/comic-data/layers/effects) for each layer in a panel.

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

### image

default: nil
{: .prop-default}

The path to an image to display for this layer.

**Note:** this path should be relative to your comic's [`imageFolder` setting]({{site.baseurl}}/docs/settings#imagefolder).

Only specify one of the following per layer: `image`, `images`, `imageTable`, `text`.  
You cannot combine them.

### images

default: nil
{: .prop-default}

A list of paths to images to display for this layer.

A layer with multiple images will switch between them as the panel scrolls across the screen. A layer with two images will switch at the halfway point, three images will switch at 1/3 and 2/3, and so on.

**Note:** these paths should be relative to your comic's [`imageFolder` setting]({{site.baseurl}}/docs/settings#imagefolder).

Only specify one of the following per layer: `image`, `images`, `imageTable`, `text`.  
You cannot combine them.

### stencil 

default: nil
{: .prop-default}

An image to use as the [stencil](https://sdk.play.date/Inside%20Playdate.html#_stencil) for this layer. 

Animations and other layer effects apply to the image layer, but not the stencil. This allows you to have an image layer animate within a mask shape represented by the stencil.

```
{ image = "s01/shadow.png", stencil = "s01/shadowMask.png",
    animate = { y = -116, x = 100 }
},
```
In the example above, the 'shadow' image animates within the area masked by the 'shadowMask' image. 

### advanceControl

default: nil
{: .prop-default}

FOR MULTI-IMAGE LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Specify a button to press to advance through a layer with multiple images. Setting this will override the default behavior of automatically swapping the images as the layer scrolls.

Options:
{: .text-delta}

-   `Panels.Input.UP`
-   `Panels.Input.RIGHT`
-   `Panels.Input.DOWN`
-   `Panels.Input.LEFT`
-   `Panels.Input.A`
-   `Panels.Input.B`

### imageTable

default: nil
{: .prop-default}

A path to an animateable image table to display for this layer.

**Note:** this path should be relative to your comic's [`imageFolder` setting]({{site.baseurl}}/docs/settings#imagefolder).

Only specify one of the following per layer: `image`, `images`, `imageTable`, `text`.  
You cannot combine them.

### scrollTrigger

default: 0
{: .prop-default}

FOR IMAGETABLE LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

The scroll point at which an imageTable layer should start to animate.

Scroll values go from `0` (just before the panel enters the screen) to `1` (just after the panel leaves the screen). A scroll trigger of `0.5` will trigger at the halfway point, which for a full-screen panel will be when the panel is fully centered on screen.

### trigger

default: nil
{: .prop-default}

FOR IMAGETABLE LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Set a button press as the trigger to start an imageTable animation.

If a trigger is set, the imageTable will hold on the first frame until the trigger button is pressed.

### delay

default: 200
{: .prop-default}

FOR IMAGETABLE LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

The amount of time (in milliseconds) each frame of the imageTable is displayed.

### reduceFlashingDelay

default: 200
{: .prop-default}

FOR IMAGETABLE LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

An alternate `delay` setting to be used when the user has Playdate's "Reduce Flashing" accessibility setting enabled.

### startDelay

default: 0
{: .prop-default}

FOR IMAGETABLE LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

The amount of time (in milliseconds) to wait before starting an imageTable animation (delay starts when the panel first appears on screen).

### loop

default: false
{: .prop-default}

FOR IMAGETABLE LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Whether or not to loop the animated imageTable.

### text

default: nil
{: .prop-default}

The string to display in a text layer.

Only specify one of the following per layer: `image`, `images`, `imageTable`, `text`.  
You cannot combine them.

### background

default: nil
{: .prop-default}

FOR TEXT LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Set a solid background color for a text layer. Useful if the text will appear over top of an image or other layer.

Options:
{: .text-delta}

-   `Panels.Color.WHITE`
-   `Panels.Color.BLACK`

### font

default: playdate.getSystemFont()
{: .prop-default}

FOR TEXT LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

The path to a font to use for this text layer.

Note that you can also set a default font to use for all text layers in a panel or all panels in a sequence.


### fontFamily

default: nil
{: .prop-default}

FOR TEXT LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

A table of font paths to use for this text layer. Font paths must be keyed to the constant for the appropriate style variant.

Setting a font family allows text layers to use **bold** and _italic_ formatting with a custom font.

Font variants:
{: .text-delta}
- `Panels.Font.NORMAL`
- `Panels.Font.BOLD`
- `Panels.Font.ITALIC`

Example text layer with font family:
{: .text-delta}

```
{ text = "Normal *Bold*, _Italic_", x = 16, y = 180,
    fontFamily = {
        [Panels.Font.NORMAL] = "fonts/SasserSlab/Sasser-Slab",
        [Panels.Font.BOLD] = "fonts/SasserSlab/Sasser-Slab-Bold",
        [Panels.Font.ITALIC] = "fonts/SasserSlab/Sasser-Slab-Italic"
    },
},
```

Note that you can also set a default font family to use for all text layers in a panel or all panels in a sequence.

### rect

default: nil
{: .prop-default}

FOR TEXT LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

A table to specify the `width` and `height` of the rectangle in which to draw multiline text. Text will be positioned using the layer's normal `x` and `y` properties.

### lineHeightAdjustment

default: 0
{: .prop-default}

FOR TEXT LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Adjust the spacing between lines of text.

### alignment

default: playdate.getSystemFont()
{: .prop-default}

FOR TEXT LAYERS ONLY
{: .text-yellow-300 .fs-2 .lh-0}

Set the alignment for multiline text layers.

Options:
{: .text-delta}

-   `Panels.TextAlignment.LEFT`
-   `Panels.TextAlignment.CENTER`
-   `Panels.TextAlignment.RIGHT`

### parallax

default: 0
{: .prop-default}

The amount of parallax movement to apply to this layer (between `0` and `1`). A layer with a higher value will move more in relation to the frame border. In general, layers closer to the viewer should have a higher parallax value than layers in the distance.

### x

default: 0
{: .prop-default}

The horizontal position of the layer (relative to the top left corner of the panel).

You can avoid setting explicit x and y values for each layer in your comic by cutting images with built-in transparency so they are always positioned at (0,0).

### y

default: 0
{: .prop-default}

The vertical position of the layer (relative to the top left corner of the panel).

You can avoid setting explicit x and y values for each layer in your comic by cutting images with built-in transparency so they are always positioned at (0,0).

### opacity

default: 1
{: .prop-default}

The opacity of the layer.

You can use this to set an initial value to animate from. If your layer will remain at a constant opacity value, then you should consider baking the transparency into the image.

### animate

default: nil
{: .prop-default}

A table describing how to animate the layer. Animate layer position or opacity over a set amount of time or based on panel scroll position.

See [Layer Animations]({{site.baseurl}}/docs/comic-data/layers/animations) for more information.

### effect

default: nil
{: .prop-default}

A table describing the layer effect. Choose from blink, shake, or text type-on effects.

See [Layer Effects]({{site.baseurl}}/docs/comic-data/layers/effects) for more information.


### transitionOffset

default: 0
{: .prop-default}

A layer that lists multiple [`images`]({{site.baseurl}}/docs/comic-data/layers#images) will transition between those images as the panel scrolls. This means a layer with two images will swap them when the panel scroll reaches `0.5` (50%).

Setting `transitionOffset` adjusts the points at which image transitions are triggered. Setting this to `-0.1` would cause the above example to swap images at scroll point `0.4` instead of `0.5`.