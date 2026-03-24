{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.stylix.homeModules.stylix];

  home.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-color-emoji
  ];

  stylix = {
    enable = true;
    autoEnable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";

    image = ./Wallpapers/TreeLake.png;
    polarity = "dark";

    fonts = {
      monospace = {
        name = "Jetbrains Mono";
        package = pkgs.jetbrains-mono;
      };
      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
      serif = {
        name = "Noto Serif";
        package = pkgs.noto-fonts;
      };
      emoji = {
        name = "Noto color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
    };
  };
}
