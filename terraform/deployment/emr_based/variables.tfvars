# General
# Note: these 3 vars need to be replaced!!!
aws_profile = "nc-account"
aws_region  = "eu-west-1"
role_arn    = "arn:aws:iam::286656190625:role/User"

# EMR related
emr_cluster_name = "inverted-index-app"
emr_release = "emr-5.33.0"
emr_apps = ["Hadoop", "Spark", "Livy"]  # "Hadoop" and "Livy" needed at least for the Jupyter notebooks
key_name = "key-ec2-emr"
emr_master_instance_type = "m3.xlarge"
emr_master_ebs_size = "50"
emr_core_instance_type = "m3.xlarge"
emr_core_ebs_size = "50"
emr_core_instance_count = 1