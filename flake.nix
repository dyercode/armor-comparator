{
  description = "Armor comparing app for some ancient rpg";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    dev.url =
      "github:dyercode/dev?rev=ffbbd50d25307bcbd3512996ba1a8db0e8b4d385";
  };

  outputs = { self, nixpkgs, flake-utils, dev }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            dev.defaultPackage.${system}
            yarn
            buildah
            fish
          ];

          shellHook = ''
            export RUNNER="podman"
            export BUILDER="buildah"
          '';
        };
      });
}
