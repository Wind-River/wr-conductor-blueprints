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
# Helm Add Repo

This blueprint installs helm client and add repository to it.

## Prerequisites

- The target host reachable by Conductor must allow the Helm binary to be downloaded and executed.
- Network access to the Helm download link and to the chart repository URL being added.

## Compatibility

Tested with:
* conductor-helm-plugin version 26.10.0

## Inputs

* `repo_name`: Name of the repo to add. Type: string. No default.
* `helm_installation_source`: Helm download link. Type: string. Default: `https://get.helm.sh/helm-v3.3.1-linux-amd64.tar.gz`.
* `repo_url`: URL of the repo to add (for example `https://kubernetes-charts.storage.googleapis.com/`). Type: string. Default: `https://charts.bitnami.com/bitnami`.
* `helm_max_sleep_time`: Maximum time in seconds to wait for the repo operation. Type: integer. Default: `250`.

## Usage Examples

The blueprint defines two node templates and wires them together through the Helm
`run_on_host` relationship:

* `helm_install` (`cloudify.nodes.helm.Binary`): downloads and installs the Helm client from
  `helm_installation_source`. `use_existing_resource` is `false`, so a fresh binary is installed.
* `repo` (`cloudify.nodes.helm.Repo`): adds the repository named `repo_name` pointing at `repo_url`
  and honors `helm_max_sleep_time`. It relates to `helm_install` with
  `cloudify.helm.relationships.run_on_host` so the repo is added on the host where Helm is installed.

Lifecycle:

* `install`: the Helm binary is installed, then the repository is added to it.
* `uninstall`: the repository is removed and the Helm binary is cleaned up.

This blueprint does not install any chart; it only prepares the Helm client and a repository so a
later release can be deployed from it.

## Notes

This blueprint references no external helper script or supporting file, so nothing extra is
packaged alongside `blueprint.yaml`.

## Source

Authored from source example: `conductor-helm-plugin/examples/add_repo.yaml`.
