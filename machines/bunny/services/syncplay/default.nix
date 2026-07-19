{ config, pkgs, ... }: {
  topology.nodes.bunny-private.services.syncplay = {
    name = "Syncplay";
    icon = "services.syncplay";
    info = "Media player synchronization";
    details.url.text = "exit.bunny.vpn:8999";
  };

  virtualisation.pnoc.syncplay = {
    path = with pkgs; [ syncplay-nogui ];

    script = ''
      exec syncplay-server                     \
        --port 8999                            \
        --disable-ready                        \
        --stats-db-file /data/stats.db         \
        --rooms-db-file /data/rooms.db         \
        --permanent-rooms-file /data/rooms.txt \
        --max-chat-message-length 10000        \
        --max-username-length 100
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/syncplay") ];

    ports = [ "8999:8999" ];

    volumes = [ "syncplay:/data" ];
  };
}
