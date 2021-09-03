#!/usr/bin/env bash
# Transfer ssl certificates and users from one cluster to another

function transfer-managed-config() {
    local managed=$1
    local unmanaged=$2
    local skipCertManager=$3

    if [[ -z $managed ]] || [[ -z $unmanaged ]]; then
        echo "Usage: transfer-managed-config <managed-cr-name> <unmanaged-cr-name> <skip-cert-manager>"
        return 1
    fi

    if [[ -z "$skipCertManager" ]]; then
        echo "---"
        kubectl get issuer $managed-psmdb-ca -o yaml |
            yq d - status |
            yq d - metadata |
            yq w - metadata.name $unmanaged-psmdb-ca
    fi

    echo "---"
    kubectl get secret $managed-ssl-internal -o yaml |
        yq d - metadata |
        yq d - status |
        yq w - metadata.name $unmanaged-ssl-internal

    echo "---"
    kubectl get secret $managed-ssl -o yaml |
        yq d - metadata |
        yq d - status |
        yq w - metadata.name $unmanaged-ssl

    if [[ -z "$skipCertManager" ]]; then
        echo "---"
        kubectl get certificate $managed-ssl -o yaml |
            yq d - metadata |
            yq d - status |
            yq w - metadata.name $unmanaged-ssl |
            yq w - spec.issuerRef.name $unmanaged-psmdb-ca |
            yq w - spec.secretName $unmanaged-ssl

        echo "---"
        kubectl get certificate $managed-ssl-internal -o yaml |
            yq d - metadata |
            yq d - status |
            yq w - metadata.name $unmanaged-ssl-internal |
            yq w - spec.issuerRef.name $unmanaged-psmdb-ca |
            yq w - spec.secretName $unmanaged-ssl-internal
    fi

    echo "---"
    kubectl get secret $managed-secrets -o yaml |
        yq d - metadata |
        yq w - metadata.name $unmanaged-secrets

    echo "---"
    kubectl get secret internal-$managed-users -o yaml |
        yq d - metadata |
        yq w - metadata.name internal-$unmanaged-secrets
}

transfer-managed-config $@
