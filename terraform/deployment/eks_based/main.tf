module "eks" {
  source = "../../modules/eks"

  cluster_name          = "${var.cluster_name}"
  vpc_id                = "${module.eks-vpc.vpc_eks_id}"
  subnet_ids            = "${module.eks-vpc.subnet_ids}"
  
}

module "eks-vpc" {
  source = "../../modules/eks-vpc"

  cluster_name          = "${var.cluster_name}"
}
