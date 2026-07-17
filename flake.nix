{
  description = "Claude Desktop (official Linux beta) packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      packages.${system} = {
        default = pkgs.callPackage ./package.nix {};
        claude-desktop = self.packages.${system}.default;
      };

      overlays.default = final: prev: {
        claude-desktop = final.callPackage ./package.nix {};
      };
    };
}
