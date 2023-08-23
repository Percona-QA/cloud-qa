#!/usr/bin/env bash

src_dir=$(realpath $(dirname $0))
source ${src_dir}/functions

usage() {
	echo "Usage:  $(basename "$0") --namespace <ns> --cluster <cluster> --endpoint <service>"
	exit 1
}

main() {

	local cluster=""
	local namespace=""
	local username="postgres"
	local password=""
	local endpoint=""
	local pod=""
	local port=""

	while [[ $# -gt 0 ]]; do
		key="$1"
		case "${key}" in
			-h | --help)
				usage
				exit 0
				;;
			-c | --cluster)
				cluster="$2"
				shift
				shift
				;;
			-n | --namespace)
				namespace="$2"
				shift
				shift
				;;
			-u | --user)
				username="$2"
				shift
				shift
				;;
			-p | --password)
				password="$2"
				shift
				shift
				;;
			-e | --endpoint)
				endpoint="$2"
				shift
				shift
				;;
			-o | --pod)
				pod="$2"
				shift
				shift
				;;
			-P | --port)
				port="$2"
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

	if [[ -z ${namespace} ]]; then
		namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
	fi

	if [[ -z ${cluster} ]]; then
		cluster=$(kubectl get pg --output name ${namespace:+--namespace $namespace} 2>/dev/null | sed 's:^perconapgcluster.pg.percona.com/::')
		if [ "$(echo "${cluster}" | wc -l)" -gt 1 ]; then
			echo "There's more than one cluster, please specify --cluster <cluster> !"
			exit 1
		elif [ -z "${cluster}" ]; then
			echo "No cluster available in the namespace!"
			exit 1
		fi
	fi

	if [[ -z "${pod}" ]]; then
		if [[ -z "${endpoint}" ]]; then
#			endpoint=$(kubectl get pg "${cluster}" -ojsonpath='{.status.host}')
			endpoint=$(kubectl get secrets ${cluster}-pguser-${username} --template='{{.data.host | base64decode}}{{"\n"}}')
		fi
	else
	    endpoint="127.0.0.1"
		port="5432"
	fi

	if [[ -z "${port}" ]]; then
		port="5432"
	fi

	if [[ -z ${password} ]]; then
#		password=$(kubectl get secrets $(kubectl get ps "${cluster}" -ojsonpath='{.spec.secretsName}') -otemplate='{{.data.'"${username}"' | base64decode}}')
		password=$(kubectl get secrets ${cluster}-pguser-${username} --template='{{.data.password | base64decode}}{{"\n"}}')
	fi

	if [[ -z ${pod} ]]; then
		echo -e "### Connecting to PostgreSQL at host: ${endpoint}:${port} ###\n"
		kubectl run -it --rm percona-client-${RANDOM} --image=perconalab/percona-distribution-postgresql:15 --restart=Never -- bash -c "PGPASSWORD=${password} psql -h${endpoint} -p${port} -U${username}"
	else
		echo -e "### Connecting to PostgreSQL from inside pod: ${pod} ###\n"
		kubectl exec -it "${pod}" -c mysql -- PGPASSWORD='${password}' psql -h"${endpoint}" -P"${port}" -U"${username}"
	fi
}

main "$@" || exit 1
