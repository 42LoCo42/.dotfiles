{ pkgs, ... }: {
  boot.extraModprobeConfig =
    let
      script = pkgs.lib.getExe (pkgs.writeShellApplication {
        name = "audio-config";

        runtimeInputs = with pkgs; [
          alsa-utils
          gnugrep
          kmod
        ];

        text = ''
          shopt -s nullglob
          modprobe -C /dev/null snd-hda-intel

          dir=
          while [ -z "$dir" ]; do
            for i in /sys/class/sound/hw*; do
              if [ "$(< "$i/vendor_name")" = "Realtek" ]; then
                dir="$i"
                break 2
              fi
            done
            sleep 0.25
          done

          while read -r line; do echo "$line" > "$dir/hints"; done << EOF
          indep_hp = true
          vmaster = false
          EOF

          while read -r line; do echo "$line" > "$dir/user_pin_configs"; done << EOF
          0x11 0x40000000
          0x12 0x40000000
          0x14 0x01114010
          0x15 0x40000000
          0x16 0x40000000
          0x17 0x40000000
          0x18 0x40000000
          0x19 0x40000000
          0x1a 0x40000000
          0x1b 0x02214020
          0x1c 0x40000000
          0x1d 0x40000000
          0x1e 0x40000000
          0x1f 0x40000000
          EOF

          echo 1 > "$dir/reconfig"

          id="$(grep -oP 'hwC\K\d' <<< "$dir")"
          while ! amixer -c "$id" sset 'Independent HP' Enabled; do :; done
        '';
      });
    in
    "install snd-hda-intel ${script}";

  hardware.alsa.enablePersistence = true;

  services.udev.extraRules = ''
    SUBSYSTEMS=="pci", ATTRS{vendor}=="0x8086", ATTRS{device}=="0xa170", \
    ENV{ACP_PROFILE_SET}="${./profile.conf}"

    # remove AMD HDMI audio
    ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:01:00.1", \
    RUN+="/bin/sh -c 'echo 1 > /sys/$devpath/remove'"
  '';

  aquaris.persist.dirs = {
    "/var/lib/alsa" = { };
  };

  environment.systemPackages = with pkgs; [ alsa-utils ];
}
