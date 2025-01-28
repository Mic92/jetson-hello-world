{
  description = "Development environment for this project";

  inputs = {
    nixpkgs.url = "git+https://github.com/TUM-DSE/nixpkgs.git?ref=nixos-24.11-backports&shallow=1";
    jetpack-nixos.url = "git+https://github.com/TUM-DSE/jetpack-nixos.git?shallow=1";
    jetpack-nixos.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = lib.systems.flakeExposed;
        perSystem =
          {
            inputs',
            pkgs,
            system,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                cudaSupport = true;
                # Only for jetson devices: https://en.wikipedia.org/wiki/CUDA#GPUs_supported
                # Faster compilation time?
                cudaCapabilities = [ "8.7" ];

              };
              overlays = [ (final: prev: { cudaPackages = inputs'.jetpack-nixos.legacyPackages.cudaPackages; }) ];
            };
            packages.default = pkgs.mkShell {
              packages = [
                pkgs.bashInteractive
                pkgs.python3Packages.torch
                pkgs.cudaPackages.cuda_nvcc
              ];
              shellHook = ''
                export CUDA_PATH=${pkgs.cudaPackages.cudatoolkit}
              '';
              LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
                "/run/opengl-driver"
              ];
            };
          };
      }
    );
}
