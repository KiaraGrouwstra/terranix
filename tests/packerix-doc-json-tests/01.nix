{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.testing-packerix;

in
{

  options.testing-packerix = {
    enable = mkEnableOption "enable testing-packerix";
  };

  config = mkIf cfg.enable { };
}
