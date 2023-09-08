---
layout: default
title: Troubleshooting
nav_order: 11
---

# Troubleshooting

## Errors

Check the console in the Playdate Simulator for helpful errors or messages.

A build error pointing to your data file usually indicates a formatting error. Make sure all quotes and braces are closed. Check for missing commas in between items.

An error pointing to code within Panels may still be caused by missing info in your data file. Take a look at the portion of the code with the error and see which items are causing the error. Check the section of your data file that provides those items to make sure you're specifying the proper paths, names, values, etc.

If everything looks good, you may have found a bug! Please [report it]({{ site.baseurl }}{% link docs/feedback.md %}#bug-reports) so it can get fixed.

## Unexpected Behavior

Unexpected behavior with no errors is much harder to track down, but is usually caused by incorrectly defined (or even simply misspelled) properties in the data table.

If something isn't working the way you'd expect please report it even if you were able to figure out the problem. Learning how others expect things to work will help me make the framework more intuitive for new users.
