#!/usr/bin/env bash

usage() {
  if [ $# -ne 2 ]; then
    echo "Usage:  psmdb-client.sh --cluster <cluster>"
    exit 1
  fi
}

main() {

  local username="clusterAdmin"
  local password=""
  local endpoint=""
  local sharding=""
  local replicaset=""

  while [[ $# -gt 0 ]]
  do
    key="$1"
    case "${key}" in
      -h|--help)
        usage
        exit 0
        ;;
      -c|--cluster)
        cluster="$2"
        shift
        shift
        ;;
      -n|--namespace)
        namespace="$2"
        shift
        shift
        ;;
      *)
        echo "unknown flag or option ${key}"
        usage
        exit 1
        ;;
      esac
  done

  if [ -z "${cluster}" ]; then
    cluster=$(kubectl get psmdb --output name ${namespace} | sed 's:^perconaservermongodb.psmdb.percona.com/::')
    if [ $(echo "${cluster}" | wc -l) -gt 1 ]; then
      echo "There's more than one cluster, please specify --cluster <cluster> !"
      exit 1
    fi
  fi

  password=$(kubectl get secrets my-cluster-name-secrets -o jsonpath="{.data.MONGODB_CLUSTER_ADMIN_PASSWORD}" ${namespace:+--namespace $namespace} | base64 --decode)
  endpoint=$(kubectl get psmdb ${namespace:+--namespace $namespace} | grep "^${cluster} " | awk '{print $2}')

  sharding=$(kubectl get psmdb ${cluster} -o jsonpath='{.spec.sharding.enabled}')

  if [ "${sharding}" == "false" ]; then
    replicaset=$(kubectl get psmdb ${cluster} -o jsonpath='{.spec.replsets[0].name}' ${namespace:+--namespace $namespace})
  fi
  kubectl run -i --rm --tty percona-client-${RANDOM} --image=percona/percona-server-mongodb:4.4 --restart=Never -- mongo "mongodb://${username}:${password}@${endpoint}/admin?ssl=false${replicaset:+&rs=$replicaset}"
}

main "$@" || exit 1
