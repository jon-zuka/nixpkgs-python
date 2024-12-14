{
  description = "Jon Zuka's python flake";
  inputs = {
    nixpkgs = {
      url = "https://flakehub.com/f/NixOS/nixpkgs/0.2411.710315.tar.gz";
    };

    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, pyproject-nix, uv2nix }:
    let
      inherit (nixpkgs) lib;
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f:
        nixpkgs.lib.genAttrs supportedSystems
        (system: f { pkgs = import nixpkgs { inherit system; }; });
      overlay = import ./default.nix { inherit uv2nix pyproject-nix lib; };
    in {
      overlay.default = overlay;
      packages = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.python3;
        hello-world = pkgs.callPackage ./packages/hello-world { };
      });
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = [ (pkgs.onlyBin pkgs.uv) pkgs.python3 pkgs.npins ];
          env.UV_NO_SYNC = 1;
        };
      });
    };
}
