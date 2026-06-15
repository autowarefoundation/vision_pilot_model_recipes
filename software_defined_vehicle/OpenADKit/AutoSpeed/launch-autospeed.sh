#!/usr/bin/env bash
# AutoSpeed demo (TensorRT). Requires the host GPU setup described in README.md.
# Host library locations can be overridden via the environment variables below.
cd "$(dirname "$0")" || exit 1

ONNXRUNTIME_GPU_DIR="${ONNXRUNTIME_GPU_DIR:-/root/onnxruntime-linux-x64-gpu-1.22.0}"
CUDA_LIB_DIR="${CUDA_LIB_DIR:-/root/cuda12-lib}"
TENSORRT_LIB_DIR="${TENSORRT_LIB_DIR:-/root/tensorrt-libs}"
CUDNN_LIB_DIR="${CUDNN_LIB_DIR:-/root/cudnn-lib}"
TRT_CACHE_DIR="${TRT_CACHE_DIR:-/root/trt_cache}"

exec ../run-demo.sh --gpu \
    -e ONNXRUNTIME_ROOT=/onnxruntime \
    -e LD_LIBRARY_PATH=/onnxruntime/lib:/cuda12-lib:/tensorrt10-lib:/cudnn-lib \
    -v "$ONNXRUNTIME_GPU_DIR:/onnxruntime:z" \
    -v "$CUDA_LIB_DIR:/cuda12-lib:z" \
    -v "$TENSORRT_LIB_DIR:/tensorrt10-lib:z" \
    -v "$CUDNN_LIB_DIR:/cudnn-lib:z" \
    -v "$TRT_CACHE_DIR:/autoware/trt_cache:z" \
    -v "$PWD/launch:/autoware/launch:z" \
    -- /autoware/launch/run_objectFinder.sh
