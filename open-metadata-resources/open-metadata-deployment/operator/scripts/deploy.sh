#!/bin/bash
# SPDX-License-Identifier: CC-BY-4.0
# Copyright Contributors to the ODPi Egeria project.

# Tested on MacOS using bash from homebrew

# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command exited with exit code $?."' EXIT

printf "\n---\nEgeria Operator build and deploy\n\n"

# This assumed you have a userid on quay.io -- or modify the registry to another
# You must update REGISTRY_USER as needed
export REGISTRY_ADDRESS="docker.io"
export REGISTRY_USER=planetf1
export REGISTRY_REPO="egeria-operator"

# MacOS - fails without this with
# runtime/cgo(__TEXT/__text): relocation target x_cgo_inittls not defined
export CGO_ENABLED=0

# Path to code
CODEPATH=`dirname $0`/../egeria-operator
cd ${CODEPATH}

printf "\n---\nBuild\n\n"

# Update any CRDs
operator-sdk generate crds


# Build the operator
operator-sdk build ${REGISTRY_ADDRESS}/${REGISTRY_USER}/${REGISTRY_REPO}

printf "\n---\nBuild & Push image\n\n"

docker login ${REGISTRY_ADDRESS}

docker push ${REGISTRY_ADDRESS}/${REGISTRY_USER}/${REGISTRY_REPO}

# Delete any old versions - even with --ignore-not-found we can get an error if AppService isn't known so force good exit
printf "\n---\nCleaning up old install\n\n"

kubectl delete --ignore-not-found -f deploy/crds/openmetadata.odpi.org_v1alpha1_egeria_cr.yaml || true
kubectl delete --ignore-not-found -f deploy/operator.yaml || true
kubectl delete --ignore-not-found -f deploy/role.yaml || true
kubectl delete --ignore-not-found -f deploy/role_binding.yaml || true
kubectl delete --ignore-not-found -f deploy/service_account.yaml || true
kubectl delete --ignore-not-found -f deploy/crds/openmetadata.odpi.org_egeria_crd.yaml || true

printf "\n---\nSetting up required definitions\n\n"

# Setup Service Account
kubectl create -f deploy/service_account.yaml
# Setup RBAC
kubectl create -f deploy/role.yaml
kubectl create -f deploy/role_binding.yaml
# Setup the CRD
kubectl create -f deploy/crds/openmetadata.odpi.org_egeria_crd.yaml
# Deploy the app-operator
kubectl create -f deploy/operator.yaml

# Create an Egeria !!
printf "\n---\nCreate an Egeria\n\n"

# The default controller will watch for Egeria objects and create a pod for each CR
kubectl create -f deploy/crds/openmetadata.odpi.org_v1alpha1_egeria_cr.yaml

# Verify that a pod is created
printf "\n---\nChecking that operator is running\n\n"
kubectl get pod -l name=egeria-operator

printf "\n---\nChecking that app is running\n\n"
kubectl get pod -l name=egeria-operator

printf "\n---\nMore details\n\n"
kubectl describe egeria/egeria-instance

exit

