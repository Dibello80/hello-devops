
#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="${APP_NAME:-hello-devops}"
IMAGE="${IMAGE:-ghcr.io/dibello80/hello-devops:latest}"

HOST_PORT="${HOST_PORT:-8080}"
CONTAINER_PORT="${CONTAINER_PORT:-8080}"

REGION="${REGION:-us-west-1}"
LOG_GROUP="${LOG_GROUP:-/hello-devops/application}"
LOG_DRIVER="${LOG_DRIVER:-awslogs}"

PREVIOUS_IMAGE=""

start_container() {
    local image="$1"

    local docker_args=(
        -d
        --restart unless-stopped
        --name "$APP_NAME"
        -p "127.0.0.1:${HOST_PORT}:${CONTAINER_PORT}"
    )

    if [[ "$LOG_DRIVER" == "awslogs" ]]; then
        docker_args+=(
            --log-driver=awslogs
            --log-opt "awslogs-region=$REGION"
            --log-opt "awslogs-group=$LOG_GROUP"
            --log-opt "awslogs-stream=$APP_NAME"
        )
    else
        docker_args+=(--log-driver="$LOG_DRIVER")
    fi

    sudo docker run "${docker_args[@]}" "$image"
}

check_health() {
    for attempt in {1..12}; do
        if curl --fail --silent --max-time 5 \
            "http://127.0.0.1:${HOST_PORT}/" \
            >/dev/null; then
            echo "Health check passed."
            return 0
        fi

        echo "Health check attempt $attempt failed."
        sleep 5
    done

    return 1
}

rollback() {
    local exit_code=${1:-$?}

    trap - ERR

    echo "Deployment failed (exit code: $exit_code)."
    echo "Attempting rollback..."

    sudo docker rm -f "$APP_NAME" || true

    if [[ -z "$PREVIOUS_IMAGE" ]]; then
        echo "No previous image available."
        exit 1
    fi

    echo "Restoring previous image: $PREVIOUS_IMAGE"

    if ! start_container "$PREVIOUS_IMAGE"; then
        echo "ERROR: Could not restore previous container."
        exit 1
    fi

    if check_health; then
        echo "ROLLBACK SUCCESSFUL: Previous version restored."
    else
        echo "ERROR: Restored container failed health check."
    fi

    exit 1
}

echo "Inspecting previous deployment..."

if sudo docker container inspect "$APP_NAME" >/dev/null 2>&1; then
    PREVIOUS_IMAGE=$(sudo docker inspect \
        --format '{{.Image}}' "$APP_NAME")
    echo "Previous image: $PREVIOUS_IMAGE"
fi

echo "Pulling image: $IMAGE"
sudo docker pull "$IMAGE"

trap rollback ERR

echo "Replacing container: $APP_NAME"

sudo docker rm -f "$APP_NAME"

start_container "$IMAGE"

if ! check_health; then
    rollback 1
fi

trap - ERR

echo "DEPLOYMENT SUCCESSFUL."
