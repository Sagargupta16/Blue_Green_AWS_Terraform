#!/usr/bin/env bash
# Render the deploy artifacts CodePipeline hands to the deploy action.
#
#   imageDetail.json       CodeDeployToECS: image to substitute for <IMAGE1_NAME>
#   taskdef.json           CodeDeployToECS: task definition template
#   appspec.yml            CodeDeployToECS: AppSpec with <TASK_DEFINITION>
#   imagedefinitions.json  ECS standard action (deployment_engine = "ecs")
#
# Every file pins the image by digest (repo@sha256:...), so every stage of a
# pipeline run deploys the image this build tested, whatever lands in ECR
# while the run waits at Manual-Approval.
#
# Required env: IMAGE_URI (digest form), task_definition_arn, container_name,
# container_port. Optional: TASKDEF_SOURCE (a saved `aws ecs
# describe-task-definition` response, used by the tests instead of calling
# AWS) and OUT_DIR (default: current directory).
set -euo pipefail

: "${IMAGE_URI:?IMAGE_URI is required}"
: "${task_definition_arn:?task_definition_arn is required}"
: "${container_name:?container_name is required}"
: "${container_port:?container_port is required}"
OUT_DIR="${OUT_DIR:-.}"

case "$IMAGE_URI" in
  *@sha256:*) ;;
  *)
    echo "IMAGE_URI must be pinned by digest (repo@sha256:...), got: $IMAGE_URI" >&2
    exit 1
    ;;
esac

case "$container_port" in
  '' | *[!0-9]*)
    echo "container_port must be a number, got: $container_port" >&2
    exit 1
    ;;
  *) ;;
esac

mkdir -p "$OUT_DIR"

if [[ -n "${TASKDEF_SOURCE:-}" ]]; then
  describe=$(cat "$TASKDEF_SOURCE")
else
  describe=$(aws ecs describe-task-definition --task-definition "$task_definition_arn" --output json)
fi

# Drop the read-only fields RegisterTaskDefinition rejects, and swap the app
# container's image for the placeholder CodeDeployToECS fills in.
printf '%s' "$describe" | jq --arg c "$container_name" '
  .taskDefinition
  | del(.taskDefinitionArn, .revision, .status, .requiresAttributes,
        .compatibilities, .registeredAt, .registeredBy, .deregisteredAt)
  | if any(.containerDefinitions[]; .name == $c) then .
    else error("container \($c) not found in the task definition") end
  | .containerDefinitions |= map(if .name == $c then .image = "<IMAGE1_NAME>" else . end)
' >"$OUT_DIR/taskdef.json"

jq -n --arg uri "$IMAGE_URI" '{ImageURI: $uri}' >"$OUT_DIR/imageDetail.json"

jq -n --arg c "$container_name" --arg uri "$IMAGE_URI" '[{name: $c, imageUri: $uri}]' \
  >"$OUT_DIR/imagedefinitions.json"

cat >"$OUT_DIR/appspec.yml" <<EOF
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: <TASK_DEFINITION>
        LoadBalancerInfo:
          ContainerName: "$container_name"
          ContainerPort: $container_port
EOF

echo "Rendered deploy artifacts for $IMAGE_URI into $OUT_DIR"
