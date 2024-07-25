{ pkgs, config, lib, ... }: {

  nixpkgs.config.allowUnfreePredicate = p: builtins.elem (lib.getName p) [
    "cuda-merged"
    "cuda_cccl"
    "cuda_cudart"
    "cuda_cuobjdump"
    "cuda_cupti"
    "cuda_cuxxfilt"
    "cuda_gdb"
    "cuda_nvcc"
    "cuda_nvdisasm"
    "cuda_nvml_dev"
    "cuda_nvprune"
    "cuda_nvrtc"
    "cuda_nvtx"
    "cuda_profiler_api"
    "cuda_sanitizer_api"
    "libcublas"
    "libcufft"
    "libcurand"
    "libcusolver"
    "libcusparse"
    "libnpp"
    "libnvjitlink"
    "nvidia-x11"
  ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.production;
    modesetting.enable = true;
    nvidiaSettings = false;
    powerManagement.enable = true;
  };

  environment.systemPackages = with pkgs; [ nvtopPackages.nvidia ];
  services.xserver.videoDrivers = [ "nvidia" ];
}
