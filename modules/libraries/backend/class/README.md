class
===
Create a table with a `new()`-method to create an instance.

With this helper [table](https://www.lua.org/pil/2.5.html), you can more easily perform object-oriented programming.
This is mostly a normal [table](https://www.lua.org/pil/2.5.html), except that it can easily be instantiated
by calling its `new()`-method. To use it, do something like this:

```lua
class = require("class")
animal = class:new({
	species = "cat",
	name = "luna",
	age = 5,
})

-- You can also create subclasses like this:
pet = animal:new({
	owner = "Tom",
	-- All the properties from the `animal`-class will be kept, in addition to
	-- the new method derived from `class`.
})
```

Possible parameters:

 - `object` (table: {}): A table you want to use as you class blueprint.

Further reading:
 - [Programming in Lua, Chapter 16: Object-Oriented Programming](https://lua.org/pil/16.html)
 - [Programming in Lua, Chapter 16.1: Classes](https://lua.org/pil/16.1.html)

---

This document is released into the public domain under the [Creative Commons Zero (CC0) license](https://creativecommons.org/publicdomain/zero/1.0/) license.