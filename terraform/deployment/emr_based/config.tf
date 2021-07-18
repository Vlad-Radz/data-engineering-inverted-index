terraform {

  /*
  backend "s3" {
    encrypt = true
  }
  */

  required_providers {
    aws = {
      version = "~> 3.0"
    }

    random = {
      version = "3.1.0"
    }
  }
}