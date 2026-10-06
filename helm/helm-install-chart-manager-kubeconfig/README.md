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
# Helm Install Chart (Manager Kubeconfig)

This blueprint installs helm client, add repository to it and install chart(without values file and flags),using kubeconfig file content.

## Prerequisites

- Network access to the Helm download link and to the chart repository URL being added.
- A kubeconfig file for the target cluster must already exist on the manager VM at the path
  supplied through the `kube_config` input.

## Compatibility

Tested with:
* conductor-helm-plugin version 26.10.0

## Inputs

* `repo_name`: Name of the repo to add. Type: string. No default.
* `chart_name`: Chart package name to deploy from repo. No default.
* `helm_installation_source`: Helm download link. Type: string. Default: `https://get.helm.sh/helm-v3.3.1-linux-amd64.tar.gz`.
* `repo_url`: URL of the repo to add (for example `https://kubernetes-charts.storage.googleapis.com/`). Type: string. Default: `https://charts.bitnami.com/bitnami`.
* `kube_config`: kubeconfig path (on the manager VM). Type: string. No default.
* `helm_max_sleep_time`: Maximum time in seconds to wait for the release operation. Type: integer. Default: `250`.

## Usage Examples

The blueprint defines three node templates connected through the Helm `run_on_host` relationship
and a `depends_on` relationship:

* `helm_install` (`cloudify.nodes.helm.Binary`): installs the Helm client from
  `helm_installation_source` (`use_existing_resource: false`).
* `repo` (`cloudify.nodes.helm.Repo`): adds the repository `repo_name` at `repo_url`, running on the
  host where Helm was installed.
* `release` (`cloudify.nodes.helm.Release`): installs the chart `{repo_name}/{chart_name}` as the
  release `myrelease`. Its `client_config.configuration` uses `manager_file_path` set to the
  `kube_config` input, so the cluster is reached via a kubeconfig file already present on the
  manager VM. It honors `helm_max_sleep_time`, depends on `repo`, and runs on the Helm host.

Lifecycle:

* `install`: install Helm, add the repository, then install the release using the manager-side
  kubeconfig file located at `kube_config`.
* `uninstall`: uninstall the release, remove the repository, and clean up the Helm binary.

## Notes

This blueprint references no external helper script that is packaged in the archive. The kubeconfig
is not packaged with the blueprint: it is expected to already exist on the manager VM at the path
given by the `kube_config` input (`manager_file_path`), and is therefore documented here rather
than included.

## Source

Authored from source example: `conductor-helm-plugin/examples/install_chart_use_manager_kubeconfig.yaml`.
