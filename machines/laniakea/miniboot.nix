{ pkgs, lib, config, ... }: {
  nixpkgs.overlays = lib.singleton
    (_: prev: {
      miniboot =
        let
          inherit (config.boot.kernelPackages) kernel;

          mods = pkgs.makeModulesClosure {
            kernel = kernel.modules;
            inherit (config.hardware) firmware;

            rootModules = [
              "dm_mod"
              "nvme"
              "rockchipdrm"
              "mmc_block"

              "ext4"
              "vfat"
              "nls_cp437"
              "nls_iso8859-1"

              "usbhid"

              "uhci_hcd"
              "ohci_hcd"
              "ehci_hcd"
              "xhci_hcd"
            ];
          };

          de-latin1 = (pkgs.runCommand "de-latin1.bmap" {
            nativeBuildInputs = with pkgs; [ kbd ];
          }) ''
            loadkeys -b ${pkgs.kbd}/share/keymaps/i386/qwertz/de-latin1.map.gz > $out
          '';

          initrd = pkgs.makeInitrdNG {
            compressor = "zstd";
            contents = [
              { source = mods; }
              { source = de-latin1; }
              { source = "${pkgs.pkgsStatic.busybox}/bin"; target = "/bin"; }
              {
                source = pkgs.writeScript "init" ''
                  #!/bin/sh
                  export PATH=/bin

                  while read -r i; do insmod "$i"; done < ${mods}/insmod-list
                  echo -e '\e[1;32mMODULES DONE!\e[m'

                  mkdir dev proc sys
                  mount -t devtmpfs devtmpfs dev
                  mount -t proc     proc     proc
                  mount -t sysfs    sysfs    sys

                  mkdir sd boot
                  mount /dev/mmcblk1p1 sd
                  mount /dev/nvme0n1p1 boot

                  loadkmap < ${de-latin1}

                  sh
                  poweroff -f
                '';

                target = "/init";
              }
            ];
          };
        in
        pkgs.linkFarm "miniboot" {
          kernel = "${kernel}/Image";
          initrd = "${initrd}/initrd";
          dtb = "${kernel}/dtbs/${config.hardware.deviceTree.name}";
        };
    });
}
