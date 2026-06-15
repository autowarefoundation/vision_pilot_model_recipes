# DomainSeg - Open AD Kit Demo

Containerized DomainSeg Demo, roadwork scene segmentation.

## Prerequisites

- Download the [DomainSeg PyTorch model weights](https://github.com/autowarefoundation/autoware.privately-owned-vehicles/tree/main/Models#domainseg---roadwork-scene-segmentation) and place it in the `model-weights` directory with the name `domainseg.pth` (or run `../download-assets.sh` to fetch all demo assets at once).

    ```bash
    mkdir -p model-weights
    curl -fL "https://drive.usercontent.google.com/download?id=1sYa2ltivJZEWMsTFZXAOaHK--Ovnadu2&confirm=xxx" -o model-weights/domainseg.pth
    ```

## Usage

```bash
./launch-domainseg.sh
```

## Output

After the container is running, you can access the visualization by opening the following URL in your browser:

<http://127.0.0.1:6080/vnc.html?resize=scale&autoconnect=true&password=visualizer>

The output shows roadwork scene segmentation of the input video in real-time.
