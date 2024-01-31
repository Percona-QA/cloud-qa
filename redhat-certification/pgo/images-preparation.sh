release='2.3.1'
pmm_version='2.41.0'
repo='percona'
export PGO_IMAGES_PROJECT_ID="6137355a74d3177984523152"
export PGO_OPERATOR_PROJECT_ID="612f4f0b0c5abda5dd37c619"

export REDHAT_CONTAINERS_KEY=""
export REDHAT_OPERATOR_KEY=""
export PYXIS_API_TOKEN=""


if [[ -z $PYXIS_API_TOKEN || -z $REDHAT_CONTAINERS_KEY || -z $REDHAT_OPERATOR_KEY ]]; then
  echo "PYXIS_API_TOKEN or REDHAT_OPERATOR_KEY or REDHAT_CONTAINERS_KEY are empty, please add it"
fi

# OPERATOR IMAGE
echo "$REDHAT_OPERATOR_KEY" | docker login -u redhat-isv-containers+612f4f0b0c5abda5dd37c619-robot quay.io --password-stdin
docker pull $repo/percona-postgresql-operator:${release}
operator_image_id=`docker images | grep "${release} " | awk '{print $3}'`

docker tag $operator_image_id quay.io/redhat-isv-containers/612f4f0b0c5abda5dd37c619:2.3.1-postgres-operator && docker push quay.io/redhat-isv-containers/612f4f0b0c5abda5dd37c619:${release}-postgres-operator
preflight check container --platform=linux/amd64 quay.io/redhat-isv-containers/612f4f0b0c5abda5dd37c619:${release}-postgres-operator --docker-config=/Users/marukovich/.docker/config.json --submit --pyxis-api-token=$PYXIS_API_TOKEN --certification-project-id=$PGO_OPERATOR_PROJECT_ID

# POSTGRES IMAGES
echo "$REDHAT_CONTAINERS_KEY" | docker login -u redhat-isv-containers+6137355a74d3177984523152-robot quay.io --password-stdin
for version in 12 13 14 15 16
do
  for postfix in pgbackrest postgres pgbouncer postgres-gis
  do
    docker pull $repo/percona-postgresql-operator:${release}-ppg${version}-${postfix}
    image_id=`docker images | grep "${release}-ppg${version}-${postfix} " | awk '{print $3}'`
    echo $image_id
    docker tag $image_id quay.io/redhat-isv-containers/6137355a74d3177984523152:${release}-ppg${version}-${postfix} && docker push quay.io/redhat-isv-containers/6137355a74d3177984523152:${release}-ppg${version}-${postfix}
    preflight check container quay.io/redhat-isv-containers/6137355a74d3177984523152:${release}-ppg${version}-${postfix} --docker-config=/Users/marukovich/.docker/config.json --submit --pyxis-api-token=$PYXIS_API_TOKEN --certification-project-id=$PGO_IMAGES_PROJECT_ID
  done
done

# PMM

docker pull $repo/pmm-client:$pmm_version
pmm_image_id=`docker images | grep "pmm-client" | grep '$pmm_version' | awk '{print $3}'`
docker tag $pmm_image_id quay.io/redhat-isv-containers/6137355a74d3177984523152:${release}-pmmclient  && docker push quay.io/redhat-isv-containers/6137355a74d3177984523152:${release}-pmmclient
preflight check container quay.io/redhat-isv-containers/6137355a74d3177984523152:${release}-pmmclient --docker-config=/Users/marukovich/.docker/config.json --submit --pyxis-api-token=$PYXIS_API_TOKEN --certification-project-id=$PGO_IMAGES_PROJECT_ID

