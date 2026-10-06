<!--
Copyright (c) 2021 Cloudify Platform Ltd. All rights reserved
Copyright (c) 2026 Wind River Systems, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
# Helm OCI Grafana on WRCP

OCI Grafana Blueprint for WRCP - Public Registry (no auth). Installs Grafana from the official OCI registry at ghcr.io onto a WRCP subcloud. No helm repo add needed - chart is referenced directly via oci:// URL.

## Prerequisites

A WRCP site/subcloud environment deployment that provides the `k8s-ip`, `k8s-cacert`, `k8s-admin-client-cert`, and `k8s-admin-client-key` capabilities; its deployment ID is passed via `site_deployment_id`. The Helm binary must be v3.8.0+ or v4.x for OCI support (the default installation source uses Helm 4). The `conductor-helm-plugin` must be installed on the manager.

## Compatibility

Tested with:
* conductor-helm-plugin version 26.10.0

## Inputs

* `site_deployment_id`: The deployment ID of the WRCP site/subcloud environment that provides k8s-ip, k8s-cacert, and k8s-admin-client-cert/key capabilities. (no default)
* `helm_installation_source`: URL to Helm binary tarball. Requires v3.8.0+ or v4.x for OCI support. Default: `https://get.helm.sh/helm-v4.1.0-linux-amd64.tar.gz`.
* `oci_chart_url`: OCI chart reference URL. Default: `oci://ghcr.io/grafana/helm-charts/grafana`.
* `chart_version`: Chart version to install (required for OCI charts). Default: `8.8.2`.
* `release_name`: Helm release name. Default: `grafana-oci-release`.
* `namespace`: Kubernetes namespace to install into. Default: `grafana`.
* `helm_max_sleep_time`: Maximum time in seconds to wait for helm operations. Default: `900`.

## Usage Examples

Lifecycle operations:

* **Install**: Deploy the blueprint to install the helm binary and install the chart release from the OCI registry.
* **Uninstall**: Run the uninstall workflow to remove the release and helm binary.
* **Upgrade**: Run the `upgrade_release` workflow to upgrade the release to a new chart version. Example:

```
cfy executions start upgrade_release -d <deployment_id> \
  -p chart=oci://ghcr.io/grafana/helm-charts/grafana \
  -p 'flags=[{"name": "version", "value": "8.9.0"}]'
```

## Supporting Files

* `scripts/base64-encode.py` (packaged): base64-encodes the CA certificate and client cert/key from the environment capabilities for use in the generated kubeconfig. Referenced by the blueprint via `implementation: scripts/base64-encode.py` and packaged alongside `blueprint.yaml` in the nested folder.

## Source

Authored from source example: `conductor-helm-plugin/examples/oci-grafana-wrcp-blueprint.yaml`.
