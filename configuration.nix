{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };

  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "udev.log_level=3"
    "mitigations=off"
    "intel_pstate=active"
    "nowatchdog"
  ];

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
    options amdgpu ppfeaturemask=0xfff7ffff freesync_video=1 dpm=1 runpm=0
    options hid_apple fnmode=0
  '';

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
    jetbrains.pycharm
    ripgrep
    bash-language-server
    fish-lsp
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

  networking.hostName = "nixos";
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
      users = [ "rokk" ];
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

  users.users.rokk = {
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

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
