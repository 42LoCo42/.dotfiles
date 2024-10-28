{ pkgs, ... }: {
  # TODO remove in next nixpkgs update
  nixpkgs.overlays = [
    (_: pkgs: {
      nix-output-monitor =
        let url = "github:nixos/nixpkgs/18536bf04cd71abd345f9579158841376fdd0c5a"; in
        (builtins.getFlake url).legacyPackages.${pkgs.system}.nix-output-monitor;
    })
  ];

  nix = {
    package = pkgs.lib.mkForce pkgs.lix;

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    settings = {
      keep-going = true;
      use-xdg-base-directories = true;
    };
  };

  home-manager.sharedModules = [{
    home.shellAliases = {
      n = "nix repl"; # i use this often, so make it short!
      nb = "nom build";
      ncc = "nix flake check -L"; # nc is netcat
      ne = "nix eval -L";
      nej = "nix eval -L --raw --apply builtins.toJSON";
      ng = "nix store gc -v";
      ni = "nix flake init";
      nm = "nix flake metadata";
      nn = "nix flake new";
      nr = "nix run -L";
      ns = "nix flake show";
      nu = "nix flake update";
    };
  }];
}
