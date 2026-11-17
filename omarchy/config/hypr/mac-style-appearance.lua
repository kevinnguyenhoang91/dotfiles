-- Frost panels while leaving the transparent dismissal area clear.
hl.layer_rule({
  match = { namespace = "^omarchy-keyboard-panel$" },
  blur = true,
  xray = false,
  ignore_alpha = 0.2,
})
