# Printing and XDG Portal Ownership Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable physical printing and make all required XDG Portal interfaces persistently discoverable in Hyprland sessions.

**Architecture:** NixOS owns CUPS, Avahi, `ipp-usb`, and every XDG Portal backend. Home Manager continues to manage Hyprland user configuration but does not install a second Hyprland portal package, preventing its higher-priority profile from masking GTK and KDE backend descriptors.

**Tech Stack:** NixOS modules, Home Manager, systemd user services, D-Bus, XDG Desktop Portal 1.20.

## Global Constraints

- Keep the existing interface routing in `modules/xdg-portal.nix`: KDE for `FileChooser`, GTK for `Print`, and Hyprland for Wayland-specific interfaces.
- Do not modify Chromium or Zen profiles.
- Do not modify the existing `flake.lock` update.
- Do not run `nixos-rebuild`; the user will rebuild and activate the configuration.
- Target driverless IPP/AirPrint for network printers and IPP-over-USB for modern USB printers.

---

### Task 1: Declare the Printing Stack

**Files:**
- Modify: `configuration.nix:280`

**Interfaces:**
- Consumes: NixOS options `services.printing`, `services.avahi`, and `services.ipp-usb`.
- Produces: CUPS activation, mDNS name resolution and firewall access, and IPP-over-USB discovery after the user rebuilds.

- [ ] **Step 1: Verify the pre-change evaluation is red**

Run:

```bash
XDG_CACHE_HOME=/tmp/nix-cache nix eval .#nixosConfigurations.desktop.config.services.printing.enable
XDG_CACHE_HOME=/tmp/nix-cache nix eval .#nixosConfigurations.desktop.config.services.avahi.enable
XDG_CACHE_HOME=/tmp/nix-cache nix eval .#nixosConfigurations.desktop.config.services.ipp-usb.enable
```

Expected before the implementation: all three commands print `false`.

- [ ] **Step 2: Add the minimal printing configuration**

Add this block after `services.flatpak.enable`:

```nix
  # Enable local, network (driverless IPP/AirPrint), and USB printing.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.ipp-usb.enable = true;
```

- [ ] **Step 3: Verify every printing option is green**

Run:

```bash
XDG_CACHE_HOME=/tmp/nix-cache nix eval .#nixosConfigurations.desktop.config.services.printing.enable
XDG_CACHE_HOME=/tmp/nix-cache nix eval .#nixosConfigurations.desktop.config.services.avahi.enable
XDG_CACHE_HOME=/tmp/nix-cache nix eval .#nixosConfigurations.desktop.config.services.avahi.nssmdns4
XDG_CACHE_HOME=/tmp/nix-cache nix eval .#nixosConfigurations.desktop.config.services.avahi.openFirewall
XDG_CACHE_HOME=/tmp/nix-cache nix eval .#nixosConfigurations.desktop.config.services.ipp-usb.enable
```

Expected: all five commands print `true` and exit successfully.

- [ ] **Step 4: Commit only the printing declaration**

```bash
git add configuration.nix
git diff --cached --check
git commit -m "feat(printing): enable CUPS and driverless discovery"
```

Confirm with `git status --short` that `flake.lock` remains modified and unstaged.

---

### Task 2: Give NixOS Sole Ownership of Portal Backends

**Files:**
- Modify: `wm-desktop/wm.nix:5`
- Modify: `wm-laptop/wm.nix:5`
- Preserve: `modules/xdg-portal.nix`

**Interfaces:**
- Consumes: Home Manager option `wayland.windowManager.hyprland.portalPackage` and the NixOS portal packages declared in `modules/xdg-portal.nix`.
- Produces: Home Manager configurations whose `portalPackage` value is `null`, leaving the complete system portal descriptor directory unmasked.

- [ ] **Step 1: Verify the ownership regression is red**

Run:

```bash
XDG_CACHE_HOME=/tmp/nix-cache nix eval --raw .#nixosConfigurations.desktop.config.home-manager.users.desktop.wayland.windowManager.hyprland.portalPackage.name
XDG_CACHE_HOME=/tmp/nix-cache nix eval --raw .#nixosConfigurations.laptop.config.home-manager.users.laptop.wayland.windowManager.hyprland.portalPackage.name
```

Expected before the implementation: both commands print `xdg-desktop-portal-hyprland-1.3.12`, proving that Home Manager adds the redundant backend.

- [ ] **Step 2: Disable the Home Manager portal package on desktop**

Change the start of the Hyprland block in `wm-desktop/wm.nix` to:

