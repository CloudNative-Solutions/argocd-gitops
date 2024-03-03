# GitOps with ArgoCD and ClusterAPI

## Prerequisites

    - kubectl installed
    - secrets configured

## Configure secrets

The following secrets are required in the [secrets/kind](secrets/kind) folder:

* CAPI AWS credentials:

```
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

```
apiVersion: v1
kind: Secret
metadata:
  name: github
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@github.com:CloudNative-Solutions/gitops.git
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    WW91J3ZlIGJlZW4gUmljayBSb2xsZWQK==
    -----END OPENSSH PRIVATE KEY-----
```

## Install

```
./install.sh
```
