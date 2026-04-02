{ pkgs, ... }:
{
  #programs.zsh.enable = true;
  programs.fish.enable = true;

  users = {
    defaultUserShell = pkgs.fish;

    users.kmc = {
      isNormalUser = true;
      description = "Rok Kambic";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
      ];
      packages = with pkgs; [ ];
    };
  };
}
