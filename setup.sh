#!/usr/bin/env bash

kind create cluster --name=issue-4442
kubectx kind-issue-4442
kubectl create ns crossplane-system
echo "#### install 1.3.1"
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane --version 1.3.1 --wait 

helm list -A
echo "storedVersion for locks..."
kubectl get crd locks.pkg.crossplane.io -o json | jq '.status.storedVersions'
kubectl get pods -n crossplane-system

echo "#### upgrade 1.7.0"
helm upgrade crossplane --namespace crossplane-system crossplane-stable/crossplane --version 1.7.0 --wait
echo "storedVersion for locks..."
kubectl get crd locks.pkg.crossplane.io -o json | jq '.status.storedVersions'

kubectl get lock
kubectl get pods -n crossplane-system

echo "#### upgrade 1.12.2"
helm upgrade crossplane --namespace crossplane-system crossplane-stable/crossplane --version 1.12.2 --wait
echo "storedVersion for locks..."
kubectl get crd locks.pkg.crossplane.io -o json | jq '.status.storedVersions'

kubectl get lock
kubectl get pods -n crossplane-system

sleep 15
kubectl get pods -n crossplane-system | grep "Init" | awk {'print $1'} | xargs -I% kubectl logs -n crossplane-system % -c crossplane-init
