import base
import rdgui/button

var
  myWin = wm.newFloatingWindow(32, 32, 128, 128)
  myButton = newButton(16, 16, 64, 32)

wm.add(myWin)
myWin.add(myButton)

start()
