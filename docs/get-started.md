---
layout: default
nav_order: 2
---

# Get Started

Need help getting started?  
📺 Check out [these video tutorials on YouTube](https://www.youtube.com/playlist?list=PLvk_cJkKCihbN4Q61lopDtSQMbx4vNLvv).

---

## Requirements

-   [Playdate SDK](https://play.date/dev/)
-   [Playdate Console](https://shop.play.date) (optional)

## Setup

### From Template Project

1. Clone the [Panels Project Template](https://github.com/cadin/panels-project-template).
   This is a [Template Repo](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template). Click "Use this template" to create your own fresh repo with all the contents of the project template.
2. The template project includes the Panels framework as a git submodule. Be sure to properly [initialize the submodule](https://www.w3docs.com/snippets/git/how-to-clone-including-submodules.html) when cloning the repo.
3. Start editing table in `myComicData.lua`.

### Manual Setup

1. Clone the [Panels repo](//github.com/cadin/panels) into your project, preferrably into a `libraries/panels` folder.
2. Inside your `main.lua` file import Panels.
3. Create or import your [`comicData`]({{site.baseurl}}/docs/comic-data) table.
4. Start Panels with your `comicData` table as the sole argument.

### Example `main.lua` File:

```lua
import 'libraries/panels/Panels'
local comicData = {
    -- comic data goes here...
}
Panels.start(comicData)
```

## Project Structure

Panels expects to be placed in a folder called `libraries` within your project source folder.

<pre>
📁 MyProjectSource
├── 📄 main.lua
├── 📁 audio
├── 📁 images
└── 📁 libraries
    └── 📁 <b>panels</b>
</pre>

If you need to place Panels somewhere else in your project, you'll need to update the `path` setting before starting Panels:

```
Panels.Settings.path = "frameworks/panels/"
Panels.start(comicData)
```

### Images and Audio

Panels will attempt to load images and audio files from the `images` and `audio` folders respectively. These folders can also be changed by altering [settings]({{site.baseurl}}/docs/settings) before calling `start()`.
