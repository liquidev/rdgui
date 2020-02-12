import rapid/gfx/text

import rdgui/textbox

import base

const
  openSansTtf = slurp("data/OpenSans-Regular.ttf")

var
  font = newRFont(openSansTtf, 14)

  myWin = wm.newFloatingWindow(32, 32, 256, 256)
  myTextBox = newTextBox(32, 32, 192, font)

font.lineSpacing = 1.5

wm.add(myWin)
myWin.add(myTextBox)

start()
