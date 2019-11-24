#--
# rdgui - a modular GUI toolkit for rapid
# copyright (C) 2019 iLiquid
#--

import rapid/gfx

import event

#--
# Control
#--

type
  ControlRenderer* = proc (ctx: RGfxContext, step: float, ctrl: Control)
  Control* = ref object of RootObj
    rwin*: RWindow
    parent: Control
    pos*: Vec2[float]
    renderer*: ControlRenderer

method width*(ctrl: Control): float {.base.} = 0
method height*(ctrl: Control): float {.base.} = 0

proc screenPos*(ctrl: Control): Vec2[float] =
  if ctrl.parent.isNil: ctrl.pos
  else: ctrl.parent.screenPos + ctrl.pos

proc mouseInRect*(ctrl: Control, x, y, w, h: float): bool =
  let
    a = ctrl.screenPos + vec2(x, y)
    b = ctrl.screenPos + vec2(x + w, y + h)
  result = ctrl.rwin.mouseX >= a.x and ctrl.rwin.mouseY >= a.y and
           ctrl.rwin.mouseX < b.x and ctrl.rwin.mouseY < b.y

proc mouseInCircle*(ctrl: Control, x, y, r: float): bool =
  let
    sp = ctrl.screenPos
    dx = (x + sp.x) - ctrl.rwin.mouseX
    dy = (y + sp.y) - ctrl.rwin.mouseY
  result = dx * dx + dy * dy <= r * r

proc contain*(parent: Control, child: Control) =
  child.rwin = parent.rwin
  child.parent = parent

proc initControl*(ctrl: Control, x, y: float, rend: ControlRenderer) =
  ctrl.pos = vec2(x, y)
  ctrl.renderer = rend

template renderer*(T, name, varName, body) {.dirty.} =
  ## Shortcut for declaring a ControlRenderer.
  proc `T name`*(ctx: RGfxContext, step: float, ctrl: Control) =
    var varName = ctrl.T
    body

proc draw*(ctrl: Control, ctx: RGfxContext, step: float) =
  # don't use `ctx.transform()` here to avoid unnecessary matrix copies
  ctx.translate(ctrl.pos.x, ctrl.pos.y)
  ctrl.renderer(ctx, step, ctrl)
  ctx.translate(-ctrl.pos.x, -ctrl.pos.y)

method event*(ctrl: Control, ev: UIEvent) {.base.} =
  discard

#--
# Box
#--

type
  Box* = ref object of Control
    children*: seq[Control]

method width*(box: Box): float =
  for child in box.children:
    let realWidth = child.pos.x + child.width
    if realWidth > result:
      result = realWidth

method height*(box: Box): float =
  for child in box.children:
    let realHeight = child.pos.y + child.height
    if realHeight > result:
      result = realHeight

renderer(Box, Children, box):
  for child in box.children:
    child.draw(ctx, step)

method event*(box: Box, ev: UIEvent) =
  for i in countdown(box.children.len - 1, 0):
    box.children[i].event(ev)
    if ev.consumed:
      break

proc initBox*(box: Box, x, y: float, rend = BoxChildren) =
  box.initControl(x, y, rend)

proc newBox*(x, y: float, rend = BoxChildren): Box =
  result = Box()
  result.initBox(x, y, rend)

proc add*(box: Box, child: Control): Box {.discardable.} =
  result = box
  result.children.add(child)
  result.contain(child)

proc bringToTop*(box: Box, child: Control) =
  let i = box.children.find(child)
  box.children.delete(i)
  box.children.add(child)
