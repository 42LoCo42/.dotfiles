{ lib, config, ... }: {
  virtualisation.pnoc.photoview = {
    cmd = [ (lib.getExe config.rice.obscura.photoview) ];
    environment = {
      PHOTOVIEW_DATABASE_DRIVER = "postgres";
      PHOTOVIEW_LISTEN_IP = "0.0.0.0";
      PHOTOVIEW_MEDIA_CACHE = "/data";
    };
    environmentFiles = [ (config.aquaris.secret "machine/photoview") ];
    volumes = [
      "photoview:/data"
      "/persist/home/admin/img:/media:ro"
    ];
  };
}
