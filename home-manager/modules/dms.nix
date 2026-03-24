{
  config,
  pkgs,
  inputs,
  dms,
  ...
}: {
  imports = [
    dms.homeModules.dank-material-shell
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

    # Auto-start with systemd
    systemd.enable = true;
    systemd.restartIfChanged = true;
  };
}
