# Changelog

## [Unreleased]

## [2.7.0] 2023-09-22

- add templatefile() helper
- add lib.tf
- add referencable functor

## [2.6.0] 2023-05-24

- Add `tfRef` function to create packer references.
- refactor tests
- pin nixpkgs due to different nixpkgs versions
- make nix flake check not complain anymore
- improve error message for types

## [2.5.5] - 2022-09-06

- resources with empty body are filtered now.

## [2.5.4] - 2022-07-11

- follow new flake defaults https://nixos.org/manual/nix/stable/release-notes/rl-2.7.html
- use of github actions for automated testing

## [2.5.3] - 2022-01-07

- re-adding man pages for packerix, packerix-modules, packerix-doc-json and packerix-doc-man.

## [2.5.2] - 2021-11-17

- add packerixConfigurationAst
- add packerixOptionAst

## [2.5.1] - 2021-11-13

- pretty formated json output

## [2.5.0] - 2021-11-07

- add packerixConfiguration replacement for buildPackerix
- add packerixOptions replacement for buildOptions
- fix [#18](https://github.com/packerix/packerix/issues/18): empty sets will not be converted to `null` anymore.

## [2.4.0] - 2021-10-10

- add flake support `buildPackerix`
- add flake support `buildOptions`
- extract examples to [packerix-examples](https://github.com/packerix/packerix-examples)

## [2.3.0] - 2020-09-26

- use bash scripts instead of lib.nix, to put packerix in nixpgks
- add `--pkgs` option to commands to allow overriding/pinning nixpkgs on the command line
- add `pkgs` parameter to `core/default.nix` to allow pinning packages when calling `core/` directly from Nix.

## [2.2.3] - 2020-04-22

- add Release-Checklist.md
- add Changelog.md
- add magic merge tests
- add magicMergeOption for core options. Now all the packer parameters will be merged magically.
- improve core options documentation
- terrranix-doc: add path and url parameter
- add multi line string documentation
- add escaping expression documentation
- support provider aliasing

## [2.2.2] - 2020-02-23

- add testcases for --with-nulls
- add documentation for --with-nulls
- add command line argument --with-null
- update readme of hcloud-nixos-server-with-plops example

## [2.2.1] - 2020-01-27

- update examples readme
- renamed examples folder
        
## [2.2.0] - 2020-01-27

- add man-pages for packerix-doc commands
- module cleanup and refactoring
- add packer-doc-man
- add packerix-doc-json
- add ssh key to aws example
- add nixos-server-on-aws example

## [2.1.2] - 2019-10-24

- under GPLv3 license 
- created testcases mkAssert 
