#!/usr/bin/env bash
# Usage: ./launch-sceneseg.sh [--gpu]
cd "$(dirname "$0")" || exit 1
exec ../run-demo.sh "$@" -- \
    python3 /autoware/Models/visualizations/SceneSeg/video_visualization.py \
    -v -p /autoware/model-weights/sceneseg.pth \
    -i /autoware/test/traffic-driving.mp4 \
    -o /autoware/test/output_sceneseg.avi
