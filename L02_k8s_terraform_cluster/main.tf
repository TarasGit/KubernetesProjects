# 1. Provider Definition
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 2. Ressourcengruppe
resource "azurerm_resource_group" "k8s" {
  name     = "MyK8sProject"
  location = "westeurope"
}

# 3. AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "MyFirstCluster"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = "myk8s"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }
}

# 4. Kubernetes Provider Konfiguration
# Zieht die Zertifikate direkt aus dem erstellten Cluster
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# 5. Das Deployment (mit automatischer Namespace-Zuweisung)
resource "kubernetes_manifest" "echo_deployment" {
  manifest = merge(
    yamldecode(file("${path.module}/deployment.yml")),
    {
      metadata = merge(
        yamldecode(file("${path.module}/deployment.yml")).metadata,
        { namespace = "default" }
      )
    }
  )

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# 6. Der Service (für die Public IP)
resource "kubernetes_manifest" "echo_service" {
  manifest = merge(
    yamldecode(file("${path.module}/service.yml")),
    {
      metadata = merge(
        yamldecode(file("${path.module}/service.yml")).metadata,
        { namespace = "default" }
      )
    }
  )

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# 7. Output: Zeigt dir die IP-Adresse nach dem Apply an
output "app_public_ip" {
  description = "Die öffentliche IP deiner Go-App"
  value       = kubernetes_manifest.echo_service.object.status.loadBalancer.ingress[0].ip
}
