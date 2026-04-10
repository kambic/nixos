{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  #################################
  # Boot
  #################################
  # ─── ZRAM swap (prevents OOM freezes during heavy builds like Quickshell) ──
  # Creates a compressed RAM-backed swap device — no disk writes, much faster.
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # best compression/speed ratio
    # memoryPercent = 100 means the zram device can hold up to 100% of RAM
    # when compressed. Effective real swap is ~2-3x that in practice.
    memoryPercent = 100;
  };
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
  };
  boot = {
    loader = {
      grub = {
        enable = true;
        device = "nodev"; # "nodev" is used for UEFI
        efiSupport = true;
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
    };
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
          options = ["NOPASSWD"];
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
