# VxWorks RTOS Deployment on Kubernetes

Conductor blueprint that deploys a VxWorks RTOS instance inside QEMU on a Kubernetes cluster, with browser-based shell access via a web terminal widget.

## Overview

This blueprint stands up a complete VxWorks environment with a single deployment:

- **VxWorks kernel** running in QEMU inside a Kubernetes pod
- **Web terminal** (ttyd) providing interactive VxWorks shell access from a browser
- **Conductor widget** that embeds the terminal directly in the Conductor UI dashboard

Two container images are used (pulled from the registry specified in the `image_registry` blueprint input):

| Image | Purpose |
|-------|---------|
| `vxworks-qemu` | Ubuntu 22.04 + QEMU x86_64 + VxWorks kernel and application binaries. Runs the RTOS with port forwarding (telnet, debug). |
| `vxworks-ttyd` | Sidecar running ttyd connected to the QEMU telnet port, exposing the VxWorks shell over HTTP. |

## Prerequisites

- Conductor with `cloudify-kubernetes-plugin` installed
- A Kubernetes cluster accessible from the Conductor manager
- An in-cluster Docker registry (default: `cluster.local:5000`)
- `buildah` installed for building container images
- VxWorks SDK (download from https://labs.windriver.com) — required for building the `vxworks-qemu` image. Download and unpack it in this folder before building.
- Container images built and pushed to the registry (see Build Images below)
- A Kubernetes API token stored as a Conductor secret (`kubernetes_token`)

## Setup

### 1. Build and Push Container Images

On a machine with access to the cluster registry and the VxWorks SDK:

```bash
# Set registry address (defaults to 127.0.0.1:30501)
export REGISTRY_IP=127.0.0.1
export REGISTRY_PORT=30501
REGISTRY="$REGISTRY_IP:$REGISTRY_PORT"
```

Build the QEMU runtime container:

```bash
buildah bud --layers -t vxworks-qemu -f k8s-deploy/Dockerfile.qemu .
buildah tag vxworks-qemu "$REGISTRY/vxworks-qemu:latest"
```

Build the ttyd web terminal container:

```bash
buildah bud --layers -t vxworks-ttyd -f k8s-deploy/Dockerfile.ttyd .
buildah tag vxworks-ttyd "$REGISTRY/vxworks-ttyd:latest"
```

Push to the registry:

```bash
buildah push --format=docker --tls-verify=false "$REGISTRY/vxworks-qemu:latest"
buildah push --format=docker --tls-verify=false "$REGISTRY/vxworks-ttyd:latest"
```

### 2. Deploy to Kubernetes (standalone, without Conductor)

```bash
kubectl apply --validate=false -f k8s-deploy/deployment.yaml
kubectl rollout status deployment/vxworks-qemu
```

### 3. Create Secrets

Store the Kubernetes API token as a Conductor secret:

```bash
cfy secrets create kubernetes_token -s <K8S_API_TOKEN>
```

### 4. Upload Blueprint

```bash
cfy blueprints upload vxworks-k8s.zip -b vxworks-k8s -n blueprint.yaml
```

### 5. Create Deployment and Install

1. Open the Conductor web console and navigate to **Local Blueprints**.
2. Find the **vxworks-k8s** blueprint and click **Deploy**.
3. Fill in the deployment inputs:
   - **kubernetes_master_endpoint** – Kubernetes API server URL (default: `https://k8_cluseter_ip:6443`)
   - **kubernetes_token_secret** – secret name containing the K8s token (default: `kubernetes_token`)
   - **image_registry** – Docker registry address (default: `cluster.local:5000`)
4. Click **Install** to create the deployment and run the install workflow.

### 6. Install Terminal Widget

Upload the terminal widget to the Conductor UI:

1. In the Conductor web console, go to **Admin → Widgets**.
2. Click **Upload Widget** and select `terminal-widget.zip`.
3. Add the widget to your dashboard page.

### 7. View Results

1. In the Conductor web console, go to **Deployments** and select the **vxworks-k8s** deployment.
2. Click the **Outputs** tab to see:
   - `web_terminal_endpoint` – browser-based VxWorks shell (ttyd)
   - `telnet_endpoint` – raw telnet access to the VxWorks shell
3. The terminal widget on the dashboard automatically displays the VxWorks shell for the selected deployment.

## Exposed Services (NodePort)

| Port | Service |
|------|---------|
| 30023 | VxWorks telnet shell |
| 30681 | Web terminal (ttyd) |

## Files

| File | Description |
|------|-------------|
| `blueprint-vxworks/blueprint.yaml` | Conductor blueprint definition |
| `blueprint-vxworks/resources/` | Kubernetes service definition |
| `vxworks-k8s.zip` | Blueprint archive for upload |
| `terminal-widget.zip` | Conductor UI terminal widget |
| `k8s-deploy/Dockerfile.qemu` | QEMU container image definition |
| `k8s-deploy/Dockerfile.ttyd` | ttyd sidecar image definition |
| `k8s-deploy/entrypoint.sh` | QEMU container entrypoint script |
| `k8s-deploy/deployment.yaml` | Standalone Kubernetes deployment manifest (for reference) |

## Notes

- This is **not real-time VxWorks** — QEMU emulation inside a container adds latency. It is suitable for demos, developer onboarding, and CI pipelines, not production real-time workloads.
- The ttyd sidecar runs in `--writable` mode with no authentication. For shared environments, place it behind an auth proxy or restrict access with a NetworkPolicy.
- Keep `QEMU_MEM` (default 4G) below the pod memory limit (default 5Gi) to avoid OOM kills.
