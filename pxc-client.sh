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

	if [[ -z ${endpoint} ]]; then
		endpoint=$(kubectl get pxc "${cluster}" -ojsonpath='{.status.host}')
	fi

	if [[ -z ${password} ]]; then
		password=$(kubectl get secrets $(kubectl get pxc "${cluster}" -o jsonpath='{.spec.secretsName}') -o template='{{ .data.'"${username}"' | base64decode }}')
	fi

	if [[ -n ${endpoint} ]]; then
		set -x
		kubectl run -i --rm --tty percona-client-${RANDOM} --image=percona/percona-xtradb-cluster:8.0 --restart=Never -- mysql -h"${endpoint}" -u"${username}" -p"${password}"
	else
		echo "Error getting MySQL endpoint!"
		exit 1
	fi
}

main "$@" || exit 1
