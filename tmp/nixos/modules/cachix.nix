{pkgs, ...}: {
  environment.systemPackages = [pkgs.cachix];

  nix.settings = {
    substituters = [
      "https://ezkea.cachix.org"
      "https://niri.cachix.org"
    ];

    trusted-public-keys = [
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };
}
