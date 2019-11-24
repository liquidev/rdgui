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

## Examples

### Setting up

```nim
import rapid/gfx
import rdgui/windows

var
  # we first set up a basic rapid window
  win = initRWindow()
    .size(800, 600)
    .title("rdgui example")
  surface = win.openGfx()
  # then, we create a window manager
  wm = newWindowManager(win)

# then, we draw the UI
surface.loop:
  draw ctx, step:
    ctx.clear(gray(127))
    wm.draw(ctx, step)
```

### Opening windows

```nim
import rdgui/control

# for draggable, floating windows, use ``FloatingWindow``
var myFloatingWindow = wm.newFloatingWindow(32, 32, 256, 256)
# the window must be added to the wm before any controls are added to it!
wm.add(myFloatingWindow)

# to add controls "globally" (without displaying a window), use ``Window``
import rdgui/button
var
  myWindow = wm.newWindow(0, 0)
  myButton = newButton(192, 192, 192, 32)
wm.add(myWindow)
myWindow.add(myButton)
```

### Customizing the rendering

```nim
import rdgui/control
import rdgui/button

# the renderer() template is a shortcut to creating a ControlRenderer
Button.renderer(Rounded, button):
  ctx.begin()
  # (0, 0) is the position of the control—no need to do any annoying offsetting
  ctx.rrect(0, 0, button.width, button.height, 8)
  ctx.draw()

# the above is equivalent to:
proc ButtonRounded*(ctx: RGfxContext, step: float, ctrl: Control) =
  var button = ctrl.Button
  # (drawing code)

# then, we can use the renderer when creating the button
# renderers are always the last parameter of control initializers/constructors
var roundedButton = newButton(32, 32, 192, 32, ButtonRounded)

# renderers can have parameters by wrapping them in closures
proc ButtonColored*(color: RColor): ControlRenderer =
  Button.renderer(ColoredImpl, button):
    ctx.begin()
    ctx.color = color
    ctx.rect(0, 0, button.width, button.height)
    ctx.color = gray(255)
    ctx.draw()
  result = ButtonColoredImpl

var redButton = newButton(32, 64, 192, 32, ButtonColored(rgb(255, 0, 0)))

# renderers can also "inherit" from each other
import rapid/gfx/text
var font = loadRFont("Source Code Pro.ttf", 12)

proc ButtonText*(text: string): ControlRenderer =
  Button.renderer(TextImpl, button):
    # here, we'll inherit from the built-in ButtonRd renderer
    # *Rd renderers are default renderers meant as placeholders
    ctx.ButtonRd(step, button)
    ctx.color = gray(0)
    ctx.text(font, 0, 0, text,
             button.width, button.height, hAlign = taCenter, vAlign = taMiddle)
    ctx.color = gray(255)
```

### Creating your own controls

```nim
# as an example, we'll create a counter which increments when it's clicked
import rdgui/control
import rdgui/event

type
  Counter = ref object of Control
    min, value, max: int

# every control that processes events must have an ``event`` implementation
method event*(counter: Counter, ev: UIEvent) =
  if ev.kind == evMousePress: # trigger an increment on mouse press
    if counter.mouseInRect(0, 0, 64, 64):
      # consume the event to prevent it from propagating further into the
      # control tree
      ev.consume()
      inc(counter.value)
      if counter.value >= max:
        counter.value = min

# all controls should also have a default renderer, usually named ``Default``
Counter.renderer(Default, counter):
  ctx.begin()
  ctx.color = gray(0)
  ctx.lrect(0, 0, 64, 64)
  ctx.draw(prLineShape)
  ctx.text(font, 0, 0, $counter.value,
           64, 64, hAlign = taCenter, vAlign = taMiddle)
  ctx.color = gray(255)

# controls must have an initializer
proc initCounter*(counter: Counter, x, y: float, min, max: int,
                  renderer = CounterDefault) =
  # the first thing the initializer must do is call
  # the parent type's initializer
  counter.initControl(x, y, renderer)
  # then initialize any fields, etc.
  counter.min = min
  counter.value = min
  counter.max = max

# controls should have a constructor
proc newCounter*(x, y: float, min, max: int,
                 renderer = CounterDefault): Counter =
  # the constructor should create a new instance and call the initializer
  new(result)
  result.initCounter(x, y, min, max, renderer)
```
