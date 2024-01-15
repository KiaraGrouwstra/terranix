{ nixpkgs, pkgs, lib, packerix, ... }:
with lib;
let
  # example:
  #[ {
  #  text = "assert : don't trigger error on true mkAssert ";
  #  file = ./packerix-tests/05.nix;
  #  success = true;
  #  outputFile = ./packerix-tests/05.nix.output;
  #} ]
  packerix-tests = import ./packerix-tests.nix;
  packerix-test-template = { text, file, options ? [ ], success ? true, outputFile ? "", partialMatchOutput ? false, ... }:
    ''
      @test "${text}" {
      run ${packerix}/bin/packerix ${concatStringsSep " " options} --pkgs ${nixpkgs} --quiet ${file}

      # edit output to make sure no nix store paths are included
      # - they cause tests to fail depending on environment
      output=$(echo "$output" | sed 's|/nix/store/.*-|<nix store path>-|')

      ${if success then "assert_success" else "assert_failure"}
      ${optionalString (outputFile != "") "assert_output ${optionalString partialMatchOutput "--partial"} ${escapeShellArg (fileContents outputFile)}"}
      }
    '';


  packerix-doc-json-tests = import ./packerix-doc-json-tests.nix;
  packerix-doc-json-test-template = { text, path ? "", file, options ? [ ], success ? true, outputFile ? "", ... }:
    ''
      @test "${text}" {
      run ${packerix}/bin/packerix-doc-json --quiet ${optionalString (path != "") "--path ${path}"} ${concatStringsSep " " options} --pkgs ${nixpkgs} --quiet ${file}
      ${if success then "assert_success" else "assert_failure"}
      ${optionalString (outputFile != "") "assert_output ${escapeShellArg (fileContents outputFile)}"}
      }
    '';


in
(map packerix-test-template packerix-tests) ++
(map packerix-doc-json-test-template packerix-doc-json-tests)
