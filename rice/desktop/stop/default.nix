{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.writeScriptBin "stop" (builtins.readFile ./stop.zsh))
  ];
}
