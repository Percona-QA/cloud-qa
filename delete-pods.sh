#!/usr/bin/env bash

echo "Deleting pods: $@ in a loop, press CTRL-C to stop."

while true; do
  kubectl delete pod $@ --force --grace-period=0 >/dev/null 2>&1
  sleep 1
done
