# Panels

Build interactive comics for the Playdate console.

![Banner](./assets/images/panelsBanner.gif)

<!--<img src="./assets/images/PanelsLoop.gif" width="800px"style="image-rendering: pixelated; margin:0 auto; text-align: center;"/> -->

Provide Panels with a Lua table that describes the sequences in your comic (scroll direction, panel sizes, text, animation and effects) along with your layered graphics. Panels will handle layout, scrolling, animation, and even chapter navigation for you.

Comics built with Panels can support these features:

-   layered, parallax scrolling
-   nested panels
-   sequences with different scroll directions
-   manual (crank) scrolling and auto advancing (panel-by-panel)
-   panel effects like shake and blink
-   animated transitions between sequences
-   animations and transitions within panels based on scroll position
-   animated text layers
-   panels with fully custom render functions

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

The `comicData` table defines your entire comic. A Panels comic is broken down into [Sequences](#sequences), [Panels](#panels), and [Layers](#layers). Your `comicData` table can be defined as one large table in a single file, or it can be assembled from multiple smaller tables. Keeping each sequence in its own file can help keep things organized.

The top level of the `comicData` table is a list of the sequences in your app. Each sequence is represented by its own table.
No other information should appear at the top level of your table.

```lua
comicData = {
    {
        -- data for sequence 1
    }, {
        -- data for sequence 2
    }, {
        -- data for sequence 3
    }
}
```

### Sequences

A comic can contain multiple sequences. A sequence acts like a separate chapter in most instances.

Each sequence can define different settings scroll direction and background color. Sequences can scroll manually (with the crank or arrows), or they can animate between panels automatically by pressing a button.

#### Required Properties

**`axis`**
**`panels`**

#### Optional Properties

`advanceControl`
`backgroundColor`
`direction`
`scroll`
`title`

### Panels

#### Required Properties

**`layers`**

#### Optional Properties

`audio`
`font`
`frame`
`parallaxDistance`

#### Panel Effects

`Panels.Effect.SHAKE_INDIVIDUAL`
`Panels.Effect.SHAKE_UNISON`

### Layers

#### Image Layers

`animate`
`effect`
`image`
`images`
`parallax`
`x` and `y`

#### Text Layers

`background`
`effect`
`text`
`parallax`
`x` and `y`

#### Layer Effects

`Panels.Effect.BLINK`
`Panels.Effect.TYPE_ON`

## Image Format

## Settings

## Support

### Troubleshooting

#### Errors

Check the console in the Playdate Simulator for helpful errors or messages.

A build error pointing to your data file usually indicates a formatting error. Make sure all quotes and braces are closed. Check for missing commas in between items.

An error pointing to code within Panels may still be caused by missing info in your data file. Take a look at the portion of the code with the error and see which items are causing the error. Check the section of your data file that provides those items to make sure you're specifying the proper paths, names, values, etc.

If everything looks good, you may have found a bug! Please [report it](#bug-reports) so it can get fixed.

#### Unexpected Behavior

Unexpected behavior with no errors is much harder to track down, but is usually caused by incorrectly defined (or even simply misspelled) properties in the data table.

If something isn't working the way you'd expect please report it even if you were able to figure out the problem. Learning how others expect things to work will help me make the framework more intuitive for new users.

### Feature Requests

Add feature requests to the [Issues](https://github.com/cadin/panels/issues) page.

Include a description of the general functionality you need, along with your preferred implementation (if you have one). Please search first to see if someone else has already created an issue for your feature. If so, you can add a vote or comment to show your support.

### Bug Reports

File bug reports on the [Issues](https://github.com/cadin/panels/issues) page.

Each bug should be listed as a separate issue. Please search first to see if someone else has already filed the bug, and list all steps needed to reproduce the issue in the smallest possible project.

### Contribute

If you would like to contribute a feature or bug fix please contact me first and let me know which issue you want work on. If there isn't yet an issue for your change, go ahead and write one.

## License

Panels is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

**TLDR:** You can use or this code (or modified versions) to create anything you want, public or private, free or commercial. For attribution, please retain the Panels credit (with URL and QR code) on the Credits page of your game so that others may find their way here.

---

👨🏻‍🦲❤️🛠
