#!/usr/bin/env bash
# Shared launcher for the Open AD Kit demos.
#
# Usage (from a demo directory):
#   ../run-demo.sh [--gpu] [-v HOST:CTR[:opts]] [-e KEY=VAL] -- COMMAND [ARGS...]
#
# - Uses podman if available, docker otherwise (override with CONTAINER_ENGINE)
# - Runs ghcr.io/autowarefoundation/visionpilot:latest (override with VISIONPILOT_IMAGE)
# - Always mounts ./model-weights and ../Test, and publishes the noVNC port (6080)
# - --gpu adds the engine-specific GPU flags (podman CDI / docker --gpus)
set -euo pipefail

IMAGE="${VISIONPILOT_IMAGE:-ghcr.io/autowarefoundation/visionpilot:latest}"
ENGINE="${CONTAINER_ENGINE:-}"

if [ -z "$ENGINE" ]; then
    if command -v podman >/dev/null 2>&1; then
        ENGINE=podman
    elif command -v docker >/dev/null 2>&1; then
        ENGINE=docker
    else
        echo "Error: neither podman nor docker found in PATH" >&2
        exit 1
    fi
fi

GPU=false
EXTRA_ARGS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --gpu) GPU=true; shift ;;
        -v|-e) EXTRA_ARGS+=("$1" "$2"); shift 2 ;;
        --) shift; break ;;
        *) echo "Error: unknown option '$1' (use -- before the container command)" >&2; exit 1 ;;
    esac
done

if [ $# -eq 0 ]; then
    echo "Error: no container command given (append: -- COMMAND [ARGS...])" >&2
    exit 1
fi

RUN_ARGS=(-i --rm -p 6080:6080)
if [ -t 0 ]; then
    RUN_ARGS+=(-t)
fi
if [ "$GPU" = true ]; then
    if [ "$ENGINE" = podman ]; then
        RUN_ARGS+=(--device nvidia.com/gpu=all)
    else
        RUN_ARGS+=(--gpus all)
    fi
fi

# Every demo directory provides model-weights/ and shares the ../Test assets
RUN_ARGS+=(-v "$PWD/model-weights:/autoware/model-weights:z")
RUN_ARGS+=(-v "$PWD/../Test:/autoware/test:z")

exec "$ENGINE" run "${RUN_ARGS[@]}" ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"} "$IMAGE" "$@"
