#!/usr/bin/env bash

src_dir=$(realpath $(dirname $0))
source ${src_dir}/functions

usage() {
  if [ $# -ne 2 ]; then
    echo "Usage:  psmdb-client.sh --namespace <ns> --cluster <cluster>"
    exit 1
  fi
}

main() {

  local cluster=""
  local namespace=""
  local username="backup"
  local password=""
  local endpoint=""
  local replset=""
  local database="admin"

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

  if [[ -z "${namespace}" ]]; then
    namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
  fi

  if [[ -z "${cluster}" ]]; then
    cluster=$(kubectl get psmdb --output name ${namespace:+--namespace $namespace} 2>/dev/null | sed 's:^perconaservermongodb.psmdb.percona.com/::')
    if [ $(echo "${cluster}" | wc -l) -gt 1 ]; then
      echo "There's more than one cluster, please specify --cluster <cluster> !"
      exit 1
    elif [ -z "${cluster}" ]; then
      echo "No cluster available in the namespace!"
      exit 1
    fi
  fi

  mongodb_uri=$(get_mongodb_uri "${namespace}" "${cluster}" "${replset}" "${username}" "${password}" "${endpoint}" "${database}")
  if [[ ! -z "${mongodb_uri}" ]]; then
    set -x
    kubectl run -i --rm --tty percona-client-${RANDOM} --image=percona/percona-server-mongodb:4.4 --restart=Never -- mongo "${mongodb_uri}"
  else
    echo "Error getting MongoDB URI!"
    exit 1
  fi
}

main "$@" || exit 1
