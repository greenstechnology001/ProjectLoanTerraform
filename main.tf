# terraform block for azure
terraform {
    required_providers {
      azurerm = {
          source = "hashicorp/azurerm"
          version = "=4.14.0"
      }
    }
    
    backend "azurerm" {
        resource_group_name  = "terraformsa20241214"  
        storage_account_name = "terraformsa20241214"  
        container_name       = "terraformsa20241214"  
        key                  = "terraform.tfstate"
    }

}

# to connect to azure
# assign "contributor" using IAM for the subscription role to the app registration we created
provider "azurerm" {
    features {}
    subscription_id = "b14c50e0-832c-495a-8972-f31cde2082c3"
    tenant_id = "e4446420-af43-4a37-b2b2-eafcaf22488f"
    client_id = "37326bdb-2185-4f5f-8926-ffb5191cb402"
    client_secret = "1dd8Q~cXqFyoo6plvlg4YpqSPQ4YER8plZIz7b5V"
}


# resources
# resource group, vnet, subnet, aks, acr, azure sql

# resource group
resource "azurerm_resource_group" "iciciloan-rg" {
  name     = var.rgname
  location = var.rglocation
}

# vnet 
resource "azurerm_virtual_network" "iciciloan-vnet" {
  name                = "iciciloanvnet"
  location            = azurerm_resource_group.iciciloan-rg.location
  resource_group_name = azurerm_resource_group.iciciloan-rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

# subnet
resource "azurerm_subnet" "iciciloan-subnet" {
  name                 = "iciciloansubnet"
  resource_group_name  = azurerm_resource_group.iciciloan-rg.name
  virtual_network_name = azurerm_virtual_network.iciciloan-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# aks
resource "azurerm_kubernetes_cluster" "iciciloan-aks" {
  name                = "iciciloanaks"
  location            = azurerm_resource_group.iciciloan-rg.location
  resource_group_name = azurerm_resource_group.iciciloan-rg.name
  dns_prefix          = "iciciloanaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# acr
resource "azurerm_container_registry" "iciciloanacr" {
  name                = "iciciloanacr"
  location            = azurerm_resource_group.iciciloan-rg.location
  resource_group_name = azurerm_resource_group.iciciloan-rg.name
  sku                 = "Premium"
  admin_enabled       = false
  georeplications {
    location                = "East US"
    zone_redundancy_enabled = true
    tags                    = {}
  }
}

# sql server
resource "azurerm_mssql_server" "iciciloan-sqlserver" {
  name                         = "iciciloansqlserver"
  location            = azurerm_resource_group.iciciloan-rg.location
  resource_group_name = azurerm_resource_group.iciciloan-rg.name
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

# sql database
resource "azurerm_mssql_database" "iciciloan-db" {
  name         = "iciciloandb"
  server_id    = azurerm_mssql_server.iciciloan-sqlserver.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

  tags = {
    foo = "bar"
  }
}