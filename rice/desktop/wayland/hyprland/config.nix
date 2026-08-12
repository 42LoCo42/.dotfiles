{ pkgs, ... }: {
  rice.desktop.wayland.hyprland = {
    env = {
      GDK_BACKEND = "wayland";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";

      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    settings = {
      config = {
        debug = {
          disable_logs = false;
          enable_stdout_logs = true;
        };

        general = {
          gaps_in = 5;
          gaps_out = 5;
          border_size = 2;

          col = {
            active_border = {
              colors = [
                "rgba(33ccffee)"
                "rgba(00ff99ee)"
              ];

              angle = 45;
            };

            inactive_border = "rgba(595959aa)";
          };

          layout = "dwindle";
        };

        input = {
          kb_layout = "de";
          kb_options = "compose:sclk";
          repeat_delay = 300;
          repeat_rate = 50;
        };

        cursor = {
          inactive_timeout = 3;
          persistent_warps = true;
          zoom_rigid = true;
          zoom_detached_camera = false;
        };

        decoration = {
          rounding = 10;

          blur = {
            enabled = true;
            new_optimizations = true;
            size = 3;
            passes = 1;
          };
        };

        animations = {
          enabled = true;
        };

        dwindle = {
          force_split = 2;
          preserve_split = true;
        };

        binds = {
          workspace_back_and_forth = true;
        };

        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;

          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;

          # swallowing doesn't work in tmux, but that's fine
          enable_swallow = true;
          swallow_regex = "foot";

          # unmax current fullscreen window if another window opens
          on_focus_under_fullscreen = 2;

          enable_anr_dialog = false;
        };

        plugin = {
          dynamic_cursors = {
            enabled = true;
            mode = "stretch";

            shake = {
              enabled = true;
              effects = true;
            };
          };

          hyprfocus = {
            keyboard_focus_animation = "slide";
            mouse_focus_animation = "slide";
            only_on_monitor_change = true;
          };
        };
      };

      "plugin.hyprwinwrap.window" = {
        class = "background-wrap";
        pos_x = 0;
        pos_y = 0;
        size_x = 100;
        size_y = 100;
      };
    };

    binds = f: with f; {
      Return = function ''
        ws = "1"
        class = "foot-main-terminal"
        should_move = true

        if hl.get_active_workspace().name ~= ws then
          hl.dispatch(hl.dsp.focus({ workspace = ws }))
          should_move = false
        end

        present = #hl.get_windows({
          workspace = ws,
          class = class,
        }) > 0

        if not present then
          hl.dispatch(hl.dsp.exec_cmd(fmt("foot -a %s tmux new-session -A -s 0", class)))
        elseif should_move then
          hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
        end
      '';

      ##### programs #####
      S-Return = exec "foot";
      S-a = dropdown "pulsemixer";
      S-e = exec "emacsclient -e '(save-buffers-kill-emacs)'";
      a = dropdown "qalc";
      d = exec "fuzzel";
      e = exec "emacsclient -nce '(my/greeter)'";
      i = exec "foot htop";
      m = exec "foot ncmpcpp";
      n = exec "foot sh -c 'sleep 0.1; nmtui'";
      w = exec "uwsm app librewolf";
      x = exec "loginctl lock-session";

      ##### power options #####
      Backspace = power "Shutdown" "systemctl poweroff";
      S-Backspace = power "Reboot" "systemctl reboot";
      C-Backspace = power "Suspend" "systemctl suspend";
      Escape = power "Logout" "hyprctl dispatch hl.dsp.exit()";

      C-i = exec (pkgs.writeShellScript "idle-toggle" ''
        if systemctl --user is-active hypridle; then
          systemctl --user stop hypridle
          notify-send "Idle disabled!"
        else
          systemctl --user start hypridle
          notify-send "Idle enabled!"
        fi
      '');

      ##### zoom #####
      Plus = function ''
        zoom = hl.get_config("cursor.zoom_factor") * 1.25
        hl.config({ cursor = { zoom_factor = zoom } })'';

      Minus = function ''
        zoom = math.max(1, hl.get_config("cursor.zoom_factor") / 1.25)
        hl.config({cursor = { zoom_factor = zoom }})'';

      Numbersign = function ''
        hl.config({ cursor = { zoom_factor = 1 }})'';

      ##### media keys #####
      XF86AudioLowerVolume = raw (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-");
      XF86AudioRaiseVolume = raw (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+");
      XF86AudioMute = raw (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle");
      XF86AudioMicMute = raw (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle");
      XF86AudioPlay = raw (exec "mpc toggle");
      XF86AudioPrev = raw (exec "mpc prev");
      XF86AudioNext = raw (exec "mpc next");
      XF86MonBrightnessDown = raw (exec "brightnessctl set 10%-");
      XF86MonBrightnessUp = raw (exec "brightnessctl set 10%+");

      ##### fullscreen #####
      f = fullscreen 1 0; # almost fullscreen, keep bar
      C-f = fullscreen 2 2; # true fullscreen
      A-f = fullscreen 0 2; # fake fullscreen

      ##### (un)hide windows #####
      h = move { workspace = "special:hidden"; follow = false; };
      S-h = dsp ''workspace.toggle_special("hidden")'';

      ##### misc #####
      S-f = dsp ''window.float({ "toggle" })'';
      Tab = focus { workspace = "previous"; };
      q = function ''
        window = hl.get_active_window()
        if window.class == "librewolf" and window.initial_title == "LibreWolf" then
          hl.dispatch(hl.dsp.send_shortcut({
            mods = "CTRL",
            key = "q",
            window = window,
          }))
        else
          hl.dispatch(hl.dsp.window.close())
        end
      '';

      dead_circumflex = focus { workspace = 1; };
      S-dead_circumflex = move { workspace = 1; };

      "mouse:272" = dsp "window.drag()";
      "mouse:273" = dsp "window.resize()";
    };

    events = {
      "window.open win" = ''
        if win.class == "background-wrap" then
          hl.config({ decoration = { blur = { new_optimizations = false } } })
        end
      '';

      "window.close win" = ''
        if win.class == "background-wrap" then
          hl.config({ decoration = { blur = { new_optimizations = true } } })
        end
      '';
    };

    animations = f: with f; {
      border = { speed = 10; };
      borderangle = { speed = 8; };
      fade = { speed = 7; };
      windows = { speed = 7; curve = bezier "myBezier"; };
      windowsOut = { speed = 7; style = "popin 80%"; };
      workspaces = { speed = 6; };
    };

    curves = f: with f; {
      myBezier = bezier {
        points = [
          [ 0.05 0.9 ]
          [ 0.1 1.05 ]
        ];
      };
    };

    windowRules = [{
      match = { float = false; workspace = "w[tv1]"; };
      border_size = 0;
      rounding = 0;
    }];

    workspaceRules = [{
      workspace = "w[tv1]";
      gaps_out = 0;
      gaps_in = 0;
    }];
  };
}
