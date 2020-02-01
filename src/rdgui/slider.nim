import rapid/gfx

import control
import event

type
  Slider* = ref object of Control
    fWidth, fHeight: float
    fValue, min*, max*, step*: float
    dragging: bool
    onChange*: proc (oldVal, newVal: float)

method width*(slider: Slider): float = slider.fWidth
method height*(slider: Slider): float = slider.fHeight

proc value*(slider: Slider): float =
  result = round(slider.fValue / slider.step) * slider.step

proc `value=`*(slider: Slider, val: float) =
  slider.fValue = val

method onEvent*(slider: Slider, ev: UiEvent) =
  proc updateValue() =
    let
      oldVal = slider.value
      sp = slider.screenPos
      t = clamp((slider.rwin.mouseX - sp.x) / slider.width, 0.0, 1.0)
    slider.value = mix(slider.min, slider.max, t)
    if slider.value != oldVal and slider.onChange != nil:
      slider.onChange(oldVal, slider.value)

  if ev.kind in {evMousePress, evMouseRelease}:
    slider.dragging = slider.mouseInRect(0, 0, slider.width, slider.height) and
                      ev.kind == evMousePress
    if slider.dragging:
      updateValue()
      ev.consume()
  elif ev.kind == evMouseMove:
    if slider.dragging:
      updateValue()
      ev.consume()

Slider.renderer(Rd, slider):
  ctx.begin()
  ctx.color = gray(192)
  ctx.rect(0, slider.height / 2 - 1, slider.width, 2)
  let x = slider.value / (slider.max - slider.min) * slider.width
  ctx.color = gray(128)
  ctx.rect(x, 0, 2, slider.height)
  ctx.color = gray(255)
  ctx.draw()

proc initSlider*(slider: Slider, x, y, width, height: float,
                 min, max: float, value = 0.0, step = 0.01,
                 rend = SliderRd) =
  slider.initControl(x, y, rend)
  slider.fWidth = width
  slider.fHeight = height
  slider.fValue = value
  slider.min = min
  slider.max = max
  slider.step = step

proc newSlider*(x, y, width, height, min, max: float,
                value = 0.0, step = 0.01, rend = SliderRd): Slider =
  new(result)
  result.initSlider(x, y, width, height, min, max, value, step, rend)
