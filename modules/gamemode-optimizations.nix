{ lib, pkgs, inputs, ... }:

let
  caelestiaShell = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;

  dockerHelper = pkgs.writeShellApplication {
    name = "gamemode-docker";
    runtimeInputs = with pkgs; [
      coreutils
      docker
      systemd
      util-linux
    ];
    text = ''
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
          if [[ -n "$containers_output" ]]; then
            mapfile -t running <<<"$containers_output"
            log "stopping ''${#running[@]} running Docker container(s)"
            docker stop --time 15 "''${running[@]}"
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
        if [[ -e "$state_dir" ]]; then
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
        trap 'if [[ -n "''${temporary_state:-}" && -d "$temporary_state" ]]; then rm -f "$temporary_state/valid" "$temporary_state/docker.service" "$temporary_state/docker.socket" "$temporary_state/containers"; rmdir "$temporary_state"; fi' RETURN

        if [[ "$service_state" == "active" ]]; then
          if ! containers_output="$(docker ps --no-trunc --quiet)"; then
            log "could not capture the initial running container set"
            return 1
          fi
          if [[ -n "$containers_output" ]]; then
            mapfile -t containers <<<"$containers_output"
          fi
        fi

        printf '%s\n' "$service_state" >"$temporary_state/docker.service"
        printf '%s\n' "$socket_state" >"$temporary_state/docker.socket"
        printf '%s\n' "''${containers[@]}" >"$temporary_state/containers"
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
          [[ -n "$container" ]] && wanted["$container"]=1
        done <"$state_dir/containers"

        if ! running_output="$(docker ps --no-trunc --quiet)"; then
          log "could not list containers after Docker restoration"
          return 1
        fi
        if [[ -n "$running_output" ]]; then
          mapfile -t running <<<"$running_output"
        fi
        for container in "''${running[@]}"; do
          if [[ -z "''${wanted[$container]+present}" ]]; then
            unexpected+=("$container")
          fi
        done

        if ((''${#unexpected[@]} > 0)); then
          log "stopping ''${#unexpected[@]} container(s) started by restart policies"
          docker stop --time 15 "''${unexpected[@]}"
        fi

        for container in "''${!wanted[@]}"; do
          if [[ "$(docker inspect --format '{{.State.Running}}' "$container")" != "true" ]]; then
            docker start "$container"
          fi
        done

        expected="$(sort "$state_dir/containers")"
        actual="$(docker ps --no-trunc --quiet | sort)"
        if [[ "$actual" != "$expected" ]]; then
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
        if [[ ! -e "$state_dir" ]]; then
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

      case "''${1:-}" in
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
    '';
  };

  userHelper = pkgs.writeShellApplication {
    name = "gamemode-optimizations";
    runtimeInputs = with pkgs; [
      caelestiaShell
      coreutils
      hyprland
      jq
      sudo
      systemd
      util-linux
    ];
    text = ''
      set -euo pipefail

      readonly prefix="gamemode-optimizations:"
      runtime_dir="/run/user/$(id -u)"
      readonly runtime_dir
      readonly syncthing_state="$runtime_dir/gamemode-syncthing.state"
      readonly lock_file="$runtime_dir/gamemode-optimizations.lock"
      readonly docker_helper=${lib.getExe dockerHelper}

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
          [[ -n "$signature" ]] || continue
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
        if [[ -f "$syncthing_state" ]]; then
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
        if [[ ! -f "$syncthing_state" ]]; then
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

      if [[ ! -d "$runtime_dir" ]]; then
        log "runtime directory $runtime_dir is unavailable"
        exit 1
      fi
      exec 9>"$lock_file"
      flock 9

      case "''${1:-}" in
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
    '';
  };
in
{
  programs.gamemode.settings.custom = {
    start = "${lib.getExe userHelper} start";
    end = "${lib.getExe userHelper} end";
    script_timeout = 120;
  };

  security.sudo.extraRules = [
    {
      users = [ "desktop" ];
      commands = [
        {
          command = lib.getExe dockerHelper;
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  systemd.tmpfiles.rules = [
    "d /run/gamemode-docker 0700 root root -"
  ];
}
