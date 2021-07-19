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

variable emr_cluster_name {}
variable emr_release {}
variable emr_apps {}
variable key_name {}
variable emr_master_instance_type {}
variable emr_master_ebs_size {}
variable emr_core_instance_type {}
variable emr_core_instance_count {}
variable emr_core_ebs_size {}
