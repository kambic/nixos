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


  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    ensureDatabases = [ "kmc" ];
    ensureUsers = [

      {
        name = "alligator";
      }
      {
        name = "kmc";
        ensureDBOwnership = true;
      }

    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };

  system.stateVersion = "25.11";
}
