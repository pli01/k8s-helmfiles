#!/bin/bash
#
# For local development purpose, local root CA with cert-manager
# The CA issuer represents a Certificate Authority whose certificate and private key are stored inside the cluster as a Kubernetes Secret
# CA Issuers must be configured with a certificate and private key stored in a Kubernetes secret.
#   here , a root certificate is bootstrap externally and imported in a Kubernetes secret
# https://cert-manager.io/docs/configuration/ca/
#
DIR="$(dirname $0)"
CA_ROOT_DIR="$(mkcert -CAROOT)"
TLS_KEY_FILE="rootCA-key.pem"
TLS_CRT_FILE="rootCA.pem"

CA_ISSUER_KEY_PAIR_TEMPLATE="$DIR/ca-issuer-key-pair.yaml.tmpl"
CA_ISSUER_KEY_PAIR="$DIR/../secrets/$(basename $CA_ISSUER_KEY_PAIR_TEMPLATE .tmpl)"
CERT_MANAGER_NAMESPACE="${CERT_MANAGER_NAMESPACE:-cert-manager}"

if [[ ! ( -n "$CA_ROOT_DIR" && -d "$CA_ROOT_DIR" && -f "$CA_ROOT_DIR/$TLS_KEY_FILE" && -f "$CA_ROOT_DIR/$TLS_CRT_FILE" ) ]] ;then
    echo "To bootstrap root certificate, please run before: mkcert -install"
    exit 1
fi

if [[ ! -f "$CA_ISSUER_KEY_PAIR_TEMPLATE" ]] ; then
    echo "$CA_ISSUER_KEY_PAIR_TEMPLATE not found"
    exit 1
fi
echo "# Found root CA"
echo "  key: $CA_ROOT_DIR/$TLS_KEY_FILE"
echo "  crt: $CA_ROOT_DIR/$TLS_CRT_FILE"
echo "# Generate $CA_ISSUER_KEY_PAIR"
export TLS_KEY="$( cat "$CA_ROOT_DIR"/$TLS_KEY_FILE | openssl base64 -A )"
export TLS_CRT="$( cat "$CA_ROOT_DIR"/$TLS_CRT_FILE | openssl base64 -A )"
export CERT_MANAGER_NAMESPACE

echo "# Generate root CA secret $(basename $CA_ISSUER_KEY_PAIR)"
mkdir -p $(dirname $CA_ISSUER_KEY_PAIR)
envsubst < $CA_ISSUER_KEY_PAIR_TEMPLATE > ${CA_ISSUER_KEY_PAIR}

#echo "# Import root CA secret $CA_ISSUER_KEY_PAIR"
#kubectl create  -f ${CA_ISSUER_KEY_PAIR} --dry-run=client -o yaml | kubectl apply -f -
