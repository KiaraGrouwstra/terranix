# entry point for packerix

let
  configuration = import ./default.nix {
    packerix_config = { imports = [ <config> ]; };
  };
in

configuration.config
