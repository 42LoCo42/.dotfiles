{ pkgs, ... }: {
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "pcie_acs_override=downstream,multifunction"
  ];

  specialisation.windows.configuration = {
    boot = {
      kernelParams = [
        "initcall_blacklist=sysfb_init"
      ];

      blacklistedKernelModules = [
        "amdgpu"
        "snd_hda_intel"
      ];

      extraModprobeConfig = ''
        options vfio-pci ids=1002:67df disable_vga=1
        options snd-hda-core gpu_bind=0
        options kvm ignore_msrs=1
      '';
    };

    systemd.services.start-windows = {
      wantedBy = [ "multi-user.target" ];

      after = [ "libvirtd.service" ];
      wants = [ "libvirtd.service" ];

      path = with pkgs; [
        libvirt
      ];

      script = ''
        virsh -c qemu:///system start win11
      '';
    };

    # virtualisation.libvirtd.hooks.qemu.windows = pkgs.writeShellScript "windows" ''
    #   if [ "$1" = "win11" ] && [ "$2" = "release" ]; then
    #     ${pkgs.systemd}/bin/systemctl reboot
    #   fi
    # '';
  };
}
