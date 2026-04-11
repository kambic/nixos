{
  user,
  inputs,
  ...
}: {
  imports = [
    inputs.niri.homeModules.niri
    ./modules/default.nix
  ];
# In home.nix
gtk = {
  enable = true;
  gtk4.theme = null; # This adopts the new default behavior
};
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "25.05";
  };
}
