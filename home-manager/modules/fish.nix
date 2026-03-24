{...}: {
  programs.fish = {
    enable = true;

    shellAliases = let
      flakeDir = "~/nix";
    in {
      rebuild = "sudo nixos-rebuild switch --flake ${flakeDir}";
      update = "sudo nix flake update --flake ${flakeDir}";
      upgrade = "sudo nixos-rebuild switch --upgrade --flake ${flakeDir}";
    };
  };
}
