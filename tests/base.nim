import rapid/gfx
import rdgui/[control, windows]

export gfx
export control
export windows

var
  win* = initRWindow()
    .size(800, 600)
    .title("test")
    .open()
  surface* = win.openGfx()
  wm* = newWindowManager(win)

win.onKeyPress do (key: Key, scancode: int, mods: RModKeys):
  if key == keyQ:
    quitGfx()
    quit(0)

proc start*() =
  surface.loop:
    draw ctx, step:
      ctx.clear(gray(128))
      wm.draw(ctx, step)
    update:
      discard
