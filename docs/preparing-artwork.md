---
layout: default
title: Preparing Artwork
nav_order: 4
---

# Preparing Artwork for Panels

Images for your comic should be saved in PNG or GIF format in accordance with the Playdate SDK guidelines.

## Layered Images

Every layer that you wish to separate with parallax scrolling, apply an effect to, or animate will need to be saved as a separate image.

This means most panels in your comic will be made up of several separate images.

Be mindful of which areas of your images are transparent since different parts of the background may show through as the layer moves around on the screen. You may also need to draw areas of panel backgrounds that appear hidden in a static image, but which will be uncovered as foreground layers scroll or animate.

## Sizing & Position

You may be tempted to slice your image layers as small as possible, cutting out unused empty space:

![Cut image to size](assets/images/cut-to-size.png)

You certainly _can_ do this, but this means you'll need to measure the image's position in the frame, and then position the layer in your `comicData` file using the `x` and `y` properties.

Instead, you might simply save the image at full frame (including the emtpy areas as transparency):

![Full frame image](assets/images/cut-full-frame.png)

This keeps your layer position at `x:0`, `y:0` — making it much easier to set up the layers in your data file.

## Organizing Images

Be sure to save all your images in the folder specified in the `imageFolder` setting. Beyond that, there are no organizational structures imposed on you. But a comic with several sequences and many panels will require a lot of layered images.

I recommend creating a new folder for each sequence, and naming each layer with the number of the panel in which it belongs.

<pre>
📁 MyProjectSource
├── 📄 main.lua
├── 📁 audio
├── 📁 images
│    └── 📁 seq01
│    │    └── 📄 1-bg.png
│    │    └── 📄 1-tree.png
│    │    └── 📄 1-ship.png
│    │    └── 📄 2-bg.png
│    │    └── 📄 2-man.png
│    │    └── 📄 2-speechBubble.png
│    └── 📁 seq02
│    └── 📁 seq03
│    └── ...etc
└── 📁 libraries
</pre>
