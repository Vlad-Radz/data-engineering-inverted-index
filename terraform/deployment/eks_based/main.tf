module "eks" {
  source = "../../modules/eks"

  cluster_name          = "${var.cluster_name}"
  vpc_id                = "${module.eks-vpc.vpc_eks_id}"
  subnet_ids            = "${module.eks-vpc.subnet_ids}"
  
}

module "eks-vpc" {
  source = "../../modules/eks-vpc"

  cluster_name          = "${var.cluster_name}"  # This one should comply to the following requirements (for eksctl to work with that cluster): only alphanumeric characters (case-sensitive) and hyphens; must start with an alphabetic character and can't be longer than 128 characters.
}
