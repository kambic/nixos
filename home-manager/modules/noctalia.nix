{
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;

    settings = {
      settingsVersion = 0;

      theme = "default";

      bar = {
        density = "compact";
        position = "left";
        showCapsule = false;
        barType = "framed";
        frameThickness = 8;
        frameRadius = 12;
        widgets = {
          left = [
            {
              id = "Clock";
              formatVertical = "HH mm - dd MM";
              useMonospacedFont = true;
            }
            {
              id = "SystemMonitor";
            }
            {
              id = "MediaMini";
            }
          ];
          center = [
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "index";
            }
          ];
          right = [
            {
              id = "Network";
            }
            {
              id = "Volume";
            }
            {
              id = "NotificationHistory";
            }
            {
              id = "Tray";
            }
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
          ];
        };
      };

      location = {
        monthBeforeDay = true;
        name = "Karlsruhe, Germany";
      };
    };
  };
}
