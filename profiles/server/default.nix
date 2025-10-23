{ pkgs, lib, config, aquaris, ... }: {
  imports = [ ../common ./options.nix ];

  nixpkgs.overlays = [
    (_: pkgs: {
      tscaddy = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/tailscale/caddy-tailscale@v0.0.0-20250207163903-69a970c84556"
        ];

        hash = "sha256-RBOL8YKZdF6WC2aK7zrErPabo8vC12EVLLM7G5csLcc=";
      };
    })
  ];

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

  rice = {
    pam-rssh.enable = true;
    podman.enable = true;
  };
}
