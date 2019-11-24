import rapid/gfx
import rdgui/windows

var
  win = initRWindow()
    .size(800, 600)
    .title("twm")
    .open()
  surface = win.openGfx()

win.onKeyPress do (key: Key, scancode: int, mods: RModKeys):
  if key == keyQ:
    quitGfx()
    quit(0)

var wm = newWindowManager(win)

for i in 1..4:
  wm.add(wm.newFloatingWindow(i.float * 32, i.float * 32, 128, 128))

surface.loop:
  draw ctx, step:
    ctx.clear(gray(128))
    wm.draw(ctx, step)
  update step:
    discard
