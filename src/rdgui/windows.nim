#--
# rdgui - a modular GUI toolkit for rapid
# copyright (C) 2019 iLiquid
#--

import rapid/gfx

import control
import event

{.push warning[LockLevel]: off.}

#--
# Basic definitions
#--

type
  WindowManager* = ref object
    rwin: RWindow
    windows*: seq[Window]
  Window* = ref object of Box
    wm*: WindowManager
    # Properties
    fWidth, fHeight: float
    # Callbacks
    onClose*: proc (): bool

#--
# Window manager
#--

proc draw*(wm: WindowManager, ctx: RGfxContext, step: float) =
  for win in wm.windows:
    win.draw(ctx, step)

proc event*(wm: WindowManager, ev: UIEvent) =
  for i in countdown(wm.windows.len - 1, 0):
    wm.windows[i].event(ev)
    if ev.consumed:
      break

proc add*(wm: WindowManager, win: Window) =
  win.rwin = wm.rwin
  wm.windows.add(win)

proc bringToTop*(wm: WindowManager, win: Window) =
  let i = wm.windows.find(win)
  wm.windows.delete(i)
  wm.windows.add(win)

proc initWindowManager*(wm: WindowManager, win: RWindow) =
  wm.rwin = win
  win.registerEvents do (ev: UIEvent):
    wm.event(ev)

proc newWindowManager*(win: RWindow): WindowManager =
  new(result)
  result.initWindowManager(win)

#--
# Window
#--

method width*(win: Window): float = win.fWidth
method height*(win: Window): float = win.fHeight
proc `width=`*(win: Window, width: float) =
  win.fWidth = width
proc `height=`*(win: Window, height: float) =
  win.fHeight = height

proc close*(win: Window) =
  if win.onClose == nil or win.onClose():
    let handle = win.wm.windows.find(win)
    win.wm.windows.delete(handle)

method event*(win: Window, ev: UIEvent) =
  procCall win.Box.event(ev)

proc initWindow*(win: Window, wm: WindowManager, x, y, width, height: float,
                 renderer = BoxChildren) =
  win.initBox(x, y, renderer)
  win.wm = wm
  win.width = width
  win.height = height

proc newWindow*(wm: WindowManager, x, y, width, height: float,
                renderer = BoxChildren): Window =
  new(result)
  result.initWindow(wm, x, y, width, height, renderer)

#--
# Floating window
#--

type
  FloatingWindow* = ref object of Window
    draggable*: bool
    dragging: bool
    prevMousePos: Vec2[float]

method event*(win: FloatingWindow, ev: UIEvent) =
  procCall win.Window.event(ev)
  if ev.consumed: return

  if win.draggable and
      win.mouseInRect(0, 0, win.width, win.height) and
      ev.kind == evMousePress or ev.kind == evMouseRelease:
    win.dragging = ev.kind == evMousePress
    if win.dragging:
      win.wm.bringToTop(win)
      ev.consume()
  elif ev.kind == evMouseMove:
    if win.dragging:
      win.pos += ev.mousePos - win.prevMousePos
    win.prevMousePos = ev.mousePos

renderer(FloatingWindow, Rd, win):
  ctx.begin()
  ctx.rect(0, 0, win.width, win.height)
  ctx.draw()
  ctx.color = gray(0, 64)
  ctx.begin()
  ctx.lrect(0, 0, win.width, win.height)
  ctx.draw(prLineShape)
  ctx.color = gray(255)
  BoxChildren(ctx, step, win)

proc initFloatingWindow*(win: FloatingWindow, wm: WindowManager,
                         x, y, width, height: float,
                         renderer = FloatingWindowRd) =
  win.initWindow(wm, x, y, width, height, renderer)
  win.draggable = true

proc newFloatingWindow*(wm: WindowManager, x, y, width, height: float,
                        renderer = FloatingWindowRd): FloatingWindow =
  new(result)
  result.initFloatingWindow(wm, x, y, width, height, renderer)

{.pop.}
