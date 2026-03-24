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
# OpenStack Server (VM)

This is a comprehensive "Hello World" blueprint that demonstrates deploying a complete VM infrastructure on OpenStack with networking, storage, security, and scaling capabilities.

## Deployed Infrastructure

This example deploys a fully functional server environment including:

- **Server (VM)**: OpenStack compute instance with custom user data
- **Network**: Private network with subnet and DNS configuration
- **Router**: Router connecting the private network to external network
- **Floating IP**: Public IP address for external access
- **Security Group**: Firewall rules for HTTP (80), SSH (22), and custom port (53333)
- **Port**: Network interface with fixed IP assignment
- **Volume**: Block storage volume attached to the server
- **Scaling**: Auto-scaling policy supporting 1-10 instances

## Prerequisites

- User must have OpenStack credentials with permissions to create compute, network, and storage resources.
- OpenStack authentication credentials should be added as WRC secrets or provided as inputs.
- External network must exist for floating IP allocation.
- Valid image ID and flavor ID for the target OpenStack environment.

## Compatibility

Tested with:

- conductor-openstack-plugin version 26.3.0

## Required Inputs

### Authentication

- **auth_url**: OpenStack authentication URL
- **username**: OpenStack username (secret name, default: `openstack_username_secret`)
- **password**: OpenStack password (secret name, default: `openstack_password_secret`)
- **project_name**: OpenStack project/tenant name where it resouces will be created
- **region_name**: OpenStack region name
- **user_domain_name**: User domain name
- **project_domain_name**: Project domain name
- **insecure**: Boolean to disable SSL verification (default: `false`)
- **ca_cert**: CA certificate (secret name, default: `openstack_cacert_secret`)

### Infrastructure

- **external_network_id**: ID of the external network for floating IP allocation
- **image**: UUID of the VM image to use
- **flavor**: UUID of the flavor (instance size) to use

### Optional Customization

- **network_name**: Name for the private network (default: `conductor-hello-world-network`)
- **subnet_name**: Name for the subnet (default: `conductor-hello-world-subnet`)
- **name_prefix**: Prefix for resource names (default: `hellow_world`)
- **volume1_name**: Name for the attached volume
- **volume1_size**: Volume size in GB (default: `1`)

## Outputs

- **application_endpoint_ips**: The public floating IP addresses of deployed servers
- **vm_backups_list**: List of VM backups/snapshots created
- **vm_latest_backup**: The most recent VM backup
- **vm_latest_backup_image_download_url**: URL to download the latest backup image
- **volume_backups_list**: List of volume backups created
- **volume_latest_backup**: The most recent volume backup

## Key Features

### Networking

- Private network with customizable CIDR (10.10.4.0/24)
- Subnet with DNS servers (8.8.4.4, 8.8.8.8)
- Router with external gateway for internet access
- Floating IP for public accessibility

### Security

Security group configured with rules for:

- HTTP traffic (port 80) - ingress and egress
- SSH access (port 22) - ingress and egress
- Custom application port (53333) - ingress and egress

### Storage

- Boot disk from image
- Additional block storage volume (1GB by default)
- Support for VM and volume backups/snapshots

### Scaling

Includes a scaling policy that allows:

- Minimum instances: 1
- Maximum instances: 10 (configurable to any number)
- Default instances: 1

## Node Types Used

- `cloudify.nodes.openstack.Server`: VM instances
- `cloudify.nodes.openstack.Network`: Private network
- `cloudify.nodes.openstack.Subnet`: IP subnet configuration
- `cloudify.nodes.openstack.Router`: Network router
- `cloudify.nodes.openstack.Port`: Network interface
- `cloudify.nodes.openstack.FloatingIP`: Public IP address
- `cloudify.nodes.openstack.SecurityGroup`: Firewall rules
- `cloudify.nodes.openstack.Volume`: Block storage

## Usage

1. Configure your OpenStack credentials as secrets in Conductor
2. Update the inputs file with your environment-specific values (image ID, flavor ID, external network ID)
3. Set the desired number of instances in the inputs (via `instances` input parameter)
4. Install the blueprint: `cfy install blueprint.yaml -i inputs.yaml`
5. Access your application using the floating IP from outputs

## Additional Files

- **blueprint.yaml**: Main blueprint definition (primary entrypoint)
- **inputs.yaml**: Input parameters template
- **install-script.yaml**: User data script for VM initialization
- **vm_use_external_resource.yaml**: Alternative entrypoint for connecting to existing VMs (instead of creating new resources)

## Notes

- The blueprint includes scaling capabilities for horizontal scaling of VM instances
- Each VM can have its own backup/snapshot management
- Security group allows traffic from any IP (0.0.0.0/0) - customize for production use
- The install script is injected as user_data during VM creation
