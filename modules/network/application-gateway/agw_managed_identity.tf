# create an user-assigned identity to grant key vault access to application gateway
locals {
  agw_identity_name = "id-${local.agw_name}"
}

resource azurerm_user_assigned_identity agw {
  name = local.agw_identity_name
  resource_group_name = var.resource_group_name
  location = var.resource_group_location
  tags = merge({ Name = local.agw_identity_name }, local.module_common_tags)
}

# allow the user-assigned identity of the application gateway to fetch the certificate
resource azurerm_key_vault_access_policy agw {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.agw.principal_id
  key_vault_id = var.key_vault_id
  secret_permissions = [
    "get"]
  certificate_permissions = [
    "create",
    "delete",
    "deleteissuers",
    "get",
    "getissuers",
    "import",
    "list",
    "listissuers",
    "managecontacts",
    "manageissuers",
    "purge",
    "setissuers",
    "update",
  ]
}

# make sure we can wait until access policy is present
resource null_resource wait_for_access_policy {
  triggers = {
    access_policy_id = azurerm_key_vault_access_policy.agw.id
  }
}