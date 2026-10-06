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
# Helm Install Chart (Kubeconfig Content)

This blueprint installs helm client, add repository to it and install chart(without values file and flags),using kubeconfig file content.

## Prerequisites

- Network access to the Helm download link and to the chart repository URL being added.
- An existing EKS (or equivalent Kubernetes) deployment whose `connection_details` capability
  provides the cluster connection configuration; its deployment id is supplied as `eks_deployment_id`.

## Compatibility

Tested with:
* conductor-helm-plugin version 26.10.0
* conductor-kubernetes-plugin version 26.10.0

## Inputs

* `repo_name`: Name of the repo to add. Type: string. Default: `bitnami`.
* `chart_name`: Chart package name to deploy from repo. Default: `nginx`.
* `helm_installation_source`: Helm download link. Type: string. Default: `https://get.helm.sh/helm-v3.3.1-linux-amd64.tar.gz`.
* `repo_url`: URL of the repo to add (for example `https://kubernetes-charts.storage.googleapis.com/`). Type: string. Default: `https://charts.bitnami.com/bitnami`.
* `helm_max_sleep_time`: Maximum time in seconds to wait for the release operation. Type: integer. Default: `250`.
* `eks_deployment_id`: Deployment id whose `connection_details` capability provides the Kubernetes cluster configuration. Type: string. No default.

## Usage Examples

The blueprint defines three node templates connected through the Helm `run_on_host` relationship
and a `depends_on` relationship:

* `helm_install` (`cloudify.nodes.helm.Binary`): installs the Helm client from
  `helm_installation_source` (`use_existing_resource: false`).
* `repo` (`cloudify.nodes.helm.Repo`): adds the repository `repo_name` at `repo_url`, running on the
  host where Helm was installed.
* `release` (`cloudify.nodes.helm.Release`): installs the chart `{repo_name}/{chart_name}` as the
  release `myrelease`. Its `client_config.configuration` is resolved from the `connection_details`
  capability of the deployment identified by `eks_deployment_id`, and it honors `helm_max_sleep_time`.
  It depends on `repo` and runs on the Helm host.

Lifecycle:

* `install`: install Helm, add the repository, then install the release using the cluster
  connection details obtained from the referenced deployment capability.
* `uninstall`: uninstall the release, remove the repository, and clean up the Helm binary.

## Notes

This blueprint references no external helper script or supporting file, so nothing extra is
packaged alongside `blueprint.yaml`. The Kubernetes cluster configuration is obtained at runtime
from another deployment's `connection_details` capability rather than from a packaged file.

## Source

Authored from source example: `conductor-helm-plugin/examples/install_chart_kubeconfig_file_content.yaml`.
