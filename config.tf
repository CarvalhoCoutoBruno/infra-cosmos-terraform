terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.1.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = local.subscription_id
  tenant_id       = local.tenant_id
  features {}
}

# az login --use-device-code