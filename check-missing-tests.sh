#!/usr/bin/env bash
operator=$1
jenkinsfile=$2
cloud="openshift eks lke gke minikube"
tmp_file1=/tmp/check-missing-tests-1.log
tmp_file2=/tmp/check-missing-tests-2.log

usage() {
  echo "Usage: $(basename $0) <psmdb|pxc|pgo> <full_path_to_jenkinsfile>"
  echo "This script needs to be run from jenkins-pipelines/cloud/jenkins folder!"
}

extract_tests() {
  local file=$1

  cat ${file} | grep "runTest('" | sed "s/ //g" | sed "s/runTest('//" | sed "s/','.*')$//" | sed "s/')$//" | sort | uniq
}

if [[ $# -ne 2 ]]; then
  echo "Illegal number of arguments!"
  usage
  exit 1
fi

if [[ ! -f ${jenkinsfile} ]]; then
  echo "Jenkinsfile does't exist!"
  exit 1
fi

# parse main jenkinsfile first
extract_tests ${jenkinsfile} > ${tmp_file2}
echo "###############"

# check difference for each pipeline
for c in ${cloud}; do
  for f in ${operator}*_${c}*.groovy; do
    echo "FILENAME: ${f}"
    extract_tests ${f} > ${tmp_file1}
    diff ${tmp_file1} ${tmp_file2} --side-by-side --suppress-common-lines | sed 's/\t//g' | sed 's/ //g' | sed 's/>/  > /'
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
      echo "  No difference!"
    fi
    echo "###############"
  done
done

rm -f ${tmp_file1}
rm -f ${tmp_file2}
