---
layout: default
nav_order: 7
---

# Settings
{: .no_toc}

These settings apply to your entire comic.  
They need to be set _before_ calling `start()` in your `main.lua` file.

Example:
{: .text-delta}

```lua
import 'libraries/panels/Panels'
import 'comicData.lua'

-- change settings before calling start
Panels.Settings.snapToPanels = false
Panels.Settings.useChapterMenu = false

Panels.start(comicData)
```

<br />
<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

---

## Path Settings

### path

default: "libraries/panels/"
{: .prop-default }

The path to the Panels library in your project source.  
There is normally no need to change this unless you need to put Panels in a different location in your project.

### imageFolder

default: "images/"
{: .prop-default }

The path to the folder where images are stored in your project source.
With this set, you can omit the folder name when specifying images in your comic data files.

Usage:
{: .text-delta}

```lua
 -- With the default setting, instead of this:
{ image = 'images/s01/image-1.png' }
-- you'd omit the base folder name to make things slightly cleaner:
{ image = 's01/image-1.png' }
```

If you wish to specify images using the full path, set this property to `""`.

### audioFolder

default: "audio/"
{: .prop-default }

The path to the folder where audio files are stored in your project source.
With this set, you can omit the folder name when specifying audio in your comic data files.

If you wish to specify files using the full path, set this property to `""`.

## Behavior Settings

### resetVarsOnGameOver

default: true
{: .prop-default }

If you're using [global variables]({{site.baseurl}}/docs/comic-data/variables) to track state in your comic, they will automatically reset when the user completes the game by finishing all sequences, or by hitting a sequence marked with the `endSequence` flag.

Set this to `false` to have Panels retain global vars between playthroughs. Variables will still be reset when the user chooses "Start Over" from the main menu.

### maxScrollSpeed

default: 8
{: .prop-default }

Change the maximum speed when scrolling with the d-pad. This does not affect crank scroll speed.

## Panel Settings

### defaultFrame

default: {gap = 50, margin = 8}
{: .prop-default }

This default frame will be used for any panel that does not specify a frame in your [`comicData`]({{site.baseurl}}/docs/comic-data) table.

You can override this frame for any individual panel in your comic by specifying the [`frame`]({{site.baseurl}}/docs/comic-data/panels#frame) property for that panel.

### snapToPanels

default: false
{: .prop-default }

When set to true, scrolling lightly snaps to the edges of panels.

### sequenceTransitionDuration

default: 750
{: .prop-default }

The duration (in milliseconds) of the transition (in and out) between sequences.

### defaultFont

default: playdate.graphics.getSystemFont()
{: .prop-default }

Set the default font for every panel in your comic. This font will be used for any text layers that do not specify a font.

### defaultFontFamily

default: nil
{: .prop-default }

Set the default [font family](https://sdk.play.date/Inside%20Playdate.html#f-graphics.setFontFamily) for your *entire comic*. This font family will be used for any text layers that do not specify a font. This font family will also be used for all menus in your comic. If you want to use a different font for menus set [`menuFontFamily`]({{site.baseurl}}/docs/settings#menufontfamily).

Example:
{: .text-delta }

```lua
local fontFamily = {
	[Panels.Font.NORMAL] = 'fonts/Sasser Slab/Sasser-Slab',
	[Panels.Font.BOLD]   = 'fonts/Sasser Slab/Sasser-Slab-Bold',
	[Panels.Font.ITALIC] = 'fonts/Sasser Slab/Sasser-Slab-Italic',
}

Panels.Settings.defaultFontFamily = fontFamily
```

### borderWidth

default: 2
{: .prop-default }

The thickness (in pixels) of the border drawn around panels.

### borderRadius

default: 2
{: .prop-default }

The corner radius (in pixels) of the border drawn around panels.

### typingSounds

default: Panels.Audio.TypingSound.DEFAULT
{: .prop-default}

Change or disable the sound effect used for the `TYPE_ON` text layer effect.

When using a custom sound the path should be relative to the folder specified in the [`audioFolder`](#audiofolder) setting.

Options:
{: .text-delta}

-   `Panels.Audio.TypingSound.DEFAULT`
-   `Panels.Audio.TypingSound.NONE`
-   path to custom sound file

### maxScrollSpeed

default: 8
{: .prop-default}

Change the maximum scroll speed when the user scrolls with the d-pad. This does not affect crank scrolling.

## Menu Settings

### menuImage

default: "menuImage.png"
{: .prop-default }

The image that will be shown behind the comic's main menu. This should be a full screen (400x240) image.
The system will look for this image in the folder specified in the [`imageFolder`](#imagefolder) setting.

**Note: The bottom 45 pixels of the image will be covered by the menu options.**

### showMenuOnLaunch

default: false
{: .prop-default }

By default, users are taken straight into the comic at the start of the chapter where they last left off.

Change this setting to `true` to instead display the comic's main menu when the game launches.

### skipMenuOnFirstLaunch

default: false
{: .prop-default }

If you choose to display the menu on launch, you can set this to `true` to skip the menu if the user is starting out on the first chapter. This gives you the opportunity to show an intro chapter on first play—skipping the menu until next launch.

### playMenuSounds

default: true
{: .prop-default }

Disable the menu navigation and select sounds.

### menuFontFamily

default: nil
{: .prop-default }

Set the [font family](https://sdk.play.date/Inside%20Playdate.html#f-graphics.setFontFamily) to be used for menus in your comic (main menu, chapter menu & credits).

Example: 
{: .text-delta}

```lua
local fontFamily = {
	[Panels.Font.NORMAL] = 'fonts/Sasser Slab/Sasser-Slab',
	[Panels.Font.BOLD]   = 'fonts/Sasser Slab/Sasser-Slab-Bold',
	[Panels.Font.ITALIC] = 'fonts/Sasser Slab/Sasser-Slab-Italic',
}

Panels.Settings.menuFontFamily = fontFamily
```

### showMainMenuOption

default: false
{: .prop-default}

Add a "Main menu" option to the system menu that takes the user back to your comic's menu screen.  
This can be useful if your comic doesn't display a Chapters menu. Otherwise, the user has no way to restart the comic from the beginning without playing all the way through.


## Chapter Menu Settings

### listLockedSequences

default: true
{: .prop-default }

Set this to `false` to prevent locked sequences from appearing in the chapter menu. By default, locked sequences are displayed in the chapter menu, but are not selectable.

### chapterMenuHeaderImage

default: nil
{: .prop-default }

Set an image (likely your comic's logo) to display at the top of the chapter menu. The image will be centered at the top of the menu.

The system will look for this image in the folder specified in the [`imageFolder`](#imagefolder) setting.

If this option is not set, the chapter menu will display "Chapters" in plain text.

### useChapterMenu

default: true
{: .prop-default }

Set this to `false` if you don't wish to use a chapter menu in your comic. This will remove the "Chapters" items from the system menu and the comic's main menu.

Without the chapter menu, users will be forced to play through your comic in strict linear order (or start over from the beginning).

## Debug Settings

### listUnnamedSequences

default: false
{: .prop-default }

By default, sequences that don't list a [`title`]({{site.baseurl}}/docs/comic-data/sequences#title) property are not listed in the chapter menu.

Set this to `true` to make unnamed sequences selectable. This is useful to more easily skip to a sub-chapter during testing and debugging. Unnamed sequences appear in the chapter menu as "--", therefore it is not recommended to ship your game with this option turned on.

### debugControlsEnabled

default: false
{: .prop-default }

Set this to `true` to enable debugging controls.

Current debugging controls are:

-   press `0` key to unlock all sequences (requires restart)
