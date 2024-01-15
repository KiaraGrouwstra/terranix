[
  {
    text = "packerix-doc-json: works with simple module";
    path = ./packerix-doc-json-tests;
    file = "${./packerix-doc-json-tests}/01.nix";
    outputFile = ./packerix-doc-json-tests/01.nix.output;
  }

  {
    text = "packerix-doc-json: works with empty module";
    file = ./packerix-doc-json-tests/02.nix;
    outputFile = ./packerix-doc-json-tests/02.nix.output;
  }
]
