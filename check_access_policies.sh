#!/bin/bash
issue_detected=1

checkaccesspolicies() {
	policy_object="$1"
	policy_object_name="$2"
	policy_permission_role="$3"
	policy_permission_group="$4"
	policy_permissions="$(tmc $policy_object iam get-policy $policy_object_name | yq --arg role "$policy_permission_role" --arg group "$policy_permission_group" -r '.policyList[]? | . as $object | .roleBindings[]? | select(.role==$role) | . as $rolebinding | .subjects[]? | select(.name==$group) | $rolebinding.role + " : " + .name')"

	if [ -z "$policy_permissions" ]; then
		echo "$policy_object $policy_object_name does not have correct access policies, please review: $policy_permission_role : $policy_permission_group"
		issue_detected=0
	fi
}

checkaccesspolicies "clustergroup" "dev-cg" "clustergroup.edit" "sso:appops@vsphere.local"
checkaccesspolicies "clustergroup" "prod-cg" "clustergroup.view" "sso:appops@vsphere.local"
checkaccesspolicies "clustergroup" "prod-cg" "cluster.admin" "sso:appops@vsphere.local"
checkaccesspolicies "workspace" "prod-ws" "workspace.admin" "sso:appops@vsphere.local"
checkaccesspolicies "workspace" "prod-ws" "workspace.view" "sso:development@vsphere.local"
checkaccesspolicies "workspace" "dev-ws" "workspace.admin" "sso:appops@vsphere.local"
checkaccesspolicies "workspace" "dev-ws" "workspace.edit" "sso:development@vsphere.local"

if [ "$issue_detected" == "1" ]; then
	echo "No issues detected"
fi
