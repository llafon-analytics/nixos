-- Shared Hyprland configuration.
-- See https://wiki.hypr.land/Configuring/Start/

-- Caelestia (bar, notifications, launcher, lock, wallpaper) is started by its own
-- systemd user service, bound to graphical-session.target.
hl.on("hyprland.start", function()
  hl.exec_cmd("~/Documents/nix-configuration/hyprsunset.sh")
  hl.exec_cmd("clipse -listen")
end)

hl.config({
  input = {
    resolve_binds_by_sym = true,
    kb_layout = "us,fr",
    kb_options = "grp:shift_caps_toggle",
    follow_mouse = 1,
    touchpad = {
      natural_scroll = false,
    },
    sensitivity = 0,
    numlock_by_default = true,
  },
  general = {
    gaps_in = 2,
    gaps_out = 10,
    border_size = 0,
    col = {
      active_border = {
        colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
        angle = 45,
      },
    },
    layout = "dwindle",
  },
  decoration = {
    rounding = 10,
    active_opacity = 0.87,
    inactive_opacity = 0.75,
    fullscreen_opacity = 1,
    blur = {
      enabled = true,
      size = 2,
      passes = 1,
      new_optimizations = true,
      ignore_opacity = true,
      xray = false,
      popups = true,
    },
    shadow = {
      enabled = true,
      range = 15,
      render_power = 5,
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
    vrr = 1,
  },
  dwindle = {
    preserve_split = true,
  },
  master = {
    new_status = "master",
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

opacity_rule({ title = ".*YouTube.*" }, "0.95 override 0.95 override")
opacity_rule({ title = ".*Twitch.*" }, "0.95 override 0.95 override")
opacity_rule({ class = "steam_app_975370" }, "0.95 override 0.95 override")
opacity_rule({ class = "gambatte_speedrun.exe" }, "1.0 override 1.0 override")
opacity_rule({ initial_title = ".*Discord Popout.*" }, "0.95 override 0.95 override")
opacity_rule({ initial_title = ".*Picture-in-Picture.*" }, "0.95 override 0.95 override")

hl.curve("fluid", {
  type = "bezier",
  points = { { 0.15, 0.85 }, { 0.25, 1 } },
})
hl.curve("snappy", {
  type = "bezier",
  points = { { 0.3, 1 }, { 0.4, 1 } },
})

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "fluid", style = "popin 5%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "snappy" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "snappy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.7, bezier = "snappy", style = "slide" })
hl.animation({
  leaf = "specialWorkspace",
  enabled = true,
  speed = 4,
  bezier = "fluid",
  style = "slidefadevert -35%",
})
hl.animation({ leaf = "layers", enabled = true, speed = 2, bezier = "snappy", style = "popin 70%" })

hl.layer_rule({
  match = { namespace = "selection" },
  no_anim = true,
})

hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

local mainMod = "SUPER"

hl.bind(mainMod .. " + semicolon", hl.dsp.exec_cmd("/home/desktop/Documents/nix-configuration/mute-discord.sh toggle"))

hl.window_rule({ match = { class = "(clipse)" }, float = true })
hl.window_rule({ match = { class = "(clipse)" }, size = { 622, 652 } })
hl.window_rule({ match = { class = "(clipse)" }, stay_focused = true })

hl.bind("SUPER + V", hl.dsp.exec_cmd("kitty --class clipse -e clipse"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Z", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("caelestia shell drawers toggle launcher"))
-- Caelestia has no window switcher, so rofi keeps this one.
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("rofi -show window"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("caelestia shell drawers toggle dashboard"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("caelestia shell drawers toggle sidebar"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("caelestia shell lock lock"))
hl.bind("print", hl.dsp.exec_cmd("hyprshot -m region -z --clipboard-only"))
hl.bind("CTRL + print", hl.dsp.exec_cmd("/home/desktop/Documents/nix-configuration/scripts/satty-shot.sh"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -q s 5%-"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -q s +5%"))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

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
