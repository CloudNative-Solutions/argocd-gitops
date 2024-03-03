#!/bin/bash

KEY_PAIR=cns-capi
ARGOCD_NS=argocd
ARGO_CHART=argo-cd

create_key_pair() {
    local key_name=$1
    aws ssm put-parameter --name "/sigs.k8s.io/cluster-api-provider-aws/ssh-key" \
    --type SecureString \
    --value "$(aws ec2 create-key-pair --key-name ${key_name} --output json | jq .KeyMaterial -r)"
}

create_kind_cluster() {
    kind create cluster
    kubectl cluster-info --context kind-kind
}

apply_secrets() {
    kubectl apply -f ./secrets/kind
}

install_argocd() {
    # Install ArgoCD with sync-waves enabled
    helm repo add argo-cd https://argoproj.github.io/argo-helm
    helm repo update
    helm upgrade --install ${ARGO_CHART} --create-namespace --namespace ${ARGOCD_NS} -f values/kind/argo-cd/values.yaml argo-cd/argo-cd
    echo "Waiting for ArgoCD deployment to be ready"
    until kubectl wait deployment -n ${ARGOCD_NS} ${ARGO_CHART}-argocd-server --for condition=Available=True --timeout=90s; do sleep 1; done
    until kubectl wait deployment -n ${ARGOCD_NS} ${ARGO_CHART}-argocd-applicationset-controller --for condition=Available=True --timeout=90s; do sleep 1; done
    until kubectl wait deployment -n ${ARGOCD_NS} ${ARGO_CHART}-argocd-repo-server --for condition=Available=True --timeout=90s; do sleep 1; done
}

create_argo_apps() {
    kubectl apply -f ./kind/argo-apps.yaml
    until kubectl wait application -n ${ARGOCD_NS} argo-apps --for jsonpath='{.status.sync.status}'=Synced; do sleep 1; done
}

argo_ui() {
    ARGO_PASS=$(kubectl get secret argocd-initial-admin-secret -n ${ARGOCD_NS} -o jsonpath='{.data.password}' | base64 -d )
    echo ArgoCD credentials:
    echo   User: admin
    echo   Password: ${ARGO_PASS}
    echo   Url: https://localhost:8080
    echo Starting port forward:
    kubectl port-forward svc/${ARGO_CHART}-argocd-server -n ${ARGOCD_NS} 8080:443
}

create_key_pair ${KEY_PAIR}
create_kind_cluster
install_argocd
apply_secrets
create_argo_apps
argo_ui

