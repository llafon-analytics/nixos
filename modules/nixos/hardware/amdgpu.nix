# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:
{
  # AMD Gpu 
  boot.initrd.kernelModules = [ "amdgpu" ];
  # services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
    # rocm-opencl-icd
    # rocm-opencl-runtime
    vulkan-loader
    vulkan-validation-layers
    vulkan-extension-layer
    # amdvlk
  ];
  # AMDvlk For 32 bit applications
  hardware.graphics.extraPackages32 = with pkgs; [
   # driversi686Linux.amdvlk
  ];
  environment.variables.AMD_VULKAN_ICD = "RADV";
  # For 32 bit applications
  #wayland specific apps
  #environment.systemPackages = with pkgs; [
  #  rofi-wayland
  #];

}

