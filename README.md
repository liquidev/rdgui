# rdgui

rdgui (pronounced _redgui_) is a modular retained GUI toolkit made for
the rapid game engine.

The main idea of rdgui is *reusability without complexity*. Everything rdgui
does is fundamentally based on the idea of windows. You can imagine rdgui as
a windowing system, like X11 or Wayland, but apart from windows, rdgui also does
controls—buttons, textboxes, sliders, etc.

Every component in rdgui has a defined *base implementation*, but only for
handling events—rendering is defined separately in _renderers_, which are
simply procs that render a given control. Whilst event handlers are shared
across all instances of a given control, renderers are not, eg. one button can
use a "basic" renderer, which draws the button outlined, and another can use an
"emphasized" renderer, which draws the button filled. This approach is superior
to using configuration files like CSS, because it's much faster—style lookups
don't have to be done every frame the control is rendered. Instead, everything
is defined once when the control is instantiated, and then the values remain
constant every frame—no need to do expensive string manipulation and table
lookups.

## Installing

rdgui can be installed using nimble:
```sh
$ nimble install rdgui
```
In your nimble file:
```nim
requires "rdgui"
```
