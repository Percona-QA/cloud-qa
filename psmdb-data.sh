#!/usr/bin/env bash

src_dir=$(realpath $(dirname $0))
source ${src_dir}/functions

usage() {
	echo "Usage:  $(basename "$0") --namespace <ns> --cluster <cluster> --insert/--rw --database <db>"
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
	local recordcount=100000
	local operationcount=1000000
	local threads=32

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
			--recordcount)
				recordcount="$2"
				shift
				shift
				;;
			--operationcount)
				operationcount="$2"
				shift
				shift
				;;
			--threads)
				threads="$2"
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
		echo -e "### Running ${command} workload on database: ${database} ###"
		echo -e "mongodb_uri: ${mongodb_uri}\n"
		kubectl run -it --rm ycsb-client-${RANDOM} --image=plavi/test:ycsb --restart=Never -- load mongodb -s -P /ycsb/workloads/workloada -p recordcount=${recordcount} -threads ${threads} -p mongodb.url="${mongodb_uri}" -p mongodb.auth="true"
	elif [[ ${command} == "rw" ]]; then
		echo -e "### Running ${command} workload on database: ${database} ###"
		echo -e "mongodb_uri: ${mongodb_uri}\n"
		kubectl run -it --rm ycsb-client-${RANDOM} --image=plavi/test:ycsb --restart=Never -- run mongodb -s -P /ycsb/workloads/workloadb -p recordcount=${recordcount} -p operationcount=${operationcount} -threads 8 -p mongodb.url="${mongodb_uri}" -p mongodb.auth="true"
	fi
}

main "$@" || exit 1
