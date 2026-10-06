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
# Helm Install Chart (Kubeconfig Content and Service Account Token)

This blueprint installs helm client, add repository to it and install chart(without values file and flags),using kubeconfig file content.

## Prerequisites

- Network access to the Helm download link and to the chart repository URL being added.
- A WRC secret named `kube_config` containing the kubeconfig file content for the target cluster.
- A WRC secret named `kube_token` containing the service account API token used to authenticate
  against the Kubernetes API server.

## Compatibility

Tested with:
* conductor-helm-plugin version 26.10.0

## Inputs

* `repo_name`: Name of the repo to add. Type: string. No default.
* `chart_name`: Chart package name to deploy from repo. No default.
* `helm_installation_source`: Helm download link. Type: string. Default: `https://get.helm.sh/helm-v3.3.1-linux-amd64.tar.gz`.
* `repo_url`: URL of the repo to add (for example `https://kubernetes-charts.storage.googleapis.com/`). Type: string. No default.
* `release_name`: Name of the created release. Type: string. No default.

## Usage Examples

The blueprint defines three node templates connected through the Helm `run_on_host` relationship
and a `depends_on` relationship:

* `helm_install` (`cloudify.nodes.helm.Binary`): installs the Helm client from
  `helm_installation_source` (`use_existing_resource: false`).
* `repo` (`cloudify.nodes.helm.Repo`): adds the repository `repo_name` at `repo_url`, running on the
  host where Helm was installed.
* `release` (`cloudify.nodes.helm.Release`): installs the chart
  `{repo_name}/{chart_name}` as release `release_name`. Its `client_config.configuration` supplies
  the cluster kubeconfig via `file_content` (from the `kube_config` secret) and authenticates with
  `api_options.api_key` (from the `kube_token` secret). It depends on `repo` and runs on the Helm host.

Lifecycle:

* `install`: install Helm, add the repository, then install the release using the provided
  kubeconfig content and service account token.
* `uninstall`: uninstall the release, remove the repository, and clean up the Helm binary.

## Notes

This blueprint references no external helper script or supporting file, so nothing extra is
packaged alongside `blueprint.yaml`. The cluster kubeconfig content and the service account token
are supplied at deploy time through the WRC secrets `kube_config` and `kube_token`.

## Source

Authored from source example: `conductor-helm-plugin/examples/install_chart_kubeconfig_file_content_and_service_account_token.yaml`.
