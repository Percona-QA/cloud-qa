#!/usr/bin/env bash
# This checks container memory usage in a loop

usage() {
	echo "Usage:  $(basename "$0") <pod> <container>"
	exit 1
}

main() {
	local pod="$1"
	local container="$2"

	if [ "$#" -ne 2 ]; then
		usage >&2
		exit 1
	fi
    kubectl exec -ti ${pod} -c ${container} -- bash -c "while true; do ps -eLf | wc -l && sleep 5 ; done"
}

main "$@" || exit 1
