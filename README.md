# KubernetesProjects
Kubernetes deployment configurations

## Resource group creation 
az group create --name k8sprojects --location westeurope

## For new Azure subscription 
az provider register --namespace Microsoft.ContainerService
az provider show -n Microsoft.ContainerService --query registrationState

## Azure AKS cluster manually
az aks create \
    --resource-group MyK8sProject \
    --name MyFirstCluster \
    --node-count 1 \
    --node-vm-size Standard_D2s_v3 \
    --location westeurope \
    --generate-ssh-keys
    
## Cluster connection
az aks get-credentials --resouce-group k8sprojects --name L01_cluster 
kubclt get nodes

## Apply deployment
kubclt apply -f deployment.yml

## Test deployment
kubctl get service echo-service --watch

## Cleanup RG to save costs
az group delete --name k8sprojects --yes --no-wait
