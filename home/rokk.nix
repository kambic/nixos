
{ config, pkgs, ... }:

{
  home.username = "rokk";
  home.homeDirectory = "/home/rokk";

  programs.home-manager.enable = true;

  # Cursor (KDE respects this better via HM)
  home.pointerCursor = {
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    size = 24;
  };

  # Fonts (force KDE to behave)
  fonts.fontconfig.enable = true;

  # KDE Plasma settings
  programs.plasma = {
    enable = true;

    fonts = {
      general = "IBM Plex Sans,10";
      fixedWidth = "BlexMono Nerd Font,10";
    };

    # Optional but nice
    workspace = {
      clickItemTo = "select";
    };
  };
}