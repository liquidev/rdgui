#--
# rdgui - a modular GUI toolkit for rapid
# copyright (C) 2019 iLiquid
#--

import unicode

export unicode

import rapid/gfx

type
  UIEventKind* = enum
    evMousePress = "mousePress"
    evMouseRelease = "mouseRelease"
    evMouseMove = "mouseMove"
    evMouseScroll = "mouseScroll"
    evKeyPress = "keyPress"
    evKeyRelease = "keyRelease"
    evKeyChar = "keyChar"
  UIEvent* = ref object
    fConsumed: bool
    case kind: UIEventKind
    of evMousePress, evMouseRelease:
      mbButton: MouseButton
      mbMods: RModKeys
    of evMouseMove:
      mmPos: Vec2[float]
    of evMouseScroll:
      sPos: Vec2[float]
    of evKeyPress, evKeyRelease:
      kbKey: Key
      kbScancode: int
      kbMods: RModKeys
    of evKeyChar:
      kcRune: Rune
      kcMods: RModKeys
  UIEventHandler* = proc (event: UIEvent)

proc kind*(ev: UIEvent): UIEventKind = ev.kind
proc consumed*(ev: UIEvent): bool = ev.fConsumed

proc mouseButton*(ev: UIEvent): MouseButton = ev.mbButton
proc mousePos*(ev: UIEvent): Vec2[float] = ev.mmPos
proc scrollPos*(ev: UIEvent): Vec2[float] = ev.sPos

proc key*(ev: UIEvent): Key = ev.kbKey
proc scancode*(ev: UIEvent): int = ev.kbScancode
proc rune*(ev: UIEvent): Rune = ev.kcRune

proc modKeys*(ev: UIEvent): RModKeys =
  case ev.kind
  of evMousePress, evMouseRelease: ev.mbMods
  of evKeyPress, evKeyRelease: ev.kbMods
  of evKeyChar: ev.kcMods
  else: {}

proc consume*(ev: UIEvent) =
  ev.fConsumed = true

proc registerEvents*(win: RWindow, handler: UIEventHandler) =
  win.onMousePress do (button: MouseButton, mods: RModKeys):
    handler(UIEvent(kind: evMousePress, mbButton: button, mbMods: mods))
  win.onMouseRelease do (button: MouseButton, mods: RModKeys):
    handler(UIEvent(kind: evMouseRelease, mbButton: button, mbMods: mods))
  win.onCursorMove do (x, y: float):
    handler(UIEvent(kind: evMouseMove, mmPos: vec2(x, y)))
  win.onScroll do (x, y: float):
    handler(UIEvent(kind: evMouseScroll, sPos: vec2(x, y)))

  win.onKeyPress do (key: Key, scancode: int, mods: RModKeys):
    handler(UIEvent(kind: evKeyPress, kbKey: key, kbScancode: scancode,
                    kbMods: mods))
  win.onKeyRelease do (key: Key, scancode: int, mods: RModKeys):
    handler(UIEvent(kind: evKeyRelease, kbKey: key, kbScancode: scancode,
                    kbMods: mods))
  win.onChar do (rune: Rune, mods: RModKeys):
    handler(UIEvent(kind: evKeyChar, kcRune: rune, kcMods: mods))

proc `$`*(ev: UIEvent): string =
  result.add($ev.kind & ' ')
  case ev.kind
  of evMousePress, evMouseRelease:
    result.add($ev.mouseButton & " mods=" & $ev.modKeys)
  of evMouseMove:
    result.add($ev.mousePos)
  of evMouseScroll:
    result.add($ev.scrollPos)
  of evKeyPress, evKeyRelease:
    result.add($ev.key & '(' & $ev.scancode & ") mods=" & $ev.modKeys)
  of evKeyChar:
    result.add($ev.rune.int & '(' & $ev.rune & ") mods=" & $ev.modKeys)
