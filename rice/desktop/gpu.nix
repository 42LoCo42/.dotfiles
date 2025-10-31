{ self, pkgs, lib, config, ... }:
let
  inherit (lib) mkBefore mkIf mkMerge mkOption;
  inherit (lib.types) bool;

  cfg = config.rice.desktop.gpu;
  mkEnable = mkOption { type = bool; default = false; };
in
{
  options.rice.desktop.gpu = {
    enable = mkEnable;

    baseload = mkOption {
      type = bool;
      description = "Provide a constant GPU baseload (using vkcube)";
      default = false;
    };

    ############################################################################

    amd.enable = mkEnable;

    intel = {
      enable = mkEnable;
      maxFreq = mkEnable;
    };

    nvidia.enable = mkEnable;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment = {
        systemPackages = [
          self.inputs.obscura.packages.${pkgs.stdenv.hostPlatform.system}.nvidia.entries.nvtop
        ];

        sessionVariables.MOZ_DISABLE_RDD_SANDBOX = "1";
      };

      home-manager.sharedModules = [{
        aquaris.firefox = {
          extensions = {
            # https://addons.mozilla.org/en-US/firefox/addon/enhanced-h264ify
            "{9a41dee2-b924-4161-a971-7fb35c053a4a}" = { };
          };

          prefs = {
            "media.ffmpeg.vaapi.enabled" = true;
            "media.hardware-video-decoding.force-enabled" = true;
            "media.rdd-ffmpeg.enabled" = true;
            "widget.dmabuf.force-enabled" = true;
          };
        };
      }];
    }

    (mkIf cfg.baseload {
      rice.desktop.wayland.hyprland.postConfig = ''
        # fix GPU spikes by providing a constant baseload
        windowrulev2 = float,    title:vkcube
        windowrulev2 = pin,      title:vkcube
        windowrulev2 = nofocus,  title:vkcube
        windowrulev2 = move 0 0, title:vkcube
        windowrulev2 = size 1 1, title:vkcube
        exec-once    = ${lib.getExe' pkgs.vulkan-tools "vkcube"} --wsi wayland
      '';
    })

    ############################################################################

    (mkIf cfg.amd.enable {
      hardware.amdgpu.opencl.enable = true;
    })

    (mkIf cfg.intel.enable {
      boot.kernelParams = [
        "i915.enable_guc=2"
        "i915.enable_psr=0"
      ];

      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vpl-gpu-rt
      ];

      systemd.services.intel-gpu-max-freq = mkIf cfg.intel.maxFreq {
        path = with pkgs; [ intel-gpu-tools ];
        script = "intel_gpu_frequency -m";
        serviceConfig.Type = "oneshot";
        before = [ "graphical.target" ];
        wantedBy = [ "graphical.target" ];
      };

      services.xserver.videoDrivers = [ "modesetting" ];
    })

    (mkIf cfg.nvidia.enable {
      rice = {
        unfreeNames = [ "nvidia-x11" ];

        desktop.wayland.hyprland.preConfig = mkBefore ''
          env = GBM_BACKEND,nvidia-drm
          env = LIBVA_DRIVER_NAME,nvidia
          env = NVD_BACKEND,direct
          env = VDPAU_DRIVER,nvidia
          env = __GLX_VENDOR_LIBRARY_NAME,nvidia
          env = __NV_PRIME_RENDER_OFFLOAD,1
          env = __NV_PRIME_RENDER_OFFLOAD_PROVIDER,NVIDIA-G0
          env = __VK_LAYER_NV_optimus,NVIDIA_only

          cursor:no_hardware_cursors = 1
        '';
      };

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        open = false;
        modesetting.enable = true;
        nvidiaSettings = false;
        powerManagement.enable = true;
      };

      services.xserver.videoDrivers = [ "nvidia" ];
    })
  ]);
}
