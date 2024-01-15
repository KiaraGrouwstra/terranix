{ lib, pkgs, ... }:

{
  resource.a_resource.with_template = {
    templated_field = lib.tf.ref (lib.tf.template {
      text = "A template that uses a packer \${variable}";
      variables = {
        variable = "some value with \${packer} templating";
      };
    });
    template_from_file = lib.tf.ref (lib.tf.template {
      source = pkgs.writeText "test-source" "A template sourced from file";
    });
  };
}
