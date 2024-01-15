# core options
#

{ lib, ... }:

with lib;

let
  mkMagicMergeOption = { description ? "", example ? { }, default ? { }, apply ? id, ... }:
    mkOption {
      inherit example description default apply;
      type = with lib.types;
        let
          valueType = nullOr
            (oneOf [
              bool
              int
              float
              str
              (attrsOf valueType)
              (listOf valueType)
            ]) // {
            description = "bool, int, float or str";
            emptyValue.value = { };
          };
        in
        valueType;
    };

  mkReferenceableOption = { referencePrefix ? "", ... }@args:
    mkMagicMergeOption (args // {
      apply =
        let
          mapAttrsOrSkip = f: attrs:
            if isAttrs attrs then mapAttrs f attrs else attrs;
        in
        mapAttrsOrSkip (type: v1:
          mapAttrsOrSkip
            (label: v2:
              if isAttrs v2
              then v2 // { __functor = self: attr: "\${${referencePrefix}${type}.${label}.${attr}}"; }
              else v2)
            v1);
    });
in
{

  options = {
    data = mkReferenceableOption {
      referencePrefix = "data.";
      description = ''
        Data objects, are queries to use resources which
        are already exist, as if they are created by a the resource
        option.
        See for more details : https://www.packer.io/docs/configuration/data-sources.html
      '';
    };
    locals = mkMagicMergeOption {
      example = {
        locals = {
          service_name = "forum";
          owner = "Community Team";
        };
      };
      description = ''
        Define packer variables with file scope.
        Like modules this is packer intern and packerix has better ways.
        See for more details : https://www.packer.io/docs/configuration/locals.html
      '';
    };
    module = mkMagicMergeOption {
      example = {
        module.consul = { source = "github.com/hashicorp/example"; };
      };
      description = ''
        A packer module, to define multiple resources,
        for sharing or duplication.
        The packer module system, and has nothing to
        do with the module system of packerix or nixos.
        See for more details : https://www.packer.io/docs/configuration/modules.html
      '';
    };
    output = mkMagicMergeOption {
      example = {
        output.instance_ip_addr.value = "aws_instance.server.private_ip";
      };
      description = ''
        Useful in combination with packer_remote_state.
        See for more details : https://www.packer.io/docs/configuration/outputs.html
      '';
    };
    provider = mkMagicMergeOption {
      example = {
        provider.google = {
          project = "acme-app";
          region = "us-central1";
        };
      };
      description = ''
        Define you API connection.
        Don't use secrets in here, they will be visible in the nix-store and the resulting
        config.tf.json. Instead use packer variables.
        See for more details : https://www.packer.io/docs/configuration/providers.html
        or https://www.packer.io/docs/providers/index.html
      '';
    };
    resource = mkReferenceableOption {
      example = {
        resource.aws_instance.web = {
          ami = "ami-a1b2c3d4";
          instance_type = "t2.micro";
        };
      };
      description = ''
        The backbone of packer and packerix to change and create state.
        See for more details : https://www.packer.io/docs/configuration/resources.html
      '';
    };
    variable = mkMagicMergeOption {
      example = {
        variable.image_id = {
          type = "string";
          description =
            "The id of the machine image (AMI) to use for the server.";
        };
      };
      description = ''
        Input Variables, which can be set by `--var=name` or by environment variables prefixt with `TF_VAR_`.
        Usually used in packer modules or to ask for API tokens.
        See for more details : https://www.packer.io/docs/configuration/variables.html
      '';
    };
    packer = mkReferenceableOption {
      referencePrefix = "packer.";
      example = {
        packer = {
          required_plugins = {
            happycloud = {
              version = ">= 2.7.0";
              source = "github.com/hashicorp/happycloud";
            };
          };
        };
      };
      description = ''
        The packer configuration block type is used to configure some behaviors
        of Packer itself, such as the minimum required Packer version
        needed to apply your configuration.
        See for more details : https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
      '';
    };
    build = mkReferenceableOption {
      referencePrefix = "build.";
      example = {
        build = {
          name = "a";
          sources = [
            "sources.null.first-example"
            "sources.null.second-example"
          ];
        };
      };
      description = ''
        The `build` block defines what builders are started,
        how to `provision` them and if necessary
        what to do with their artifacts using `post-process`.
        See for more details : https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
      '';
    };
    source = mkReferenceableOption {
      referencePrefix = "source.";
      example = {
        source = {
          "source.happycloud.example" = {
            image_name = "build_specific_field";
          };
        };
      };
      description = ''
        The top-level `source` block defines reusable builder configuration blocks.
        The build-level `source` block allows to set specific source fields.
        Each field must be defined only once
        and it is currently not allowed to override a value.
        See for more details : https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
      '';
    };
    post-processor = mkReferenceableOption {
      referencePrefix = "post-processor.";
      example = {
        post-processor = {
          "checksum" = {
            checksum_types = [ "md5" "sha512" ];
            keep_input_artifact = true;
          };
        };
      };
      description = ''
        The `post-processor` block defines how a post-processor is configured.
        See for more details : https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/post-processor
      '';
    };
    post-processors = mkReferenceableOption {
      referencePrefix = "post-processors.";
      example = {
        post-processors = {
          "shell-local" = {
            inline = [ "echo hello > artifice.txt" ];
          };
          "artifice" = {
            files = ["artifice.txt"];
          };
          "checksum" = {
            checksum_types = [ "md5" "sha512" ];
            keep_input_artifact = true;
          };
        };
      };
      description = ''
        The `post-processors` block allows to define lists of `post-processors`,
        that will run from the artifact of each build.
        See for more details : https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/post-processors
      '';
    };
  };
}
