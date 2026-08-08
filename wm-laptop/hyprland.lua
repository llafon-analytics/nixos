-- Laptop-specific Hyprland settings.

hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1.5,
})
hl.monitor({
  output = "HDMI-A-1",
  mode = "1920x1080@60",
  position = "-1920x0",
  scale = 1,
})

for workspace = 1, 5 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = "eDP-1",
    default = workspace == 1,
  })
end

for workspace = 6, 10 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = "HDMI-A-1",
  })
end

hl.config({
  input = {
    kb_options = "caps:none",
  },
  gestures = {
    workspace_swipe_distance = 700,
    workspace_swipe_cancel_ratio = 0.15,
    workspace_swipe_min_speed_to_force = 5,
    workspace_swipe_direction_lock = true,
    workspace_swipe_direction_lock_threshold = 10,
    workspace_swipe_create_new = true,
  },
})

-- Touchpad gestures (laptop only, no trackpad on desktop).
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({
  fingers = 4,
  direction = "down",
  action = function()
    hl.exec_cmd("systemctl suspend-then-hibernate")
  end,
})
