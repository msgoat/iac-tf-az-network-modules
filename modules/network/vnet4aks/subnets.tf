locals {
  subnet_name_prefix = "snet-${var.region_code}-${var.solution_fqn}-${var.network_name}"
  subnet_cidrs = cidrsubnets(var.network_cidr, 4, 4, 8, 8, 8, 8)
  worker_nodes_subnet_cidr = local.subnet_cidrs[0]
  private_link_subnet_cidr = local.subnet_cidrs[1]
  application_gateway_subnet_cidr = local.subnet_cidrs[2]
  internal_loadbalancer_subnet_cidr = local.subnet_cidrs[3]
  bastion_subnet_cidr = local.subnet_cidrs[4]
  admin_subnet_cidr = local.subnet_cidrs[5]
}

# create a subnet for application gateway
resource azurerm_subnet gateway {
  name = "${local.subnet_name_prefix}-gateway"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [local.application_gateway_subnet_cidr]
}

# create a subnet for the internal loadbalancer managed by AKS
resource azurerm_subnet loadbalancer {
  name = "${local.subnet_name_prefix}-loadbalancer"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [local.internal_loadbalancer_subnet_cidr]
}

# create a subnet for the AKS worker nodes
resource azurerm_subnet nodegroups {
  name = "${local.subnet_name_prefix}-nodegroups"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [local.worker_nodes_subnet_cidr]
}

# create a subnet for Azure Bastion service (troubleshooting etc)
resource azurerm_subnet bastion {
  name = "AzureBastion"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [local.bastion_subnet_cidr]
}

# create a subnet for internal administration of this virtual network (troubleshooting etc)
resource azurerm_subnet admin {
  name = "${local.subnet_name_prefix}-admin"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [local.admin_subnet_cidr]
}

# create a subnet for private endpoints to Azure services via Private Link
resource azurerm_subnet endpoints {
  name = "${local.subnet_name_prefix}-endpoints"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [local.private_link_subnet_cidr]
  enforce_private_link_endpoint_network_policies = true
}

locals {
  subnets_by_role = [
    {
      role = "NodeGroupsContainer"
      id = azurerm_subnet.nodegroups.id
      name = azurerm_subnet.nodegroups.name
      address_prefix = azurerm_subnet.nodegroups.address_prefix
    },
    {
      role = "ApplicationGatewayContainer"
      id = azurerm_subnet.gateway.id
      name = azurerm_subnet.gateway.name
      address_prefix = azurerm_subnet.gateway.address_prefix
    },
    {
      role = "LoadBalancerContainer"
      id = azurerm_subnet.loadbalancer.id
      name = azurerm_subnet.loadbalancer.name
      address_prefix = azurerm_subnet.loadbalancer.address_prefix
    },
    {
      role = "BastionServiceContainer"
      id = azurerm_subnet.bastion.id
      name = azurerm_subnet.bastion.name
      address_prefix = azurerm_subnet.bastion.address_prefix
    },
    {
      role = "AdminMachinesContainer"
      id = azurerm_subnet.admin.id
      name = azurerm_subnet.admin.name
      address_prefix = azurerm_subnet.admin.address_prefix
    },
    {
      role = "PrivateEndpointsContainer"
      id = azurerm_subnet.endpoints.id
      name = azurerm_subnet.endpoints.name
      address_prefix = azurerm_subnet.endpoints.address_prefix
    },
  ]
}
