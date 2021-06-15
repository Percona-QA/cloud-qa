#!/bin/bash
set -x
while true; do
  kubectl delete pod $@ --force --grace-period=0
  sleep 1
done
