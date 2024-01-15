{
  description = "packerix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-unfree = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    # packerix-examples.url = "github:packerix/packerix-examples";
    bats-support = {
      url = "github:bats-core/bats-support";
      flake = false;
    };
    bats-assert = {
      url = "github:bats-core/bats-assert";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    # , packerix-examples
    , bats-support
    , bats-assert
    , nixpkgs-unfree
    }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      # nix build
      packages.packerix = pkgs.callPackage ./default.nix {
        # as long nix flake is an experimental feature;
        nix = pkgs.nixUnstable;
      };
      # nix build "manpages"
      packages.manpages = (pkgs.callPackage ./doc/default.nix { }).manPages;
      packages.default = self.packages.${system}.packerix;
      # TODO: Legacy attribute, drop soon
      defaultPackage = self.packages.${system}.default;

      # nix develop
      devShells.default = pkgs.mkShell {
        buildInputs =
          [
            nixpkgs-unfree.legacyPackages.${system}.packer
            self.packages.${system}.packerix
            pkgs.treefmt
            pkgs.nixpkgs-fmt
            pkgs.shfmt
            pkgs.shellcheck
            pkgs.nodePackages.prettier
          ];
      };
      # TODO: Legacy attribute, drop soon
      devShell = self.devShells.${system}.default;

      # nix run
      apps.default = self.apps.${system}.test;
      # TODO: Legacy attribute, drop soon
      defaultApp = self.apps.${system}.default;
      # nix run ".#test"
      apps.test =
        let
          tests = import ./tests/test.nix {
            inherit nixpkgs;
            inherit pkgs;
            inherit (pkgs) lib;
            packerix = self.packages.${system}.packerix;
          };
          testFile = pkgs.writeText "test" ''
            load '${bats-support}/load.bash'
            load '${bats-assert}/load.bash'
            ${pkgs.lib.concatStringsSep "\n" tests}
          '';
        in
        {
          type = "app";
          program = toString (pkgs.writeShellScript "test" ''
            set -e
            echo "running packerix tests" | ${pkgs.boxes}/bin/boxes -d ian_jones -a c
            #cat ${testFile}
            ${pkgs.bats}/bin/bats ${testFile}
          '');
        };
      # nix run ".#docs"
      apps.doc = self.apps.${system}.docs;
      apps.docs = {
        type = "app";
        program = toString (pkgs.writeShellScript "docs" ''
          set -e
          export PATH=${pkgs.pandoc}/bin:$PATH
          ${pkgs.gnumake}/bin/make --always-make --directory=doc
          nix build ".#manpages"
          cp -r result/share .
          chmod -R 755 ./share
          rm result
        '');
      };

      formatter = pkgs.treefmt;
    })) // {

      # packerConfiguration ast, if you want to run
      # packerix in the repl.
      lib.packerixConfigurationAst =
        { system ? ""
        , pkgs ? builtins.getAttr system nixpkgs.outputs.legacyPackages
        , extraArgs ? { }
        , modules ? [ ]
        , strip_nulls ? true
        }:
        import ./core/default.nix {
          inherit pkgs extraArgs strip_nulls;
          packerix_config.imports = modules;
        };

      # packerixOptions ast, if you want to run
      # packerix in a repl.
      lib.packerixOptionsAst =
        { system ? ""
        , pkgs ? builtins.getAttr system nixpkgs.outputs.legacyPackages
        , modules ? [ ]
        , moduleRootPath ? "/"
        , urlPrefix ? ""
        , urlSuffix ? ""
        }:
        import ./lib/packerix-doc-json.nix {
          packerix_modules = modules;
          inherit moduleRootPath urlPrefix urlSuffix pkgs;
        };

      # create a config.tf.json.
      # you have to either have to name a system or set pkgs.
      lib.packerixConfiguration =
        { system ? ""
        , pkgs ? builtins.getAttr system nixpkgs.outputs.legacyPackages
        , extraArgs ? { }
        , modules ? [ ]
        , strip_nulls ? true
        }:
        let
          packerixCore = import ./core/default.nix {
            inherit pkgs extraArgs strip_nulls;
            packerix_config.imports = modules;
          };
        in
        (pkgs.formats.json { }).generate "config.tf.json" packerixCore.config;

      # create a options.json.
      # you have to either have to name a system or set pkgs.
      lib.packerixOptions =
        { system ? ""
        , pkgs ? builtins.getAttr system nixpkgs.outputs.legacyPackages
        , modules ? [ ]
        , moduleRootPath ? "/"
        , urlPrefix ? ""
        , urlSuffix ? ""
        }:
        let
          packerixOptions = import ./lib/packerix-doc-json.nix {
            packerix_modules = modules;
            inherit moduleRootPath urlPrefix urlSuffix pkgs;
          };
        in
        pkgs.runCommand "packerix-options" { }
          ''
            cat ${packerixOptions}/options.json | \
              ${pkgs.jq}/bin/jq '
                del(.data) |
                del(.locals) |
                del(.module) |
                del(.output) |
                del(.provider) |
                del(.resource) |
                del(.packer) |
                del(.variable)
                ' > $out
          '';

      # deprecated
      lib.buildPackerix = nixpkgs.lib.warn "buildPackerix will be removed in 3.0.0 use packerixConfiguration instead"
        ({ pkgs, packerix_config, ... }@packerix_args:
          let packerixCore = import ./core/default.nix packerix_args;
          in
          pkgs.writeTextFile {
            name = "config.tf.json";
            text = builtins.toJSON packerixCore.config;
          });

      # deprecated
      lib.buildOptions =
        nixpkgs.lib.warn "buildOptions will be removed in 3.0.0 use packerixOptions instead"
          ({ pkgs
           , packerix_modules
           , moduleRootPath ? "/"
           , urlPrefix ? ""
           , urlSuffix ? ""
           , ...
           }@packerix_args:
            let
              packerixOptions = import ./lib/packerix-doc-json.nix packerix_args;
            in
            pkgs.stdenv.mkDerivation {
              name = "packerix-options";
              src = self;
              installPhase = ''
                mkdir -p $out
                cat ${packerixOptions}/options.json \
                  | ${pkgs.jq}/bin/jq '
                    del(.data) |
                    del(.locals) |
                    del(.module) |
                    del(.output) |
                    del(.provider) |
                    del(.resource) |
                    del(.packer) |
                    del(.variable)
                    ' > $out/options.json
              '';
            });

      # # nix flake init -t github:packerix/packerix#flake
      # templates = packerix-examples.templates // {
      #   default = packerix-examples.defaultTemplate;
      # };
      # # nix flake init -t github:packerix/packerix

      # # TODO: Legacy attribute, drop soon
      # defaultTemplate = self.templates.default;
    };
}
