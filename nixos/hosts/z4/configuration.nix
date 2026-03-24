{ config, pkgs, ... }:

{
  imports = [
    ../../common.nix
    ./hardware-configuration.nix

  ];

  #################################
  # Boot
  #################################

  boot = {
    kernelParams = [
      "loglevel=3"
      "udev.log_level=3"
      "mitigations=off"
      "intel_pstate=active"
    ];

    extraModprobeConfig = ''
      options snd_hda_intel power_save=0
      options amdgpu ppfeaturemask=0xfff7ffff freesync_video=1 dpm=1 runpm=0
      options hid_apple fnmode=0
    '';
  };

  zramSwap.enable = false;

  # ─── Nix settings ──────────────────────────────────────────────────────────
  nix.settings = {
    max-jobs = 6;
    cores = 2; # cores per individual builder process
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
  };

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

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
  };

  services.printing.enable = false;

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

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "25.11";
}
