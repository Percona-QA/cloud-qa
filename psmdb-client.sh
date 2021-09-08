#!/usr/bin/env bash

usage() {
  if [ $# -ne 2 ]; then
    echo "Usage:  psmdb-client.sh --cluster <cluster>"
    exit 1
  fi
}

main() {

  local username="backup"
  local password=""
  local endpoint=""
  local sharding=""
  local replica=""
  local replset_exposed=""
  local user_secrets=""

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
      -r|--replset)
        replset="$2"
        shift
        shift
        ;;
      -u|--user)
        username="$2"
        shift
        shift
        ;;
      -p|--password)
        password="$2"
        shift
        shift
        ;;
      -e|--endpoint)
        endpoint="$2"
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

  if [ -z "${namespace}" ]; then
    namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
  fi

  if [ -z "${cluster}" ]; then
    cluster=$(kubectl get psmdb --output name ${namespace:+--namespace $namespace} | sed 's:^perconaservermongodb.psmdb.percona.com/::')
    if [ $(echo "${cluster}" | wc -l) -gt 1 ]; then
      echo "There's more than one cluster, please specify --cluster <cluster> !"
      exit 1
    elif [ -z "${cluster}" ]; then
      echo "No cluster available in the namespace!"
      exit 1
    fi
  fi

  if [ -z "${password}" -a "${username}" == "backup" ]; then
    user_secrets=$(kubectl get psmdb ${cluster} -ojson | jq -r ".spec.secrets.users")
    password=$(kubectl get secrets ${user_secrets} -o jsonpath="{.data.MONGODB_BACKUP_PASSWORD}" ${namespace:+--namespace $namespace} | base64 --decode)
  elif [ ! -z "${password}" -a "${username}" == "backup" ]; then
    echo "When specifying password please specify --user also."
    exit 1
  fi

  sharding=$(kubectl get psmdb ${cluster} -o jsonpath='{.spec.sharding.enabled}')
  if [ "${sharding}" == "false" -a -z "${replset}" ]; then
    replset=$(kubectl get psmdb ${cluster} -o jsonpath='{.spec.replsets[0].name}' ${namespace:+--namespace $namespace})
  fi

  if [ ! -z "${replset}" ]; then
    if [ "${replset}" != "cfg" ]; then
      replset_exposed=$(kubectl get psmdb ${cluster} -ojson | jq -r ".spec.replsets | select(.[].name | contains (\"${replset}\")) | .[].expose.enabled")
    else
      replset_exposed=$(kubectl get psmdb ${cluster} -ojson | jq -r ".spec.sharding.configsvrReplSet.expose.enabled")
    fi

    if [ -z "${replset_exposed}" ]; then
      echo "Replica set name not found!"
      exit 1
    fi
  fi

  if [ -z "${endpoint}" ]; then
    endpoint=$(kubectl get psmdb ${cluster} -o jsonpath="{.status.host}" ${namespace:+--namespace $namespace})
    if [ ! -z "${replset}" -a "${replset_exposed}" == "false" ]; then
      endpoint="${cluster}-${replset}.${namespace}.svc.cluster.local"
    elif [ ! -z "${replset}" -a "${replset_exposed}" == "true" ]; then
      endpoint="${cluster}-${replset}-0.${namespace}.svc.cluster.local"
    fi
  fi

  set -x
  kubectl run -i --rm --tty percona-client-${RANDOM} --image=percona/percona-server-mongodb:4.4 --restart=Never -- mongo "mongodb://${username}:${password}@${endpoint}/admin?ssl=false${replset:+&replicaSet=$replset}"
}

main "$@" || exit 1
