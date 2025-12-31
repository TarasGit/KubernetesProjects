# 1. Provider Definition
terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
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

# 3. AKS Cluster (mit deiner funktionierenden VM-Größe)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "MyFirstCluster"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = "myk8s"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3" # Die Größe, die vorhin geklappt hat
  }

  identity {
    type = "SystemAssigned"
  }
}

# 4. Kubernetes Provider Konfiguration 
# (Wichtig: Nutzt die Daten des gerade erstellten Clusters)
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# 5. Das Deployment
resource "kubernetes_manifest" "echo_deployment" {
  manifest = yamldecode(file("${path.module}/deployment.yml"))
  
  # Falls du den Namespace nicht in der YAML hast, erzwinge ihn hier:
  # manifest = merge(yamldecode(file("${path.module}/deployment.yml")), { metadata = { namespace = "default" } })

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# 6. Der Service (Falls du eine separate service.yml hast)
resource "kubernetes_manifest" "echo_service" {
  manifest = yamldecode(file("${path.module}/service.yml"))
  
  depends_on = [azurerm_kubernetes_cluster.aks]
}