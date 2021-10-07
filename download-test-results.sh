#!/usr/bin/env bash

usage() {
	if [ $# -ne 2 ]; then
		echo "Usage:  $(basename "$0") --product psmdbo/pxco/pgo --commit xxxzzz"
		exit 1
	fi
}

main() {
	local jobs=()

	while [[ $# -gt 0 ]]; do
		key="$1"
		case "${key}" in
			-h | --help)
				usage
				exit 0
				;;
			-p | --product)
				product="$2"
				shift
				shift
				;;
			-c | --commit)
				commit="$2"
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

	case "${product}" in
		psmdbo)
	        jobs=("psmdb-operator-gke-version" "psmdb-operator-gke-latest" "psmdb-operator-aws-openshift-latest" "psmdb-operator-aws-openshift-4" "psmdb-operator-eks" "psmdb-operator-minikube")
			;;
		pxco)
	        jobs=("pxc-operator-gke-version" "pxc-operator-gke-latest" "pxc-operator-aws-openshift-latest" "pxc-operator-aws-openshift-4" "pxc-operator-eks" "pxc-operator-minikube")
			;;
		pgo)
	        jobs=("pgo-operator-gke-version" "pgo-operator-gke-latest" "pgo-operator-aws-openshift-latest" "pgo-operator-aws-openshift-4" "pgo-operator-eks" "pgo-operator-minikube")
			;;
	esac

	for job in "${jobs[@]}"; do
		echo "Downloading files from job: ${job}"
		mkdir -p "$job"/"$commit"
		pushd "$job"/"$commit" >/dev/null || exit 1
		aws s3 cp s3://percona-jenkins-artifactory/"$job"/"$commit" . --recursive >/dev/null
		echo "Number of files: $(ls -1 | wc -l)"
		echo "---"
		popd >/dev/null || exit 1
	done
}

main "$@" || exit 1
