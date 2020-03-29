import rapid/gfx
import rapid/gfx/text

import control

type
  Label* = ref object of Control
    text*: string
    font*: RFont
    fontSize*: int

method width*(label: Label): float =
  let oldFontSize = label.font.height
  label.font.height = label.fontSize
  result = label.font.widthOf(label.text)
  label.font.height = oldFontSize
method height*(label: Label): float =
  label.fontSize.float * label.font.lineSpacing

Label.renderer(Default, label):
  let oldFontSize = label.font.height
  label.font.height = label.fontSize
  ctx.text(label.font, 0, 0, label.text)
  label.font.height = oldFontSize

proc initLabel*(label: Label, x, y: float, text: string, font: RFont,
                fontSize = 14, rend = LabelDefault) =
  label.initControl(x, y, rend)
  label.text = text
  label.font = font
  label.fontSize = fontSize

proc newLabel*(x, y: float, text: string, font: RFont, fontSize = 14): Label =
  new(result)
  result.initLabel(x, y, text, font, fontSize)
