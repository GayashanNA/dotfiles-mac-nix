{
  description = "Minimal macOS Nix setup with nix-darwin + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
    let
      # hostSpec: per-machine facts (username, email, homebrew extras…).
      # Shared config lives in nix/host.nix + nix/user.nix; hosts differ
      # only by what's declared in nix/hosts/<host>.nix.
      mkDarwin = hostSpec:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit hostSpec; };
          modules = [
            ./nix/host.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit hostSpec; };
              home-manager.users.${hostSpec.username} = import ./nix/user.nix;
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        mac = mkDarwin (import ./nix/hosts/personal.nix);
        work = mkDarwin (import ./nix/hosts/work.nix);
      };
    };
}
