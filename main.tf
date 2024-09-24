# NB Airflow has only a prod environment

locals {
  app_name  = "airflow"
  stage     = local.is_prod ? "prod" : "staging"
  namespace = local.is_prod ? local.app_name : "${local.app_name}-${local.stage}"
  hostname  = "${local.namespace}.example.com"

  vpc_id = "vpc-123456"

  tags = {
    "Name"            = "tails-live-data-${local.namespace}"
    "tails-app-name"  = local.app_name
    "tails-app-stage" = local.stage
    "tails-org-unit"  = "data"
    "tails-owner"     = "data"
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_vpc" "vpc" {
  id = local.vpc_id
}

# Used by the ALB for HTTPS
data "aws_acm_certificate" "cert" {
  domain      = "*.example.com"
  most_recent = true
}

# Deploy application as a Helm chart
resource "helm_release" "helm" {
  name        = local.app_name
  namespace   = local.namespace
  chart       = "${path.module}/chart/"
  max_history = 10

  set {
    name  = "app_name"
    value = local.app_name
  }
  set {
    name  = "namespace"
    value = local.namespace
  }
  # set {
  #   name  = "service_account_name"
  #   value = kubernetes_service_account.service.metadata.0.name
  # }
  set {
    name  = "cluster_name"
    value = local.cluster_name
  }
  set {
    name  = "hostname"
    value = local.hostname
  }
  set {
    name  = "certificate_arn"
    value = data.aws_acm_certificate.cert.arn
  }
  set {
    name  = "commitid"
    value = var.commitid
  }
  set {
    name  = "stage"
    value = local.stage
  }
  set {
    name  = "GE_SNOWFLAKE_USERNAME"
    value = var.GE_SNOWFLAKE_USERNAME
  }
  set {
    name  = "GE_SNOWFLAKE_PASSWORD"
    value = var.GE_SNOWFLAKE_PASSWORD
  }
  set {
    name  = "GE_SNOWFLAKE_HOST"
    value = var.GE_SNOWFLAKE_HOST
  }
  set {
    name  = "GE_SNOWFLAKE_DATABASE"
    value = var.GE_SNOWFLAKE_DATABASE
  }
  set {
    name  = "GE_SNOWFLAKE_SCHEMA"
    value = var.GE_SNOWFLAKE_SCHEMA
  }
  set {
    name  = "GITHUB_API_KEY"
    value = var.GITHUB_API_KEY
  }
  set {
    name  = "EMARSYS_API_USERNAME"
    value = var.EMARSYS_API_USERNAME
  }
  set {
    name  = "EMARSYS_API_SECRET"
    value = var.EMARSYS_API_SECRET
  }
  set {
    name  = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
    value = var.AIRFLOW__CORE__SQL_ALCHEMY_CONN
  }

  # This is not a chart value, but just a way to trick helm_release into running every time.
  # Without this, helm_release only updates the release if the chart version (in Chart.yaml) has been updated
  set {
    name  = "timestamp"
    value = timestamp()
  }
}
