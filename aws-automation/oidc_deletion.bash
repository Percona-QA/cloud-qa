oidc_providers=$(aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[*].Arn' --output text)

for oidc_provider_arn in $oidc_providers; do
  echo "Processing OIDC Provider: $oidc_provider_arn"
  # Describe the OIDC provider to get details
    oidc_details=$(aws iam get-open-id-connect-provider --open-id-connect-provider-arn $oidc_provider_arn)

#     Extract the OIDC URL
    cluster_name=$(echo $oidc_details | jq -r '.Tags[1].Value')
    echo $cluster_name
    # str can be update with any value
    str="jenkins"
    if [[ "$cluster_name" == *"$str"* ]]; then
        echo "Cluster Name: $cluster_name"
        aws iam delete-open-id-connect-provider --open-id-connect-provider-arn $oidc_provider_arn
        echo "$$cluster_name $oidc_provider_arn deleted"
    fi
done