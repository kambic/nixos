{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

  ];

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
      "loglevel=3"
      "udev.log_level=3"
      "mitigations=off"
      "intel_pstate=active"
      "nowatchdog"
    ];

    extraModprobeConfig = ''
      options snd_hda_intel power_save=0
      options amdgpu ppfeaturemask=0xfff7ffff freesync_video=1 dpm=1 runpm=0
      options hid_apple fnmode=0
    '';

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
    enable = false;
    algorithm = "zstd"; # best compression/speed ratio
    # memoryPercent = 100 means the zram device can hold up to 100% of RAM
    # when compressed. Effective real swap is ~2-3x that in practice.
    memoryPercent = 100;
  };


  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
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
    home-manager
  ];
  environment.variables.EDITOR = "nvim";
  environment.etc."nixd/nixd.json".text = ''
    {
      "options": {
        "nixos": {
          "expr": "(import <nixpkgs/nixos> {}).options"
        }
      }
    }
  '';

  networking.hostName = "z4";
  networking.networkmanager.enable = true;

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

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
  };

  services.printing.enable = false;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

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

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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

  programs.firefox.enable = true;
  programs.mtr.enable = true;
  programs.yazi.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
stylix = {
  enable = true;
  polarity = "dark";
  base16Scheme = ../../themes/no-clown-fiesta.yaml;

  targets = {
    qt.enable = true;
    kde.enable = true; # if available in your Stylix version
  };

  cursor = {
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
    size = 24;
  };

  fonts = {
    sansSerif = {
      package = pkgs.ibm-plex;
      name = "IBM Plex Sans";
    };

    serif = {
      package = pkgs.ibm-plex;
      name = "IBM Plex Sans";
    };

    monospace = {
      package = pkgs.nerd-fonts.blex-mono;
      name = "BlexMono Nerd Font";
    };
  };
};
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
