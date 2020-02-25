## Auto-layout primitives for Boxes.

import glm/vec

import control

proc listHorizontal*(box: Box, padding, spacing: float) =
  var x = padding
  for ctrl in box.children:
    ctrl.pos = vec2(x, padding)
    x += ctrl.width + spacing

proc listVertical*(box: Box, padding, spacing: float) =
  var y = padding
  for ctrl in box.children:
    ctrl.pos = vec2(padding, y)
    y += ctrl.height + spacing
