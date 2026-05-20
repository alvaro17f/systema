{
  description = "systema";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        name = "systema";

        pkgs = import nixpkgs { inherit system; };

        version = pkgs.lib.fileContents ./VERSION;

        buildInputs = with pkgs; [ odin ];
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = name;
          src = ./.;
          buildInputs = buildInputs;
          buildPhase = ''
            odin build . -define="VERSION=${version}" -o:speed -out:${name}
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp ${name} $out/bin
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = buildInputs;
        };
      }
    );
}
