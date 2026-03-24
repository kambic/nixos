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
    ../../common.nix
    ./hardware-configuration.nix
  ];

  #################################
  # Boot
  #################################

  boot = {
    loader = {
      systemd-boot.xbootldrMountPoint = "/boot";

      efi = {
        efiSysMountPoint = "/efi";
      };
    };

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

    pipewire.wireplumber.enable = true;

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
  # Power
  #################################

  powerManagement.cpuFreqGovernor = "schedutil";

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
  };

  #################################
  # Programs
  #################################

  programs = {
    zsh.enable = true;
    fish.enable = true;

    waybar.enable = true;
    seahorse.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Themes
  stylix = {
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

  environment.variables = {
    TESTKO = "zen-beta";
  };
}
