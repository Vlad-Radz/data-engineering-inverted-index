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

    http = {
      version = "2.1.0"
    }
  }
}