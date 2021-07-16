variable "emr_cluster_name" {}
# variable "subnet_id" {}
variable "key_name" {}
variable "emr_release" {}
variable "emr_apps" {
  type = list(string)
}
variable "emr_master_instance_type" {}
variable "emr_master_ebs_size" {}
variable "emr_core_instance_type" {}
variable "emr_core_instance_count" {}
variable "emr_core_ebs_size" {}
# variable "emr_master_security_group" {}
# variable "emr_slave_security_group" {}
variable "emr_ec2_instance_profile" {}

variable "emr_service_role" {}
# variable "emr_autoscaling_role" {}

variable "bucket_scripts_name" {}
variable "bucket_logs_name" {}