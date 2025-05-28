#!/bin/bash

PROJECT="marathon"
CRONJOB_NAME="scaling"
IMAGE="quay.io/redhattraining/scaling"
SCHEDULE="5 4 2 * *"
SA_NAME="ex280-ocpsa"
SUCCESS_LIMIT="13"

echo "🔍 Validating CronJob '$CRONJOB_NAME' in project '$PROJECT'..."

# Check if CronJob exists
if ! oc get cronjob "$CRONJOB_NAME" -n "$PROJECT" &>/dev/null; then
    echo "❌ CronJob '$CRONJOB_NAME' not found in project '$PROJECT'"
    exit 1
fi
echo "✅ CronJob exists"

# Validate image
cron_image=$(oc get cronjob "$CRONJOB_NAME" -n "$PROJECT" -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}')
if [ "$cron_image" == "$IMAGE" ]; then
    echo "✅ Image is correct: $cron_image"
else
    echo "❌ Incorrect image: $cron_image"
fi

# Validate schedule
cron_schedule=$(oc get cronjob "$CRONJOB_NAME" -n "$PROJECT" -o jsonpath='{.spec.schedule}')
if [ "$cron_schedule" == "$SCHEDULE" ]; then
    echo "✅ Schedule is correct: $cron_schedule"
else
    echo "❌ Incorrect schedule: $cron_schedule"
fi

# Validate service account
cron_sa=$(oc get cronjob "$CRONJOB_NAME" -n "$PROJECT" -o jsonpath='{.spec.jobTemplate.spec.template.spec.serviceAccountName}')
if [ "$cron_sa" == "$SA_NAME" ]; then
    echo "✅ Service account is correct: $cron_sa"
else
    echo "❌ Incorrect service account: $cron_sa"
fi

# Validate successful job history limit
success_history_limit=$(oc get cronjob "$CRONJOB_NAME" -n "$PROJECT" -o jsonpath='{.spec.successfulJobsHistoryLimit}')
if [ "$success_history_limit" == "$SUCCESS_LIMIT" ]; then
    echo "✅ Successful job history limit is correct: $success_history_limit"
else
    echo "❌ Incorrect successful job history limit: $success_history_limit"
fi

