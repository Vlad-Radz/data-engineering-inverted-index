# These definition are equal for "eks_based" and "emr_based" -> put into 1 file into another location, to avoid redundancy!

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile which is used for the deployment"
}

variable "aws_shared_credentials_file" {
  type        = string
  default     = "~/.aws/credentials"
  description = "Location of the AWS CLI credentials"
}

variable role_arn {}

variable cluster_name {}