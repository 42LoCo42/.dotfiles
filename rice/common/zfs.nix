{ pkgs, ... }: {
  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "zfsnaps";
      text = ''
        zfs list -t snapshot -o name,used,refer \
        | sed -E '
          s|(snap)_([^-]+)-([^ ]+)|\1-\3-\2|;
          s| +| |g;' \
        | sort | column -t -s ' ' | less
      '';
    })
  ];
}
