-- Shared Hyprland configuration.
-- See https://wiki.hypr.land/Configuring/Start/

-- Caelestia (bar, notifications, launcher, lock, wallpaper) is started by its own
-- systemd user service, bound to graphical-session.target.
hl.on("hyprland.start", function()
  hl.exec_cmd("clipse -listen")
end)

hl.config({
  input = {
    resolve_binds_by_sym = true,
    kb_layout = "us,fr",
    kb_options = "grp:shift_caps_toggle",
    follow_mouse = 1,
    repeat_delay = 250,
    repeat_rate = 35,
    focus_on_close = 1,
    touchpad = {
      natural_scroll = true,
      disable_while_typing = true,
      scroll_factor = 0.3,
    },
    sensitivity = 0,
    numlock_by_default = true,
  },
  binds = {
    scroll_event_delay = 0,
  },
  cursor = {
    hotspot_padding = 1,
  },
  general = {
    gaps_workspaces = 20,
    gaps_in = 5,
    gaps_out = 10,
    border_size = 1,
    col = {
      active_border = "rgba(ea76cbe6)",
      inactive_border = "rgba(9ca0b011)",
    },
    layout = "dwindle",
  },
  decoration = {
    rounding = 15,
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
      new_optimizations = true,
      ignore_opacity = true,
      xray = false,
      popups = true,
      input_methods = true,
    },
    shadow = {
      enabled = true,
      range = 15,
      render_power = 4,
      color = "rgba(0,0,0,.5)",
    },
  },
  animations = {
    enabled = true,
  },
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = true,
    focus_on_activate = true,
    vrr = 3,
    animate_manual_resizes = false,
    animate_mouse_windowdragging = false,
    on_focus_under_fullscreen = 2,
    allow_session_lock_restore = true,
    middle_click_paste = false,
    session_lock_xray = true,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
  },
  dwindle = {
    preserve_split = true,
    smart_split = false,
    smart_resizing = true,
  },
  master = {
    new_status = "master",
  },
  -- Horizontal scrolling layout, opted into per workspace with SUPER+CTRL+S.
  scrolling = {
    column_width = 0.5,
    fullscreen_on_one_column = true,
    focus_fit_method = 1,
    follow_focus = true,
  },
  group = {
    col = {
      border_active = "rgba(ea76cbe6)",
      border_inactive = "rgba(9ca0b011)",
      border_locked_active = "rgba(ea76cbe6)",
      border_locked_inactive = "rgba(8839efe6)",
    },
    groupbar = {
      font_family = "JetBrains Mono NF",
      font_size = 15,
      gradients = true,
      gradient_round_only_edges = false,
      gradient_rounding = 5,
      height = 25,
      indicator_height = 0,
      gaps_in = 3,
      gaps_out = 3,
      text_color = "rgb(eff1f5)",
      col = {
        active = "rgba(ea76cbd4)",
        inactive = "rgba(9ca0b0d4)",
        locked_active = "rgba(ea76cbd4)",
        locked_inactive = "rgba(8839efd4)",
      },
    },
  },
  xwayland = {
    force_zero_scaling = true,
  },
  debug = {
    disable_logs = true,
  },
})

local function opacity_rule(match, opacity)
  hl.window_rule({
    match = match,
    opacity = opacity,
  })
end

-- Default opacity for all non-fullscreen windows, per-app rules below override it.
hl.window_rule({ match = { fullscreen = false }, opacity = "0.95 override" })

opacity_rule({ title = ".*YouTube.*" }, "0.95 override 0.95 override")
opacity_rule({ title = ".*Twitch.*" }, "0.95 override 0.95 override")
opacity_rule({ class = "steam_app_975370" }, "0.95 override 0.95 override")
opacity_rule({ class = "gambatte_speedrun.exe" }, "1.0 override 1.0 override")
opacity_rule({ initial_title = ".*Discord Popout.*" }, "0.95 override 0.95 override")
opacity_rule({ initial_title = ".*Picture-in-Picture.*" }, "0.95 override 0.95 override")

-- Wider outer gaps when a workspace holds a single window.
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 20 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 20 })

hl.curve("specialWorkSwitch", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })

hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "emphasizedAccel", style = "slide" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 5, bezier = "standard" })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard" })

