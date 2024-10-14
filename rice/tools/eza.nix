{
  home-manager.sharedModules = [{
    aquaris.lsd = false;

    programs.eza = {
      enable = true;
      extraOptions = [
        "--almost-all"
        "--group"
        "--group-directories-first"
        "--header"
        "--icons"
        "--links"
        "--long"
        "--mounts"
      ];
    };

    xdg.configFile."eza/theme.yml".text = builtins.toJSON {
      filenames = {
        ".cache".icon.glyph = "󰃨";
        ".ghci".icon.glyph = "";
        ".icons".icon.glyph = "";
        ".local".icon.glyph = "󰆼";
        ".mozilla".icon.glyph = "";
        ".nix-defexpr".icon.glyph = "";
        ".nix-profile".icon.glyph = "";
        ".pki".icon.glyph = "󰌾";
        ".zsh".icon.glyph = "";

        "dev".icon.glyph = "";
        "doc".icon.glyph = "󰈙";
        "img".icon.glyph = "";
        "keys".icon.glyph = "󰢬";
        "music".icon.glyph = "";
        "secrets".icon.glyph = "󰌾";
        "work".icon.glyph = "";
      };

      extensions = {
        "gpx".icon.glyph = "󰖃";
        "json".icon.glyph = "";
        "ora".icon.glyph = "";
        "yaml".icon.glyph = "";
        "excalidraw".icon.glyph = "";
      };
    };
  }];
}
