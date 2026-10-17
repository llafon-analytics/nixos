#!/usr/bin/env bash
# Mute Discord/Discord Canary via PipeWire (auto-detect):
# - Output (lecture): set-volume 0% / 100%
# - Input  (micro)  : set-mute   1 / 0    (option --input-volume pour 0%/100% aussi)
# toggle: coupe si un flux actif (OUT vol>0 ou IN non-muted), sinon remet.
# Deps: hyprctl, pw-cli, jq, wpctl, awk, pgrep

set -u
ACTION="${1:-toggle}"; case "$ACTION" in toggle|on|off) shift || true ;; *) ACTION="toggle" ;; esac

ONLY_PLAYBACK=false; ONLY_CAPTURE=false; VERBOSE=false; DRYRUN=false; INPUT_VOLUME=false
WIN_REGEX=${WIN_REGEX:-"Discord|discord|DiscordCanary|discordcanary"}
APP_REGEX=${APP_REGEX:-"discord|discordcanary|vencord|chromium|electron"}
CACHE_FILE="${MUTE_DISCORD_CACHE:-${XDG_RUNTIME_DIR:-/tmp}/mute-discord.cache}"
CACHE_TTL="${MUTE_DISCORD_CACHE_TTL:-0}"
IDS_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --playback|-p) ONLY_PLAYBACK=true; shift ;;
    --capture|-c)  ONLY_CAPTURE=true;  shift ;;
    --win)         WIN_REGEX="$2"; shift 2 ;;
    --app)         APP_REGEX="$2"; shift 2 ;;
    --ids)         IDS_OVERRIDE="$2"; shift 2 ;;   # ex: "66:OUT,149:IN" ou "66,149" (OUT par défaut)
    --verbose|-v)  VERBOSE=true; shift ;;
    --dry-run)     DRYRUN=true; shift ;;
    --input-volume) INPUT_VOLUME=true; shift ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

need(){ command -v "$1" >/dev/null 2>&1 || { echo "Error: '$1' required." >&2; exit 1; }; }
need pw-cli; need jq; need wpctl; need awk; need hyprctl; need pgrep

