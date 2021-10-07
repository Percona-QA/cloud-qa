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
	local username="proxyadmin"
	local password=""
	local endpoint=""
	local port="6032"
	local pod=""

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
		cluster=$(kubectl get pxc --output name ${namespace:+--namespace $namespace} 2>/dev/null | sed 's:^perconaxtradbcluster.pxc.percona.com/::')
		if [ "$(echo "${cluster}" | wc -l)" -gt 1 ]; then
			echo "There's more than one cluster, please specify --cluster <cluster> !"
			exit 1
		elif [ -z "${cluster}" ]; then
			echo "No cluster available in the namespace!"
			exit 1
		fi
	fi

	if [[ -z ${pod} ]]; then
		endpoint="${cluster}-proxysql-unready"
	else
	    endpoint="127.0.0.1"
	fi

	if [[ -z ${password} ]]; then
		password=$(kubectl get secrets $(kubectl get pxc "${cluster}" -ojsonpath='{.spec.secretsName}') -otemplate='{{ .data.'"${username}"' | base64decode }}')
	fi

	if [[ -z ${pod} ]]; then
		echo "### Connecting to proxysql admin at host: ${endpoint} ###"
		kubectl run -it --rm percona-client-${RANDOM} --image=percona:8.0 --restart=Never -- mysql -h"${endpoint}" -u"${username}" -p"${password}" -P"${port}"
	else
		echo "### Connecting to proxysql admin from inside pod: ${pod} ###"
	    kubectl exec -it "${pod}" -c proxysql -- mysql -h"${endpoint}" -P"${port}" -u"${username}" -p"${password}"
	fi
}

main "$@" || exit 1
