{
  config,
  pkgs,
  pkgs-stable,
  inputs,
  ...
}:
{
  imports = [
    ./modules/default.nix
  ];

  #################################
  # Nix
  #################################


  # gpu driver stuff
  hardware.graphics = {
    enable = true;

  };

  services.flatpak.enable = true;

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  nix.settings = {
    # max-jobs = 6;
    # cores = 2; # cores per individual builder process
    substituters = [
      "https://cache.nixos.org"
      "https://noctalia.cachix.org"
      "https://niri.cachix.org" # ← niri-flake binary cache
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "noctalia.cachix.org-1:FZ3ALcCPf2vd5ZfNMT1v3yLVaSN/yHjFyJJv6VGy7MY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfry9N242KbEMHfDLqJbfnssqvFiM=" # ← niri-flake key
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    download-buffer-size = 524288000;
    # nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  #################################
  # Boot
  #################################

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };

    kernelPackages = pkgs.linuxPackages;

    kernelParams = [
      "quiet"
      "splash"
      "nowatchdog"
    ];

    # Tune kernel swap behaviour so RAM is preferred over zram until necessary
    kernel.sysctl = {
      "kernel.sysrq" = 1;
    };

    consoleLogLevel = 3;
    initrd.verbose = false;

    plymouth = {
      enable = true;
      #   theme = "catppuccin-mocha";
    };
  };

  # ─── ZRAM swap (prevents OOM freezes during heavy builds like Quickshell) ──
  # Creates a compressed RAM-backed swap device — no disk writes, much faster.
  #   zramSwap = {
  #     enable = true;
  #     algorithm = "zstd"; # best compression/speed ratio
  #     # memoryPercent = 100 means the zram device can hold up to 100% of RAM
  #     # when compressed. Effective real swap is ~2-3x that in practice.
  #     memoryPercent = 100;
  #   };

  #################################
  # Networking
  #################################

  networking.networkmanager.enable = true;

  #################################
  # Locale
  #################################

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sl_SI.UTF-8";
    LC_IDENTIFICATION = "sl_SI.UTF-8";
    LC_MEASUREMENT = "sl_SI.UTF-8";
    LC_MONETARY = "sl_SI.UTF-8";
    LC_NAME = "sl_SI.UTF-8";
    LC_NUMERIC = "sl_SI.UTF-8";
    LC_PAPER = "sl_SI.UTF-8";
    LC_TELEPHONE = "sl_SI.UTF-8";
    LC_TIME = "sl_SI.UTF-8";
  };

  #################################
  # Audio
  #################################

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true;

  #################################
  # Programs
  #################################

  programs.firefox.enable = true;
  programs.mtr.enable = true;

  #################################
  # Fonts
  #################################

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      font-awesome
      liberation_ttf
      noto-fonts
      nerd-fonts.fira-code
      inter
      roboto
    ];

    fontconfig.defaultFonts = {
      serif = [ "Liberation Serif" ];
      sansSerif = [ "Inter" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    variables = {
      EDITOR = "nvim";
    };
  };


  security.sudo.extraRules = [
    {
      users = [
        "rokk"
        "kmc"
      ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  users.users = {

    kmc = {
      isNormalUser = true;
      description = "Rok Kambic";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };

    rokk = {
      isNormalUser = true;
      description = "Rok Kambic";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsnY4xKXJzMqSOMVXb7P771QAkL+paZxLDt6nAHkTPO kamba@master"
      ];
      packages = with pkgs; [
        kdePackages.kate
      ];
    };

  };


  #################################
  # System packages (minimal)
  #################################
  environment.systemPackages = with pkgs; [
    # Development
    wget
    git
    neovim
    vscode
    jetbrains.pycharm
    vscodium
    glances
    fish
    ffmpeg
    htop
    ripgrep
    tree-sitter
    nh
    nil
    nixd # lsp
    nixfmt
    nixfmt-tree
    home-manager
    nodejs
    gnumake
    libgcc
    llvmPackages_20.clang-tools

    # Desktop apps
    kitty
    alacritty
    fuzzel
    thunderbird
    vlc
    discord
    libreoffice
    blender
    mangohud
    via

    # CLI utils
    tree
    nix-index
    unzip
    zip
    yt-dlp
    bluez
    bluez-tools
    pciutils
    aria2
    rar
    unrar
    lazygit
    alejandra
    wireplumber

    # GUI utils
    pavucontrol
    mako
    swappy

    # Wayland
    xwayland
    xwayland-satellite
    wl-clipboard
    cliphist
    swaybg
    swaylock
    swayidle

    # Notifications
    libnotify

    # Stable packages
    pkgs-stable.bottles
    pkgs-stable.texlab

    # From flake inputs
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    xivlauncher
    protonplus
    forge-mtg
  ];
}
