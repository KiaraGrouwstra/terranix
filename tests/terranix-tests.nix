[
  {
    text = "backend : setting a backend";
    file = ./packerix-tests/01.nix;
    outputFile = ./packerix-tests/01.nix.output;
  }
  {
    text = "backend : setting 2 packerixs will fail";
    file = ./packerix-tests/02.nix;
    success = false;
    outputFile = ./packerix-tests/02.nix.output;
    partialMatchOutput = true;
  }
  {
    text = "remote_state : 2 remote states with the same names are forbidden";
    file = ./packerix-tests/03.nix;
    success = false;
    outputFile = ./packerix-tests/03.nix.output;
    partialMatchOutput = true;
  }
  {
    text = "remote_state : 2 remote states with differente names are ok";
    file = ./packerix-tests/04.nix;
    outputFile = ./packerix-tests/04.nix.output;
  }
  {
    text = "assert : don't trigger error on true mkAssert";
    file = ./packerix-tests/05.nix;
    outputFile = ./packerix-tests/05.nix.output;
  }
  {
    text = "assert : trigger error on false mkAssert";
    file = ./packerix-tests/06.nix;
    success = false;
    outputFile = ./packerix-tests/06.nix.output;
    partialMatchOutput = true;
  }
  {
    text = "strip-nulls: print no nulls without --with-nulls";
    file = ./packerix-tests/07.nix;
    outputFile = ./packerix-tests/07.nix.output;
  }
  {
    text = "strip-nulls: print nulls with --with-nulls";
    options = [ "--with-nulls" ];
    file = ./packerix-tests/07.nix;
    outputFile = ./packerix-tests/07-nulls.nix.output;
  }
  {
    text = "magic-merge: works for attrs and lists";
    file = ./packerix-tests/08-magic-merge.nix;
    outputFile = ./packerix-tests/08-magic-merge.nix.output;
  }
  {
    text = "magic-merge: fails for setting different types";
    file = ./packerix-tests/09-magic-merge-fail.nix;
    success = false;
  }
  {
    text = "magic-merge: leave empty sets untouched";
    file = ./packerix-tests/10-empty-sets.nix;
    outputFile = ./packerix-tests/10-empty-sets.nix.output;
  }
  {
    text = "empty resources: should be filtered out";
    file = ./packerix-tests/11.nix;
    outputFile = ./packerix-tests/11.nix.output;
  }
  {
    text = "packerix lib: tfRef should be available and properly return a reference";
    file = ./packerix-tests/12.nix;
    outputFile = ./packerix-tests/12.nix.output;
  }
  {
    text = "references: should properly reference references and data from config";
    file = ./packerix-tests/13.nix;
    outputFile = ./packerix-tests/13.nix.output;
  }
  {
    text = "packerix lib: tf.ref.template should be available and properly return a templatefile() invocation";
    file = ./packerix-tests/14.nix;
    outputFile = ./packerix-tests/14.nix.output;
  }
]
