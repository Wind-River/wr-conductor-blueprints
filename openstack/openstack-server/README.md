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
# OpenStack Server

This blueprint creates an OpenStack Server (VM instance) with networking, security groups, keypair, and floating IP configuration.

## Prerequisites

- User must have OpenStack credentials with the required permissions to manage server resources.
- OpenStack authentication credentials should be added as WRC secrets or provided as inputs.
- Required resources: image ID, flavor ID, external network ID.

## Compatibility

Tested with:

- cloudify-openstack-plugin version 26.3.0

## Node Type: cloudify.nodes.openstack.Server

This node type refers to an OpenStack server (VM instance).

### Operations

#### cloudify.interfaces.lifecycle.create

Executes `create_server`.

- Creates a new server instance.

#### cloudify.interfaces.lifecycle.start

Executes `start_server`.

- Starts the server instance.

#### cloudify.interfaces.lifecycle.delete

Executes `delete_server`.

- Deletes the server instance.

#### cloudify.interfaces.operations.start_server

Executes `start_server`.

- Explicitly starts a stopped server.

#### cloudify.interfaces.resize.create

Ensures that there are sufficient resources (vCPUs, memory, and disk) to perform the resize, then executes `resize_server`.

- **Inputs**:
  - `args`: Dictionary. Required. Key-word arguments accepted by the update Server API method.
  - **Request Example**:
    ```json
    {
      "args": {
        "flavor_id": "1"
      }
    }
    ```

#### cloudify.interfaces.resize.revert

Executes `revert_resize`.

- Reverts a server resize operation.

#### cloudify.interfaces.freeze.suspend

Suspends a server and changes its status to `SUSPENDED`.

- Useful for temporarily pausing a server without terminating it.

#### cloudify.interfaces.freeze.resume

Resumes a suspended server and changes its status to `ACTIVE`.

- Brings a suspended server back to active state.

#### cloudify.interfaces.operations.list

Executes `list_servers`.

- **Inputs**:
  - `query`: Dictionary. Optional. Key-word arguments accepted by the List Server API method.
  - `all_projects`: Boolean. Optional. Flag to list servers from all projects. By default it is `false`.
  - `details`: Boolean. Optional. Flag to list servers with details. By default it is `true`.

#### cloudify.interfaces.operations.update

Executes `update_server`.

- **Inputs**:
  - `args`: Dictionary. Required. Key-word arguments accepted by the update Server API method.
  - **Request Example**:
    ```json
    {
      "args": {
        "name": "new-name"
      }
    }
    ```

#### cloudify.interfaces.validation.creation

This operation verifies that there is sufficient quota to allocate a new resource of the specified type.

## Inputs

- **auth_url**: The OpenStack authentication URL.
- **username**: OpenStack username.
- **password**: OpenStack password.
- **region_name**: OpenStack region name.
- **project_name**: OpenStack project (tenant) name.
- **user_domain_name**: OpenStack user domain name.
- **project_domain_name**: OpenStack project domain name.
- **image**: The UUID of an image in your OpenStack account.
- **flavor**: The UUID of a flavor in your OpenStack account.
- **name_prefix**: Prefix string for all resources (default: `'server-blueprint-'`).
- **external_network_id**: A network that provisions floating IPs.
- **example_subnet_cidr_1**: Subnet 1 CIDR (default: `'172.16.0.0/16'`).
- **example_subnet_cidr_2**: Subnet 2 CIDR (default: `'10.0.0.0/16'`).

## Outputs

- **latest_backup_name**: The last backup image name made by the VM.

## Example: Complete Server Blueprint

