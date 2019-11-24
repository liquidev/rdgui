#--
# rdgui - a modular GUI toolkit for rapid
# copyright (C) 2019 iLiquid
#--

import rapid/gfx

import control
import event

type
  Button* = ref object of Control
    fWidth, fHeight: float
    fPressed: bool
    onClick*: proc ()

proc width*(button: Button): float = button.fWidth
proc height*(button: Button): float = button.fHeight
proc `width=`*(button: Button, width: float) =
  button.fWidth = width
proc `height=`*(button: Button, height: float) =
  button.fHeight = height

proc pressed*(button: Button): bool = button.fPressed
proc hasMouse*(button: Button): bool =
  button.mouseInRect(0, 0, button.width, button.height)

method event*(button: Button, ev: UIEvent) =
  if ev.kind in {evMousePress, evMouseRelease}:
    if button.hasMouse and ev.kind == evMousePress:
      ev.consume()
      button.fPressed = true
    elif ev.kind == evMouseRelease:
      if button.pressed:
        ev.consume()
        if button.onClick != nil:
          button.onClick()
      button.fPressed = false

Button.renderer(Rd, button):
  ctx.begin()
  ctx.color = gray(0, 64)
  ctx.lrect(0, 0, button.width, button.height)
  ctx.draw(prLineShape)
  if button.hasMouse or button.pressed:
    ctx.begin()
    ctx.color =
      if button.pressed: gray(0, 64)
      elif button.hasMouse: gray(0, 32)
      else: gray(0, 0)
    ctx.rect(0, 0, button.width, button.height)
    ctx.draw()
  ctx.color = gray(255)

proc initButton*(button: Button, x, y, width, height: float,
                 renderer = ButtonRd) =
  button.initControl(x, y, renderer)
  button.width = width
  button.height = height

proc newButton*(x, y, width, height: float, renderer = ButtonRd): Button =
  new(result)
  result.initButton(x, y, width, height, renderer)
