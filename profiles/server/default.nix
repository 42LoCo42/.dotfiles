{ aquaris, config, lib, pkgs, ... }: {
  imports = [ ../common ./options.nix ./oci-firewall.nix ];

  nixpkgs.overlays = lib.singleton (_: prev: {
    caddy = (prev.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/porkbun@v0.3.1"
        "github.com/relvacode/caddy-oidc@v0.4.3"
        "github.com/tailscale/caddy-tailscale@v0.0.0-20260826180304-de41b249af4f"
      ];

      hash = "sha256-bL8F2sn691uhR0yNrEEAACkjgVvJF5DMzj9IhtxVbZ8=";
    }).overrideAttrs {
      doCheck = false;
    };
  });

  aquaris = {
    users = pkgs.lib.mkMerge [
      { inherit (aquaris.cfg.users) admin; }
      { admin.admin = true; }
    ];
  };

  system.autoUpgrade = {
    enable = true;
    dates = "04:00";
    flake = "github:42loco42/.dotfiles";
    flags = [ "--refresh" "-L" ];
  };

  systemd.services.nixos-upgrade.script =
    let keep = config.aquaris.machine.keepGenerations; in
    lib.mkIf (keep != null) (lib.mkAfter ''
      nix-env \
        --profile /nix/var/nix/profiles/system \
        --delete-generations "+${toString keep}"
    '');

  nix.gc.dates = "05:00";

  networking.networkmanager.enable = false;

  rice = {
    pam-rssh.enable = true;
    podman.enable = true;
  };
}