hl.animation({
  leaf = "specialWorkspace",
  enabled = true,
  speed = 4,
  bezier = "specialWorkSwitch",
  style = "slidefadevert 15%",
})
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "standard" })

hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ match = { namespace = "hyprpicker" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "wayfreeze" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "caelestia-(border-exclusion|area-picker)" }, no_anim = true })
hl.layer_rule({ match = { namespace = "caelestia-(drawers|background)" }, animation = "fade" })

hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

local mainMod = "SUPER"

hl.bind(mainMod .. " + semicolon", hl.dsp.exec_cmd("/home/desktop/Documents/nix-configuration/mute-discord.sh toggle"))

hl.window_rule({ match = { class = "(clipse)" }, float = true })
hl.window_rule({ match = { class = "(clipse)" }, size = { 622, 652 } })
hl.window_rule({ match = { class = "(clipse)" }, stay_focused = true })

-- Pyprland drop-down terminal, cheatsheet, docs and ChatGPT (hm/pyprland.nix). Floating is declared here too so
-- they survive a `hyprctl reload` that drops pyprland's runtime rules.
hl.window_rule({ match = { class = "kitty-dropterm" }, float = true })
hl.window_rule({ match = { class = "kitty-cheatsheet" }, float = true })
hl.window_rule({ match = { class = "chromium-docs" }, float = true })
hl.window_rule({ match = { class = "chromium-chatgpt" }, float = true })

hl.bind("SUPER + V", hl.dsp.exec_cmd("kitty --class clipse -e clipse"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("pypr toggle term"))
hl.bind(mainMod .. " + ALT + ampersand", hl.dsp.exec_cmd("pypr toggle help"))
hl.bind(mainMod .. " + ALT + eacute", hl.dsp.exec_cmd("pypr toggle docs"))
hl.bind(mainMod .. " + ALT + quotedbl", hl.dsp.exec_cmd("pypr toggle chatgpt"))
hl.bind(mainMod .. " + Z", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + space", hl.dsp.global("caelestia:launcher"))
-- Caelestia has no window switcher, so rofi keeps this one.
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("rofi -show window"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))

-- Switch the active workspace between dwindle and the scrolling layout. The rule
-- merges into the workspace's existing rule (monitor, default) and is dropped on
-- reload, so dwindle stays the default everywhere.
local function toggle_scrolling()
  local ws = hl.get_active_workspace()
  if not ws or ws.special then
    return
  end
  local layout = ws.tiled_layout == "scrolling" and "dwindle" or "scrolling"
  hl.workspace_rule({ workspace = tostring(ws.id), layout = layout })
  -- Workspace rules alone don't re-run layout matching; setting general.layout does.
  hl.config({ general = { layout = "dwindle" } })
end

hl.bind(mainMod .. " + CTRL + S", toggle_scrolling)
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + M", hl.dsp.global("caelestia:dashboard"))
hl.bind(mainMod .. " + B", hl.dsp.global("caelestia:sidebar"))
hl.bind(mainMod .. " + X", hl.dsp.global("caelestia:lock"))
hl.bind("print", hl.dsp.exec_cmd("hyprshot -m region -z --clipboard-only"))
hl.bind("CTRL + print", hl.dsp.exec_cmd("/home/desktop/Documents/nix-configuration/scripts/satty-shot.sh"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -q s 5%-"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -q s +5%"))

-- Directional focus is geometric, which misses off-screen columns of the scrolling
-- layout; there the layout's own focus scrolls them into view instead.
local function focus(direction)
  return function()
    local ws = hl.get_active_workspace()
    local win = hl.get_active_window()
    if ws and ws.tiled_layout == "scrolling" and win and not win.floating then
      hl.dispatch(hl.dsp.layout("focus " .. direction))
    else
      hl.dispatch(hl.dsp.focus({ direction = direction }))
    end
  end
end

hl.bind(mainMod .. " + H", focus("l"))
hl.bind(mainMod .. " + L", focus("r"))
hl.bind(mainMod .. " + K", focus("u"))
hl.bind(mainMod .. " + J", focus("d"))

local workspaceKeys = {
  "ampersand",
  "eacute",
  "quotedbl",
  "apostrophe",
  "parenleft",
  "minus",
  "egrave",
  "underscore",
  "ccedilla",
  "agrave",
}

for workspace, key in ipairs(workspaceKeys) do
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })

hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
