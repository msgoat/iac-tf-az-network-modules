terraform {
  required_providers {
    azurerm = {
      version = "~> 2.42"
    }
  }
}

locals {
  module_common_tags = var.common_tags
}
