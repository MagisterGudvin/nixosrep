{ inputs, ... }: {
  flake.homeModules.niri = { pkgs, ... }:
    let
      noctalia = "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia-shell";

      niri-screenshot = pkgs.writeShellApplication {
        name = "niri-screenshot";
        runtimeInputs = with pkgs; [ niri swappy coreutils ];
        text = ''
          SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
          mkdir -p "$SCREENSHOT_DIR"
          case "''${1:-}" in
            screen) niri msg action screenshot-screen ;;
            *)      niri msg action screenshot ;;
          esac
          sleep 1
          shot="$(ls -t "$SCREENSHOT_DIR"/*.png 2>/dev/null | head -1)"
          [ -n "$shot" ] && swappy -f "$shot"
        '';
      };
    in {
      imports = [ inputs.niri.homeModules.config-niri ];

      home.packages = with pkgs; [
        niri-screenshot
        xwayland-satellite
        wl-clipboard
        cliphist
      ];

      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = "${noctalia} ipc call lockScreen lock";
          }
        ];
      };

      programs.niri.settings = {
        prefer-no-csd = true;

        input = {
          keyboard = {
            xkb.layout = "us,ru";
            repeat-delay = 250;
            repeat-rate = 35;
          };
          touchpad = {
            accel-profile = "adaptive";
            accel-speed = 0.2;
            dwt = true;
            natural-scroll = true;
            tap = true;
            scroll-factor = 0.8;
          };
          focus-follows-mouse.enable = true;
        };

        hotkey-overlay = {
          hide-not-bound = true;
          skip-at-startup = true;
        };

        layer-rules = [
          {
            matches = [ { namespace = "^notification$"; } ];
            block-out-from = "screencast";
          }
          {
            matches = [ { namespace = "^noctalia-wallpaper.*"; } ];
            place-within-backdrop = true;
          }
        ];

        cursor = {
          hide-after-inactive-ms = 3000;
          hide-when-typing = true;
          size = 32;
          theme = "volantes_cursors";
        };

        environment = {
          XDG_CURRENT_DESKTOP = "niri";
          XDG_SESSION_DESKTOP = "niri";
          XCURSOR_THEME = "volantes_cursors";
          XCURSOR_SIZE = "32";
        };

        gestures.hot-corners.enable = false;

        outputs."eDP-1".scale = 1.2;

        overview = {
          workspace-shadow.enable = false;
          zoom = 0.5;
        };

        layout = {
          background-color = "transparent";
          center-focused-column = "never";
          default-column-width.proportion = 0.5;
          gaps = 5;
          preset-column-widths = [
            { proportion = 0.5; }
            { proportion = 0.75; }
            { proportion = 1.0; }
          ];

          focus-ring = {
            width = 1;
            active.gradient = {
              angle = 210;
              from = "#80c8ff";
              to = "#223366";
              relative-to = "workspace-view";
            };
            inactive.gradient = {
              angle = 45;
              from = "#505050";
              to = "#808080";
              relative-to = "workspace-view";
            };
          };

          shadow = {
            enable = true;
            softness = 30;
            spread = 5;
            offset.x = 0;
            offset.y = 8;
            color = "#00000060";
          };
        };

        animations = {
          slowdown = 1.0;
          window-open.kind.spring = {
            damping-ratio = 0.8;
            stiffness = 1000;
            epsilon = 0.0001;
          };
          window-close.kind.easing = {
            duration-ms = 150;
            curve = "ease-out-cubic";
          };
          window-movement.kind.spring = {
            damping-ratio = 0.8;
            stiffness = 1000;
            epsilon = 0.0001;
          };
          workspace-switch.kind.easing = {
            duration-ms = 250;
            curve = "ease-out-expo";
          };
          overview-open-close.kind.easing = {
            duration-ms = 200;
            curve = "ease-out-expo";
          };
        };

        spawn-at-startup = [
          { command = [ noctalia ]; }
          { command = [ "xwayland-satellite" ]; }
          { command = [ "sh" "-c" "wl-paste --type text --watch cliphist store" ]; }
          { command = [ "sh" "-c" "wl-paste --type image --watch cliphist store" ]; }
        ];

        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

        window-rules = [
          # --- Floating ---
          {
            matches = [ { app-id = "^pavucontrol$"; } ];
            open-floating = true;
            default-column-width.fixed = 800;
            default-window-height.fixed = 600;
          }
          {
            matches = [ { app-id = "^nm-connection-editor$"; } ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "^(Thunar|thunar)$"; } ];
            open-floating = true;
            default-column-width.fixed = 1400;
            default-window-height.fixed = 1000;
          }
          {
            matches = [ { app-id = "^org.gnome.Calculator$"; } ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "^(imv|mpv)$"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "^Picture-in-Picture$"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "^(Open|Save) File.*$"; } ];
            open-floating = true;
          }

          # --- Прозрачность + закругления для конкретных приложений ---
          {
            matches = [ { app-id = "^foot$"; } ];
            opacity = 0.92;
            draw-border-with-background = false;
            geometry-corner-radius = {
              top-left = 10.0; top-right = 10.0;
              bottom-left = 10.0; bottom-right = 10.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [ { app-id = "^(code|Code)$"; } ];
            opacity = 0.94;
            draw-border-with-background = false;
            geometry-corner-radius = {
              top-left = 10.0; top-right = 10.0;
              bottom-left = 10.0; bottom-right = 10.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [ { app-id = "^brave-browser$"; } ];
            opacity = 1.0;
            draw-border-with-background = false;
            geometry-corner-radius = {
              top-left = 10.0; top-right = 10.0;
              bottom-left = 10.0; bottom-right = 10.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [ { app-id = "^pavucontrol$"; } ];
            draw-border-with-background = false;
            geometry-corner-radius = {
              top-left = 12.0; top-right = 12.0;
              bottom-left = 12.0; bottom-right = 12.0;
            };
            clip-to-geometry = true;
            opacity = 0.95;
          }
          {
            matches = [ { app-id = "^(Thunar|thunar)$"; } ];
            draw-border-with-background = false;
            geometry-corner-radius = {
              top-left = 12.0; top-right = 12.0;
              bottom-left = 12.0; bottom-right = 12.0;
            };
            clip-to-geometry = true;
            opacity = 0.95;
          }
          {
            matches = [ { app-id = "^(Swappy|swappy)$"; } ];
            draw-border-with-background = false;
            geometry-corner-radius = {
              top-left = 12.0; top-right = 12.0;
              bottom-left = 12.0; bottom-right = 12.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [ { app-id = "^obsidian$"; } ];
            opacity = 0.93;
            draw-border-with-background = false;
            geometry-corner-radius = {
              top-left = 12.0; top-right = 12.0;
              bottom-left = 12.0; bottom-right = 12.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [ { app-id = "^spotify$"; } ];
            open-floating = true;
            default-column-width.fixed = 1200;
            default-window-height.fixed = 800;
            opacity = 0.92;
            draw-border-with-background = false;
            geometry-corner-radius = {
              top-left = 12.0; top-right = 12.0;
              bottom-left = 12.0; bottom-right = 12.0;
            };
            clip-to-geometry = true;
          }
          # Дефолт для всего остального — закруглённые углы
          {
            matches = [ { } ];
            draw-border-with-background = false;
            geometry-corner-radius = {
              top-left = 10.0; top-right = 10.0;
              bottom-left = 10.0; bottom-right = 10.0;
            };
            clip-to-geometry = true;
          }
        ];

        binds = {
          # --- Apps ---
          "Mod+Return".action.spawn = [ "foot" ];
          "Mod+E".action.spawn = [ "foot" ];
          "Mod+B".action.spawn = [ "brave" ];
          "Mod+Q".action.spawn = [ "thunar" ];

          "Mod+Escape".action.spawn = [ noctalia "ipc" "call" "sessionMenu" "toggle" ];
          "Mod+Space".action.spawn = [ noctalia "ipc" "call" "launcher" "toggle" ];
          "Mod+Shift+Space".action.spawn = [ noctalia "ipc" "call" "controlCenter" "toggle" ];
          "Mod+Shift+Comma".action.spawn = [ noctalia "ipc" "call" "settings" "toggle" ];
          "Mod+W".action.spawn = [ noctalia "ipc" "call" "wallpaper" "toggle" ];

          "Mod+V".action.spawn = [ "sh" "-c" "cliphist list | rofi -dmenu -p ' Clipboard' | cliphist decode | wl-copy" ];

          # --- Screenshots ---
          "Mod+S".action.spawn = [ "niri-screenshot" ];
          "Mod+Shift+S".action.spawn = [ "niri-screenshot" "screen" ];

          # --- Window Management ---
          "Mod+C".action.close-window = { };
          "Mod+F".action.maximize-column = { };
          "Mod+Shift+F".action.fullscreen-window = { };
          "Mod+T".action.toggle-window-floating = { };
          "Mod+O".action.toggle-overview = { };
          "Mod+R".action.switch-preset-column-width = { };
          "Mod+Shift+R".action.reset-window-height = { };

          # Focus
          "Mod+H".action.focus-column-left = { };
          "Mod+L".action.focus-column-right = { };
          "Mod+J".action.focus-window-or-workspace-down = { };
          "Mod+K".action.focus-window-or-workspace-up = { };
          "Mod+Left".action.focus-column-left = { };
          "Mod+Right".action.focus-column-right = { };
          "Mod+Up".action.focus-window-or-workspace-up = { };
          "Mod+Down".action.focus-window-or-workspace-down = { };
          "Mod+Home".action.focus-column-first = { };
          "Mod+End".action.focus-column-last = { };

          # Move windows
          "Mod+Ctrl+H".action.move-column-left = { };
          "Mod+Ctrl+L".action.move-column-right = { };
          "Mod+Ctrl+J".action.move-window-down = { };
          "Mod+Ctrl+K".action.move-window-up = { };

          # Resize
          "Mod+Shift+Right".action.set-column-width = "+80";
          "Mod+Shift+Left".action.set-column-width = "-80";
          "Mod+Shift+Down".action.set-window-height = "+80";
          "Mod+Shift+Up".action.set-window-height = "-80";

          # Workspaces
          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+0".action.focus-workspace = 10;

          "Mod+Shift+1".action.move-window-to-workspace = 1;
          "Mod+Shift+2".action.move-window-to-workspace = 2;
          "Mod+Shift+3".action.move-window-to-workspace = 3;
          "Mod+Shift+4".action.move-window-to-workspace = 4;
          "Mod+Shift+5".action.move-window-to-workspace = 5;
          "Mod+Shift+6".action.move-window-to-workspace = 6;
          "Mod+Shift+7".action.move-window-to-workspace = 7;
          "Mod+Shift+8".action.move-window-to-workspace = 8;
          "Mod+Shift+9".action.move-window-to-workspace = 9;
          "Mod+Shift+0".action.move-window-to-workspace = 10;

          # Toggle window opacity
          "Mod+Shift+O".action.toggle-window-rule-opacity = { };

          # Session
          "Mod+Shift+M".action.quit = { };
          "Mod+Alt+L".action.spawn = [ noctalia "ipc" "call" "lockScreen" "lock" ];
          "Mod+Shift+L".action.spawn = [ noctalia "ipc" "call" "lockScreen" "lock" ];
          "Mod+Shift+B".action.spawn = [ noctalia "ipc" "call" "bar" "toggle" ];
          "Mod+Shift+N".action.spawn = [ noctalia "ipc" "call" "nightLight" "toggle" ];

          # Media
          "Mod+P".action.spawn = [ "playerctl" "play-pause" ];
          "Mod+Shift+P".action.spawn = [ "playerctl" "stop" ];
          "Mod+comma".action.spawn = [ "playerctl" "previous" ];
          "Mod+period".action.spawn = [ "playerctl" "next" ];

          # Volume (работают и на lock-screen)
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" ];
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
          };

          # Brightness (работают и на lock-screen)
          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            action.spawn = [ "brightnessctl" "set" "5%+" ];
          };
          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            action.spawn = [ "brightnessctl" "set" "5%-" ];
          };
        };
      };
    };
}
