#!/bin/bash
set -euo pipefail

cat > overrides.txt <<EOF
{
  "containerOverrides": [
    {
      "name": "service",
      "command": ["goose", "-dir", "migrations", "up"]
    }
  ]
}
EOF

RUN_TASK_OUTPUT=$(aws ecs run-task \
	--cluster "${ECS_CLUSTER_NAME}" \
	--launch-type EC2 \
	--overrides file://overrides.txt \
	--task-definition "${ECS_SERVICE_NAME}")

FAILURES=$(echo "${RUN_TASK_OUTPUT}" | jq -r '.failures | length')
if [ "${FAILURES}" -gt 0 ]; then
    echo "aws ecs run-task failed:"
    echo "${RUN_TASK_OUTPUT}" | jq '.failures'
    exit 1
fi

TASK_ARN=$(echo "${RUN_TASK_OUTPUT}" | jq -r '.tasks[0].taskArn')
echo "Running task: ${TASK_ARN}"

aws ecs wait tasks-stopped \
    --cluster "${ECS_CLUSTER_NAME}" \
    --tasks "${TASK_ARN}"

EXIT_CODE=$(aws ecs describe-tasks \
    --cluster "${ECS_CLUSTER_NAME}" \
    --tasks "${TASK_ARN}" | jq -r '.tasks[0].containers[0].exitCode')

if [ "$EXIT_CODE" -ne 0 ]; then
    echo "Task failed with exit code: $EXIT_CODE"
    exit 1
fi

echo "Task completed successfully with exit code: $EXIT_CODE"

rm -f overrides.txt exit_code.txt

echo "Updating ECS service to use the latest task definition..."

aws ecs update-service \
  --force-new-deployment \
  --cluster "${ECS_CLUSTER_NAME}" \
  --service "${ECS_SERVICE_NAME}" | jq

echo "Waiting for ECS service to stabilize..."

aws ecs wait services-stable \
  --cluster "${ECS_CLUSTER_NAME}" \
  --services "${ECS_SERVICE_NAME}"

echo "ECS service is stable."