get_vol(){ wpctl get-volume "$1" 2>/dev/null | awk '{print $2}'; }  # -> 0.00..1.xx
is_gt_zero(){ awk -v v="$1" 'BEGIN{exit !(v>0.0001)}'; }
is_muted_flag(){ wpctl get-volume "$1" 2>/dev/null | grep -q '\[MUTED\]' && echo 1 || echo 0; }
pw_prop(){
  pw-cli info "$1" 2>/dev/null | awk -F ' = ' -v key="$2" '
    {
      k=$1
      gsub(/^[ \t*]+/, "", k)
      if (k == key) {
        v=$2
        gsub(/^"/, "", v)
        gsub(/"$/, "", v)
        print v
        exit
      }
    }'
}
node_props(){
  pw-cli info "$1" 2>/dev/null | awk -F ' = ' -v id="$1" '
    BEGIN { is_node=0; mc=""; pid=""; an=""; bin=""; nn="" }
    /^[[:space:]]*type: PipeWire:Interface:Node/ { is_node=1 }
    {
      k=$1
      v=$2
      gsub(/^[ \t*]+/, "", k)
      gsub(/^"/, "", v)
      gsub(/"$/, "", v)
      if (k == "media.class") mc=v
      else if (k == "application.process.id") pid=v
      else if (k == "application.name") an=v
      else if (k == "application.process.binary") bin=v
      else if (k == "node.name") nn=v
    }
    END {
      if (is_node && mc ~ /[Aa]udio/) print id "\t" mc "\t" pid "\t" an "\t" bin "\t" nn
    }'
}
collect_descendants(){
  local pid child
  for pid in "$@"; do
    printf '%s\n' "$pid"
    while IFS= read -r child; do
      [[ -n "$child" ]] && collect_descendants "$child"
    done < <(pgrep -P "$pid" 2>/dev/null || true)
  done
}
audio_nodes(){
  local id
  while IFS= read -r id; do
    node_props "$id"
  done < <(pw-cli ls Node 2>/dev/null | awk '/^[[:space:]]*id [0-9]+, type PipeWire:Interface:Node/ {gsub(",", "", $2); print $2}')
}
ids_valid(){
  local id volume
  for id in "$@"; do
    [[ -n "$id" ]] || continue
    volume="$(wpctl get-volume "$id" 2>/dev/null)" || return 1
    [[ "$volume" == Volume:* ]] || return 1
  done
}
load_cache(){
  [[ -r "$CACHE_FILE" ]] || return 1

  local key value cache_pid="" cache_win="" cache_app="" cache_playback="" cache_capture="" cache_ts="" cache_out="" cache_in=""
  while IFS='=' read -r key value; do
    case "$key" in
      pid) cache_pid="$value" ;;
      win_regex) cache_win="$value" ;;
      app_regex) cache_app="$value" ;;
      only_playback) cache_playback="$value" ;;
      only_capture) cache_capture="$value" ;;
      timestamp) cache_ts="$value" ;;
      out_ids) cache_out="$value" ;;
      in_ids) cache_in="$value" ;;
    esac
  done < "$CACHE_FILE"

  [[ -n "$cache_pid" && "$cache_win" == "$WIN_REGEX" && "$cache_app" == "$APP_REGEX" ]] || return 1
  [[ "$cache_playback" == "$ONLY_PLAYBACK" && "$cache_capture" == "$ONLY_CAPTURE" ]] || return 1
  kill -0 "$cache_pid" 2>/dev/null || return 1

  if [[ "$CACHE_TTL" =~ ^[0-9]+$ && "$CACHE_TTL" -gt 0 && "$cache_ts" =~ ^[0-9]+$ ]]; then
    (( $(date +%s) - cache_ts <= CACHE_TTL )) || return 1
  fi

  OUT_IDS=(); IN_IDS=()
  [[ -n "$cache_out" ]] && read -r -a OUT_IDS <<<"$cache_out"
  [[ -n "$cache_in" ]] && read -r -a IN_IDS <<<"$cache_in"
  [[ ${#OUT_IDS[@]} -gt 0 || ${#IN_IDS[@]} -gt 0 ]] || return 1
  ids_valid "${OUT_IDS[@]}" "${IN_IDS[@]}" || return 1

  DETECTION_MODE="cache"
}
save_cache(){
  $DRYRUN && return 0
  ((${#PID_LIST[@]} > 0)) || return 0

  {
    printf 'pid=%s\n' "${PID_LIST[0]}"
    printf 'win_regex=%s\n' "$WIN_REGEX"
    printf 'app_regex=%s\n' "$APP_REGEX"
    printf 'only_playback=%s\n' "$ONLY_PLAYBACK"
    printf 'only_capture=%s\n' "$ONLY_CAPTURE"
    printf 'timestamp=%s\n' "$(date +%s)"
    printf 'out_ids=%s\n' "${OUT_IDS[*]}"
    printf 'in_ids=%s\n' "${IN_IDS[*]}"
  } > "$CACHE_FILE" 2>/dev/null || true
}
detect_targets(){
  local line id mc

  mapfile -t PID_LIST < <(hyprctl clients -j | jq -r --arg re "$WIN_REGEX" '
    map(select((.class // "" | test($re; "i")) or (.title // "" | test($re; "i")))) | .[].pid' | awk 'NF')
  $VERBOSE && { echo "Hyprland regex: /$WIN_REGEX/i"; ((${#PID_LIST[@]})) && echo "PIDs: ${PID_LIST[*]}" || echo "No PID matched, will try regex fallback."; }

  NODES=()
  if ((${#PID_LIST[@]})); then
    mapfile -t PID_LIST < <(collect_descendants "${PID_LIST[@]}" | awk 'NF' | sort -n | uniq)
    mapfile -t NODES < <(audio_nodes | awk -F '\t' -v pids="$(printf ' %s ' "${PID_LIST[@]}")" '
      $3 != "" && index(pids, " " $3 " ") { print $1 "\t" $2 }')
    DETECTION_MODE="pids"
    if [[ ${#NODES[@]} -eq 0 ]]; then
      $VERBOSE && echo "No nodes for PIDs; fallback regex: /$APP_REGEX/i"
      mapfile -t NODES < <(audio_nodes | awk -F '\t' -v appre="$APP_REGEX" '
        BEGIN { IGNORECASE=1 }
        $4 ~ appre || $5 ~ appre || $6 ~ appre { print $1 "\t" $2 }')
      DETECTION_MODE="regex"
    fi
  else
    mapfile -t NODES < <(audio_nodes | awk -F '\t' -v appre="$APP_REGEX" '
      BEGIN { IGNORECASE=1 }
      $4 ~ appre || $5 ~ appre || $6 ~ appre { print $1 "\t" $2 }')
    DETECTION_MODE="regex"
  fi

  for line in "${NODES[@]}"; do
    [[ -z "$line" ]] && continue
    id="${line%%$'\t'*}"; mc="${line#*$'\t'}"
    $ONLY_PLAYBACK && [[ ! "$mc" =~ [Oo]utput ]] && continue
    $ONLY_CAPTURE  && [[ ! "$mc" =~ [Ii]nput  ]] && continue
    if [[ "$mc" =~ [Ii]nput ]]; then IN_IDS+=("$id"); else OUT_IDS+=("$id"); fi
  done
}

OUT_IDS=(); IN_IDS=(); PID_LIST=(); NODES=(); DETECTION_MODE=""; NEED_SAVE_CACHE=false

# 0) --ids bypass
if [[ -n "$IDS_OVERRIDE" ]]; then
  IFS=',' read -r -a raw <<<"$IDS_OVERRIDE"
  for spec in "${raw[@]}"; do
    id="${spec%%:*}"; kind="${spec#*:}"
    if [[ "$spec" == "$id" ]]; then
      mc=$(pw_prop "$id" "media.class")
      if [[ "$mc" =~ [Ii]nput ]]; then IN_IDS+=("$id"); else OUT_IDS+=("$id"); fi
    else
      [[ "${kind^^}" == "IN" ]] && IN_IDS+=("$id") || OUT_IDS+=("$id")
    fi
  done
  DETECTION_MODE="ids"
else
  load_cache || { OUT_IDS=(); IN_IDS=(); detect_targets; NEED_SAVE_CACHE=true; }
fi

# uniq
((${#OUT_IDS[@]})) && mapfile -t OUT_IDS < <(printf '%s\n' "${OUT_IDS[@]}" | awk 'NF' | sort -n | uniq)
((${#IN_IDS[@]}))  && mapfile -t IN_IDS  < <(printf '%s\n' "${IN_IDS[@]}"  | awk 'NF' | sort -n | uniq)

if [[ ${#OUT_IDS[@]} -eq 0 && ${#IN_IDS[@]} -eq 0 ]]; then
  $VERBOSE && echo "No targets (mode=$DETECTION_MODE, win=/$WIN_REGEX/i, app=/$APP_REGEX/i)."
  exit 0
fi

$NEED_SAVE_CACHE && save_cache

$VERBOSE && {
  echo "Targets (mode=$DETECTION_MODE):"
  ((${#OUT_IDS[@]})) && echo "  OUT: ${OUT_IDS[*]}"
  ((${#IN_IDS[@]}))  && echo "  IN : ${IN_IDS[*]}"
}

# 3) Decide toggle
CUT=false
if [[ "$ACTION" == "toggle" ]]; then
  any_active=0
  for id in "${OUT_IDS[@]}"; do v="$(get_vol "$id" || echo "1.00")"; is_gt_zero "$v" && { any_active=1; break; }; done
  if (( ! any_active )); then
    for id in "${IN_IDS[@]}"; do
      if $INPUT_VOLUME; then v="$(get_vol "$id" || echo "1.00")"; is_gt_zero "$v" && { any_active=1; break; }
      else [[ "$(is_muted_flag "$id")" -eq 0 ]] && { any_active=1; break; }
      fi
    done
  fi
  $VERBOSE && echo "Toggle => $([[ $any_active -eq 1 ]] && echo 'cut' || echo 'restore')."
  (( any_active )) && CUT=true || CUT=false
fi

# 4) Apply (always run both loops, one cannot block the other)
apply_cmd(){ $VERBOSE && echo "CMD: $*"; $DRYRUN || "$@"; }

if [[ "$ACTION" == "on" || ( "$ACTION" == "toggle" && "$CUT" = true ) ]]; then
  for id in "${OUT_IDS[@]}"; do apply_cmd wpctl set-volume "$id" 0%; done
  for id in "${IN_IDS[@]}";  do
    if $INPUT_VOLUME; then apply_cmd wpctl set-volume "$id" 0%
    else                   apply_cmd wpctl set-mute   "$id" 1
    fi
  done
else # off OR toggle restore
  for id in "${OUT_IDS[@]}"; do apply_cmd wpctl set-volume "$id" 100%; done
  for id in "${IN_IDS[@]}";  do
    if $INPUT_VOLUME; then apply_cmd wpctl set-volume "$id" 100%
    else                   apply_cmd wpctl set-mute   "$id" 0
    fi
  done
fi
