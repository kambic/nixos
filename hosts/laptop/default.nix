{ pkgs, inputs, ... }:

{
  # ─── Basic system ──────────────────────────────────────────────────────────
  time.timeZone = "Europe/Ljubljana"; # ← change to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "nixer"; # ← change to your hostname

  # ─── Bootloader ────────────────────────────────────────────────────────────
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.xbootldrMountPoint = "/boot";

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
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

  # Tune kernel swap behaviour so RAM is preferred over zram until necessary
  boot.kernel.sysctl = {
    "vm.swappiness" = 180; # high swappiness is correct for zram (not disk)
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0; # zram works best with single-page reads

    # Magic SysRq — Alt+SysRq(PrtSc)+key for emergency recovery
    # 1 = all functions enabled (safe for personal laptop)
    "kernel.sysrq" = 1;
  };

  # ─── Nix settings ──────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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
  nixpkgs.config.allowUnfree = true;

  # ─── User account ──────────────────────────────────────────────────────────
  users.users.kmc = {
    # ← change "user" everywhere
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "input"
    ];
    shell = pkgs.bash;
  };

  # ─── Wayland / Niri prerequisites ──────────────────────────────────────────
  # Niri registers itself as a display-manager-free session
  programs.niri.enable = true;

  # XDG portals — needed for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  # ─── Graphics ──────────────────────────────────────────────────────────────
  hardware.graphics.enable = true;

  # Uncomment one block if you need proprietary GPU drivers:
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = { modesetting.enable = true; open = false; };

  # ─── Audio (PipeWire) ──────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ─── Noctalia system services ───────────────────────────────────────────────
  # These are required for Noctalia's wifi / bluetooth / power widgets
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # ─── Fonts ─────────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    inter
    roboto
  ];

  # ─── Minimal system packages ───────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git
    htop
    glances
    curl
    wget
    wl-clipboard # clipboard in Wayland
    xwayland-satellite # optional: run X11 apps seamlessly
  ];

  # ─── PAM (required by Noctalia's lock screen) ──────────────────────────────
  security.pam.services.login = { };

  system.stateVersion = "25.05";
}
