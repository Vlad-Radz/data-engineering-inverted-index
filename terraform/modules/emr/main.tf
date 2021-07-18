resource "aws_emr_cluster" "emr-spark-cluster" {
  name                              = "${var.emr_cluster_name}"
  release_label                     = "${var.emr_release}"
  applications                      = "${var.emr_apps}"
  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true
  log_uri                           = "s3://${var.bucket_logs_name}/"

  ec2_attributes {
    subnet_id                         = "${var.subnet_id}"
    key_name                          = "${var.key_name}"
    # emr_managed_master_security_group = "${var.emr_master_security_group}"
    # emr_managed_slave_security_group  = "${var.emr_slave_security_group}"
    instance_profile                  = "${var.emr_ec2_instance_profile}"
  }

  ebs_root_volume_size = "12"

  master_instance_group {
    name           = "EMR master"
    instance_type  = "${var.emr_master_instance_type}"
    instance_count = "1"

    ebs_config {
      size                 = "${var.emr_master_ebs_size}"
      type                 = "gp2"
      volumes_per_instance = 1
    }
  }

  core_instance_group {
    name           = "EMR slave"
    instance_type  = "${var.emr_core_instance_type}"
    instance_count = "${var.emr_core_instance_count}"

    ebs_config {
      size                 = "${var.emr_core_ebs_size}"
      type                 = "gp2"
      volumes_per_instance = 1
    }
  }

  service_role     = "${var.emr_service_role}"

  bootstrap_action {
    name = "Bootstrap setup."
    path = "s3://${var.bucket_scripts_name}/scripts/bootstrap_actions.sh"
  }

  step {
      name              = "Calculate inverted index"
      action_on_failure = "CONTINUE"

      hadoop_jar_step {
        jar  = "command-runner.jar" 
        args = [
            "spark-submit",
            #"–deploy-mode",
            #"cluster",
            "–master",
            "yarn",
            #"–conf",
            #"spark.yarn.submit.waitAppCompletion=true",
            "s3://${var.bucket_scripts_name}/inverted_index.py"]
      }
    }

  step {
    action_on_failure = "TERMINATE_CLUSTER"
    name              = "Setup Hadoop Debugging"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["state-pusher-script"]
    }
  }

  # Optional: ignore outside changes to running cluster steps
  lifecycle {
    ignore_changes = [step]
  }

  configurations_json = <<EOF
    [
  {
     "Classification": "spark-env",
     "Configurations": [
       {
         "Classification": "export",
         "Properties": {
            "PYSPARK_PYTHON": "/usr/bin/python3"
          }
       }
    ]
  }
]
  EOF

}