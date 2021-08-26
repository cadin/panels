# Panels

Build interactive comics for the Playdate console.

![Banner](./assets/images/panelsBanner.gif)

<!-- TODO: add a general description about what Panels is and what it does. -->
<!-- would be nice to have an animation here too as a demonstration -->

## Getting Started

### Requirements

-   [Playdate SDK](https://play.date/dev/)
-   [Playdate Console](https://shop.play.date) (optional)

### Setup

1. Clone this repo into your project, preferrably into a `libraries` folder.
2. Inside your `main.lua` file import Panels.
3. Tell Panels where to find your [`comicData`](#comic-data) table.
4. Start Panels.

#### Example `main.lua` File:

```lua
import "libraries/panels/Panels"
import "comicData.lua"  -- contains your comicData table

Panels.Settings.comicData = comicData
Panels.start()
```

### Project Structure

Panels expects to be placed in a folder called `libraries` within your project source folder.

<pre>
📁 MyProjectSource
├── 📄 main.lua
├── 📁 audio
├── 📁 images
└── 📁 libraries
    └── 📁 <b>panels</b>
</pre>

If you need to place Panels somewhere else in your project, you just need to update the `path` setting before starting Panels:

```
Panels.Settings.path = "frameworks/panels/"
Panels.start()
```

Panels will attempt to load images and audio files from the `images` and `audio` folders respectively. These folders can also be changed by altering [settings](#settings) before calling `start()`.

## Comic Data

### Sequences

### Panels

### Layers

## Settings

## Support

### Troubleshooting

#### Errors

Check the console in the Playdate Simulator for helpful errors or messages.

A build error pointing to your data file usually indicates a formatting error. Make sure all quotes and braces are closed. Check for missing commas in between items.

An error pointing to code within Panels may still be caused by missing info in your data file. Take a look at the portion of the code with the error and see which item(s) is causing the error. Check the section of your data file that provides those items to make sure you're specifying the proper paths, names, values, etc.

If everything looks good, you may have found a bug! Please [report it](#bug-reports) so it can get fixed.

#### Unexpected Behavior

### Feature Requests

### Bug Reports

File bug reports on the [Issues](./issues) page.

Each bug should be listed as a separate issue. Please search first to see if someone else has already filed the bug, and list all steps needed to reproduce the issue in the smallest possible project.

### Contribute

If you would like to contribute a feature or bug fix please contact me first and let me know which issue you want work on. If there isn't yet an issue for your change, go ahead and write one.
