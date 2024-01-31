release=2.3.2

docker build --platform=linux/amd64 . -f bundle-${release}.Dockerfile -t tishina/percona-postgresql-operator:${release}-community-bundle
docker push tishina/percona-postgresql-operator:${release}-community-bundle
darwin-amd64-opm index add --bundles docker.io/tishina/percona-postgresql-operator:${release}-community-bundle  --tag tishina/percona-postgresql-operator-bundle.v${release}-index:latest --build-tool docker --debug