```yaml
tosca_definitions_version: cloudify_dsl_1_4

imports:
  - cloudify/types/types.yaml
  # For use with a manager use: plugin:cloudify-openstack-plugin
  - plugin:cloudify-openstack-plugin

inputs:
  auth_url:
    type: string
    default: { get_secret: openstack_url }

  username:
    type: string
    default: { get_secret: openstack_username }

  password:
    type: string
    default: { get_secret: openstack_password }

  project_name:
    type: string
    default: { get_secret: openstack_tenant_name }

  region_name:
    type: string

  user_domain_name:
    type: string

  project_domain_name:
    type: string

  image:
    type: string
    description: The UUID of an image in your Openstack account.

  flavor:
    type: string
    description: The UUID of small flavor in your Openstack account.

  name_prefix:
    type: string
    default: "server-blueprint-"
    description: Prefix string for all resources

  external_network_id:
    type: string
    description: A network that provisions floating IPs.

  example_subnet_cidr_1:
    type: string
    description: Subnet 1 cidr
    default: "172.16.0.0/16"

  example_subnet_cidr_2:
    type: string
    description: Subnet 2 cidr
    default: "10.0.0.0/16"

dsl_definitions:
  client_config: &client_config
    auth_url: { get_input: auth_url }
    username: { get_input: username }
    password: { get_input: password }
    region_name: { get_input: region_name }
    project_name: { get_input: project_name }
    user_domain_name: { get_input: user_domain_name }
    project_domain_name: { get_input: project_domain_name }

node_templates:
  example-external-network:
    type: cloudify.nodes.openstack.Network
    properties:
      client_config: *client_config
      use_external_resource: true
      resource_config:
        id: { get_input: external_network_id }
        kwargs:
          routing:
            external: true

  example-server:
    type: cloudify.nodes.openstack.Server
    properties:
      client_config: *client_config
      agent_config:
        install_method: none
      resource_config:
        name: { concat: [{ get_input: name_prefix }, "server"] }
        image_id: { get_input: image }
        flavor_id: { get_input: flavor }
    relationships:
      - type: cloudify.relationships.openstack.server_connected_to_port
        target: example-port
      - type: cloudify.relationships.openstack.server_connected_to_keypair
        target: example-keypair
    # This is only run on local mode. For use with a manager, it can be commented out.
    interfaces:
      cloudify.interfaces.lifecycle:
        create:
          inputs:
            resource_config: { get_property: [SELF, resource_config] }

  example-keypair:
    type: cloudify.nodes.openstack.KeyPair
    properties:
      client_config: *client_config
      resource_config:
        name: { concat: [{ get_input: name_prefix }, "keypair"] }

  example-router:
    type: cloudify.nodes.openstack.Router
    properties:
      client_config: *client_config
      resource_config:
        name: { concat: [{ get_input: name_prefix }, "router"] }
    relationships:
      - type: cloudify.relationships.connected_to
        target: example-external-network
    # This is only run on local mode. For use with a manager, it can be commented out.
    interfaces:
      cloudify.interfaces.lifecycle:
        create:
          inputs:
            resource_config: { get_property: [SELF, resource_config] }

  example-security-group:
    type: cloudify.nodes.openstack.SecurityGroup
    properties:
      client_config: *client_config
      security_group_rules:
        - remote_ip_prefix: 0.0.0.0/0
          port_range_max: 80
          port_range_min: 80
          direction: ingress
          protocol: tcp

        - remote_ip_prefix: 0.0.0.0/0
          port_range_max: 80
          port_range_min: 80
          direction: egress
          protocol: tcp

        - remote_ip_prefix: 0.0.0.0/0
          port_range_min: 53333
          port_range_max: 53333
          protocol: tcp
          direction: ingress

        - remote_ip_prefix: 0.0.0.0/0
          port_range_min: 53333
          port_range_max: 53333
          protocol: tcp
          direction: egress

        - remote_ip_prefix: 0.0.0.0/0
          port_range_max: 22
          port_range_min: 22
          direction: ingress
          protocol: tcp

        - remote_ip_prefix: 0.0.0.0/0
          port_range_max: 22
          port_range_min: 22
          direction: egress
          protocol: tcp
      resource_config:
        name: { concat: [{ get_input: name_prefix }, "security-group"] }
        description: "A security group created by Cloudify OpenStack SDK plugin."

  example-port:
    type: cloudify.nodes.openstack.Port
    properties:
      client_config: *client_config
      resource_config:
        name: { concat: [{ get_input: name_prefix }, "port"] }
        fixed_ips:
          - subnet_id: { get_attribute: [example-subnet-1, id] }
    relationships:
      - type: cloudify.relationships.connected_to
        target: example-security-group
      - type: cloudify.relationships.connected_to
        target: example-network-1
      - type: cloudify.relationships.connected_to
        target: example-subnet-1
      - type: cloudify.relationships.openstack.port_connected_to_floating_ip
        target: example-ip
    # This is only run on local mode. For use with a manager, it can be commented out.
    interfaces:
      cloudify.interfaces.lifecycle:
        create:
          inputs:
            resource_config: { get_property: [SELF, resource_config] }
      cloudify.interfaces.operations:
        list:
          inputs:
            query:
              all_tenants: false

  example-network-1:
    type: cloudify.nodes.openstack.Network
    properties:
      client_config: *client_config
      resource_config:
        name: { concat: [{ get_input: name_prefix }, "network-1"] }

  example-subnet-1:
    type: cloudify.nodes.openstack.Subnet
    properties:
      client_config: *client_config
      resource_config:
        name: { concat: [{ get_input: name_prefix }, "subnet-1"] }
        cidr: { get_input: example_subnet_cidr_1 }
        enable_dhcp: true
        ip_version: 4
    relationships:
      - type: cloudify.relationships.contained_in
        target: example-network-1
      - type: cloudify.relationships.openstack.subnet_connected_to_router
        target: example-router
    # This is only run on local mode. For use with a manager, it can be commented out.
    interfaces:
      cloudify.interfaces.lifecycle:
        create:
          inputs:
            resource_config: { get_property: [SELF, resource_config] }

  example-port-2:
    type: cloudify.nodes.openstack.Port
    properties:
      client_config: *client_config
      resource_config:
        name: { concat: [{ get_input: name_prefix }, "port-2"] }
        fixed_ips:
          - subnet_id: { get_attribute: [example-subnet-2, id] }
    relationships:
      - type: cloudify.relationships.connected_to
        target: example-security-group
      - type: cloudify.relationships.connected_to
        target: example-network-2
      - type: cloudify.relationships.connected_to
        target: example-subnet-2
      - type: cloudify.relationships.openstack.port_connected_to_server
        target: example-server
    # This is only run on local mode. For use with a manager, it can be commented out.
    interfaces:
      cloudify.interfaces.lifecycle:
        create:
          inputs:
            resource_config: { get_property: [SELF, resource_config] }
      cloudify.interfaces.operations:
        list:
          inputs:
            query:
              all_tenants: false

  example-network-2:
    type: cloudify.nodes.openstack.Network
    properties:
      client_config: *client_config
      resource_config:
        name: { concat: [{ get_input: name_prefix }, "network-2"] }

  example-subnet-2:
    type: cloudify.nodes.openstack.Subnet
    properties:
      client_config: *client_config
      resource_config:
        name: { concat: [{ get_input: name_prefix }, "subnet-2"] }
        cidr: { get_input: example_subnet_cidr_2 }
        enable_dhcp: true
        ip_version: 4
    relationships:
      - type: cloudify.relationships.contained_in
        target: example-network-2
      - type: cloudify.relationships.openstack.subnet_connected_to_router
        target: example-router
    # This is only run on local mode. For use with a manager, it can be commented out.
    interfaces:
      cloudify.interfaces.lifecycle:
        create:
          inputs:
            resource_config: { get_property: [SELF, resource_config] }

  example-ip:
    type: cloudify.nodes.openstack.FloatingIP
    properties:
      client_config: *client_config
    relationships:
      - type: cloudify.relationships.connected_to
        target: example-external-network
    # This is only run on local mode. For use with a manager, it can be commented out.
    interfaces:
      cloudify.interfaces.lifecycle:
        create:
          inputs:
            resource_config: { get_property: [SELF, resource_config] }

outputs:
  latest_backup_name:
    description: The last backup image name made by vm.
    value: { get_attribute: [example-server, backup_done] }
```

This example demonstrates a complete server setup with:

- Two networks with subnets
- Router connected to external network
- Security group with HTTP, SSH, and custom port rules
- Floating IP for external access
- Keypair for SSH access
- Multiple ports (one with floating IP, one internal)
