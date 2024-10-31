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
        "--long"
        "--mounts"
      ];
    };

    xdg.configFile."eza/theme.yml".text = builtins.toJSON {
      filenames = {
        # dot stuff in home
        ".cache".icon.glyph = "󰃨";
        ".ghci".icon.glyph = "";
        ".icons".icon.glyph = "";
        ".local".icon.glyph = "󰆼";
        ".mozilla".icon.glyph = "";
        ".nix-defexpr".icon.glyph = "";
        ".nix-profile".icon.glyph = "";
        ".pki".icon.glyph = "󰌾";
        ".zsh".icon.glyph = "";

        # main dirs in home
        "dev".icon.glyph = "";
        "doc".icon.glyph = "󰈙";
        "img".icon.glyph = "";
        "music".icon.glyph = "";
        "work".icon.glyph = "";

        # nixos config
        "homepage".icon.glyph = "󰖟";
        "images".icon.glyph = "";
        "keys".icon.glyph = "󰢬";
        "machines".icon.glyph = "";
        "rice".icon.glyph = "󰟪";
        "secrets".icon.glyph = "󰦝";

        # misc
        ".jj".icon.glyph = "󰘬";
        "Caddyfile".icon.glyph = "󰒒";
        "result".icon.glyph = "";
      };

      extensions = {
        "excalidraw".icon.glyph = "";
        "gpx".icon.glyph = "󰖃";
        "json".icon.glyph = "";
        "key".icon.glyph = "󰌆";
        "ora".icon.glyph = "";
        "prettierrc".icon.glyph = "";
        "pug".icon.glyph = "";
        "yaml".icon.glyph = "";
      };
    };
  }];
}
