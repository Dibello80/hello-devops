
#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="hello-devops"
IMAGE="ghcr.io/dibello80/hello-devops:latest"
REGION="us-west-1"
LOG_GROUP="/hello-devops/application"

PREVIOUS_IMAGE=""
ROLLBACK_STARTED=false

start_container() {
    local image="$1"

    sudo docker run -d \
        --restart unless-stopped \
        --name "$APP_NAME" \
        -p 127.0.0.1:8080:8080 \
        --log-driver=awslogs \
        --log-opt "awslogs-region=$REGION" \
        --log-opt "awslogs-group=$LOG_GROUP" \
        --log-opt "awslogs-stream=$APP_NAME" \
        "$image"
}

check_health() {
    for attempt in {1..12}; do
        if curl --fail --silent \
            --max-time 5 \
            http://127.0.0.1:8080/ >/dev/null; then

            echo "Application health check passed."
            return 0
        fi

        echo "Health check attempt $attempt failed."
        sleep 5
    done

    return 1
}

rollback() {
    local exit_code=$?

    # Prevent recursive rollback attempts.
    trap - ERR

    if [[ "$ROLLBACK_STARTED" == true ]]; then
        exit 1
    fi

    ROLLBACK_STARTED=true

    echo "Deployment failed (exit code: $exit_code)."

    sudo docker rm -f "$APP_NAME" || true

    if [[ -z "$PREVIOUS_IMAGE" ]]; then
        echo "No previous image available for rollback."
        exit 1
    fi

    echo "Restoring previous image: $PREVIOUS_IMAGE"

    if ! start_container "$PREVIOUS_IMAGE"; then
        echo "ERROR: Could not restart previous image."
        exit 1
    fi

    if check_health; then
        echo "ROLLBACK SUCCESSFUL: Previous version restored."
    else
        echo "ERROR: Rollback health check failed."
    fi

    # Report deployment failure even when rollback works.
    exit 1
}

echo "Checking current deployment..."

if sudo docker container inspect "$APP_NAME" >/dev/null 2>&1; then
    PREVIOUS_IMAGE=$(sudo docker inspect \
        --format '{{.Image}}' "$APP_NAME")

    echo "Previous image saved: $PREVIOUS_IMAGE"
else
    echo "No existing application container found."
fi

echo "Pulling new Docker image..."

# Pull before removing the current working container.
sudo docker pull "$IMAGE"

echo "Replacing application container..."

# Enable automatic rollback before changing the container.
trap rollback ERR

sudo docker rm -f "$APP_NAME"

start_container "$IMAGE"

if ! check_health; then
    echo "New application failed its health check."
    rollback
fi

trap - ERR

echo "DEPLOYMENT SUCCESSFUL: Application is healthy."
