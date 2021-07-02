#!/usr/bin/env bash

usage() {
  if [ $# -ne 2 ]; then
    echo "Usage:  download-test-results.sh --product psmdbo/pxco/pgo --commit xxxzzz"
    exit 1
  fi
}

main() {
  local pxco_jobs=("pxc-operator-gke-version" "pxc-operator-gke-latest" "pxc-operator-aws-openshift-latest" "pxc-operator-aws-openshift-4" "pxc-operator-eks" "pxc-operator-minikube")
  local psmdbo_jobs=("psmdb-operator-gke-version" "psmdb-operator-gke-latest" "psmdb-operator-aws-openshift-latest" "psmdb-operator-aws-openshift-4" "psmdb-operator-eks" "psmdb-operator-minikube")
  local pgo_jobs=("pgo-operator-gke-version" "pgo-operator-gke-latest" "pgo-operator-aws-openshift-latest" "pgo-operator-aws-openshift-4" "pgo-operator-eks" "pgo-operator-minikube")
  local jobs=()

  while [[ $# -gt 0 ]]
  do
    key="$1"
    case "${key}" in
      -h|--help)
        usage
        exit 0
        ;;
      -p|--product)
        product="$2"
        shift
        shift
        ;;
      -c|--commit)
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
      jobs=${psmdbo_jobs[@]}
      ;;
    pxco)
      jobs=${pxco_jobs[@]}
      ;;
    pgo)
      jobs=${pgo_jobs[@]}
  esac

  for job in ${jobs[@]}; do
    echo "Downloading files from job: ${job}"
    mkdir -p $job/$commit
    pushd $job/$commit >/dev/null
    aws s3 cp s3://percona-jenkins-artifactory/$job/$commit . --recursive >/dev/null
    echo "Number of files: $(ls -1|wc -l)"
    echo "---"
    popd >/dev/null
  done
}

main "$@" || exit 1
