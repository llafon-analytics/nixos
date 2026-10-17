# Ajouter un host

## 1) Créer le dossier du host

```text
hosts/<host>/
├── default.nix     # système
├── hardware.nix    # généré par nixos-generate-config
├── home.nix        # Home Manager de l'utilisateur
└── hyprland.lua    # écrans, entrées, raccourcis propres au host
```

`hardware.nix` se génère sur la machine cible :

```sh
nixos-generate-config --show-hardware-config > hosts/<host>/hardware.nix
```

## 2) `default.nix`

```nix
{ ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos
    ../../modules/nixos/hardware/amdgpu.nix   # ou nvidia.nix
  ];

  networking.hostName = "<host>";

  users.users.<user> = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "input" ];
  };
  home-manager.users.<user> = import ./home.nix;
  nix.settings.trusted-users = [ "<user>" ];

  # Ports ouverts uniquement via Tailscale.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ ];

  system.stateVersion = "26.05"; # release de la première installation
}
```

## 3) `home.nix`

```nix
{ ... }:

{
  imports = [ ../../modules/home/common.nix ];

  home.username = "<user>";
  home.homeDirectory = "/home/<user>";
  xdg.configFile."hypr/host.lua".source = ./hyprland.lua;
}
```

## 4) Déclarer le host

Dans `flake/hosts.nix` :

```nix
<host> = mkHost { name = "<host>"; };
```

## 5) Vérifier

```sh
git add hosts/<host>       # la flake ne voit que les fichiers suivis par git
nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
nix flake check --no-build
```
