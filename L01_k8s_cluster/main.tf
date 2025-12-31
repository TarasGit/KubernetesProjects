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

resource "azurerm_kubernetes_cluster" "myaks" {
  name = "mycluster"
  location = azurerm_resource_group.myk8s.location
  resource_group_name = azurerm_resource_group.myk8s.name
  dns_prefix = "myk8s"

  default_node_pool {
    name = "default"
    node_count = 1
    vm_size = "Standard_D2s_V3"
  }

  identity {
    type = "SystemAssigned"
  }
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.myaks.kube_config.0.host
  client_certificate = base64decode(azurerm_kubernetes_cluster.myaks.kube_config.0.client_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.myaks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.myaks.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_manifest" "echo_app" {
  manifest = yamldecode(file("${path.module}/deployment.yml"))

  depends_on = [ azurerm_kubernetes_cluster.myaks ]
}