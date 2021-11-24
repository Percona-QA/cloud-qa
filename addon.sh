#!/usr/bin/env bash

CHAOS_MESH_VER="2.0.4"
CERT_MANAGER_VER="1.5.4"

usage() {
	cat <<EOF
This script is used to add/remove various stuff to kubernetes cluster.
USAGE:
    $(basename "$0") [FLAGS] [OPTIONS]
FLAGS:
    -h, --help               Prints help information
    -i, --install                Install selected options
    -r, --remove             Remove selected options
OPTIONS:
    -c, --cert-manager       Add/remove cert-manager
    -m, --chaos-mesh         Add/remove chaos-mesh
    -v, --cadvisor           Add/remove cadvisor
EOF
}

version_gt() {
	if [ $(echo "$1 >= $2" | bc -l) -eq 1 ]; then
		return 0
	else
		return 1
	fi
}

main() {
	local command=""
	local cert_manager=false
	local chaos_mesh=false
	local cadvisor=false
	local kube_version=$(kubectl version -o json | jq -r '.serverVersion.major + "." + .serverVersion.minor' | sed -r 's/[^0-9.]+//g')
	local namespace=""

	while [[ $# -gt 0 ]]; do
		key="$1"
		case "$key" in
			-h | --help)
				usage
				exit 0
				;;
			-i | --install)
				command="install"
				shift
				;;
			-r | --remove)
				command="remove"
				shift
				;;
			-c | --cert-manager)
				cert_manager=true
				namespace="cert-manager"
				shift
				;;
			-m | --chaos-mesh)
				chaos_mesh=true
				namespace="chaos-testing"
				shift
				;;
			-v | --cadvisor)
				cadvisor=true
				shift
				;;
			*)
				echo "unknown flag or option $key"
				usage
				exit 1
				;;
		esac
	done

	if [ -z "${command}" ]; then
		echo "This script requires either --install or --remove parameter!"
		usage
		exit 1
	fi

	if [ "${command}" == "install" ]; then
		if [ "${cert_manager}" = true ]; then
			echo -e "\n### Adding cert-manager ###"
			kubectl create namespace cert-manager || :
			kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true || :
			kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v${CERT_MANAGER_VER}/cert-manager.yaml --validate=false || : 2>/dev/null
			sleep 45
		fi

		if [ "${chaos_mesh}" = true ]; then
			echo -e "\n### Adding chaos-mesh ###"
			kubectl create ns chaos-testing
			helm repo add chaos-mesh https://charts.chaos-mesh.org
			if version_gt "$kube_version" "1.19"; then
				helm install chaos-mesh chaos-mesh/chaos-mesh --namespace=${namespace} --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock --set dashboard.create=false --version ${CHAOS_MESH_VER} --set clusterScoped=false --set controllerManager.targetNamespace=${namespace}
			else
				helm install chaos-mesh chaos-mesh/chaos-mesh --namespace=${namespace} --set dashboard.create=false --version ${CHAOS_MESH_VER} --set clusterScoped=false --set controllerManager.targetNamespace=${namespace}
			fi
		fi

		if [ "${cadvisor}" = true ]; then
			echo -e "\n### Adding cadvisor ###"
			kubectl apply -f https://raw.github.com/astefanutti/kubebox/master/cadvisor.yaml
		fi
	fi

	if [ "${command}" == "remove" ]; then
		if [ "${cert_manager}" = true ]; then
			echo -e "\n### Removing cert-manager ###"
			kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v${CERT_MANAGER_VER}/cert-manager.yaml 2>/dev/null || :
			kubectl delete --grace-period=0 --force=true namespace "${namespace}"
		fi

		if [ "${chaos_mesh}" = true ]; then
			echo -e "\n### Removing chaos-mesh ###"
			kubectl delete podchaos --all --all-namespaces || :
			kubectl delete networkchaos --all --all-namespaces || :
			helm uninstall chaos-mesh --namespace=${namespace}
			timeout 30 kubectl delete --grace-period=0 --force=true crd awschaos.chaos-mesh.org dnschaos.chaos-mesh.org gcpchaos.chaos-mesh.org httpchaos.chaos-mesh.org iochaos.chaos-mesh.org jvmchaos.chaos-mesh.org kernelchaos.chaos-mesh.org networkchaos.chaos-mesh.org podchaos.chaos-mesh.org podhttpchaos.chaos-mesh.org podiochaos.chaos-mesh.org podnetworkchaos.chaos-mesh.org schedules.chaos-mesh.org stresschaos.chaos-mesh.org timechaos.chaos-mesh.org workflownodes.chaos-mesh.org workflows.chaos-mesh.org || :
			timeout 30 kubectl delete --grace-period=0 --force=true clusterrolebinding chaos-mesh-chaos-controller-manager-cluster-level || :
			timeout 30 kubectl delete --grace-period=0 --force=true clusterrole chaos-mesh-chaos-controller-manager-cluster-level chaos-mesh-chaos-controller-manager-target-namespace || :
			timeout 30 kubectl delete --grace-period=0 --force=true MutatingWebhookConfiguration chaos-mesh-mutation
			timeout 30 kubectl delete --grace-period=0 --force=true ValidatingWebhookConfiguration chaos-mesh-validation validate-auth
			kubectl delete --grace-period=0 --force=true namespace ${namespace}
		fi

		if [ "${cadvisor}" = true ]; then
			echo -e "\n### Removing cadvisor ###"
			kubectl delete -f https://raw.github.com/astefanutti/kubebox/master/cadvisor.yaml
		fi
	fi
}

main "$@" || exit 1
