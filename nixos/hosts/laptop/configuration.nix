{ config, pkgs, ... }:

let
  commonGroups = [
    "wheel"
    "networkmanager"
    "video"
    "input"
    "uucp"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
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
      systemd-boot.xbootldrMountPoint = "/boot";

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
    };

    kernelPackages = pkgs.linuxPackages;

    kernelParams = [
      "quiet"
      "splash"
      "amd_pstate=active"
      #      "acpi_backlight=native"
      "amdgpu.gpu_recovery=1"
      "nowatchdog"
      "acpi.ec_no_wakeup=1"
    ];

    kernelModules = [
      "kvm-amd"
      "thinkpad_acpi"
    ];

    # Tune kernel swap behaviour so RAM is preferred over zram until necessary
    kernel.sysctl = {
      "vm.swappiness" = 180; # high swappiness is correct for zram (not disk)
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0; # zram works best with single-page reads

      # Magic SysRq — Alt+SysRq(PrtSc)+key for emergency recovery
      # 1 = all functions enabled (safe for personal laptop)
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

  # Logind
  # https://www.freedesktop.org/software/systemd/man/latest/logind.conf.html
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "ignore";
    HandlePowerKey = "hibernate";
    HandlePowerKeyLongPress = "poweroff";
  };

  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 0;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 85;
    };
  };

  #################################
  # Networking
  #################################

  networking = {
    hostName = "nixer";
    networkmanager = {
      enable = true;

      ensureProfiles.profiles = {
        "MyWiFi" = {
          connection = {
            id = "MyWiFi";
            type = "wifi";
            autoconnect = true;
          };
          wifi = {
            ssid = "Loading...";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "kambic001";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };
  };
  #################################
  # Locale
  #################################

  time.timeZone = "Europe/Ljubljana";
  i18n.defaultLocale = "en_US.UTF-8";

  #################################
  # Wayland (Niri only)
  #################################

  programs.niri.enable = true;

  services = {
    libinput.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      xkb = {
        layout = "us";
        variant = "";
      };
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --asterisks --remember --time";
          user = "greeter";
        };
      };
    };

    pipewire = {
      enable = true;
      wireplumber.enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;

      pulse.enable = true;
    };

    gnome.gnome-keyring.enable = true;
    fwupd.enable = true;
    fprintd.enable = true;
    power-profiles-daemon.enable = false;

  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  #################################
  # Graphics
  #################################

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  #################################
  # Audio
  #################################

  #################################
  # Power
  #################################

  powerManagement.cpuFreqGovernor = "schedutil";

  #################################
  # Hardware services
  #################################

  #################################
  # Users
  #################################

  users.users = {
    rok = {
      isNormalUser = true;
      description = "Rok";
      shell = pkgs.zsh;
      extraGroups = commonGroups;
    };

    kmc = {
      isNormalUser = true;
      description = "Kmc";
      shell = pkgs.zsh;
      extraGroups = commonGroups;
    };
  };

  #################################
  # Security
  #################################

  security = {
    sudo.wheelNeedsPassword = false;
    polkit.enable = true;
    pam.services.swaylock = { };

    pam.services = {
      greetd-password.enableGnomeKeyring = true;
      greetd.enableGnomeKeyring = true;
      hyprland = {
        enableGnomeKeyring = true;
        gnupg.enable = true;
      };
      swaylock = {};
    };

    rtkit.enable = true;
  };

  #################################
  # Shells
  #################################

  #################################
  # Programs
  #################################

  programs = {
    zsh.enable = true;
    fish.enable = true;

    waybar.enable = true;
    firefox.enable = true;
    seahorse.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };

    # nix-ld.enable = true;
    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

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
    base16Scheme = ../../themes/no-clown-fiesta.yaml;
    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-dark";
      size = 24;
    };
    fonts = rec {
      sansSerif = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Sans";
      };

      serif = sansSerif;

      monospace = {
        package = pkgs.nerd-fonts.blex-mono;
        name = "BlexMono Nerd Font";
      };
    };
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    variables = {
      EDITOR = "nvim";
      TESTKO = "zen-beta";
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
