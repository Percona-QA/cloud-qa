#!/usr/bin/env bash

declare -A firewalls

readarray -t lines < <(gcloud compute firewall-rules list --format='table(name, targetTags.list():label=TARGET_TAGS)' | tail -n +2 | sed 's/ gke-/ /' | sed 's/-.\{8\}-node//')

active_clusters=$(gcloud container clusters list 2>/dev/null | tail -n +2 | awk '{print $1}')

for line in "${lines[@]}"; do
	key=$(echo "$line" | awk '{print $1}')
	value=$(echo "$line" | awk '{print $2}')
	firewalls[$key]=$value
done

for firewall in "${!firewalls[@]}"; do
	if [ -n "${firewalls[$firewall]}" ]; then
		if [ ! $(echo "${active_clusters}" | grep "${firewalls[$firewall]}") ]; then
			echo "inactive_fw_rule: $firewall"
			echo "inactive_cluster: ${firewalls[$firewall]}"
		fi
	fi
done
