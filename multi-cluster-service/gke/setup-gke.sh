#!/bin/bash
prefix=${1:-psmdb}

for binary in gcloud kubectl
do
  command -v $binary >/dev/null 2>&1 || { echo >&2 "The script requires $binary but it's not installed.  Aborting."; exit 1; }
done
gcloud container clusters create $prefix-mcs-1 \
--region=europe-west1 \
--enable-ip-alias \
--create-subnetwork name="$prefix-mcs-1" \
--workload-pool=cloud-dev-112233.svc.id.goog \
--preemptible \
--machine-type n1-standard-4 \
--num-nodes=1

kubectl create namespace mcs && kubectl config set-context --current --namespace mcs

gcloud container clusters create $prefix-mcs-2 \
--region=europe-west2 \
--enable-ip-alias \
--create-subnetwork name="$prefix-mcs-2" \
--workload-pool=cloud-dev-112233.svc.id.goog \
--preemptible \
--machine-type n1-standard-4 \
--num-nodes=1

kubectl create namespace mcs &&  kubectl config set-context --current --namespace mcs

gcloud container hub memberships register $prefix-mcs-1 \
--gke-cluster europe-west1/$prefix-mcs-1 \
--enable-workload-identity

gcloud container hub memberships register $prefix-mcs-2 \
--gke-cluster europe-west2/$prefix-mcs-2 \
--enable-workload-identity
