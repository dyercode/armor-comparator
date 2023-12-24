{
  description = "Armor comparing app for some ancient rpg";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    dev.url = "github:dyercode/dev";
    container.url = "github:dyercode/cnt";
  };

  outputs = { self, nixpkgs, flake-utils, dev, container }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs;
            [
              dev.packages.${system}.default
              container.defaultPackage.${system}
              yarn
              buildah
              fish
            ] ++ (with pkgs.elmPackages; [
              elm-coverage
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
      });
}
