#!/usr/bin/env bash
# Script to generate tls secret for minio service
# minio-tls-generate.sh minio-service test minio-secret
SERVICE_NAME=$1
NAMESPACE=$2
SECRET=$3

cat <<EOF | cfssl gencert -initca - | cfssljson -bare ca
  {
    "CN": "Root CA",
    "names": [
      {
        "O": "Cloud"
      }
    ],
    "key": {
      "algo": "rsa",
      "size": 2048
    }
  }
EOF

cat <<EOF > ca-config.json
  {
    "signing": {
      "default": {
        "expiry": "87600h",
        "usages": ["signing", "key encipherment", "server auth", "client auth"]
      }
    }
  }
EOF

cat <<EOF | cfssl gencert -ca=ca.pem  -ca-key=ca-key.pem -config=./ca-config.json - | cfssljson -bare server
  {
    "hosts": [
      "localhost",
      "${SERVICE_NAME}",
      "${SERVICE_NAME}.${NAMESPACE}",
      "${SERVICE_NAME}.${NAMESPACE}.svc.cluster.local",
      "*.${SERVICE_NAME}",
      "*.${SERVICE_NAME}.${NAMESPACE}",
      "*.${SERVICE_NAME}.${NAMESPACE}.svc.cluster.local"
    ],
    "names": [
      {
        "O": "Cloud"
      }
    ],
    "CN": "${SERVICE_NAME}",
    "key": {
      "algo": "rsa",
      "size": 2048
    }
  }
EOF

cfssl bundle -ca-bundle=ca.pem -cert=server.pem | cfssljson -bare server
kubectl create secret generic ${SECRET} --from-file=private.key=server-key.pem --from-file=public.crt=server.pem
