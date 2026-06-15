#!/usr/bin/env bash
# Usage: ./launch-scene3d.sh [--gpu]
cd "$(dirname "$0")" || exit 1
exec ../run-demo.sh "$@" -- \
    python3 /autoware/Models/visualizations/Scene3D/video_visualization.py \
    -v -p /autoware/model-weights/scene3d.pth \
    -i /autoware/test/traffic-driving.mp4 \
    -o /autoware/test/output_scene3d.avi
