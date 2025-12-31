terraform {
  required_providers {
    azurerm    = { source = "hashicorp/azurerm", version = "~> 3.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }

  }
}

provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "myk8s" {
  name = "myk8sproject"
  location = "westeurope"
}

