---
layout: default
title: "Using Panels for Cutscenes"
nav_order: 9
---

# Using Panels for Cutscenes in Other Games
{: .no_toc}

A Panels comic is meant to be a self-contained, standalone game. You can, however, embed your Panels comics into another game to use them as cutscenes, intros, or other story elements.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Setup

Follow the instructions in the main [Get Started]({{site.baseurl}}/docs/get-started) section to install and import the Panels library. 

All the setup instructions apply with one exception:  
**Do not call `Panels.start()` from your game code.**


## Create Your Comics

Follow the normal instructions for creating [artwork]({{site.baseurl}}/docs/preparing-artwork) and [comic data]({{site.baseurl}}/docs/comic-data) files for your cutscenes. Each cutscene must be a complete comic data file that defines 1 or more [sequences]({{site.baseurl}}/docs/comic-data/sequences).


## Play Your Cutscene

At the point in your game when your cutscene should be triggered call `Panels.startCutscene(comicData, callback)`.

Where `comicData` is the full [comic data]({{site.baseurl}}/docs/comic-data) table for the cutscene you wish to play (1 or more sequences), and `callback` is a function in your code that will be called when the cutscene is complete.

While the cutscene is active, continue to call `Panels.update()` every frame from your main [`playdate.update()`](https://sdk.play.date/1.12.3/Inside%20Playdate.html#c-update) function.

## Resume Your Game

When your callback function runs, you can stop calling `Panels.update()` and resume your normal game loop. It's up to your game code to keep track of when a cutscene is running, and to send the appropriate comic data table each time a cutscene starts.

## Branching Cutscenes

If your cutscene has a branching multiple choice ending, you can receive the user's choice in your callback function. Panels will send back the `target` parameter from the `advanceControls` option the user selected.

An example of a branching cutscene ending is shown in the [example project](https://github.com/cadin/panels-cutscene-example).

## Credits

When using Panels in your project, please include the following (or similar) text in your game credits or about screen:

> Cutscenes built with Panels:  
> cadin.github.io/panels


## Gotchas

### Accidental Input
[Button callbacks](https://sdk.play.date/1.12.3/Inside%20Playdate.html#buttonCallbacks) and [input handlers](https://sdk.play.date/1.12.3/Inside%20Playdate.html#_input_handlers) in your game may continue to get called while the cutscene is running. Make sure to clean up input handlers before starting the cutscene, and check if a cutscene is running in any button handler code.

### Never-ending Comics
Remember to stop calling `Panels.update()` when the comic ends (after your callback function gets called). Continuing to call `Panels.update()` will cause the comic to appear stuck on the last panel.

### Never-starting Comics
Neglecting to call `Panels.update()` in your update loop will prevent the comic from appearing. `Panels.startCutscene()` won't draw anything to the screen without also calling `Panels.update()` every frame.

### Crashes
Calling `Panels.update()` before `Panels.startCutscene()` will cause your game to crash.

Likewise, calling `Panels.startCutscene()` with an incomplete or invalid comic data table will also crash.

### Interupting a Cutscene

If your game interrupts a cutscene before it naturally completes (eg. from the system menu), Panels doesn't have a chance to clean up any background audio or input handlers before returning to your game. In that case, you should call `Panels.haltCutscene()` to trigger Panels to do the clean up manually.

## Examples

See below for an abbreviated example of the general flow for starting and stopping a cutscene. 

Download the **full example project** for more details:  
**[Panels Cutscene Example](https://github.com/cadin/panels-cutscene-example)**


```lua
local cutsceneIsPlaying = false

function cutsceneDidFinish()
    cutsceneIsPlaying = false
end

function startCutScene()
    cutsceneIsPlaying = true
    Panels.startCutscene(comicData, cutsceneDidFinish)
end

function playdate.update()
    if cutsceneIsPlaying then
        Panels.update()
    else
        updateGame() -- your game loop
    end
end
```
