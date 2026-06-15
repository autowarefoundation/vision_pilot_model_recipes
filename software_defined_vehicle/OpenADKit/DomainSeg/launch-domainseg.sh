#!/usr/bin/env bash
# Usage: ./launch-domainseg.sh [--gpu]
cd "$(dirname "$0")" || exit 1
exec ../run-demo.sh "$@" -- \
    python3 /autoware/Models/visualizations/DomainSeg/video_visualization.py \
    -v -p /autoware/model-weights/domainseg.pth \
    -i /autoware/test/traffic-driving.mp4 \
    -o /autoware/test/output_domainseg.avi
