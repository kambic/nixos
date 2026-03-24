{
  pkgs,
  pkgs-stable,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Desktop apps
    kitty
    fuzzel
    thunderbird
    pkgs-stable.bottles
    vlc
    xivlauncher
    discord
    libreoffice
    protonplus
    inputs.zen-browser.packages.${pkgs.system}.default
    vscodium
    via
    forge-mtg
    blender

    # Coding
    nodejs
    gnumake
    libgcc

    # CLI utils
    tree
    git
    htop
    nix-index
    unzip
    zip
    ffmpeg
    yt-dlp
    bluez
    bluez-tools
    pciutils
    aria2
    rar
    unrar

    # GUI utils
    mako

    # Wayland
    xwayland
    wl-clipboard
    cliphist
    xwayland-satellite

    # LSP
    llvmPackages_20.clang-tools
    pkgs-stable.texlab
    nixd

    # Screenshots
    swappy
    grim
    slurp

    # Other
    home-manager
    mangohud
    swaybg
    alejandra
    wireplumber
  ];
}
