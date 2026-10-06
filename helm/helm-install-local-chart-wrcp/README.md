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
# Helm Install Local Chart on WRCP

Helm LCM (install, uninstall, upgrade) on WRCP using client cert auth from environment capabilities and a local chart archive.

## Prerequisites

A WRCP environment providing the `k8s-ip`, `k8s-cacert`, `k8s-admin-client-cert`, and `k8s-admin-client-key` capabilities (zero manual setup - all auth and TLS come from parent deployment capabilities). The `conductor-helm-plugin` must be installed on the manager. Before deploying you must supply your local chart archive (and optional values override) under `resources/` as described below.

## Compatibility

Tested with:
* conductor-helm-plugin version 26.10.0

## Inputs

* `chart_path`: Relative path to the chart .tgz file within the blueprint archive. For example: `resources/wind-river-conductor-<xxx>.tgz`. (no default)
* `values_file`: Relative path to an optional values override YAML file within the blueprint archive. For example: `resources/override-values-<xxx>.yaml`. Default: `''` (empty).
* `release_name`: Name of the helm release. Default: `myrelease`.
* `helm_installation_source`: Helm binary download URL. Defaults to Helm 4. Default: `https://get.helm.sh/helm-v4.1.0-linux-amd64.tar.gz`.
* `helm_max_sleep_time`: Maximum time in seconds to wait for helm operations. Default: `1800`.

## Usage Examples

Steps to use this blueprint:

1. Place your chart `.tgz` file in the blueprint `resources/` directory.
2. The encoder is provided at `scripts/base64-encode.py`.
3. Optionally place a values override YAML in `resources/`.
4. Set `chart_path` and `values_file` inputs accordingly.
5. Deploy as a service on a WRCP environment.

Lifecycle operations:

* **Install**: Deploys the helm binary and installs the chart from the local archive on the target subcloud.
* **Uninstall**: Removes the release and helm binary.
* **Upgrade**: Run the `upgrade_release` workflow with a new chart archive. Example:

```
cfy executions start upgrade_release -d <deployment_id> \
  -p chart=resources/mychart-2.0.0.tgz
```

## Supporting Files

* `scripts/base64-encode.py` (packaged): base64-encodes the CA certificate and client cert/key from the environment capabilities for use in the generated kubeconfig. Referenced by the blueprint via `implementation: scripts/base64-encode.py` and packaged alongside `blueprint.yaml` in the nested folder.
* `resources/<chart>.tgz` (user-supplied, NOT packaged): the local Helm chart archive. This file is provided by the user at deploy time and placed under `resources/` (referenced by the `chart_path` input, e.g. `resources/wind-river-conductor-<xxx>.tgz`). It is documented here rather than packaged because it is deployment-specific.
* `resources/<values>.yaml` (optional, user-supplied, NOT packaged): an optional values override YAML placed under `resources/` (referenced by the `values_file` input, e.g. `resources/override-values-<xxx>.yaml`). Supplied by the user at deploy time if needed.

## Source

Authored from source example: `conductor-helm-plugin/examples/install_local_chart_wrcp.yaml`.
