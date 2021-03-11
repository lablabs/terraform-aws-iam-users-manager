

module "label" {
  source      = "cloudposse/label/null"
  version     = "0.24.1"
  namespace   = var.namespace
  environment = var.environment
  tags        = var.tags
}
