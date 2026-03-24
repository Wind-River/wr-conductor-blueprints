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
# OpenStack Host Aggregate

This blueprint creates an OpenStack Host Aggregate resource with custom configuration.

## Prerequisites

- User must have OpenStack credentials with the required permissions to manage host aggregate resources.
- OpenStack authentication credentials should be added as WRC secrets or provided as inputs.

## Compatibility

Tested with:

- cloudify-openstack-plugin version 26.3.0

## Node Type: cloudify.nodes.openstack.HostAggregate

This node type refers to an OpenStack host aggregate resource.

### Resource Config

- **name**: String. Required. The user-readable name in OpenStack.
- **availability_zone**: String. Optional. The name of the availability zone for the host aggregate.

For more information and possible keyword arguments, see: [create_aggregate](https://docs.openstack.org/api-ref/compute/#create-aggregate).

### Properties

- **metadata**: Dictionary. Optional. Metadata key and value pairs. The maximum size for each metadata key and value pair is 255 bytes. All keys and values should be provided as strings.
- **hosts**: List. Optional. List of host IDs which will be members of the host aggregate.

### Operations

#### cloudify.interfaces.lifecycle.create

Executes `create_aggregate`.

- Creates a new host aggregate.

#### cloudify.interfaces.lifecycle.configure

Executes `set_metadata`.

- Sets metadata for the host aggregate.

#### cloudify.interfaces.lifecycle.delete

Executes `delete_aggregate`.

- Deletes the host aggregate resource.

#### cloudify.interfaces.operations.update

Executes `update_aggregate`.

- **Inputs**:
  - `args`: Dictionary. Required. Key-word arguments accepted by the update Host Aggregate API method.
  - **Example**: `{ "args": { "name": "new-name" } }`

#### cloudify.interfaces.operations.list

Executes `list_aggregates`.

- Lists all host aggregates.

#### cloudify.interfaces.operations.add_hosts

Executes `add_hosts`.

- **Inputs**:
  - `hosts`: List. Required. List of hosts (strings) to add to an aggregate.
  - **Example**: `{ "hosts": ["host-name"] }`

#### cloudify.interfaces.operations.remove_hosts

Executes `remove_hosts`.

- **Inputs**:
  - `hosts`: List. Required. List of hosts (strings) to remove from an aggregate.
  - **Example**: `{ "hosts": ["host-name"] }`

## Inputs

- **auth_url**: The OpenStack authentication URL.
- **username**: OpenStack username.
- **password**: OpenStack password.
- **region_name**: OpenStack region name.
- **project_name**: OpenStack project (tenant) name where it resouces will be created.
- **user_domain_name**: OpenStack user domain name.
- **project_domain_name**: OpenStack project domain name.
- **host_aggregate_config**: Dictionary containing the host aggregate configuration (name, availability_zone, etc.).

## Example

```yaml
example-host-aggregate:
  type: cloudify.nodes.openstack.HostAggregate
  properties:
    client_config:
      auth_url: { get_input: auth_url }
      username: { get_input: username }
      password: { get_input: password }
      region_name: { get_input: region_name }
      project_name: { get_input: project_name }
      user_domain_name: { get_input: user_domain_name }
      project_domain_name: { get_input: project_domain_name }
    metadata:
      ssd: "True"
    resource_config: { get_input: host_aggregate_config }
```
