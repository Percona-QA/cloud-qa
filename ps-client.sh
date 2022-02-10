#!/usr/bin/env bash

src_dir=$(realpath $(dirname $0))
source ${src_dir}/functions

usage() {
	echo "Usage:  $(basename "$0") --namespace <ns> --cluster <cluster>"
	exit 1
}

main() {

	local cluster=""
	local namespace=""
	local username="root"
	local password=""
	local endpoint=""
	local pod=""
	local port="3306"

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
		cluster=$(kubectl get ps --output name ${namespace:+--namespace $namespace} 2>/dev/null | sed 's:^perconaservermysql.ps.percona.com/::')
		if [ "$(echo "${cluster}" | wc -l)" -gt 1 ]; then
			echo "There's more than one cluster, please specify --cluster <cluster> !"
			exit 1
		elif [ -z "${cluster}" ]; then
			echo "No cluster available in the namespace!"
			exit 1
		fi
	fi

	if [[ -z ${pod} ]]; then
		#endpoint=$(kubectl get ps "${cluster}" -ojsonpath='{.status.host}')
 		endpoint="${cluster}-mysql-primary"
	else
	    endpoint="127.0.0.1"
	fi

	if [[ -z ${password} ]]; then
		password=$(kubectl get secrets $(kubectl get ps "${cluster}" -ojsonpath='{.spec.secretsName}') -otemplate='{{.data.'"${username}"' | base64decode}}')
	fi

	if [[ -z ${pod} ]]; then
		echo -e "### Connecting to MySQL at host: ${endpoint} ###\n"
		kubectl run -it --rm percona-client-${RANDOM} --image=percona/percona-server:8.0 --restart=Never -- mysql -h"${endpoint}" -u"${username}" -p"${password}"
	else
		echo -e "### Connecting to MySQL from inside pod: ${pod} ###\n"
		kubectl exec -it "${pod}" -c pxc -- mysql -h"${endpoint}" -P"${port}" -u"${username}" -p"${password}"
	fi
}

main "$@" || exit 1
