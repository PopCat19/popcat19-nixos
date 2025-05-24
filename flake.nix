# flake.nix
{
  description = "nixos config with som stuff idk";

  inputs = {
    # Pin nixpkgs to a specific channel for reproducibility.
    # Using nixos-unstable as per your hyprpanel example and likely preference.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # For a more stable setup, you could use a tagged release, e.g.:
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # Or your current NixOS version

    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      # It's often a good idea to make external flakes use the same nixpkgs
      # as your main configuration to ensure consistency and avoid
      # building/downloading multiple versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: If you plan to use Home Manager with Flakes in the future
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs
    # };
  };

  outputs = { self, nixpkgs, hyprpanel, ... }@inputs: let
    # Define the system architecture you are using.
    # "x86_64-linux" is common for most desktops/laptops.
    # Change if you use a different architecture (e.g., "aarch64-linux").
    system = "x86_64-linux";

    # === IMPORTANT: Set your hostname here ===
    # This name identifies your NixOS configuration within the flake.
    # It should ideally match `networking.hostName` if set in your `configuration.nix`,
    # or simply be a unique identifier for this machine's configuration.
    # Example: if your machine is named "desktop", use "desktop".
    # Your configuration.nix has `networking.hostName = "nixos";` commented out.
    # Let's use "nixos-hyprland" as an example.
    myHostname = "popcat19-nixos0"; # <<< CHANGE THIS TO YOUR ACTUAL HOSTNAME

  in {
    # NixOS configuration for your specific host
    nixosConfigurations."${myHostname}" = nixpkgs.lib.nixosSystem {
      inherit system;

      # Pass all flake inputs to your NixOS modules.
      # This allows modules to reference `inputs` if needed, e.g. `inputs.hyprpanel`.
      specialArgs = { inherit inputs; };

      modules = [
        # Apply the HyprPanel overlay. This makes `pkgs.hyprpanel`
        # available within your NixOS modules (like configuration.nix).
        { nixpkgs.overlays = [ inputs.hyprpanel.overlay ]; }

        # Import your main NixOS configuration file
        ./configuration.nix

        # Example for Home Manager (if you decide to use it later)
        # Make sure to uncomment `home-manager` in the `inputs` section above.
        # home-manager.nixosModules.home-manager
        # {
        #   home-manager = {
        #     useGlobalPkgs = true; # Use nixpkgs from the system
        #     useUserPackages = true; # Manage packages in user environment
        #     extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to home.nix
        #     # Assuming your username is 'popcat19' and you have a 'home.nix'
        #     users.popcat19 = import ./home.nix;
        #     # Or, define Home Manager config directly for a user:
        #     # users.popcat19 = { pkgs, ... }: {
        #     #   home.username = "popcat19";
        #     #   home.homeDirectory = "/home/popcat19";
        #     #   home.stateVersion = "24.11"; # Or your desired HM state version
        #     #   home.packages = [ pkgs.hyprpanel ]; # Example
        #     #   programs.git.enable = true;
        #     # };
        #   };
        # }
      ];
    };
  };
}
