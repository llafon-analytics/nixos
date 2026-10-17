{ pkgs, ... }:

# AMD GPU (laptop): amdgpu in the initrd, RADV for Vulkan, ROCm OpenCL.
{
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
    vulkan-loader
    vulkan-validation-layers
    vulkan-extension-layer
  ];
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
