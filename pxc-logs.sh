#!/usr/bin/env bash

usage() {
	echo "Usage:  $(basename "$0") --namespace <namespace>"
	exit 1
}

main() {
	local namespace=""
	local pod=""

	while [[ $# -gt 0 ]]; do
		key="$1"
		case "${key}" in
			-h | --help)
				usage
				exit 0
				;;
			-n | --namespace)
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

	pod=$(kubectl get pods -l app.kubernetes.io/name=percona-xtradb-cluster-operator --output name ${namespace:+--namespace $namespace})
	if [ -n "${pod}" ]; then
		kubectl logs "${pod}" ${namespace:+--namespace $namespace}
	else
		echo "Operator pod is not found in the namespace!"
		exit 1
	fi
}

main "$@" || exit 1
