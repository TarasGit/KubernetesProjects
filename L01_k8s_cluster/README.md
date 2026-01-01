# Project
Static Web Page from Docker Container in Kubernetes

## Resource group creation 
az group create --name k8sprojects --location westeurope

## For new Azure subscription 
az provider register --namespace Microsoft.ContainerService
az provider show -n Microsoft.ContainerService --query registrationState

## Azure AKS cluster manually
az aks create \
    --resource-group k8sprojects \
    --name MyFirstCluster \
    --node-count 1 \
    --node-vm-size Standard_D2s_v3 \
    --location westeurope \
    --generate-ssh-keys
    
## Cluster connection
az aks get-credentials --admin --resource-group k8sprojects --name MyFirstCluster
kubclt get nodes

## Apply deployment
kubclt apply -f deployment.yml

## Test deployment
kubctl get service echo-service --watch

## Cleanup RG to save costs
az group delete --name k8sprojects --yes --no-wait

## Remove Kubernetes Cluster
kubectl config get-contexts
kubectl config delete-context MyFirstCluster

