# Rebuild

## With `nh` (recommended)

`nh` knows where the repository lives (`~/Documents/nix-configuration`) and picks the configuration
from the hostname. It shows the build tree and the package diff before activation.

| Command | Effect |
|---|---|
| `nh os switch` | apply now and update the bootloader |
| `nh os test` | apply until the next reboot |
| `nh os boot` | apply on next boot |
| `dupdate` / `lupdate` | `nh os switch --hostname desktop` (resp. `laptop`) `--show-trace` |

!!! note "First rebuild after the switch to the `desktop` / `laptop` hostnames"
    While the machine is still called `nixos`, use `dupdate` / `lupdate` (or `--hostname`),
    which name the configuration explicitly.

## With `nixos-rebuild`

| Mode | Command | Effect |
|---|---|---|
| Preview | `sudo nixos-rebuild dry-activate --flake .#desktop` | simulation |
| Temporary | `sudo nixos-rebuild test --flake .#desktop` | active until reboot |
| Permanent | `sudo nixos-rebuild switch --flake .#desktop` | active immediately |
| Next boot | `sudo nixos-rebuild boot --flake .#desktop` | applied on next boot |

Replace `desktop` with `laptop` as needed.
