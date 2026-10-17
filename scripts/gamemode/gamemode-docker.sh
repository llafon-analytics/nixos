set -euo pipefail

readonly prefix="gamemode-optimizations:"
readonly state_root="/run/gamemode-docker"
readonly state_dir="$state_root/state"
readonly lock_file="$state_root/lock"

log() {
  printf '%s %s\n' "$prefix" "$*" >&2
}

unit_was_active() {
  [[ "$(<"$state_dir/$1")" == "active" ]]
}

state_is_valid() {
  [[ -f "$state_dir/valid" ]] || return 1
  [[ "$(<"$state_dir/valid")" == "1" ]] || return 1
  [[ -f "$state_dir/docker.service" ]] || return 1
  [[ -f "$state_dir/docker.socket" ]] || return 1
  [[ -f "$state_dir/containers" ]] || return 1
  [[ "$(<"$state_dir/docker.service")" =~ ^(active|inactive)$ ]] || return 1
  [[ "$(<"$state_dir/docker.socket")" =~ ^(active|inactive)$ ]] || return 1
}

stop_docker() {
  local containers_output
  local -a running=()

  if systemctl is-active --quiet docker.service; then
    if ! containers_output="$(docker ps --no-trunc --quiet)"; then
      log "could not list running Docker containers"
      return 1
    fi
    if [[ -n $containers_output ]]; then
      mapfile -t running <<<"$containers_output"
      log "stopping ${#running[@]} running Docker container(s)"
      docker stop --time 15 "${running[@]}"
    fi
  fi

  systemctl stop docker.socket
  systemctl stop docker.service

  if systemctl is-active --quiet docker.service || systemctl is-active --quiet docker.socket; then
    log "docker.service or docker.socket is still active after stop"
    return 1
  fi
  log "Docker daemon and socket stopped"
}

enter() {
  if [[ -e $state_dir ]]; then
    if state_is_valid; then
      log "Docker state already recorded; keeping the initial snapshot"
      stop_docker
      return
    fi
    log "refusing to overwrite an invalid Docker state at $state_dir"
    return 1
  fi

  local service_state="inactive"
  local socket_state="inactive"
  local containers_output
  local temporary_state
  local -a containers=()

  if systemctl is-active --quiet docker.service; then
    service_state="active"
  fi
  if systemctl is-active --quiet docker.socket; then
    socket_state="active"
  fi

  temporary_state="$(mktemp -d "$state_root/.state.XXXXXX")"
  trap 'if [[ -n "${temporary_state:-}" && -d "$temporary_state" ]]; then rm -f "$temporary_state/valid" "$temporary_state/docker.service" "$temporary_state/docker.socket" "$temporary_state/containers"; rmdir "$temporary_state"; fi' RETURN

  if [[ $service_state == "active" ]]; then
    if ! containers_output="$(docker ps --no-trunc --quiet)"; then
      log "could not capture the initial running container set"
      return 1
    fi
    if [[ -n $containers_output ]]; then
      mapfile -t containers <<<"$containers_output"
    fi
  fi

  printf '%s\n' "$service_state" >"$temporary_state/docker.service"
  printf '%s\n' "$socket_state" >"$temporary_state/docker.socket"
  printf '%s\n' "${containers[@]}" >"$temporary_state/containers"
  printf '1\n' >"$temporary_state/valid"
  chmod 0600 "$temporary_state"/*
  mv "$temporary_state" "$state_dir"
  temporary_state=""
  trap - RETURN

  stop_docker
}

wait_for_docker() {
  local _
  for _ in {1..30}; do
    if docker info >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  log "Docker daemon did not become ready within 30 seconds"
  return 1
}

restore_containers() {
  local container
  local expected
  local actual
  local running_output
  local -a running=()
  local -a unexpected=()
  declare -A wanted=()

  while IFS= read -r container; do
    [[ -n $container ]] && wanted["$container"]=1
  done <"$state_dir/containers"

  if ! running_output="$(docker ps --no-trunc --quiet)"; then
    log "could not list containers after Docker restoration"
    return 1
  fi
  if [[ -n $running_output ]]; then
    mapfile -t running <<<"$running_output"
  fi
  for container in "${running[@]}"; do
    if [[ -z ${wanted[$container]+present} ]]; then
      unexpected+=("$container")
    fi
  done

  if ((${#unexpected[@]} > 0)); then
    log "stopping ${#unexpected[@]} container(s) started by restart policies"
    docker stop --time 15 "${unexpected[@]}"
  fi

  for container in "${!wanted[@]}"; do
    if [[ "$(docker inspect --format '{{.State.Running}}' "$container")" != "true" ]]; then
      docker start "$container"
    fi
  done

  expected="$(sort "$state_dir/containers")"
  actual="$(docker ps --no-trunc --quiet | sort)"
  if [[ $actual != "$expected" ]]; then
    log "running container set does not match the recorded state"
    return 1
  fi
}

remove_state() {
  rm -f \
    "$state_dir/valid" \
    "$state_dir/docker.service" \
    "$state_dir/docker.socket" \
    "$state_dir/containers"
  rmdir "$state_dir"
}

exit_mode() {
  if [[ ! -e $state_dir ]]; then
    log "no Docker state to restore"
    return 0
  fi
  if ! state_is_valid; then
    log "invalid Docker state retained at $state_dir"
    return 1
  fi

  if unit_was_active docker.socket; then
    systemctl start docker.socket
  fi
  if unit_was_active docker.service; then
    systemctl start docker.service
    wait_for_docker
    restore_containers
  fi

  if unit_was_active docker.socket; then
    systemctl is-active --quiet docker.socket || {
      log "docker.socket was not restored"
      return 1
    }
  elif systemctl is-active --quiet docker.socket; then
    systemctl stop docker.socket
  fi

  if unit_was_active docker.service; then
    systemctl is-active --quiet docker.service || {
      log "docker.service was not restored"
      return 1
    }
  elif systemctl is-active --quiet docker.service; then
    systemctl stop docker.service
  fi

  remove_state
  log "Docker services and containers restored"
}

install -d -m 0700 -o root -g root "$state_root"
exec 9>"$lock_file"
flock 9

case "${1:-}" in
start)
  enter
  ;;
end)
  exit_mode
  ;;
*)
  log "usage: gamemode-docker {start|end}"
  exit 2
  ;;
esac
