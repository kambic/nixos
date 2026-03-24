{
  config,
  pkgs,
  inputs,
  dms,
  ...
}: {
  imports = [
    dms.homeModules.dank-material-shell
    dms.homeModules.niri
  ];

  programs.dank-material-shell = {
    enable = true;

    # Core features
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;

    # niri integration
    niri = {
      enableKeybinds = true;
      enableSpawn = true;

      includes = {
        enable = true;
        override = true;
        filesToInclude = [
          "alttab"
          "binds"
          "colors"
          "layout"
          "outputs"
          "wpblur"
        ];
      };
    };
  };
}
