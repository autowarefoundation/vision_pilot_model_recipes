# VisionPilot - Open AD Kit Demos

VisionPilot demos with Open AD Kit containers.

## Container images

Two images are published to GHCR:

- [`ghcr.io/autowarefoundation/visionpilot`](https://github.com/orgs/autowarefoundation/packages/container/package/visionpilot) — slim runtime image used by the demos (AutoSpeed binary, Python inference/visualization code, VNC/noVNC visualizer)
- [`ghcr.io/autowarefoundation/visionpilot-devel`](https://github.com/orgs/autowarefoundation/packages/container/package/visionpilot-devel) — development image with the build toolchain, full `Models`/`middleware_recipes` sources, the ONNX Runtime SDK, and the complete training-capable Python environment

The runtime image is pulled automatically when running demos.

## Prerequisites

- **podman or docker** — the launch scripts auto-detect the engine (podman preferred; set `CONTAINER_ENGINE=docker` or `CONTAINER_ENGINE=podman` to override).
- **Demo assets** — the test video and model weights are not tracked in git. Fetch them all with:

  ```bash
  ./download-assets.sh
  ```

  You can add other test videos to the `Test` folder; pass a different `-i` path in the demo's launch script to use them.

## Running a demo

Each demo folder contains a launch script, e.g.:

```bash
cd SceneSeg && ./launch-sceneseg.sh          # CPU
cd EgoLanes && ./launch-egolanes.sh --gpu    # GPU (requires nvidia-container-toolkit; see the demo README)
```

Then open the visualizer in your browser:

<http://127.0.0.1:6080/vnc.html?resize=scale&autoconnect=true&password=visualizer>

All launch scripts are thin wrappers around [`run-demo.sh`](run-demo.sh), which handles engine detection, GPU flags, and the standard `model-weights`/`Test` mounts. Override the image with `VISIONPILOT_IMAGE=<image:tag>`.

## Building the images locally

Run from the **project root**:

```bash
# Runtime image (x64; use ARCH=aarch64 on ARM64)
docker build -t visionpilot --target runtime \
  -f VisionPilot/software_defined_vehicle/OpenADKit/Docker/Dockerfile . \
  --build-arg ARCH=x64 --build-arg ONNXRUNTIME_VERSION=1.22.0

# Development image
docker build -t visionpilot-devel --target devel \
  -f VisionPilot/software_defined_vehicle/OpenADKit/Docker/Dockerfile . \
  --build-arg ARCH=x64 --build-arg ONNXRUNTIME_VERSION=1.22.0
```

`ARCH` must match the ONNX Runtime release artifact naming: `x64` or `aarch64`.
