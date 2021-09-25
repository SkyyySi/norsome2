# Buttonify

## General

`buttonify` is a library that will automatically color a [widget](https://awesomewm.org/apidoc/libraries/wibox.widget.html) with a `bg` value at it's root (such as any widget contained in [`wibox.container.background`](https://awesomewm.org/apidoc/widget_containers/wibox.container.background.html)) and adjust its colors dynamically depeding on what the mouse cursor above it does (using [signals](https://awesomewm.org/apidoc/widget_containers/wibox.container.background.html#Signals)). In addition to that, it can also add callback [function](https://www.lua.org/pil/2.6.html) based on these actions.

### Possible arguments:

#### Human-readable

 - `widget`: The widget that should be turned into a button. --> [`table`](https://www.lua.org/pil/2.5.html)
 - `button_color_enter` (`beautiful.button_enter`): The color that will be applied when hovering above the button with the mouse cursor. --> [`string`](https://www.lua.org/pil/2.4.html) OR [`gears.color`](https://awesomewm.org/apidoc/theme_related_libraries/gears.color.html)
 - `button_color_leave` (`beautiful.button_normal`): The color that will be applied when leaving the button with the mouse cursor above. Should be the normal/default color. --> [`string`](https://www.lua.org/pil/2.4.html) OR [`gears.color`](https://awesomewm.org/apidoc/theme_related_libraries/gears.color.html)
 - `button_color_press` (`beautiful.button_press`): The color that will be applied when clicking on the button. --> [`string`](https://www.lua.org/pil/2.4.html) OR [`gears.color`](https://awesomewm.org/apidoc/theme_related_libraries/gears.color.html)
 - `button_color_release` (`beautiful.button_release`): The color that will be applied when releasing the mouse button from clicking on the button. --> [`string`](https://www.lua.org/pil/2.4.html) OR [`gears.color`](https://awesomewm.org/apidoc/theme_related_libraries/gears.color.html)
 - `button_callback_enter` (`nil`): The function that will be executed when hovering above the button with the mouse cursor. --> [`function`](https://www.lua.org/pil/2.6.html) OR [`nil`](https://www.lua.org/pil/2.1.html)
 - `button_callback_leave` (`nil`): The function that will be executed when leaving the button with the mouse cursor above. --> [`function`](https://www.lua.org/pil/2.6.html) OR [`nil`](https://www.lua.org/pil/2.1.html)
 - `button_callback_press` (`nil`): The function that will be executed when clicking on the button. --> [`function`](https://www.lua.org/pil/2.6.html) OR [`nil`](https://www.lua.org/pil/2.1.html)
 - `button_callback_release` (`nil`): The function that will be executed when releasing the mouse button from clicking on the button. --> [`function`](https://www.lua.org/pil/2.6.html) OR [`nil`](https://www.lua.org/pil/2.1.html)

#### Code-style format:

```lua
widget: table,
button_color_enter: (string|gears.color) = beautiful.button_enter
button_color_leave: (string|gears.color) = beautiful.button_normal
button_color_press: (string|gears.color) = beautiful.button_press
button_color_release: (string|gears.color) = beautiful.button_release
button_callback_enter: (string|gears.color) = nil
button_callback_leave: (string|gears.color) = nil
button_callback_press: (string|gears.color) = nil
button_callback_release: (string|gears.color) = nil
```

---

This document is released into the public domain under the [Creative Commons Zero (CC0) license](https://creativecommons.org/publicdomain/zero/1.0/) license. No rights reserved.