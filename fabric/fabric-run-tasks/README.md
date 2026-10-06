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
# Fabric Run Tasks

This blueprint runs scripts, ad-hoc shell commands, Python task-file tasks, and installed Python module tasks on a remote host over SSH using the Fabric plugin.

## Prerequisites

SSH access to the target host. Provide the host address and login user (`host_string`, `user`) and either a password stored as a WRC secret (`password_secret`) or an SSH key stored as a WRC secret (`ssh_key_secret`).

## Compatibility

Tested with:
* conductor-fabric-plugin version 26.10.0

## Inputs

* `host_string`: Host string (address of the target host to connect to).
* `user`: User to connect as over SSH.
* `password`: Secret name containing the password used for SSH authentication.
* `ssh_key_secret`: Secret containing an SSH key used for SSH authentication.

## Usage Examples

The blueprint defines several `cloudify.nodes.ApplicationServer` node templates, each wiring a Fabric task implementation into a `cloudify.interfaces.lifecycle` operation:

* `nohup_server` (create) - runs a script on the remote host via `fabric.fabric_plugin.tasks.run_script` using `scripts/server.sh`.
* `remote_setup` (create, start) - runs ad-hoc shell commands via `fabric.fabric_plugin.tasks.run_commands`.
* `fabric_task_runner` (create) - runs the `provision` task from `scripts/fabric_tasks.py` via `fabric.fabric_plugin.tasks.run_task`.
* `module_task_runner` (create) - runs a task from an installed Python module via `fabric.fabric_plugin.tasks.run_module_task`.
* `privileged_script_runner` (create) - runs a script with `use_sudo` and custom process environment via `run_script`.
* `guarded_commands` (create) - runs commands with `use_sudo` and non-recoverable error exit codes via `run_commands`.
* `key_secret_auth_host` (create) - runs commands authenticating with an SSH key secret via `run_commands`.

## Notes

* Source example file: `conductor-fabric-plugin/examples/blueprint.yaml`.
* Supporting files packaged alongside `blueprint.yaml` at their referenced relative paths:
  * `scripts/server.sh` (referenced by the `run_script` `script_path`).
  * `scripts/fabric_tasks.py` (referenced by the `run_task` `tasks_file`).
