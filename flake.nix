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
          (nixvimModules.lib.mkNvim [
            nixvimModules.nixosModules.javascript
            ({ lib, ... }: {
              plugins.lsp.servers.astro.enable = true;
              plugins.lsp.servers.astro.settings = {
                before_init = lib.nixvim.mkRaw ''
                  function(config, root_dir)
                    config.init_options = config.init_options or {}
                    config.init_options.typescript = config.init_options.typescript or {}
                    local tsdk = vim.fs.find('node_modules/typescript/lib', { path = root_dir, upward = true })[1]
                    config.init_options.typescript.tsdk = tsdk
                      or "${pkgs.typescript}/lib/node_modules/typescript/lib"
                  end
                '';
              };
              plugins.lsp.servers.cssls.enable = true;
            })
          ])
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
