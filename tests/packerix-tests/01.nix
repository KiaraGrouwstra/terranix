{ ... }:
{

  backend.s3 = {
    bucket = "some-where-over-the-rainbow";
    key = "my-packer-state.tfstate";
    region = "eu-central-1";
  };

}
