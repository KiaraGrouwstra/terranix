# DESCRIPTION

Packerix is a NixOS way to generate terraform json.
You can create modules like you would in NixOS.

path
: path to the `config.nix`.
If not given it will use the `config.nix` in the current folder.

## Run Examples

To create a JSON file out of a `config.nix` run

```shell
packerix | jq
```

To create a JSON file out of a file `./path/my-config.nix` run

```shell
packerix ./path/my-config.nix | jq
```

To create a JSON file and run terraform

```shell
packerix > config.tf.json && terraform init && terraform apply
```
