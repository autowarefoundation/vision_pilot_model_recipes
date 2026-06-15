#!/usr/bin/env bash
# Usage: ./launch-egolanes.sh [--gpu]
# With --gpu, PyTorch auto-detects CUDA inside the container (see README "GPU Usage")
cd "$(dirname "$0")" || exit 1
exec ../run-demo.sh "$@" -- \
    python3 /autoware/Models/visualizations/EgoLanes/video_visualization.py \
    -v -p /autoware/model-weights/egolanes.pth \
    -i /autoware/test/traffic-driving.mp4 \
    -o /autoware/test/output_egolanes.avi
