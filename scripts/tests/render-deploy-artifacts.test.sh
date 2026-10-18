#!/usr/bin/env bash
# Tests for scripts/render-deploy-artifacts.sh. Needs bash and jq; no AWS.
# Run: bash scripts/tests/render-deploy-artifacts.test.sh
set -uo pipefail

here=$(cd "$(dirname "$0")" && pwd)
script="$here/../render-deploy-artifacts.sh"
fixture="$here/fixtures/describe-task-definition.json"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

pass=0
fail=0
check() {
  local name=$1
  shift
  if "$@"; then
    pass=$((pass + 1))
    echo "ok   $name"
  else
    fail=$((fail + 1))
    echo "FAIL $name"
  fi
  return 0
}

digest="111122223333.dkr.ecr.us-east-1.amazonaws.com/blue-green-dep-app-ecr-repo@sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
app="main-blue-green-dep-app-container"

render() {
  IMAGE_URI=$1 task_definition_arn="arn:aws:ecs:us-east-1:111122223333:task-definition/main-blue-green-dep-app-task-def:7" \
    container_name=$2 container_port=$3 TASKDEF_SOURCE="$fixture" OUT_DIR="$work/out" \
    bash "$script" >/dev/null 2>"$work/stderr"
  return $?
}

# Happy path
render "$digest" "$app" 3000
check "renders with a digest-pinned image" test $? -eq 0
check "writes all four artifacts" test -s "$work/out/taskdef.json" -a -s "$work/out/imageDetail.json" \
  -a -s "$work/out/imagedefinitions.json" -a -s "$work/out/appspec.yml"

check "taskdef: app image is the <IMAGE1_NAME> placeholder" \
  test "$(jq -r --arg c "$app" '.containerDefinitions[] | select(.name == $c) | .image' "$work/out/taskdef.json")" = "<IMAGE1_NAME>"
check "taskdef: sidecar image is untouched" \
  test "$(jq -r '.containerDefinitions[] | select(.name == "xray-daemon") | .image' "$work/out/taskdef.json")" = "public.ecr.aws/xray/aws-xray-daemon:latest"
check "taskdef: read-only fields are removed" \
  test "$(jq '[has("taskDefinitionArn","revision","status","requiresAttributes","compatibilities","registeredAt","registeredBy")] | any' "$work/out/taskdef.json")" = "false"
check "taskdef: keeps family, both roles and sizing" \
  test "$(jq -r '[.family, .taskRoleArn != null, .executionRoleArn != null, .cpu, .memory] | map(tostring) | join(",")' "$work/out/taskdef.json")" = "main-blue-green-dep-app-task-def,true,true,256,512"

check "imageDetail.json carries the digest" \
  test "$(jq -r '.ImageURI' "$work/out/imageDetail.json")" = "$digest"
check "imagedefinitions.json maps the app container to the digest" \
  test "$(jq -c '.' "$work/out/imagedefinitions.json")" = "[{\"name\":\"$app\",\"imageUri\":\"$digest\"}]"

check "appspec keeps the <TASK_DEFINITION> placeholder" grep -q 'TaskDefinition: <TASK_DEFINITION>' "$work/out/appspec.yml"
check "appspec names the container and port" grep -q "ContainerName: \"$app\"" "$work/out/appspec.yml"
check "appspec port is numeric" grep -q 'ContainerPort: 3000$' "$work/out/appspec.yml"

# Rejections
rm -rf "$work/out"
render "${digest%@*}:main-latest" "$app" 3000
check "rejects a mutable tag instead of a digest" test $? -ne 0
check "explains the digest requirement" grep -q 'pinned by digest' "$work/stderr"
check "writes nothing when rejected" test ! -e "$work/out/taskdef.json"

render "$digest" "no-such-container" 3000
check "rejects an unknown container name" test $? -ne 0
check "names the missing container" grep -q 'no-such-container not found' "$work/stderr"

render "$digest" "$app" "3000; rm -rf /"
check "rejects a non-numeric port" test $? -ne 0

echo
echo "$pass passed, $fail failed"
[[ "$fail" -eq 0 ]]
