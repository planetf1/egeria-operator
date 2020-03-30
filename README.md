# operators
<!-- SPDX-License-Identifier: CC-BY-4.0 -->
<!-- Copyright Contributors to the ODPi Egeria project. -->

# Intro

This project provides an operator for deployment of [ODPi Egeria](https://github.com/odpi/egeria)

# Dependencies

This project makes use of the operator-sdk at https://github.com/operator-framework/operator-sdk 0.16.0

Ensure you have the required prereqs installed - including git, go, mercurial, docker, kubectl, a k8s cluster. The link above has the full prereqs 

# Reference

This information is provided for reference. You do not need to run these!

## Initial bootstrap
Project creation:
```
2020-03-30 09:04  operator-sdk new egeria-operator --repo github.com/planetf1/egeria-operator
```
And within `egeria-operator`:
```
2020-03-30 09:26  operator-sdk add api --api-version=openmetadata.odpi.org/v1alpha1 --kind=AppService
2020-03-30 09:27  operator-sdk add controller --api-version=openmetadata.odpi.org/v1alpha1 --kind=AppService
```

## Pull Secrets

Openshift will require a pull secret for quay.io

An example is below
```
kubectl create secret docker-registry staging-secret \
    --docker-server=quay.io \
    --docker-username=giffeeLover93 \
    --docker-password='my secret passphrase' \
    --docker-email='giffeeLover93@example.com' \
    --dry-run -o yaml
```
Adopt and then run:
```
kubectl create -f my-custom-staging-secret.yaml
```
