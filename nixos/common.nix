{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./modules/default.nix
  ];

  #################################
  # Nix
  #################################

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    download-buffer-size = 524288000;
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
      theme = "stylix";
    };
  };

  # ─── ZRAM swap (prevents OOM freezes during heavy builds like Quickshell) ──
  # Creates a compressed RAM-backed swap device — no disk writes, much faster.
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # best compression/speed ratio
    # memoryPercent = 100 means the zram device can hold up to 100% of RAM
    # when compressed. Effective real swap is ~2-3x that in practice.
    memoryPercent = 100;
  };

  #################################
  # Networking
  #################################

  networking.networkmanager.enable = true;

  #################################
  # Locale
  #################################

  time.timeZone = "Europe/Ljubljana";
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

  # Themes
  stylix = {
    enable = true;
    polarity = "dark";
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    variables = {
      EDITOR = "nvim";
    };
  };

  #################################
  # System packages (minimal)
  #################################
  environment.systemPackages = with pkgs; [
    wget
    git
    neovim
    vscode
    glances
    fish
    ffmpeg
    htop
    vscode
    ripgrep
    tree-sitter
    nh
    nil
    nixd # lsp
    nixfmt
    nixfmt-tree
    home-manager

    pavucontrol

    alacritty
    kitty

    git
    lazygit

    nh
    fuzzel
    wl-clipboard
    swaybg
    swaylock
    swayidle
    xwayland-satellite

    # Notifications
    libnotify
    mako
  ];

  #################################
  # State
  #################################

  system.stateVersion = "25.11";
}