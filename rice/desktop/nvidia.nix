{ lib, config, ... }: {
  options.rice.desktop.nvidia.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.nvidia.enable {
    rice.desktop.zenkernel.config.allowUnfreePredicate = p: builtins.elem (lib.getName p) [
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
      package = config.boot.kernelPackages.nvidiaPackages.stable; # 560.35.03
      open = false;
      modesetting.enable = true;
      nvidiaSettings = false;
      powerManagement.enable = true;
    };

    environment.systemPackages = with config.rice.desktop.zenkernel.pkgs; [ nvtopPackages.nvidia ];

    services.xserver.videoDrivers = [ "nvidia" ];

    rice.desktop.wayland.hyprland.preConfig = ''
      env = GBM_BACKEND,nvidia-drm
      env = __GLX_VENDOR_LIBRARY_NAME,nvidia
      env = LIBVA_DRIVER_NAME,nvidia
    '';
  };
}
