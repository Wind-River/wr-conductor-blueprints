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
# Helm Install Chart on WRCP

Example blueprint for Helm LCM (install, uninstall, upgrade) on WRCP.

## Prerequisites

A WRCP site/subcloud environment deployment must exist and expose the `k8s-ip`, `k8s-cacert`, `k8s-admin-client-cert`, and `k8s-admin-client-key` environment capabilities. Its deployment ID is passed via the `site_deployment_id` input. The `conductor-helm-plugin` must be installed on the manager.

## Compatibility

Tested with:
* conductor-helm-plugin version 26.10.0

## Inputs

* `site_deployment_id`: The deployment ID of the WRCP site/subcloud environment that provides k8s-ip, k8s-cacert, and k8s-service-account-token capabilities. (no default)
* `repo_name`: Name of the helm repo to add. Default: `bitnami`.
* `repo_url`: URL of the helm repo. Default: `https://charts.bitnami.com/bitnami`.
* `chart_name`: Chart package name to deploy from repo. Default: `grafana`.
* `release_name`: Name of the helm release. Default: `myrelease`.
* `helm_installation_source`: Helm binary download URL. Defaults to Helm 4. Override with a Helm 3 URL if needed. Default: `https://get.helm.sh/helm-v4.1.0-linux-amd64.tar.gz`.
* `helm_max_sleep_time`: Maximum time in seconds to wait for helm operations. Default: `900`.

## Usage Examples

Lifecycle operations:

* **Install**: Deploy the blueprint to install the helm binary, add the repo, and install the chart release.
* **Uninstall**: Run the uninstall workflow to remove the release, repo, and helm binary. Uninstall is handled automatically by the delete lifecycle.
* **Upgrade**: Run the `upgrade_release` workflow to upgrade the release to a new chart version. Example:

```
cfy executions start upgrade_release -d <deployment_id> \
  -p chart=bitnami/grafana \
  -p 'flags=[{"name": "version", "value": "8.8.4"}]'
```

## Supporting Files

* `scripts/base64-encode.py` (packaged): base64-encodes the CA certificate and client cert/key from the environment capabilities for use in the generated kubeconfig. Referenced by the blueprint via `implementation: scripts/base64-encode.py` and packaged alongside `blueprint.yaml` in the nested folder.

## Source

Authored from source example: `conductor-helm-plugin/examples/install_chart_wrcp.yaml`.
