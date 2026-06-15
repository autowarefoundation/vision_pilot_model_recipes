# AutoSpeed - Open AD Kit Demo

Containerized AutoSpeed Demo, closest in-path object detection and tracking.

## Prerequisites

- Download the [AutoSpeed ONNX model weights](https://drive.google.com/file/d/1Zhe8uXPbrPr8cvcwHkl1Hv0877HHbxbB/view?usp=drive_link) and place it in the `model-weights` directory with the name `autospeed.onnx` (or run `../download-assets.sh` to fetch all demo assets at once).

    ```bash
    mkdir -p model-weights
    curl -fL "https://drive.usercontent.google.com/download?id=1Zhe8uXPbrPr8cvcwHkl1Hv0877HHbxbB&confirm=xxx" -o model-weights/autospeed.onnx
    ```

## Usage (GPU / TensorRT)

This demo runs the AutoSpeed pipeline with the TensorRT execution provider and requires additional setup on the host before launching the container.

### Host Prerequisites

1. **NVIDIA drivers + CUDA** installed on the host

2. **podman** and **nvidia-container-toolkit** with CDI configured:
   ```bash
   dnf install -y podman nvidia-container-toolkit
   nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
   ```

3. **ONNX Runtime 1.22.0 GPU** — the container ships CPU-only, GPU version must be provided externally:
   ```bash
   wget https://github.com/microsoft/onnxruntime/releases/download/v1.22.0/onnxruntime-linux-x64-gpu-1.22.0.tgz
   tar -xzf onnxruntime-linux-x64-gpu-1.22.0.tgz -C /root/
   ```

4. **CUDA 12 libraries** — ONNX Runtime 1.22.0 requires CUDA 12 even if host has CUDA 13:
   ```bash
   dnf install -y cuda-libraries-12-9
   mkdir -p /root/cuda12-lib
   find /usr/local/cuda-12.9/targets/x86_64-linux/lib -name "*.so.*" \
       -exec cp {} /root/cuda12-lib/ \;
   find /usr/local/cuda-12.9/targets/x86_64-linux/lib -name "*.so.*" \
       -type l -exec cp -P {} /root/cuda12-lib/ \;
   ```

5. **TensorRT 10** — the binary requires TRT 10; install via pip since package repos only provide TRT 11:
   ```bash
   pip install tensorrt==10.6.0 --extra-index-url https://pypi.nvidia.com
   mkdir -p /root/tensorrt-libs
   cp /usr/local/lib/python3.9/site-packages/tensorrt_libs/*.so* /root/tensorrt-libs/
   ```

6. **cuDNN 9**:
   ```bash
   dnf install -y libcudnn9-cuda-13
   mkdir -p /root/cudnn-lib
   cp /usr/lib64/libcudnn*.so.9* /root/cudnn-lib/
   ```

7. **TRT engine cache directory**:
   ```bash
   mkdir -p /root/trt_cache
   ```

### Running

```bash
./launch-autospeed.sh
```

On first run, the TRT engine is built and cached (~30 seconds). Subsequent runs start immediately.

If your host libraries live somewhere other than the default `/root/...` locations from the steps above, override them via environment variables:

```bash
ONNXRUNTIME_GPU_DIR=~/onnxruntime-linux-x64-gpu-1.22.0 \
CUDA_LIB_DIR=~/cuda12-lib TENSORRT_LIB_DIR=~/tensorrt-libs \
CUDNN_LIB_DIR=~/cudnn-lib TRT_CACHE_DIR=~/trt_cache \
./launch-autospeed.sh
```


## Output

After the container is running, you can access the visualization by opening the following URL in your browser:

<http://127.0.0.1:6080/vnc.html?resize=scale&autoconnect=true&password=visualizer>

> **Note:** Use `127.0.0.1` instead of `localhost`. On systems where `localhost` resolves to IPv6 (`::1`), the connection will fail as Podman's `pasta` network backend only handles IPv4.

The output shows closest in-path object detection and tracking of the input video in real-time.

**For GPU running on a remote machine:** First set up SSH port forwarding:
```bash
ssh -L 6080:localhost:6080 root@<machine-hostname>
```
Then open in your browser: `http://127.0.0.1:6080/vnc.html?resize=scale&autoconnect=true&password=visualizer`
