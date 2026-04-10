{
  config,
  pkgs,
  inputs,
  dms,
  ...
}: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  programs.dank-material-shell = {
    enable = true;
    niri = {
      enableKeybinds = true; # Sets static preset keybinds
      enableSpawn = true; # Auto-start DMS with niri, if enabled
    };

    # Core features
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;

    # Auto-start with systemd
    systemd.enable = true;
    systemd.restartIfChanged = true;
  };
}
