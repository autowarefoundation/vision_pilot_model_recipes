# VisionPilot Open AD Kit images.
#
# Stages:
#   base    - shared runtime foundation: Python inference deps + GUI/VNC visualizer stack
#   devel   - published as ghcr.io/<org>/visionpilot-devel: toolchain, full sources,
#             ONNX Runtime SDK; builds the AutoSpeed standalone pipeline
#   runtime - published as ghcr.io/<org>/visionpilot: slim demo image with only the
#             compiled AutoSpeed binary and the Python inference/visualization code
#
# Build from the project root, e.g.:
#   docker build --target runtime -t visionpilot \
#     -f VisionPilot/software_defined_vehicle/OpenADKit/Docker/Dockerfile . \
#     --build-arg ARCH=x64 --build-arg ONNXRUNTIME_VERSION=1.22.0

# x64 or aarch64 (matches the onnxruntime release artifact names)
ARG ARCH=x64
ARG ONNXRUNTIME_VERSION=1.22.0

########################################################################
# base
########################################################################
FROM ubuntu:24.04 AS base
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /autoware

# Runtime libraries for the demos (Python, OpenCV/GStreamer/yaml-cpp shared libs
# for the AutoSpeed binary) and the X11/VNC/noVNC visualizer stack
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-numpy \
    libgl1 \
    libglib2.0-0 \
    libopencv-core406t64 \
    libopencv-imgproc406t64 \
    libopencv-imgcodecs406t64 \
    libopencv-highgui406t64 \
    libopencv-videoio406t64 \
    libopencv-video406t64 \
    libopencv-calib3d406t64 \
    libopencv-features2d406t64 \
    libopencv-flann406t64 \
    libopencv-dnn406t64 \
    libopencv-ml406t64 \
    libopencv-objdetect406t64 \
    libopencv-photo406t64 \
    libyaml-cpp0.8 \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    x11-xserver-utils \
    dbus-x11 \
    openbox \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    openssl \
    ca-certificates \
    curl \
    procps \
    fonts-liberation \
    fonts-dejavu-core \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies needed to run the demos (inference only, no training stack)
COPY Models/requirements-inference.txt /tmp/requirements-inference.txt
RUN pip install --no-cache-dir --break-system-packages -r /tmp/requirements-inference.txt \
    && rm /tmp/requirements-inference.txt

# Self-signed certificate for the noVNC web endpoint
RUN openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/ssl/private/novnc.key \
    -out /etc/ssl/certs/novnc.crt \
    -days 365 \
    -subj "/O=GUI-Visualizer/CN=localhost"

COPY VisionPilot/software_defined_vehicle/OpenADKit/Docker/xstartup /root/.vnc/xstartup
COPY VisionPilot/software_defined_vehicle/OpenADKit/Docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /root/.vnc/xstartup

ENV PYTHONPATH=/autoware:/autoware/Models \
    ONNXRUNTIME_ROOT=/autoware/onnxruntime \
    DISPLAY=:99 \
    VNC_GEOMETRY=1280x720 \
    VNC_DEPTH=24 \
    VNC_PASSWORD=visualizer \
    GUI_APP=""

# 5999: VNC (display :99), 6080: noVNC web interface
EXPOSE 5999 6080

ENTRYPOINT ["/entrypoint.sh"]

########################################################################
# devel
########################################################################
FROM base AS devel
ARG ARCH
ARG ONNXRUNTIME_VERSION
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    git \
    wget \
    nano \
    libopencv-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libyaml-cpp-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ONNX Runtime SDK at a fixed path; the AutoSpeed binary RPATH points at its lib dir
RUN wget -q https://github.com/microsoft/onnxruntime/releases/download/v${ONNXRUNTIME_VERSION}/onnxruntime-linux-${ARCH}-${ONNXRUNTIME_VERSION}.tgz \
    && tar -xzf onnxruntime-linux-${ARCH}-${ONNXRUNTIME_VERSION}.tgz \
    && mv onnxruntime-linux-${ARCH}-${ONNXRUNTIME_VERSION} /autoware/onnxruntime \
    && rm onnxruntime-linux-${ARCH}-${ONNXRUNTIME_VERSION}.tgz

# Full sources and the complete (training-capable) Python dependency set.
# typing_extensions is pre-installed with --ignore-installed because pip cannot
# uninstall the Debian-owned copy (pulled in via websockify) when a newer
# version is required; the pip install in /usr/local shadows it.
COPY Models /autoware/Models
RUN pip install --no-cache-dir --break-system-packages --ignore-installed typing_extensions \
    && pip install --no-cache-dir --break-system-packages -r /autoware/Models/requirements.txt
COPY VisionPilot /autoware/VisionPilot

# Build the AutoSpeed standalone pipeline
RUN cmake -S /autoware/VisionPilot/middleware_recipes/Standalone/AutoSpeed -B /tmp/autospeed-build \
        -DCMAKE_BUILD_TYPE=Release \
    && cmake --build /tmp/autospeed-build -j$(nproc) \
    && install -m 755 /tmp/autospeed-build/autospeed_infer_stream /autoware/autospeed_infer_stream \
    && install -m 644 /autoware/VisionPilot/middleware_recipes/Standalone/AutoSpeed/homography.yaml /autoware/homography.yaml \
    && rm -rf /tmp/autospeed-build

########################################################################
# runtime
########################################################################
FROM base AS runtime

# AutoSpeed binary, its calibration file, and the ONNX Runtime shared libraries
# (kept at the RPATH location baked into the binary)
COPY --from=devel /autoware/onnxruntime/lib /autoware/onnxruntime/lib
COPY --from=devel /autoware/autospeed_infer_stream /autoware/autospeed_infer_stream
COPY --from=devel /autoware/homography.yaml /autoware/homography.yaml

# Python inference and visualization code only (no training/data tooling).
# AutoDrive is dropped: it is not an Open AD Kit demo and is the only visualizer
# that imports Models/data_utils, which the runtime image deliberately omits.
COPY Models/inference /autoware/Models/inference
COPY Models/model_components /autoware/Models/model_components
COPY Models/visualizations /autoware/Models/visualizations
RUN rm -rf /autoware/Models/visualizations/AutoDrive
