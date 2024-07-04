repo='percona'
psmdb-operator="percona-server-mongodb-operator"
psmdb="percona-server-mongodb"
pbm="percona-backup-mongodb"
release='1.16.0'
pmm_version='2.41.2'
psmdb7_version="7.0.8-5"
psmdb6_version="6.0.15-12"
psmdb5_version="5.0.26-22"
psmdb_backup_version="2.4.1"

export PSMDB_IMAGES_PROJECT_ID="5e627846b6bf136294e8bb8b"
export PSMDB_OPERATOR_PROJECT_ID="5e62470102235d3f505f60e3"
export PSMDB_IMAGES_PROJECT_USER="redhat-isv-containers+5e627846b6bf136294e8bb8b-robot"
export PSMDB_OPERATOR_PROJECT_USER="redhat-isv-containers+5e62470102235d3f505f60e3-robot"

export REDHAT_CONTAINERS_KEY=""
export REDHAT_OPERATOR_KEY=""
export PYXIS_API_TOKEN=""

if [[ -z $PYXIS_API_TOKEN || -z $REDHAT_CONTAINERS_KEY || -z $REDHAT_OPERATOR_KEY ]]; then
  echo "PYXIS_API_TOKEN or REDHAT_OPERATOR_KEY or REDHAT_CONTAINERS_KEY are empty, please add it"
fi

# OPERATOR IMAGE
echo "$REDHAT_OPERATOR_KEY" | docker login -u $PSMDB_OPERATOR_PROJECT_USER quay.io --password-stdin
docker pull --platform linux/amd64 $repo/${psmdb-operator}:${release}
operator_image_id=`docker images | grep "${release} " | awk '{print $3}'`
echo $operator_image_id
docker tag $operator_image_id quay.io/redhat-isv-containers/${PSMDB_OPERATOR_PROJECT_ID}:${release} && docker push quay.io/redhat-isv-containers/${PSMDB_OPERATOR_PROJECT_ID}:${release}
preflight check container --platform=linux/amd64 quay.io/redhat-isv-containers/${PSMDB_OPERATOR_PROJECT_ID}:${release} --docker-config=/Users/marukovich/.docker/config.json --submit --pyxis-api-token=$PYXIS_API_TOKEN --certification-project-id=$PSMDB_OPERATOR_PROJECT_ID

# PSMDB IMAGES
echo "$REDHAT_CONTAINERS_KEY" | docker login -u $PSMDB_IMAGES_PROJECT_USER quay.io --password-stdin

for postfix in psmdb7_version psmdb6_version psmdb5_version
do
    docker pull --platform linux/amd64  $repo/$psmdb:$postfix
    image_id=`docker images | grep "$postfix " | awk '{print $3}'`
    echo $image_id
    docker tag $image_id quay.io/redhat-isv-containers/${PSMDB_IMAGES_PROJECT_ID}:$psmdb7_version && docker push quay.io/redhat-isv-containers/${PSMDB_IMAGES_PROJECT_ID}:$psmdb7_version
    preflight check container --platform=linux/amd64 quay.io/redhat-isv-containers/${PSMDB_IMAGES_PROJECT_ID}:$psmdb7_version --docker-config=/Users/marukovich/.docker/config.json --submit --pyxis-api-token=$PYXIS_API_TOKEN --certification-project-id=$PSMDB_IMAGES_PROJECT_ID
done


# PSMDB BACKUP

docker pull --platform linux/amd64 percona/${pbm}:${psmdb_backup_version}
image_id=`docker images | grep "${psmdb_backup_version} " | awk '{print $3}'`
echo $image_id
docker tag $image_id quay.io/redhat-isv-containers/${PSMDB_IMAGES_PROJECT_ID}:${release}-backup && docker push quay.io/redhat-isv-containers/${PSMDB_IMAGES_PROJECT_ID}:${release}-backup
preflight check container --platform=linux/amd64 quay.io/redhat-isv-containers/${PSMDB_IMAGES_PROJECT_ID}:${release}-backup --docker-config=/Users/marukovich/.docker/config.json --submit --pyxis-api-token=$PYXIS_API_TOKEN --certification-project-id=$PSMDB_IMAGES_PROJECT_ID

# PMM
docker pull $repo/pmm-client:$pmm_version
pmm_image_id=`docker images | grep "pmm-client" | grep "$pmm_version" | awk '{print $3}'`
docker tag $pmm_image_id quay.io/redhat-isv-containers/${PSMDB_IMAGES_PROJECT_ID}:${release}-pmm  && docker push quay.io/redhat-isv-containers/${PSMDB_IMAGES_PROJECT_ID}:${release}-pmm
preflight check container --platform=linux/amd64 quay.io/redhat-isv-containers/${PSMDB_IMAGES_PROJECT_ID}:${release}-pmm --docker-config=/Users/marukovich/.docker/config.json --submit --pyxis-api-token=$PYXIS_API_TOKEN --certification-project-id=$PSMDB_IMAGES_PROJECT_ID

