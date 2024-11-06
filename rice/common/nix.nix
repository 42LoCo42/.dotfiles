{ pkgs, ... }: {
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
      ner = "nix eval -L --raw";
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
