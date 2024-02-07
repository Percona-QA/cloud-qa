FROM scratch

LABEL \
	operators.operatorframework.io.bundle.mediatype.v1="registry+v1" \
	operators.operatorframework.io.bundle.manifests.v1="manifests/" \
	operators.operatorframework.io.bundle.metadata.v1="metadata/" \
	operators.operatorframework.io.bundle.package.v1="percona-postgresql-operator" \
	operators.operatorframework.io.bundle.channels.v1="stable" \
	operators.operatorframework.io.bundle.channel.default.v1="stable" \
	operators.operatorframework.io.metrics.mediatype.v1=metrics+v1 \
    operators.operatorframework.io.metrics.project_layout=helm.sdk.operatorframework.io/v1 \
	com.redhat.delivery.operator.bundle=true \
	com.redhat.openshift.versions="v4.11-v4.14" \
	org.opencontainers.image.authors="info@percona.com" \
	org.opencontainers.image.url="https://percona.com" \
	org.opencontainers.image.vendor="Percona"

COPY 2.3.2/manifests/ /manifests/
COPY 2.3.2/metadata/ /metadata/
