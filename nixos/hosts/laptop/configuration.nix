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
      "amd_pstate=active"
      "amdgpu.gpu_recovery=1"
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
    };
  # Logind
  # https://www.freedesktop.org/software/systemd/man/latest/logind.conf.html
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "ignore";
    HandlePowerKey = "hibernate";
    HandlePowerKeyLongPress = "poweroff";
  };

  # ─── Nix settings ──────────────────────────────────────────────────────────
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

  networking.hostName = "t14";

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
      PasswordAuthentication = true;
    };
  };

  system.stateVersion = "25.11";
}
