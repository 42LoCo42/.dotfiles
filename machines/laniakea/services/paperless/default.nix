{ pkgs, lib, config, ... }:
let
  inherit (lib)
    getExe'
    splitString
    unique
    ;

  PAPERLESS_OCR_LANGUAGE = "deu+eng";

  PKG = pkgs.paperless-ngx.override {
    tesseract5 = pkgs.tesseract5.override {
      enableLanguages = unique ([ "equ" "osd" "eng" ] ++
        splitString "+" PAPERLESS_OCR_LANGUAGE);
    };
  };
in
{
  virtualisation.pnoc.paperless = {
    path = with pkgs; [
      PKG
      coreutils
      granian
      runit
    ];

    cmd = config.rice.redis ++ [
      (getExe' pkgs.runit "runsvdir")
      (config.rice.mkRunit {
        task-queue = ''
          exec celery --app paperless worker --loglevel INFO
        '';

        scheduler = ''
          mkdir -p                       \
            "$PAPERLESS_CONSUMPTION_DIR" \
            "$PAPERLESS_DATA_DIR"        \
            "$PAPERLESS_MEDIA_ROOT"

          paperless-ngx migrate
          exec celery --app paperless beat --loglevel INFO
        '';

        webserver = ''
          export GRANIAN_HOST="$PAPERLESS_BIND_ADDR"
          export GRANIAN_PORT="$PAPERLESS_PORT"
          exec granian --interface asginl --ws "paperless.asgi:application"
        '';
      }).outPath
    ];

    environment = {
      PYTHONPATH = builtins.concatStringsSep ":" [
        (PKG.python.pkgs.makePythonPath PKG.propagatedBuildInputs)
        "${PKG}/lib/paperless-ngx/src"
      ];

      PAPERLESS_BIND_ADDR = "0.0.0.0";
      PAPERLESS_PORT = "8080";
      PAPERLESS_URL = "https://doc.${config.rice.domain}";

      PAPERLESS_CONSUMPTION_DIR = "/data/consume";
      PAPERLESS_DATA_DIR = "/data/data";
      PAPERLESS_MEDIA_ROOT = "/data/media";

      PAPERLESS_CONSUMER_DISABLE = "true";
      PAPERLESS_TIME_ZONE = "Europe/Berlin";
      inherit PAPERLESS_OCR_LANGUAGE;
    };

    environmentFiles = [ (config.aquaris.secret "@machine/paperless") ];

    volumes = [ "paperless:/data" ];
  };
}
