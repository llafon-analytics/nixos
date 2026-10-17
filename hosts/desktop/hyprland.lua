-- Desktop-specific Hyprland settings.

hl.monitor({
  output = "DP-3",
  mode = "1920x1080@144",
  position = "1920x0",
  scale = 1,
  vrr = 3,
})
hl.monitor({
  output = "HDMI-A-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1,
})

for workspace = 1, 5 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = "DP-3",
    default = workspace == 1,
  })
end

for workspace = 6, 10 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = "HDMI-A-1",
  })
end
