# XDG Portal Profile Ownership

## Context

The Hyprland portal routing is correct: KDE is preferred for `FileChooser`,
GTK is the fallback that provides `Print`, and Hyprland provides `Screenshot`,
`ScreenCast`, and `GlobalShortcuts`. However, verbose startup diagnostics from
`xdg-desktop-portal` show that backend discovery stops at the first
`xdg-desktop-portal/portals` directory in `XDG_DATA_DIRS`.

Home Manager currently installs `xdg-desktop-portal-hyprland` through its
Hyprland module. Its higher-priority profile directory consequently contains
only `hyprland.portal` and masks the system profile directory that contains
the GTK, KDE, and Hyprland descriptors. The frontend recognizes Hyprland but
reports `gtk.portal` and `kde.portal` as unrecognized.

## Design

NixOS will be the sole owner of portal backend packages. The existing
`modules/xdg-portal.nix` routing and its GTK and KDE `extraPortals` remain
unchanged. Both Home Manager Hyprland configurations will set
`wayland.windowManager.hyprland.portalPackage = null`, preventing Home Manager
from creating a partial, higher-priority portal descriptor directory.

Home Manager continues to manage the Hyprland user configuration and package;
only its redundant portal package is disabled. The NixOS Hyprland module keeps
providing the Hyprland backend alongside the explicitly configured GTK and KDE
backends.

No browser profiles, portal preferences, or flake inputs are changed.

## Alternatives Considered

- Installing GTK and KDE portal packages in Home Manager would make the first
  descriptor directory complete, but would duplicate system-owned backends and
  leave two competing ownership layers.
- Reordering `XDG_DATA_DIRS` would affect application, icon, desktop-entry, and
  MIME-data discovery globally, making it unnecessarily broad for this issue.

## Validation

Before activation, Nix evaluation must confirm that both desktop and laptop
Home Manager configurations have a null `portalPackage`, while the NixOS
configuration still includes GTK, KDE, and Hyprland portal packages and keeps
the desired routing.

After the user rebuilds, verbose portal startup must discover all three
descriptors without an `unrecognized` warning. D-Bus introspection must expose
`FileChooser`, `Print`, `Screenshot`, `ScreenCast`, and `GlobalShortcuts`.
CUPS, Avahi, and `ipp-usb` runtime checks and browser print tests remain part of
the post-rebuild verification.
