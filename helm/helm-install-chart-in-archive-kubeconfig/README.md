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
# Helm Install Chart (In-Archive Kubeconfig)

This blueprint installs helm client, add repository to it and install chart(without values file and flags), using kubeconfig file that resides in the blueprint folder.

## Prerequisites

- Network access to the Helm download link and to the chart repository URL being added.
- A kubeconfig file for the target cluster placed inside the blueprint folder (packaged in the
  blueprint archive). Its filename within the archive is supplied through the `kube_config` input.

## Compatibility

Tested with:
* conductor-helm-plugin version 26.10.0

## Inputs

* `repo_name`: Name of the repo to add. Type: string. No default.
* `chart_name`: Chart package name to deploy from repo. No default.
* `helm_installation_source`: Helm download link. Type: string. Default: `https://get.helm.sh/helm-v3.3.1-linux-amd64.tar.gz`.
* `repo_url`: URL of the repo to add (for example `https://kubernetes-charts.storage.googleapis.com/`). Type: string. No default.
* `kube_config`: kubeconfig path. The filename of a kubeconfig file that resides in the blueprint folder. Type: string. No default.

## Usage Examples

The blueprint defines three node templates connected through the Helm `run_on_host` relationship
and a `depends_on` relationship:

* `helm_install` (`cloudify.nodes.helm.Binary`): installs the Helm client from
  `helm_installation_source` (`use_existing_resource: false`).
* `repo` (`cloudify.nodes.helm.Repo`): adds the repository `repo_name` at `repo_url`, running on the
  host where Helm was installed.
* `release` (`cloudify.nodes.helm.Release`): installs the chart `{repo_name}/{chart_name}` as the
  release `myrelease`. Its `client_config.configuration` uses `blueprint_file_name` set to the
  `kube_config` input, so the cluster is reached via a kubeconfig file bundled inside the blueprint
  archive. It depends on `repo` and runs on the Helm host.

Lifecycle:

* `install`: install Helm, add the repository, then install the release using the in-archive
  kubeconfig file named by `kube_config`.
* `uninstall`: uninstall the release, remove the repository, and clean up the Helm binary.

## Notes

This blueprint references no external helper script. It does reference an in-archive kubeconfig
file through `client_config.configuration.blueprint_file_name: { get_input: kube_config }`. That
kubeconfig is **user-supplied at deploy time** — it is not present in the plugin `examples/` source
and is not fabricated here. Package the cluster kubeconfig file into the blueprint folder alongside
`blueprint.yaml` (or upload it with the deployment) and set the `kube_config` input to that file's
name within the archive. Because it is deploy-time and environment-specific, it is documented by
name and expected location here rather than packaged.

## Source

Authored from source example: `conductor-helm-plugin/examples/install_chart_use_in_archive_kubeconfig.yaml`.
