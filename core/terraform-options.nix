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

    # opentofu / terraform

    data = mkReferenceableOption {
      referencePrefix = "data.";
      description = ''
        Data objects, are queries to use resources which
        are already exist, as if they are created by a the resource
        option.
        See for more details : https://www.terraform.io/docs/configuration/data-sources.html
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
        Define terraform variables with file scope.
        Like modules this is terraform intern and terranix has better ways.
        See for more details : https://www.terraform.io/docs/configuration/locals.html
      '';
    };
    module = mkMagicMergeOption {
      example = {
        module.consul = { source = "github.com/hashicorp/example"; };
      };
      description = ''
        A terraform module, to define multiple resources,
        for sharing or duplication.
        The terraform module system, and has nothing to
        do with the module system of terranix or nixos.
        See for more details : https://www.terraform.io/docs/configuration/modules.html
      '';
    };
    output = mkMagicMergeOption {
      example = {
        output.instance_ip_addr.value = "aws_instance.server.private_ip";
      };
      description = ''
        Useful in combination with terraform_remote_state.
        See for more details : https://www.terraform.io/docs/configuration/outputs.html
      '';
    };
    required_providers = mkMagicMergeOption {
      example = {
        required_providers = 
          mycloud = {
            source  = "mycorp/mycloud";
            version = "~> 1.0";
          };
        };
      };
      description = ''
        Each Terraform module must declare which providers it requires,
        so that Terraform can install and use them.
        Provider requirements are declared in a `required_providers` block.
        See for more details : https://developer.hashicorp.com/terraform/language/providers/requirements
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
        config.tf.json. Instead use terraform variables.
        See for more details : https://www.terraform.io/docs/configuration/providers.html
        or https://www.terraform.io/docs/providers/index.html
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
        The backbone of terraform and terranix to change and create state.
        See for more details : https://www.terraform.io/docs/configuration/resources.html
      '';
    };
    provisioner = mkMagicMergeOption {
      example = {
        provisioner = {
          "local-exec" = {
            when    = "destroy";
            command = "echo 'Destroy-time provisioner'";
          };
        };
      };
      description = ''
        You can use provisioners to model specific actions on the local machine
        or on a remote machine in order to prepare servers
        or other infrastructure objects for service.
        See for more details : https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax
      '';
    };
    terraform = mkMagicMergeOption {
      example = {
        terraform = {
          backend.s3 = {
            bucket = "mybucket";
            key = "path/to/my/key";
            region = "us-east-1";
          };
        };
      };
      description = ''
        Terraform configuration.
        But for backends have a look at the terranix options
        backend.etcd, backend.local and backend.s3.
        See for more details : https://www.terraform.io/docs/configuration/terraform.html
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
        Usually used in terraform modules or to ask for API tokens.
        See for more details : https://www.terraform.io/docs/configuration/variables.html
      '';
    };
    cloud = mkMagicMergeOption {
      example = {
        cloud = {
          organization = "my-org";
          hostname = "app.terraform.io";
          workspaces = {
            project = "networking-development";
            tags = ["networking" "source:cli"];
          };
        };
      };
      description = ''
        The `cloud` block is a nested block within the top-level `terraform` settings block.
        It specifies which Terraform Cloud workspaces to use for the current working directory.
        See for more details : https://developer.hashicorp.com/terraform/cli/cloud/settings#the-cloud-block
      '';
    };

    # openbao / packer

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
