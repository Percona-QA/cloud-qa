#!/bin/bash
rplset="cfg rs0 rs1 rs2"

for rplset in ${rplset}; do
	for podnr in $(seq 0 2); do
    kubectl logs some-name-${rplset}-${podnr} backup-agent > psmdb-${rplset}-${podnr}.log
  done
done
