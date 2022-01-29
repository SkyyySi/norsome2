# easing

This is a direct lua port of the easing functions found on [easings.net](https://easings.net), so a huge shoutout to the *awesome* people who made all of these!

## How to use

These are very simple mathmatical functions (as in: simple from a code complexity standpoint), so it's pretty straight forward to use these
*on their own*. These are basically useless, so you'll have to use an animation system or write your own. The one I use can be found [here](https://github.com/SkyyySi/norsome2/tree/master/modules/libraries/backend/animation),
but it remains undocumented for now.

The way you use them is always the same, so I'll only show it on one example:

```lua
local easing = require("modules.libraries.backend.easing")

local x = 0.4634
local y = easing.easeInCirc(x)

print(string.format("x = %s, y = %s", x, y))
```

One important note however: These functions are desinged to take in numbers from 0 to 1. If your numbers are in a different, but known range starting at 0,
you can normalize them like this:

```lua
local easing = require("modules.libraries.backend.easing")

local range_top = 53

local x = 23.57
local y = easing.easeInCirc(x / range_top) * range_top

print(string.format("x = %s, y = %s", x, y))
```
