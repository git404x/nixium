let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  nix-minecraft = fetchTarball "https://github.com/Infinidoge/nix-minecraft/archive/master.tar.gz";
  
  pkgs = import nixpkgs {
    overlays = [ (import "${nix-minecraft}/overlay.nix") ];
  };

  # Helper that forces evaluation of the packwiz derivation to fetch the hash
  getModpack = path: pkgs.fetchPackwizModpack {
    url = "file://${path}/pack.toml";
    packHash = ""; 
  };
in {
  server = getModpack ./server;
  client = getModpack ./client;
}
