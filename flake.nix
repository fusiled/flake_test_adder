{
  description = "A simple adder library";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";


    outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      package_name = "libadder";
      pkgs = system : import nixpkgs { inherit system; };

      derivRecipe = {system } : (pkgs(system)).stdenv.mkDerivation rec {
          pname = package_name;
          version = "0.0.1";

          src = ./.;

          buildPhase = ''
            $CXX -v --std=c++11  -dynamiclib -install_name $out/lib/libadder.dylib  -o libadder.dylib ./libadder.cpp;
        '';

        installPhase = ''
            mkdir -p $out/lib;
            mkdir -p $out/include;
            cp ./libadder.dylib $out/lib/;
            cp ./libadder.h $out/include;
        '';
        };

    in
    {
        packages = forAllSystems (system: {${package_name} = derivRecipe {system=system;};});
        defaultPackage = forAllSystems (system: self.packages.${system}.${package_name});
    };

}
