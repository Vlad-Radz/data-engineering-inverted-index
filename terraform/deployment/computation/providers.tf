
provider "aws" {
  region = var.aws_region
  shared_credentials_file = var.aws_shared_credentials_file
  profile = var.aws_profile
  assume_role {
    role_arn     = var.role_arn
  }
}

provider "random" {}