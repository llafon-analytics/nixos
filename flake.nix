{
  description = "A template that shows all standard flake outputs";
  nixConfig = {
    experimental-features = [ "nix-command" "flakes"];
    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"

      "https://cache.nixos.org"
     ];

    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Stable is the default channel. Unstable is reserved for explicit fast-moving package exceptions.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-craftapps = {
      url = "github:olafkfreund/nix-craftapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pipewire-screenaudio.url = "github:IceDBorn/pipewire-screenaudio";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    claude-code-nix.url = "github:sadjow/claude-code-nix";
    millennium = {
      url = "github:SteamClientHomebrew/Millennium/next?dir=packages/nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix.url = "github:danth/stylix/release-26.05";
    # Caelestia builds on quickshell (git), which tracks nixos-unstable; pinning it to
    # stable 26.05 is the likeliest way to break the build.
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
    # Prebuilt weekly nix-index database, used by comma and command-not-found.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-zen = {
      url = "github:catppuccin/zen-browser";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, pipewire-screenaudio, stylix, zen-browser, ... }:
    let
      system = "x86_64-linux";
      desktopPorts = import ./hosts/desktop/ports.nix;
      droidcamTransformBufferOverlay = import ./overlays/droidcam-transform-buffer.nix;
      imageMagickCompatOverlay = import ./overlays/imagemagick-compat.nix;
      commonModules = import ./common-modules.nix {
        inherit inputs droidcamTransformBufferOverlay imageMagickCompatOverlay;
      };
    in {
      overlays.droidcam-transform-buffer = droidcamTransformBufferOverlay;
      overlays.imagemagick-compat = imageMagickCompatOverlay;
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = commonModules ++ [
            { nixpkgs.hostPlatform = system; }
            ./hosts/laptop
          ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = commonModules ++ [
            { nixpkgs.hostPlatform = system; }
            (import ./hosts/desktop { inherit desktopPorts; })
          ];
        };
      };
      checks = let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ droidcamTransformBufferOverlay ];
        };
      in {
        ${system} = {
          droidcam = pkgs.droidcam;
          hyprland-rules = pkgs.runCommand "hyprland-rules-check" {
            src = ./.;
            hyprlandBaseLua = ./hyprland.base.lua;
            hyprlandDesktopLua = ./wm-desktop/hyprland.lua;
            hyprlandLaptopLua = ./wm-laptop/hyprland.lua;
            nativeBuildInputs = [ pkgs.bash pkgs.lua pkgs.ripgrep ];
          } ''
            cp -R "$src" repo
            chmod -R u+w repo
            cp "$hyprlandBaseLua" repo/hyprland.base.lua
            cp "$hyprlandDesktopLua" repo/wm-desktop/hyprland.lua
            cp "$hyprlandLaptopLua" repo/wm-laptop/hyprland.lua
            cd repo
            ${pkgs.bash}/bin/bash scripts/check-hyprland-rules.sh
            touch "$out"
          '';
        };
      };
    };
}
