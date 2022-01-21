terraform {
  required_providers {
    azurerm = {
      version = "~> 2.44"
    }
    null = {
      version = "~> 3.0"
    }
    random = {
      version = "~> 3.0"
    }
  }
}

locals {
  module_common_tags = var.common_tags
}

data azurerm_client_config current {

}
