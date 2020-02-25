import base
import rdgui/contextmenu
import rdgui/layout

win.onMousePress do (button: MouseButton, mods: RModKeys):
  if button == mb2:
    var menu = wm.newContextMenu(win.mouseX, win.mouseY, 128)
    menu.addButton(24) do:
      echo "button 1"
    menu.addButton(24) do:
      echo "button 2"
    var sub = wm.newContextMenu(0, 0, 128)
    sub.addButton(24) do:
      echo "sub 1 1"
    sub.addButton(24) do:
      echo "sub 1 2"
    sub.listVertical(padding = 0, spacing = 0)
    menu.addSubMenu(24, sub)
    menu.listVertical(padding = 0, spacing = 0)
    wm.add(menu)

start()
