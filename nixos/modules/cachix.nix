{pkgs, ...}: {
  environment.systemPackages = [pkgs.cachix];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    substituters = [
      "https://ezkea.cachix.org"
      "https://niri.cachix.org"
    ];

    trusted-public-keys = [
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];

    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    download-buffer-size = 524288000;
    # nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
