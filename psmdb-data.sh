#!/usr/bin/env bash

src_dir=$(realpath $(dirname $0))
source ${src_dir}/functions

usage() {
	echo "Usage:  psmdb-add-data.sh --namespace <ns> --cluster <cluster> --insert/--rw --database <db>"
	exit 1
}

main() {

	local cluster=""
	local namespace=""
	local username="backup"
	local password=""
	local endpoint=""
	local replset=""
	local database="ycsb_test"
	local command=""

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
			-r | --replset)
				replset="$2"
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
			-d | --database)
				database="$2"
				shift
				shift
				;;
			-i | --insert)
				command="insert"
				shift
				;;
			-w | --rw)
				command="rw"
				shift
				;;
			*)
				echo "unknown flag or option ${key}"
				usage
				exit 1
				;;
		esac
	done

	if [[ -z ${command} ]]; then
		echo "Please specify either --insert or --rw parameter!"
		exit 1
	fi

	if [[ -z ${namespace} ]]; then
		namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
	fi

	if [[ -z ${cluster} ]]; then
		cluster=$(kubectl get psmdb --output name ${namespace:+--namespace $namespace} 2>/dev/null | sed 's:^perconaservermongodb.psmdb.percona.com/::')
		if [ "$(echo "${cluster}" | wc -l)" -gt 1 ]; then
			echo "There's more than one cluster, please specify --cluster <cluster> !"
			exit 1
		elif [ -z "${cluster}" ]; then
			echo "No cluster available in the namespace!"
			exit 1
		fi
	fi

	mongodb_uri=$(get_mongodb_uri "${namespace}" "${cluster}" "${replset}" "${username}" "${password}" "${endpoint}" "${database}")
	if [[ -z ${mongodb_uri} ]]; then
		echo "Error getting MongoDB URI!"
		exit 1
	fi

	if [[ ${command} == "insert" ]]; then
		echo "##### Running read/write workload on database: ${database} #####"
		set -x
		kubectl run -it --rm ycsb-client --image=plavi/test:ycsb --restart=Never -- load mongodb -s -P /ycsb/workloads/workloada -p recordcount=100000 -threads 8 -p mongodb.url="${mongodb_uri}" -p mongodb.auth="true"
	elif [[ ${command} == "rw" ]]; then
		echo "##### Running insert workload on database: ${database} #####"
		set -x
		kubectl run -it --rm ycsb-client --image=plavi/test:ycsb --restart=Never -- run mongodb -s -P /ycsb/workloads/workloadb -p recordcount=100000 -p operationcount=1000000 -threads 8 -p mongodb.url="${mongodb_uri}" -p mongodb.auth="true"
	fi
}

main "$@" || exit 1
