# GitOps with ArgoCD and ClusterAPI

Deploying an EKS cluster to be used as a Kubernetes Management Cluster.
We are going to use KinD, ArgoCD and ClusterAPI

After running the [install.sh](install.sh) script ArgoCD URL and credentials will be displayed.
All the Applications except the EKS cluster are configured to Auto-Sync and should be in Synced status.
By Sync-ing the `cluster` ArgoCD Application we will deploy an EKS cluster using ClusterAPI.

## Prerequisites

    - kubectl installed
    - AWS credentials
    - SSH key for GitHub
    - secrets configured

## Configure secrets

The following secrets are required in the [secrets/kind](secrets/kind) folder:

* CAPI AWS credentials:
Here we can use `clusterawsadm`

```yaml
---
apiVersion: v1
kind: Secret
metadata:
 name: aws-variables
 namespace: default
type: Opaque
data:
 AWS_B64ENCODED_CREDENTIALS: WW91J3ZlIGJlZW4gUmljayBSb2xsZWQK==
```

* GitHub repository credentials

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: argocd-gitops
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@github.com:CloudNative-Solutions/argocd-gitops.git
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    WW91J3ZlIGJlZW4gUmljayBSb2xsZWQK==
    -----END OPENSSH PRIVATE KEY-----
---
apiVersion: v1
kind: Secret
metadata:
  name: argocd-capi-controller
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@github.com:CloudNative-Solutions/argocd-capi-controller.git
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    WW91J3ZlIGJlZW4gUmljayBSb2xsZWQK==
    -----END OPENSSH PRIVATE KEY-----
```

## Components

The following components will be installed in KinD

* ArgoCD
* cert-manager
* cluster-api-operator
  * capi-controller
  * capa-controller
* argocd-capi-controller

## Install

The install script will deploy an EKS cluster using kind, ArgoCD and ClusterAPI

```bash
./install.sh
```
