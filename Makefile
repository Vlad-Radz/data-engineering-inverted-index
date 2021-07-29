# TODO: what is the best practice 

.PHONY: help install install-dev clean clean-pyc clean-build clean-pyenv lint test test-dbg develop mypy isort isort-check

project := data-eng-spark

tf_base:
	aws-vault exec nc-account -- terraform plan -out="../../tfplan" -var-file="variables.tfvars"
	aws-vault exec nc-account -- terraform apply -var-file="variables.tfvars"

change_dir_emr:
	cd terraform/deployment/emr_based

change_dir_eks:
	cd terraform/deployment/eks_based

tf_setup_emr: change_dir_emr tf_base

tf_setup_eks: change_dir_eks tf_base
	aws-vault exec nc-account -- terraform output kubeconfig > ../../../.kube/config
	aws-vault exec nc-account -- terraform output config_map_aws_auth  > ../../../.kube/configmap.yml

enable_k8s:
	tf_setup_eks
	cd ../../../
	set KUBECONFIG=".kube/config"
	aws-vault exec nc-account -- kubectl apply -f .kube/configmap.yml
	-- here would be nice to check the output for `configmap/aws-auth configured`
	-- this can be done with bash. https://stackoverflow.com/questions/16931244/checking-if-output-of-a-command-contains-a-certain-string-in-a-shell-script
	-- to activate bash on Windows, just type in cmd: `bash`

