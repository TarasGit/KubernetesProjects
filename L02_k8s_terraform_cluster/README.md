# Project
Terraform cluster creation

## Steps
1. git clone <this repo> into Azure terminal
2. terraform init
3. terraform plan
4. terraform apply -target=azurerm_kubernetes_cluster.aks
5. terraform apply
6. kubectl get svc echo-service

## Get app external IP
kubectl get service

