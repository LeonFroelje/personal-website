{
  description = "JavaScript/Node devShell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    nixvimModules.url = "github:LeonFroelje/nixvim-modules";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      nixvimModules,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "js-shell";
        packages = with pkgs; [
          nodejs_22
          typst
          corepack
          newcomputermodern
          lmmath
          fontconfig
          typescript-language-server
          (nixvimModules.lib.mkNvim [ nixvimModules.nixosModules.javascript ])
        ];
        shellHook = ''
          zsh
          export FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf
          mkdir -p ./public/fonts
          cp -u ${pkgs.newcomputermodern}/share/fonts/opentype/* ./public/fonts/ 2>/dev/null || true
        '';
      };
    };
}
