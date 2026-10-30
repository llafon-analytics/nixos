{ lib, pkgs, ... }:

# Secret Service provider (org.freedesktop.secrets) for both hosts. gnome-keyring is the single
# provider: KWallet would compete for the same D-Bus name, so its PAM hook is switched off.
# SDDM autologin gives PAM no password, so the keyring is not unlocked at login: the first
# secret access per session prompts for its password (gcr prompter).
{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  programs.seahorse.enable = true;

  # TEMP-FIX(kwallet-pam-login-off): the Plasma 6 module sets kwallet-pam on `login` with no
  # mkDefault; force it off so gnome-keyring stays the only Secret Service owner.
  security.pam.services.login.kwallet.enable = lib.mkForce false;

  environment.systemPackages = [ pkgs.libsecret ]; # secret-tool
}
