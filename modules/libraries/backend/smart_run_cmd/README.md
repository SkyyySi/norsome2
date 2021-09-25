smart_run_cmd
===
Smartly run a command.



This [function](https://www.lua.org/pil/5.html) will run a [table](https://www.lua.org/pil/2.5.html) with `awful.spawn`, but only if it is not already running.
Addionally, if strict is true, it will only check if the exact process
passed is running insead of searching for matches in a way like:

    $ echo 'this is some string i think' | grep 'some string'; echo "$?"
	0
	$

You should use that option if you, for example, only want to kill sh but not bash/zsh/fish/etc.
Or if you just like having predictable code.

Possible parameters:

 - `command` (table|string): The command you want to run.
 - `strict` (boolean: false): If true, it will only be checked for the exact command (see above).
 - `with_shell` (boolean: false): Whether to use awful.spawn.with_shell or awful.spawn.
 - `rerun` (boolean: false): If true, awesome will continuously check if the command is still running and re-run it if it isn't.
 - `timeout` (number: 5): The amount of seconds awesome should wait between each check. Requires `rerun` to be true.
 - `verbose` (boolean: false): If true, verbose information will be printed through notifications (useful for debugging).

---

This document is released in the public domain under the [Creative Commons Zero (CC0) license](https://creativecommons.org/publicdomain/zero/1.0/) license