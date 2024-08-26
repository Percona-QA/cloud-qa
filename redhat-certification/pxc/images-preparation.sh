#!/bin/bash
set -e

release='1.15.0'
cluster_8_version="8.0.36-28.1"
cluster_5_version="5.7.44-31.65"
backup_8_version="8.0.35"
backup_5_version="2.4.29"
fluentbit_version="3.1.4"
haproxy_version="2.8.5"
proxysql_version="2.5.5"
pmm_version="2.42.0"

DOCKER_FILE_PATH=""
PYXIS_API_TOKEN=""
PXC_OPERATOR_PROJECT_ID=""
PXC_IMAGES_PROJECT_ID=""
RED_HAT_DOCKER_REGISTRY="quay.io"
REDHAT_OPERATOR_REPO="$RED_HAT_DOCKER_REGISTRY/redhat-isv-containers"
REDHAT_IMAGES_REPO="$RED_HAT_DOCKER_REGISTRY/redhat-isv-containers"

process_image() {
    local image_name=$1
    local tag_name=$2
    local project_id=$3
    local tag_full="${REDHAT_IMAGES_REPO}/${project_id}:${tag_name}"

    docker pull "percona/$image_name"
    docker tag "percona/$image_name" "$tag_full"
    docker push "$tag_full"
    preflight check container --platform=linux/amd64 "$tag_full" --docker-config="$DOCKER_FILE_PATH" --submit --pyxis-api-token="$PYXIS_API_TOKEN" --certification-project-id="$project_id"
}

# Login for operator image
echo "$REDHAT_OPERATOR_KEY" | docker login -u redhat-isv-containers+${PXC_OPERATOR_PROJECT_ID}-robot $RED_HAT_DOCKER_REGISTRY --password-stdin

# operator image
process_image "percona-xtradb-cluster-operator:${release}" "${release}" "${PXC_OPERATOR_PROJECT_ID}"

# Login for container images
echo "$REDHAT_CONTAINERS_KEY" | docker login -u redhat-isv-containers+${PXC_IMAGES_PROJECT_ID}-robot $RED_HAT_DOCKER_REGISTRY --password-stdin

# cluster images
process_image "percona-xtradb-cluster:${cluster_8_version}" "${cluster_8_version}" "${PXC_IMAGES_PROJECT_ID}"
process_image "percona-xtradb-cluster:${cluster_5_version}" "${cluster_5_version}" "${PXC_IMAGES_PROJECT_ID}"

# backup images
process_image "percona-xtradb-cluster-operator:${release}-pxc8.0-backup-pxb${backup_8_version}" "${release}-pxc8.0-backup-pxb${backup_8_version}" "${PXC_IMAGES_PROJECT_ID}"
process_image "percona-xtradb-cluster-operator:${release}-pxc5.7-backup-pxb${backup_5_version}" "${release}-pxc5.7-backup-pxb${backup_5_version}" "${PXC_IMAGES_PROJECT_ID}"

# logcollector image
process_image "percona-xtradb-cluster-operator:${release}-logcollector-fluentbit${fluentbit_version}" "${release}-logcollector-fluentbit${fluentbit_version}" "${PXC_IMAGES_PROJECT_ID}"

# haproxy image
process_image "haproxy:${haproxy_version}" "${release}-haproxy" "${PXC_IMAGES_PROJECT_ID}"

# proxysql image
process_image "proxysql2:${proxysql_version}" "${release}-proxysql" "${PXC_IMAGES_PROJECT_ID}"

# pmm-client image
process_image "pmm-client:${pmm_version}" "${release}-pmmclient" "${PXC_IMAGES_PROJECT_ID}"