```nix
  wayland.windowManager.hyprland = {
    enable = true;
    # NixOS owns the complete Hyprland/GTK/KDE portal set. Installing only
    # Hyprland here would mask the system backend descriptors in XDG_DATA_DIRS.
    portalPackage = null;
    configType = "lua";
```

- [ ] **Step 3: Disable the Home Manager portal package on laptop**

Apply the identical ownership setting in `wm-laptop/wm.nix`:

```nix
  wayland.windowManager.hyprland = {
    enable = true;
    # NixOS owns the complete Hyprland/GTK/KDE portal set. Installing only
    # Hyprland here would mask the system backend descriptors in XDG_DATA_DIRS.
    portalPackage = null;
    configType = "lua";
```

- [ ] **Step 4: Verify both Home Manager values are null**

Run:

```bash
XDG_CACHE_HOME=/tmp/nix-cache nix eval --json .#nixosConfigurations.desktop.config.home-manager.users.desktop.wayland.windowManager.hyprland.portalPackage
XDG_CACHE_HOME=/tmp/nix-cache nix eval --json .#nixosConfigurations.laptop.config.home-manager.users.laptop.wayland.windowManager.hyprland.portalPackage
```

Expected: each command prints `null` and exits successfully.

- [ ] **Step 5: Verify the system still owns GTK and KDE**

Run:

```bash
XDG_CACHE_HOME=/tmp/nix-cache nix eval --json .#nixosConfigurations.desktop.config.xdg.portal.extraPortals --apply 'map (portal: portal.name)'
```

Expected: the JSON array contains names beginning with `xdg-desktop-portal-gtk-` and `xdg-desktop-portal-kde-`.

- [ ] **Step 6: Commit only the portal ownership change**

```bash
git add wm-desktop/wm.nix wm-laptop/wm.nix
git diff --cached --check
git commit -m "fix(portal): keep backend ownership at system level"
```

Confirm with `git status --short` that `flake.lock` remains modified and unstaged.

---

### Task 3: Static Validation and Post-Rebuild Handoff

**Files:**
- Verify: `configuration.nix`
- Verify: `modules/xdg-portal.nix`
- Verify: `wm-desktop/wm.nix`
- Verify: `wm-laptop/wm.nix`

**Interfaces:**
- Consumes: the NixOS and Home Manager configurations from Tasks 1 and 2.
- Produces: evaluated desktop and laptop system derivations plus exact runtime checks for the user to run after activation.

- [ ] **Step 1: Check the patch for formatting errors and unintended files**

Run:

```bash
git diff --check
git status --short
git diff -- configuration.nix modules/xdg-portal.nix wm-desktop/wm.nix wm-laptop/wm.nix
```

Expected: no whitespace errors; no diff for `modules/xdg-portal.nix`; browser files absent; `flake.lock` remains a separate pre-existing modification.

- [ ] **Step 2: Evaluate both complete NixOS configurations without building**

Run:

```bash
XDG_CACHE_HOME=/tmp/nix-cache nix eval --raw .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
XDG_CACHE_HOME=/tmp/nix-cache nix eval --raw .#nixosConfigurations.laptop.config.system.build.toplevel.drvPath
```

Expected: both commands print a `/nix/store/…-nixos-system-…drv` path and exit successfully. Do not run `nix build` or `nixos-rebuild`.

- [ ] **Step 3: Hand the activation command to the user**

The user runs the appropriate host command, for example:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

- [ ] **Step 4: Verify printing after activation**

The user runs:

```bash
systemctl is-active cups.service avahi-daemon.service ipp-usb.service
test -S /run/cups/cups.sock
lpstat -r
lpinfo --include-schemes usb,ipp,ipps,dnssd -v
```

Expected: all three services are active, the CUPS socket test exits zero, `lpstat` reports that the scheduler is running, and available USB or mDNS/IPP printers appear when connected or reachable.

- [ ] **Step 5: Verify portal discovery after activation and a new login**

Start all backends using their actual unit names, then restart the frontend:

```bash
systemctl --user restart xdg-desktop-portal-gtk.service plasma-xdg-desktop-portal-kde.service xdg-desktop-portal-hyprland.service
systemctl --user restart xdg-desktop-portal.service
busctl --user introspect org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop
```

Expected: `FileChooser`, `Print`, `Screenshot`, `ScreenCast`, and `GlobalShortcuts` are present. Repeat the introspection after a logout/login or reboot to confirm persistence.

- [ ] **Step 6: Complete the browser smoke tests**

In Chromium and then Zen, open a simple page and press `Ctrl+P`. Confirm that the preview opens promptly, save once as PDF, and open the generated PDF. Then select any discovered physical printer and verify that it accepts a test page.
