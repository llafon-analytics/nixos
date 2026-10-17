#!/usr/bin/env bash
set -euo pipefail

readonly prefix="gamemode-optimizations:"
runtime_dir="/run/user/$(id -u)"
readonly runtime_dir
readonly syncthing_state="$runtime_dir/gamemode-syncthing.state"
readonly lock_file="$runtime_dir/gamemode-optimizations.lock"
# GAMEMODE_DOCKER_HELPER is set by the Nix wrapper (modules/nixos/gaming/gamemode-optimizations.nix).
readonly docker_helper="$GAMEMODE_DOCKER_HELPER"

log() {
  printf '%s %s\n' "$prefix" "$*" >&2
}

find_hyprland_instance() {
  local instances_json
  local signature

  if ! instances_json="$(XDG_RUNTIME_DIR="$runtime_dir" hyprctl -j instances 2>/dev/null)"; then
    return 1
  fi
  while IFS= read -r signature; do
    [[ -n $signature ]] || continue
    if XDG_RUNTIME_DIR="$runtime_dir" HYPRLAND_INSTANCE_SIGNATURE="$signature" \
      hyprctl --instance "$signature" -j monitors >/dev/null 2>&1; then
      printf '%s\n' "$signature"
      return 0
    fi
  done < <(jq -r 'sort_by(.time) | reverse | .[].instance' <<<"$instances_json")
  return 1
}

apply_hyprland_profile() {
  local signature
  if ! signature="$(find_hyprland_instance)"; then
    log "no valid Hyprland instance found; continuing"
    return 0
  fi

  XDG_RUNTIME_DIR="$runtime_dir" HYPRLAND_INSTANCE_SIGNATURE="$signature" \
    hyprctl --instance "$signature" eval 'hl.config({ animations = { enabled = false }, general = { border_size = 0 }, decoration = { rounding = 0, blur = { enabled = false }, shadow = { enabled = false } }, debug = { disable_logs = true } }); hl.window_rule({ match = { class = ".*" }, opacity = "1.0 override 1.0 override" })'
  log "lightweight Hyprland profile applied to $signature"
}

restore_hyprland_profile() {
  local signature
  if ! signature="$(find_hyprland_instance)"; then
    log "no valid Hyprland instance found for reload; continuing"
    return 0
  fi

  XDG_RUNTIME_DIR="$runtime_dir" HYPRLAND_INSTANCE_SIGNATURE="$signature" \
    hyprctl --instance "$signature" reload
  log "declarative Hyprland configuration reloaded on $signature"
}

inhibit_idle() {
  if XDG_RUNTIME_DIR="$runtime_dir" caelestia-shell ipc call idleInhibitor enable; then
    log "idle inhibited for the game session"
  else
    log "failed to inhibit idle via caelestia-shell"
    return 1
  fi
}

uninhibit_idle() {
  if XDG_RUNTIME_DIR="$runtime_dir" caelestia-shell ipc call idleInhibitor disable; then
    log "idle inhibitor released"
  else
    log "failed to release idle inhibitor via caelestia-shell"
    return 1
  fi
}

suspend_syncthing() {
  local previous_state
  local temporary_state
  if [[ -f $syncthing_state ]]; then
    previous_state="$(<"$syncthing_state")"
    case "$previous_state" in
    active)
      log "Syncthing state already recorded; keeping the initial snapshot"
      if systemctl --user is-active --quiet syncthing.service; then
        systemctl --user stop syncthing.service
      fi
      return 0
      ;;
    inactive)
      log "Syncthing state already recorded; keeping the initial snapshot"
      return 0
      ;;
    *)
      log "invalid Syncthing state retained at $syncthing_state"
      return 1
      ;;
    esac
  fi

  temporary_state="$(mktemp "$runtime_dir/.gamemode-syncthing.XXXXXX")"
  if systemctl --user is-active --quiet syncthing.service; then
    printf 'active\n' >"$temporary_state"
    mv "$temporary_state" "$syncthing_state"
    systemctl --user stop syncthing.service
    log "syncthing.service stopped"
  else
    printf 'inactive\n' >"$temporary_state"
    mv "$temporary_state" "$syncthing_state"
    log "syncthing.service was already inactive"
  fi
}

restore_syncthing() {
  local previous_state
  if [[ ! -f $syncthing_state ]]; then
    log "no Syncthing state to restore"
    return 0
  fi

  previous_state="$(<"$syncthing_state")"
  case "$previous_state" in
  active)
    systemctl --user start syncthing.service
    systemctl --user is-active --quiet syncthing.service
    ;;
  inactive)
    ;;
  *)
    log "invalid Syncthing state retained at $syncthing_state"
    return 0
    ;;
  esac
  rm -f "$syncthing_state"
  log "Syncthing state restored ($previous_state)"
}

run_start() {
  local status=0
  apply_hyprland_profile || status=1
  inhibit_idle || status=1
  suspend_syncthing || status=1
  sudo --non-interactive "$docker_helper" start || status=1
  return "$status"
}

run_end() {
  local status=0
  restore_hyprland_profile || status=1
  uninhibit_idle || status=1
  restore_syncthing || status=1
  sudo --non-interactive "$docker_helper" end || status=1
  return "$status"
}

if [[ ! -d $runtime_dir ]]; then
  log "runtime directory $runtime_dir is unavailable"
  exit 1
fi
exec 9>"$lock_file"
flock 9

case "${1:-}" in
start)
  run_start
  ;;
end)
  run_end
  ;;
*)
  log "usage: gamemode-optimizations {start|end}"
  exit 2
  ;;
esac
