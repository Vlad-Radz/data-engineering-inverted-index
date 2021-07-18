module "emr" {
  source = "../../modules/emr"

  emr_cluster_name          = "${var.emr_cluster_name}"
  emr_release               = "${var.emr_release}"
  emr_apps                  = "${var.emr_apps}"
  key_name                  = "${module.security.ssh_key}"
  emr_master_instance_type  = "${var.emr_master_instance_type}"
  emr_master_ebs_size       = "${var.emr_master_ebs_size}"
  emr_core_instance_type    = "${var.emr_core_instance_type}"
  emr_core_instance_count   = "${var.emr_core_instance_count}"
  emr_core_ebs_size         = "${var.emr_core_ebs_size}"
  emr_ec2_instance_profile  = "${module.iam.emr_ec2_instance_profile}"
  emr_service_role          = "${module.iam.emr_service_role}"
  bucket_scripts_name       = "${module.s3.bucket_scripts_name}"
  bucket_logs_name          = "${module.s3.bucket_logs_name}"
  subnet_id                 = "${module.network.subnet_id}"
}

module "iam" {
  source = "../../modules/iam"
}

module "network" {
  source = "../../modules/network"

  aws_region                      = "${var.aws_region}"
}

module "s3" {
  source = "../../modules/s3"
}

module "security" {
  source = "../../modules/security"

  key_name                      = "${var.key_name}"
}
