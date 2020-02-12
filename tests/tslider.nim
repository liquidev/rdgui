import base
import rdgui/slider

var
  myWin = wm.newFloatingWindow(32, 32, 128, 128)
  mySlider = newSlider(16, 16, 64, 12,
                       min = 0, max = 100, value = 50, step = 5)

wm.add(myWin)
myWin.add(mySlider)

start()
