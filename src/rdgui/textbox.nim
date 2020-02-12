import unicode

import rapid/gfx/text
import rapid/gfx
import rdgui/control
import rdgui/event

type
  TextBox* = ref object of Control
    fWidth: float
    fText: seq[Rune]
    textString: string
    caret: int
    scroll: float
    blinkTimer: float
    focused*: bool
    next*: TextBox
    font*: RFont
    fontSize*: int
    placeholder*: string
    onInput*: proc ()

method width*(tb: TextBox): float = tb.fWidth
method height*(tb: TextBox): float =
  tb.fontSize.float * tb.font.lineSpacing + 1
proc `width=`*(tb: TextBox, width: float) =
  tb.fWidth = width

proc text*(tb: TextBox): string = tb.textString
proc `text=`*(tb: TextBox, text: string) =
  tb.fText = text.toRunes
  tb.textString = text

proc resetBlink(tb: TextBox) =
  tb.blinkTimer = time()

proc canBackspace(tb: TextBox): bool = tb.caret in 1..tb.fText.len
proc canDelete(tb: TextBox): bool = tb.caret in 0..<tb.fText.len

proc insert(tb: TextBox, r: Rune) =
  tb.fText.insert(r, tb.caret)
  inc(tb.caret)

proc delete(tb: TextBox) =
  if tb.canDelete:
    tb.fText.delete(tb.caret)

proc backspace(tb: TextBox) =
  if tb.canBackspace:
    dec(tb.caret)
    tb.fText.delete(tb.caret)

proc left(tb: TextBox) =
  if tb.canBackspace:
    dec(tb.caret)

proc right(tb: TextBox) =
  if tb.canDelete:
    inc(tb.caret)

proc xScroll*(tb: TextBox): float = tb.scroll

proc caretPos(tb: TextBox): float =
  tb.font.widthOf(tb.fText[0..<tb.caret]) + tb.xScroll

proc scrollToCaret(tb: TextBox) =
  if tb.caretPos < 0:
    tb.scroll -= tb.caretPos
  elif tb.caretPos > tb.width:
    tb.scroll -= tb.caretPos - tb.width

method onEvent*(tb: TextBox, ev: UIEvent) =
  if ev.kind == evMousePress:
    tb.focused = tb.mouseInRect(0, 0, tb.width, tb.height)
    if tb.focused:
      tb.resetBlink()
  elif tb.focused and ev.kind in {evKeyChar, evKeyPress, evKeyRepeat}:
    case ev.kind
    of evKeyChar: tb.insert(ev.rune)
    of evKeyPress, evKeyRepeat:
      case ev.key
      of keyBackspace: tb.backspace()
      of keyDelete: tb.delete()
      of keyLeft: tb.left()
      of keyRight: tb.right()
      else: discard
    else: discard
    tb.textString = $tb.fText
    tb.resetBlink()
    tb.scrollToCaret()
    ev.consume()
    if tb.onInput != nil: tb.onInput()

renderer(TextBox, Rd, tb):
  let oldFontHeight = tb.font.height
  tb.font.height = tb.fontSize

  ctx.color = gray(255)
  ctx.begin()
  ctx.rect(-2, -2, tb.width + 4, tb.height + 4)
  ctx.draw()
  ctx.color = gray(127)
  ctx.begin()
  ctx.lrect(-2, -2, tb.width + 4, tb.height + 4)
  ctx.draw(prLineShape)
  ctx.color = gray(0)
  let pos = tb.screenPos
  ctx.scissor(pos.x, pos.y, tb.width, tb.height):
    ctx.text(tb.font, tb.xScroll, 0, tb.fText)

  if tb.focused and floorMod(time() - tb.blinkTimer, 1.0) < 0.5:
    ctx.begin()
    var x = tb.caretPos
    ctx.line((x, 0.0), (x, tb.fontSize.float * tb.font.lineSpacing))
    ctx.draw(prLineShape)

  ctx.color = gray(255)

  tb.font.height = oldFontHeight

proc initTextBox*(tb: TextBox, x, y, w: float, font: RFont,
                  placeholder, text = "", fontSize = 14, prev: TextBox = nil,
                  rend = TextBoxRd) =
  tb.initControl(x, y, rend)
  tb.width = w
  tb.font = font
  tb.text = text
  tb.placeholder = placeholder
  tb.fontSize = fontSize
  if prev != nil:
    prev.next = tb

proc newTextBox*(x, y, w: float, font: RFont, placeholder, text = "",
                 fontSize = 14, prev: TextBox = nil,
                 rend = TextBoxRd): TextBox =
  result = TextBox()
  result.initTextBox(x, y, w, font, placeholder, text, fontSize, prev, rend)
