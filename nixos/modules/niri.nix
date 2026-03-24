{config, pkgs, lib, ...}: {
  programs.niri = {
    enable = true;

    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "us";
          };
        };
        mouse = {
          accel-speed = 0.2;
          natural-scroll = false;
        };
      };

      outputs = {
        "HDMI-1" = {
          position.x = 0;
          position.y = 0;
        };
      };

      layout = {
        gaps = 16;
        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };
      };

      spawn-at-startup = [
        {command = ["systemctl" "--user" "start" "hyprpaper"];}
      ];
    };
  };
}
