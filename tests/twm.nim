import rapid/gfx
import rdgui/windows

var
  win = initRWindow()
    .size(800, 600)
    .title("twm")
    .open()
  surface = win.openGfx()
  wm = newWindowManager(win)
  myWin = wm.newFloatingWindow(32, 32, 128, 128)

win.onKeyPress do (key: Key, scancode: int, mods: RModKeys):
  if key == keyEscape:
    echo "esc"
    win.close()
    quit(0)

wm.add(myWin)

surface.loop:
  draw ctx, step:
    ctx.clear(gray(128))
    wm.draw(ctx, step)
  update step:
    discard
