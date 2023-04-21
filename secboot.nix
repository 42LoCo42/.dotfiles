{ lib, pkgs, ... }: {
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.bootspec.enable = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  boot.initrd.kernelModules = [ "tpm_crb" ];
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.bash}/bin/bash
    copy_bin_and_libs ${pkgs.jose}/bin/jose
    copy_bin_and_libs ${pkgs.luksmeta}/bin/luksmeta

    copy_bin_and_libs ${pkgs.tpm2-tools}/bin/tpm2
    copy_bin_and_libs ${pkgs.tpm2-tools}/bin/.tpm2-wrapped

    find ${pkgs.tpm2-tss}/lib -name 'libtss*.so*' \
    | while read -r i; do cp -a "$i" "$out/lib/"; done

    $out/bin/tpm2 2>&1 | tail +2 \
    | while read -r i; do ln -s tpm2 "$out/bin/tpm2_$i"; done

    find ${pkgs.clevis}/bin -type f \
    | while read -r i; do copy_bin_and_libs "$i"; done
  '';

  boot.initrd.luks.devices."root" =
    let
      device = "/dev/disk/by-uuid/29443d31-9744-47a4-8777-6289c54c6114";
    in
    {
      inherit device;
      preOpenCommands = ''
        ln -s ../.. /nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-${pkgs.bash.name}
        ln -s ../.. /nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-${pkgs.clevis.name}
        ln -s ../.. /nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-${pkgs.coreutils.name}
        ln -s ../.. /nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-${pkgs.tpm2-tools.name}

        echo "Decrypting device ${device} with clevis..."
        clevis luks unlock -d ${device} && open_normally() { :; }
      '';
    };

  environment.systemPackages = with pkgs; [
    clevis
    sbctl
  ];
}
