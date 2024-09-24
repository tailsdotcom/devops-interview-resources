locals {
  is_prod      = var.branch == "main"
  env          = local.is_prod ? "prod" : "staging"
  cluster_name = "example-cluster"
}

terraform {
  backend "s3" {
    # Configuration options (bucket & key) are set on terraform init
  }
}
