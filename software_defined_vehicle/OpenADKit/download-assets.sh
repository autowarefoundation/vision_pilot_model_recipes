#!/usr/bin/env bash
# Download the demo assets (test video and model weights) that are not tracked in git.
set -euo pipefail
cd "$(dirname "$0")"

download() { # $1: Google Drive file id, $2: destination path
    if [ -f "$2" ]; then
        echo "[skip] $2 already exists"
        return
    fi
    echo "[download] $2"
    mkdir -p "$(dirname "$2")"
    # Download to a temp file and move into place only on success, so a failed
    # or interrupted download is never mistaken for a valid asset on re-run
    local tmp="$2.part"
    trap 'rm -f "$tmp"' RETURN
    curl -fL "https://drive.usercontent.google.com/download?id=$1&confirm=xxx" -o "$tmp"
    # Google Drive returns an HTML page (HTTP 200) instead of the file when the
    # download quota is exceeded or confirmation fails
    if head -c 512 "$tmp" | grep -qi "<!DOCTYPE html\|<html"; then
        echo "Error: $2 - Google Drive returned an HTML page instead of the file (try again later)" >&2
        return 1
    fi
    mv "$tmp" "$2"
}

# cspell:disable -- Google Drive file ids
download "1_mFCpsKkBrotVUiv_OIZi1B6Fd3UXUG3" "Test/traffic-driving.mp4"
download "1Zhe8uXPbrPr8cvcwHkl1Hv0877HHbxbB" "AutoSpeed/model-weights/autospeed.onnx"
download "1vCZMdtd8ZbSyHn1LCZrbNKMK7PQvJHxj" "SceneSeg/model-weights/sceneseg.pth"
download "1Njo9EEc2tdU1ffo8AUQ9mjwuQ9CzSRPX" "EgoLanes/model-weights/egolanes.pth"
download "1sYa2ltivJZEWMsTFZXAOaHK--Ovnadu2" "DomainSeg/model-weights/domainseg.pth"
download "1MrKhfEkR0fVJt-SdZEc0QwjwVDumPf7B" "Scene3D/model-weights/scene3d.pth"
# cspell:enable

echo "All demo assets are in place."
