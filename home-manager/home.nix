{user, ...}: {
  imports = [
    
  inputs.niri.homeModules.niri
    ./modules/default.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "25.05";
  };
}
