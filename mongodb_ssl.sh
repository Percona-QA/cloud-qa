#!/usr/bin/env bash

HOSTNAME="$(hostname -f)"

# first parameter sets the hostname/CN for certificate
if [ ! -z "$1" ]; then
  HOSTNAME="$1"
fi

# Generate self signed root CA cert
openssl req -nodes -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -subj "/C=US/ST=California/L=San Francisco/O=Percona/OU=root/CN=${HOSTNAME}/emailAddress=test@percona.com"

# Generate server cert to be signed
openssl req -nodes -newkey rsa:4096 -keyout server.key -out server.csr -subj "/C=US/ST=California/L=San Francisco/O=Percona/OU=server/CN=${HOSTNAME}/emailAddress=test@percona.com"

# Sign the server cert
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

# Create server PEM file
cat server.key server.crt > server.pem

# Generate client cert to be signed
openssl req -nodes -newkey rsa:4096 -keyout client.key -out client.csr -subj "/C=US/ST=California/L=San Francisco/O=Percona/OU=client/CN=${HOSTNAME}/emailAddress=test@percona.com"

# Sign the client cert
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -set_serial 02 -out client.crt

# Create client PEM file
cat client.key client.crt > client.pem

# Create clientPFX file (for Java, C#, etc)
# openssl pkcs12 -inkey client.key -in client.crt -export -out client.pfx

# Start mongod with SSL
# mongod --sslMode requireSSL --sslPEMKeyFile server.pem --sslCAFile ca.crt --dbpath data/db --logpath data/mongod.log --fork

# Connect to mongod with SSL
# mongo --ssl --sslCAFile ca.crt --sslPEMKeyFile client.pem --host `hostname -f`
