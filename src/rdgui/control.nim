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
    visible*: bool
    lastMousePos: Vec2[float]
    containProc: proc ()

method width*(ctrl: Control): float {.base.} = 0
method height*(ctrl: Control): float {.base.} = 0

proc screenPos*(ctrl: Control): Vec2[float] =
  if ctrl.parent == nil: ctrl.pos
  else: ctrl.parent.screenPos + ctrl.pos

proc mousePos*(ctrl: Control): Vec2[float] =
  let mouse = vec2(ctrl.rwin.mouseX, ctrl.rwin.mouseY)
  result = mouse - ctrl.screenPos

proc pointInRect*(ctrl: Control, point: Vec2[float], x, y, w, h: float): bool =
  let
    a = ctrl.screenPos + vec2(x, y)
    b = ctrl.screenPos + vec2(x + w, y + h)
  result = point.x >= a.x and point.y >= a.y and
           point.x < b.x and point.y < b.y

proc mouseInRect*(ctrl: Control, x, y, w, h: float): bool =
  ctrl.pointInRect(vec2(ctrl.rwin.mouseX, ctrl.rwin.mouseY), x, y, w, h)

proc mouseInCircle*(ctrl: Control, x, y, r: float): bool =
  let
    sp = ctrl.screenPos
    dx = (x + sp.x) - ctrl.rwin.mouseX
    dy = (y + sp.y) - ctrl.rwin.mouseY
  result = dx * dx + dy * dy <= r * r

proc onContain*(ctrl: Control, callback: proc ()) =
  ## Specify a proc to call when the control is contained within another
  ## control. If the control creates any controls on init, this is where you
  ## should create them.
  ctrl.containProc = callback

proc contain*(parent: Control, child: Control) =
  child.rwin = parent.rwin
  child.parent = parent
  if child.containProc != nil: child.containProc()

proc initControl*(ctrl: Control, x, y: float, rend: ControlRenderer) =
  ctrl.pos = vec2(x, y)
  ctrl.renderer = rend
  ctrl.visible = true

template renderer*(T, name, varName, body) {.dirty.} =
  ## Shortcut for declaring a ControlRenderer.
  let `T name`*: ControlRenderer =
    proc (ctx: RGfxContext, step: float, ctrl: Control) =
      var varName = ctrl.T
      body

template prenderer*(T, name, varName, body) {.dirty.} =
  ## Shortcur for declaring a private ControlRenderer.
  let `T name`: ControlRenderer =
    proc (ctx: RGfxContext, step: float, ctrl: Control) =
      var varName = ctrl.T
      body

proc draw*(ctrl: Control, ctx: RGfxContext, step: float) =
  if ctrl.visible:
    # don't use `ctx.transform()` here to avoid unnecessary matrix copies
    ctx.translate(ctrl.pos.x, ctrl.pos.y)
    ctrl.renderer(ctx, step, ctrl)
    ctx.translate(-ctrl.pos.x, -ctrl.pos.y)

method onEvent*(ctrl: Control, ev: UIEvent) {.base.} =
  discard

proc event*(ctrl: Control, ev: UIEvent) =
  ## Send an event to a control.
  if ctrl.visible and ev.sendable:
    ctrl.onEvent(ev)
    if ev.kind == evMouseMove:
      let
        (x, y, w, h) = (0.0, 0.0, ctrl.width, ctrl.height)
        hadMouse = ctrl.pointInRect(ctrl.lastMousePos, x, y, w, h)
        hasMouse = ctrl.pointInRect(ev.mousePos, x, y, w, h)
      if not hadMouse and hasMouse:
        ctrl.onEvent(mouseEnterEvent())
      elif hadMouse and not hasMouse:
        ctrl.onEvent(mouseLeaveEvent())
      ctrl.lastMousePos = ev.mousePos

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

Box.renderer(Children, box):
  for child in box.children:
    child.draw(ctx, step)

method onEvent*(box: Box, ev: UIEvent) =
  for i in countdown(box.children.len - 1, 0):
    box.children[i].event(ev)
    echo ev.consumed
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
