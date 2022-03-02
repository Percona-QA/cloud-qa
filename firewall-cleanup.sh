#!/usr/bin/env bash
# run with delete parameter to actually start the cleanup
# second parameter can be cluster name for which to delete fw rules

command="$1"
del_cluster="$2"

declare -A firewalls

readarray -t lines < <(gcloud compute firewall-rules list --format='table(name, targetTags.list():label=TARGET_TAGS)' | tail -n +2 | sed 's/ gke-/ /' | sed 's/-.\{8\}-node//')

active_clusters=$(gcloud container clusters list 2>/dev/null | tail -n +2 | awk '{print $1}')

for line in "${lines[@]}"; do
	key=$(echo "${line}" | awk '{print $1}')
	value=$(echo "${line}" | awk '{print $2}')
	if [ -z "${del_cluster}" -o "${del_cluster}" == "${value}" ]; then
		firewalls[${key}]=${value}
	fi
done

for firewall in "${!firewalls[@]}"; do
	cluster=${firewalls[$firewall]}
	if [ -n "${cluster}" ]; then
		if [ ! $(echo "${active_clusters}" | grep "${cluster}") -a $(echo "${cluster}" | grep -vE "http|default") ]; then
			echo "inactive_fw_rule: ${firewall}"
			echo "inactive_cluster: ${cluster}"
			if [ "${command}" == "delete" ]; then
				gcloud compute firewall-rules delete -q "${firewall}"
			fi
			echo "---"
		fi
	fi
done
