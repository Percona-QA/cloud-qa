## query version service for PXC
```bash
VS_OPERATOR_VERSION="1.14.0"
VS_ENDPOINT="https://check.percona.com"
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator/${VS_OPERATOR_VERSION}/latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator/${VS_OPERATOR_VERSION}/8.0-latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator/${VS_OPERATOR_VERSION}/5.7-latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator/${VS_OPERATOR_VERSION}/recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator/${VS_OPERATOR_VERSION}/8.0-recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator/${VS_OPERATOR_VERSION}/5.7-recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator/${VS_OPERATOR_VERSION}/8.0.19-10.1" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator/${VS_OPERATOR_VERSION}/5.7.29-31.43" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator/${VS_OPERATOR_VERSION}/latest?databaseVersion=5.7.26" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator/${VS_OPERATOR_VERSION}" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pxc-operator" | jq
```

## query version service for PSMDB
```bash
VS_OPERATOR_VERSION="1.15.0"
VS_ENDPOINT="https://check.percona.com"
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/5.0-latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/4.4-latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/4.2-latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/4.0-latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/5.0-recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/4.4-recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/4.2-recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/4.0-recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/4.2.8-8" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/4.0.19-12" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}/latest?databaseVersion=4.2.7-7" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator/${VS_OPERATOR_VERSION}" | jq
curl -s "${VS_ENDPOINT}/versions/v1/psmdb-operator" | jq
```

## query version service for PS
```bash
VS_OPERATOR_VERSION="0.7.0"
VS_ENDPOINT="https://check.percona.com"
curl -s "${VS_ENDPOINT}/versions/v1/ps-operator/${VS_OPERATOR_VERSION}/latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/ps-operator/${VS_OPERATOR_VERSION}/8.0-latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/ps-operator/${VS_OPERATOR_VERSION}/recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/ps-operator/${VS_OPERATOR_VERSION}/8.0-recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/ps-operator/${VS_OPERATOR_VERSION}/8.0.32-24" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/ps-operator/${VS_OPERATOR_VERSION}/latest?databaseVersion=8.0.32" | jq
curl -s "${VS_ENDPOINT}/versions/v1/ps-operator/${VS_OPERATOR_VERSION}" | jq
curl -s "${VS_ENDPOINT}/versions/v1/ps-operator" | jq
```

## query version service for PG
```bash
VS_OPERATOR_VERSION="2.3.1"
VS_ENDPOINT="https://check.percona.com"
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/13-latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/12-latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/11-latest" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/13-recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/12-recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/11-recommended" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/13.1" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/12.5" -H "accept: application/json" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}/latest?databaseVersion=12.4" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator/${VS_OPERATOR_VERSION}" | jq
curl -s "${VS_ENDPOINT}/versions/v1/pg-operator" | jq
