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
	local username="postgres"
	local password=""
	local endpoint=""
	local database="sbtest"
	local command=""
	local time="120"
	local sysbench_opts="--rand-type=pareto --report-interval=1 --tables=4 --table_size=500000 --threads=4"

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
			-t | --time)
				time="$2"
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
		cluster=$(kubectl get pg --output name ${namespace:+--namespace $namespace} 2>/dev/null | sed 's:^perconapgcluster.pgv2.percona.com/::')
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
			endpoint=$(kubectl get pg "${cluster}" -ojsonpath='{.status.host}')
#			endpoint=$(kubectl get secrets ${cluster}-pguser-${cluster} --template='{{.data.host | base64decode}}{{"\n"}}')
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

	if [[ ${command} == "insert" ]]; then
		echo -e "### Running ${command} workload on database: ${database} ###"
		echo -e "PG endpoint: ${endpoint}\n"
		kubectl run -it --rm percona-client-${RANDOM} --image=perconalab/percona-distribution-postgresql:15 --restart=Never -- bash -c "PGPASSWORD='${password}' psql -h${endpoint} -p${port} -U${username} -c 'CREATE DATABASE ${database};'"
		kubectl run -it --rm sysbench-client-${RANDOM} --image=perconalab/sysbench:latest --restart=Never -- sysbench oltp_read_write --db-driver=pgsql --pgsql-host="${endpoint}" --pgsql-port=${port} --pgsql-user=${username} --pgsql-password=${password} --pgsql-db=${database} ${sysbench_opts} prepare
	elif [[ ${command} == "rw" ]]; then
		echo -e "### Running ${command} workload on database: ${database} ###"
		echo -e "MySQL endpoint: ${endpoint}\n"
		kubectl run -it --rm sysbench-client-${RANDOM} --image=perconalab/sysbench:latest --restart=Never -- sysbench oltp_read_write --db-driver=pgsql --pgsql-host="${endpoint}" --pgsql-port=${port} --pgsql-user=${username} --pgsql-password=${password} --pgsql-db=${database} --time="${time}" ${sysbench_opts} run
	fi
}

main "$@" || exit 1
