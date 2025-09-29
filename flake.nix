{
  description = "Armor comparing app for some ancient rpg";

  inputs = {
    dev.url = "github:dyercode/dev";
    container.url = "github:dyercode/cnt";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      dev,
      container,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs =
          with pkgs;
          [
            dev.packages.${system}.default
            container.packages.${system}.default
            yarn-berry
            buildah
            git
          ]
          ++ (with pkgs.elmPackages; [
            elm
            elm-test
            # elm-coverage # dead and removed from nix :/
            elm-format
            elm-review
            elm-json
          ]);

        shellHook = ''
          export RUNNER="podman"
          export BUILDER="buildah"
          export IMAGE="armor"
        '';
      };
    };
}
