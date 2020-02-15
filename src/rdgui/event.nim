#--
# rdgui - a modular GUI toolkit for rapid
# copyright (C) 2019 iLiquid
#--

import unicode

export unicode

import rapid/gfx

type
  UiEventKind* = enum
    evMousePress = "mousePress"
    evMouseRelease = "mouseRelease"
    evMouseMove = "mouseMove"
    evMouseScroll = "mouseScroll"
    evMouseEnter = "mouseEnter"
    evMouseLeave = "mouseLeave"
    evKeyPress = "keyPress"
    evKeyRelease = "keyRelease"
    evKeyChar = "keyChar"
    evKeyRepeat = "keyRepeat"
  UiEvent* = ref object
    fConsumed: bool
    case kind: UIEventKind
    of evMousePress, evMouseRelease:
      mbButton: MouseButton
      mbPos: Vec2[float]
      mbMods: RModKeys
    of evMouseMove:
      mmPos: Vec2[float]
    of evMouseScroll:
      sPos: Vec2[float]
    of evMouseEnter, evMouseLeave:
      discard # sent after an evMouseMove
    of evKeyPress, evKeyRelease, evKeyRepeat:
      kbKey: Key
      kbScancode: int
      kbMods: RModKeys
    of evKeyChar:
      kcRune: Rune
      kcMods: RModKeys
  UiEventHandler* = proc (event: UiEvent)

proc kind*(ev: UiEvent): UiEventKind = ev.kind
proc consumed*(ev: UiEvent): bool = ev.fConsumed
proc unique*(ev: UiEvent): bool = ev.kind in {evMouseEnter, evMouseLeave}
proc sendable*(ev: UiEvent): bool = not ev.unique and not ev.consumed

proc mouseButton*(ev: UiEvent): MouseButton = ev.mbButton
proc mousePos*(ev: UiEvent): Vec2[float] =
  case ev.kind
  of evMousePress, evMouseRelease: ev.mbPos
  of evMouseMove: ev.mmPos
  else: vec2(0.0, 0.0)
proc scrollPos*(ev: UiEvent): Vec2[float] = ev.sPos

proc key*(ev: UiEvent): Key = ev.kbKey
proc scancode*(ev: UiEvent): int = ev.kbScancode
proc rune*(ev: UiEvent): Rune = ev.kcRune

proc modKeys*(ev: UiEvent): RModKeys =
  case ev.kind
  of evMousePress, evMouseRelease: ev.mbMods
  of evKeyPress, evKeyRelease: ev.kbMods
  of evKeyChar: ev.kcMods
  else: {}

proc consume*(ev: UiEvent) =
  ev.fConsumed = true

proc mousePressEvent*(button: MouseButton, pos: Vec2[float],
                      mods: RModKeys): UiEvent =
  UiEvent(kind: evMousePress, mbButton: button, mbPos: pos, mbMods: mods)

proc mouseReleaseEvent*(button: MouseButton, pos: Vec2[float],
                        mods: RModKeys): UiEvent =
  UiEvent(kind: evMouseRelease, mbButton: button, mbPos: pos, mbMods: mods)

proc mouseMoveEvent*(pos: Vec2[float]): UiEvent =
  UiEvent(kind: evMouseMove, mmPos: pos)

proc mouseScrollEvent*(pos: Vec2[float]): UiEvent =
  UiEvent(kind: evMouseScroll, sPos: pos)

proc mouseEnterEvent*(): UiEvent =
  UiEvent(kind: evMouseEnter)

proc mouseLeaveEvent*(): UiEvent =
  UiEvent(kind: evMouseLeave)

proc keyPressEvent*(key: Key, scancode: int, mods: RModKeys): UiEvent =
  UiEvent(kind: evKeyPress, kbKey: key, kbScancode: scancode, kbMods: mods)

proc keyReleaseEvent*(key: Key, scancode: int, mods: RModKeys): UiEvent =
  UiEvent(kind: evKeyRelease, kbKey: key, kbScancode: scancode, kbMods: mods)

proc keyRepeatEvent*(key: Key, scancode: int, mods: RModKeys): UiEvent =
  UiEvent(kind: evKeyRepeat, kbKey: key, kbScancode: scancode, kbMods: mods)

proc keyCharEvent*(rune: Rune, mods: RModKeys): UiEvent =
  UiEvent(kind: evKeyChar, kcRune: rune, kcMods: mods)

proc registerEvents*(win: RWindow, handler: UiEventHandler) =
  win.onMousePress do (button: MouseButton, mods: RModKeys):
    handler(mousePressEvent(button, vec2(win.mouseX, win.mouseY), mods))
  win.onMouseRelease do (button: MouseButton, mods: RModKeys):
    handler(mouseReleaseEvent(button, vec2(win.mouseX, win.mouseY), mods))
  win.onCursorMove do (x, y: float):
    handler(mouseMoveEvent(vec2(x, y)))
  win.onScroll do (x, y: float):
    handler(mouseScrollEvent(vec2(x, y)))

  win.onKeyPress do (key: Key, scancode: int, mods: RModKeys):
    handler(keyPressEvent(key, scancode, mods))
  win.onKeyRelease do (key: Key, scancode: int, mods: RModKeys):
    handler(keyReleaseEvent(key, scancode, mods))
  win.onKeyRepeat do (key: Key, scancode: int, mods: RModKeys):
    handler(keyRepeatEvent(key, scancode, mods))
  win.onChar do (rune: Rune, mods: RModKeys):
    handler(keyCharEvent(rune, mods))

proc `$`*(ev: UiEvent): string =
  result.add($ev.kind & ' ')
  case ev.kind
  of evMousePress, evMouseRelease:
    result.add($ev.mouseButton & " mods=" & $ev.modKeys)
  of evMouseMove:
    result.add($ev.mousePos)
  of evMouseScroll:
    result.add($ev.scrollPos)
  of evMouseEnter, evMouseLeave: discard
  of evKeyPress, evKeyRelease, evKeyRepeat:
    result.add($ev.key & '(' & $ev.scancode & ") mods=" & $ev.modKeys)
  of evKeyChar:
    result.add($ev.rune.int & '(' & $ev.rune & ") mods=" & $ev.modKeys)
