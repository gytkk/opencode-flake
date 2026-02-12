{
  description = "OpenCode - pre-built binary from GitHub Releases";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem =
        f: nixpkgs.lib.genAttrs systems (system: f { pkgs = nixpkgs.legacyPackages.${system}; });
    in
    {
      packages = forEachSystem (
        { pkgs }:
        {
          opencode = pkgs.callPackage ./package.nix { };
          default = self.packages.${pkgs.system}.opencode;
        }
      );

      overlays.default = final: _prev: {
        opencode = final.callPackage ./package.nix { };
      };
    };
}
