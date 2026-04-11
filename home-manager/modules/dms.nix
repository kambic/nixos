{
  config,
  pkgs,
  inputs,
  dms,
  ...
}: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;
  };
}
