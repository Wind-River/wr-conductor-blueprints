# OpenStack Network

This blueprint creates and manage OpenStack networks with configuration options.

## Deployed Infrastructure

It deploys a fully configured network including:

- **Network**: OpenStack network resource with customizable properties
- **Administrative State Control**: Configure network as up (active) or down
- **Advanced Configuration**: Support for segments, DNS domain, and MTU settings
- **Resource Management**: Support for external resources and quota validation

## Prerequisites

- User must have OpenStack credentials with permissions to create and manage network resources.
- OpenStack authentication credentials should be added as WRC secrets or provided as inputs.
- Sufficient network quota available in the target project.

## Compatibility

Tested with:

- conductor-openstack-plugin version 26.3.0

## Resource Configuration

### Core Properties

- **id**: String. Optional. The OpenStack ID of an existing resource if `use_external_resource` is set to `true`.
- **name**: String. Optional. The user-readable name for the network in OpenStack.
- **admin_state_up**: String. Optional. The administrative state of the network (true for up, false for down).
- **kwargs**: Dictionary. Optional. Additional key-word arguments accepted by the OpenStack API method.

### Advanced Options

- **segments**: Array. Optional (admin users only). Array of network segments with provider attributes.
  - Example: `[{"provider:segmentation_id": 2, "provider:physical_network": "public"}]`
- **dns_domain**: String. Optional. DNS domain for the network (requires update operation).
- **mtu**: String. Optional. Maximum Transmission Unit size in bytes (requires update operation).

## Operations

#### cloudify.interfaces.lifecycle.create

Executes `create_network`.

- Creates a new OpenStack network with specified configuration.

#### cloudify.interfaces.lifecycle.delete

Executes `delete_network`.

- Removes the network resource from OpenStack.

#### cloudify.interfaces.operations.update

Executes `update_network`.

- Modifies existing network configuration.

**Supported Update Parameters:**

- `name`: Change network name
- `dns_domain`: Set DNS domain
- `mtu`: Adjust MTU size
- `segments`: Modify provider segments (admin only)

**Example Update Inputs:**

```yaml
{ "args": { "name": "new-network-name" } }
{ "args": { "name": "new-network-name", "dns_domain": "example.org", "mtu": "1300" } }
```

#### cloudify.interfaces.operations.list

Executes `list_networks`.

- Retrieves networks matching query criteria.

**Query Example:**

```yaml
{ "query": { "name": "network-name" } }
```

#### cloudify.interfaces.validation.creation

- Verifies sufficient quota for new network resource allocation.

## Usage Examples

### Basic Network Creation

```yaml
example_network:
  type: cloudify.nodes.openstack.Network
  properties:
    client_config:
      auth_url: { get_secret: auth_url }
      username: { get_secret: username }
      password: { get_secret: password }
      project_name: { get_secret: project_name }
      region_name: { get_secret: region_name }
    resource_config:
      name: example-network
```

### Network with Advanced Configuration

```yaml
advanced_network:
  type: cloudify.nodes.openstack.Network
  properties:
    client_config:
      auth_url: { get_secret: auth_url }
      username: { get_secret: username }
      password: { get_secret: password }
      project_name: { get_secret: project_name }
      region_name: { get_secret: region_name }
    resource_config:
      name: advanced-network
      admin_state_up: true
      kwargs:
        dns_domain: example.org
        mtu: 1500
```

### Network with Provider Segments (Admin Only)

```yaml
provider_network:
  type: cloudify.nodes.openstack.Network
  properties:
    client_config:
      auth_url: { get_secret: auth_url }
      username: { get_secret: username }
      password: { get_secret: password }
      project_name: { get_secret: project_name }
      region_name: { get_secret: region_name }
    resource_config:
      name: provider-network
      kwargs:
        segments:
          - provider:physical_network: public
            provider:network_type: flat
          - provider:physical_network: default
            provider:segmentation_id: 100
```

### Using External Network Resource

```yaml
external_network:
  type: cloudify.nodes.openstack.Network
  properties:
    use_external_resource: true
    client_config:
      auth_url: { get_secret: auth_url }
      username: { get_secret: username }
      password: { get_secret: password }
      project_name: { get_secret: project_name }
      region_name: { get_secret: region_name }
    resource_config:
      id: 12345678-1234-5678-1234-567812345678
```

## Common Use Cases

- **Isolated Networks**: Create private networks for applications with custom routing
- **Multi-Tenancy**: Separate networks for different projects or departments
- **Provider Networks**: Admin-level network creation with provider segments
- **DNS Integration**: Networks with custom DNS domains for internal resolution
- **Jumbo Frames**: Networks with increased MTU for high-performance workloads

## Notes

- Network creation requires appropriate OpenStack project quotas
- For provider segment configuration, admin/elevated privileges are required
- Network deletion may be blocked if subnets or ports are attached
- DNS domain changes require update operations after network creation
- Default MTU for OpenStack networks is typically 1500 bytes

## API Reference

For more information on network creation and management, see the OpenStack Network API documentation:

- [Network API Reference](https://docs.openstack.org/api-ref/network/v2/)
- [create_network parameters](https://docs.openstack.org/api-ref/network/v2/#create-network)
- [update_network parameters](https://docs.openstack.org/api-ref/network/v2/#update-network)
