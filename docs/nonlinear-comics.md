---
layout: default
title: "Branching Storylines"
nav_order: 10
---

# Creating Comics with Branching Storylines
{: .no_toc}

Comics made with Panels are normally linear stories, where each sequence is presented in order from start to finish. With a few tweaks you can create a nonlinear, choose-your-own-adventure style comic instead.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Comic Creation

Basic setup & comic creation will the be the same as it is for linear comics. You will of course need to keep in mind the nonlinear nature of your story to ensure that all potential story paths are complete and coherent. 

### Setup
Follow the instructions in the main [Get Started]({{site.baseurl}}/docs/get-started) section to install and import the Panels library. 

### Creation
Follow the normal instructions for creating [artwork]({{site.baseurl}}/docs/preparing-artwork) and [comic data]({{site.baseurl}}/docs/comic-data) files.


## Define Branching Behavior

Add a decision point to a sequence by listing an [`advanceControls`]({{site.baseurl}}/docs/comic-data/sequences.html#advancecontrols) table with an input control and target sequence [`id`]({{site.baseurl}}/docs/comic-data/sequences.html#id) for each option.

These options will be presented to the user on the final panel of the sequence. When the user invokes one of the listed input controls, they will be taken to the corresponding sequence.

Example:
{: .text-delta}

```lua
advanceControls = {
    { input = Panels.Input.A, target = "climb-over" }, -- press A to go to the sequence with id "climb-over"
    { input = Panels.Input.B, target = "go-around" },  -- press B to go to the sequence with id "go-around"
},
```

## Display Choices

The way you present branching story points to the user is entirely up to you. Panels offers two built-in methods for letting the choose their path: choice lists, or advance controls. You can also create your own custom choice display using custom functions.

### Choice Lists

You can define a choice list in any panel in your comic. Providing a `target` for the choice buttons will update the `targetSequence` as the user chooses each option. This will be the next sequence in the comic when the user completes the current sequence.

```lua
choiceList = { 
  buttons = {
    { label = "Open the door", target = "roomInterior" },
    { label = "Leave", target = "street" }
  }
}
```

The buttons in a choice list can also set a [global variable](({{site.baseurl}}/docs/comic-data/variables.html)) in addition to—or instead of—the target sequence.

```lua
choiceList = { 
  buttons = {
    { label = "Pick up the food", var = { key = "hasFood", value = true} },
    { label = "Leave it", var = { key = "hasFood", value = false} }
  }
}
```

See the [Choice Lists]({{site.baseurl}}/docs/comic-data/choice-lists.html) page for more information.

### Advance Controls

When using advance controls, the layout of the choice panel will be defined by the last [panel]({{site.baseurl}}/docs/comic-data/panels.html) in the comic data for your [sequence]({{site.baseurl}}/docs/comic-data/sequences.html).

You most likely want to explain to the user what each choice does. You can do this by adding [text]({{site.baseurl}}/docs/comic-data/layers/#text) to the panel that describes each choice, or by adding [images]({{site.baseurl}}/docs/comic-data/layers/#image) that graphically illustrate the choices.

#### Position Controls
Panels will display controls for the inputs listed in your `advanceControls` table. You can position them over your panel by adding `x` and `y` properties:

```lua
advanceControls = {
    { input = Panels.Input.A, target = "climb-over", x = 180, y = 20},
    { input = Panels.Input.B, target = "go-around",  x = 180, y = 180},
},
```

#### Hide Controls

If you prefer to not display the input controls (perhaps they're already illustrated in your panel graphics), you can hide them by setting the  [`showAdvanceControls`]({{site.baseurl}}/docs/comic-data/sequences.html#showadvancecontrols) property:

```lua
showAdvanceControls = false,
advanceControls = {
    { input = Panels.Input.A, target = "climb-over" },
    { input = Panels.Input.B, target = "go-around" },
},
```


## Custom Functions (Advanced)

If you're using [custom functions]({{site.baseurl}}/docs/comic-data/custom-functions.html) for your final panel, you can specify the sequence target by returning it from a [`targetSequenceFunction`]({{site.baseurl}}/docs/comic-data/panels#targetsequencefunction).

This method would allow you to have a minigame or other interactive scene embedded in your comic where the outcome of the game determines the story path. Fun!

## Chapter Menu

The [chapter menu]({{site.baseurl}}/docs/chapter-menu.html) will by default show _all_ chapters with only the previously-visited chapters being selectable. This works well for linear stories, but in a branching comic it may be confusing for users to see the unvisited, locked chapters appearing out of order. The chapter names might also reveal spoilers and hidden endings.

To address this problem you may choose to hide the locked chapter names by adjusting the [comic settings]({{site.baseurl}}/docs/settings.html):

```
Panels.Settings.listLockedSequences = false
```

With this setting turned off, the chapter menu will only show chapters that the user has already visited.

Alternately, you could disable the chapter menu altogether:

```
Panels.Settings.useChapterMenu = false
```



## Examples

Download the **full example project** for more details:  
**[Panels Nonlinear Story Example](https://github.com/cadin/panels-nonlinear-example)**

This project contains multiple sequences with examples for different use cases:

1. **[Basic Example](https://github.com/cadin/panels-nonlinear-example/blob/main/source/comicData/s01.lua)**  
   Add two branching options to the end of the sequence.
2. **[Anchored Controls](https://github.com/cadin/panels-nonlinear-example/blob/main/source/comicData/s02.lua)**  
   By default, a sequence's advance buttons float above the panels. This example shows how they can be anchored to the scroll position of the last panel.
3. **[Hidden Controls](https://github.com/cadin/panels-nonlinear-example/blob/main/source/comicData/s03.lua)**  
   Hide Panel's built in button graphics in order to display your own text or graphics for the user.
4. **[Directional Controls](https://github.com/cadin/panels-nonlinear-example/blob/main/source/comicData/s04.lua)**  
   Let the user choose a physical direction to move in.
5. **[Dead End](https://github.com/cadin/panels-nonlinear-example/blob/main/source/comicData/s05.lua)**  
   Set a dead end sequence in your comic. Advancing past this sequence will return the user to the menu screen, even if there are sequences listed after it in the `comicData` table.
6. **[Custom Functions](https://github.com/cadin/panels-nonlinear-example/blob/main/source/comicData/s06.lua)**  
   Use a custom render function to draw interactive content (like a mini-game). Use the `targetSequenceFunction` to define a target sequence based on any custom-defined criteria.
7. **[Choice List](https://github.com/cadin/panels-nonlinear-example/blob/main/source/comicData/s07.lua)**  
   Display branching options to the user with a choice list. Each choice button sets a different target sequence to which the comic will progress when the user completes the current sequence.
8. [**Choice List** (with variables)](https://github.com/cadin/panels-nonlinear-example/blob/main/source/comicData/s08.lua)  
   In this example, each button also defines a global variable that gets set when the button is chosen.
9. [**Choice List** (with callback function)](https://github.com/cadin/panels-nonlinear-example/blob/main/source/comicData/s09.lua)  
   An advanced example showing how you can use a callback function to run custom logic whenever the chosen button is changed.