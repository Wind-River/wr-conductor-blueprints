# OpenStack Security Group

This blueprint creates an OpenStack Security Group with custom rules.

## Prerequisites

- User must have OpenStack credentials with the required permissions to manage security group resources.
- OpenStack authentication credentials should be added as WRC secrets or provided as inputs.

## Compatibility

Tested with:

- cloudify-openstack-plugin version 26.3.0

## Node Type: cloudify.nodes.openstack.SecurityGroup

This node type refers to an OpenStack security group.

### Client Config

Each node template has a `client_config` property which stores your account credentials. Use an intrinsic function to assign these to the values of secrets in your manager. For more information, see the "Using the Secrets Store" section in the Working with Wind River Conductor Guide at [https://docs.windriver.com](https://docs.windriver.com) for your release version.

```yaml
example-security-group:
  type: cloudify.nodes.openstack.SecurityGroup
  properties:
    client_config: &client_config
      auth_url: { get_secret: auth_url }
      username: { get_secret: username }
      password: { get_secret: password }
      region_name: { get_secret: region_name }
      project_name: { get_secret: project_name }
      user_domain_name: { get_secret: user_domain_name }
      project_domain_name: { get_secret: project_domain_name }
```

### Resource Config

- **id**: String. Not required. The OpenStack ID of an existing resource if `use_external_resource` is set to `true`.
- **name**: String. Required. The user-readable name in OpenStack.
- **kwargs**: Dictionary. Not required. Additional key-word arguments accepted by the API method, if not exposed in the resource_config by name.
- **description**: String. Not required. Resource description.

For more information and possible keyword arguments, see: [create_security_group](https://docs.openstack.org/api-ref/network/v2/#create-security-group).

### Properties

- **security_group_rules**: List. Optional. A list of security group rules to be created.
- **disable_default_egress_rules**: Boolean. Optional. A flag for removing the default egress rules. If not set to `true`, these rules will remain and exist alongside any additional rules passed using the `security_group_rules` property.

### Operations

#### cloudify.interfaces.lifecycle.create

Executes `create_security_group`.

- Creates a new security group.

#### cloudify.interfaces.lifecycle.configure

- Executes `delete_security_group_rule` to remove the default rules when `disable_default_egress_rules` is enabled.
- Executes `create_security_group_rule` to add rules when `security_group_rules` is provided.

#### cloudify.interfaces.lifecycle.delete

Executes `delete_security_group`.

- Deletes the security group resource.

#### cloudify.interfaces.operations.update

Executes `update_security_group`.

- **Inputs**:
  - `args`: Dictionary. Required. Key-word arguments accepted by the update Security Group API method.
  - **Request Example**:
    ```json
    {
      "args": {
        "name": "my-security-group",
        "description": "my security group"
      }
    }
    ```

#### cloudify.interfaces.operations.list

Executes `list_security_groups`.

- **Inputs**:
  - `query`: Dictionary. Optional. Key-word arguments accepted by the List Security Group API method.
  - **Request Example**: `{ "query": { "name": "any-name" } }`

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
- **security_group_config**: Dictionary containing the security group configuration (name, description, etc.).
- **security_group_rules_config**: List of security group rule configurations.

## Create a Security Group with Rules

```yaml
tosca_definitions_version: cloudify_dsl_1_4

imports:
  - cloudify/types/types.yaml
  # For use with a manager use: plugin:cloudify-openstack-plugin
  - plugin:cloudify-openstack-plugin

inputs:
  auth_url:
    type: string

  username:
    type: string

  password:
    type: string

  region_name:
    type: string

  project_name:
    type: string

  user_domain_name:
    type: string

  project_domain_name:
    type: string

  security_group_config:
    default:
      name: "cloudify_security_group"
      description: "A security group created by Cloudify OpenStack SDK plugin."

  security_group_rules_config:
    default:
      - remote_ip_prefix: 0.0.0.0/0
        port_range_max: 80
        port_range_min: 80
        direction: ingress
        protocol: tcp
        security_group_id: { get_attribute: [SELF, id] }
      - remote_ip_prefix: 0.0.0.0/0
        port_range_max: 80
        port_range_min: 80
        direction: egress
        protocol: tcp
        security_group_id: { get_attribute: [SELF, id] }

dsl_definitions:
  client_config: &client_config
    auth_url: { get_secret: auth_url }
    username: { get_secret: username }
    password: { get_secret: password }
    region_name: { get_secret: region_name }
    project_name: { get_secret: project_name }
    user_domain_name: { get_secret: user_domain_name }
    project_domain_name: { get_secret: project_domain_name }

node_templates:
  example-security-group:
    type: cloudify.nodes.openstack.SecurityGroup
    properties:
      client_config: *client_config
      security_group_rules: { get_input: security_group_rules_config }
      resource_config: { get_input: security_group_config }
    # This is only run on local mode. For use with a manager, it can be commented out.
    interfaces:
      cloudify.interfaces.lifecycle:
        create:
          inputs:
            resource_config: { get_property: [SELF, resource_config] }
```
