# OpenStack Image

This blueprint creates an OpenStack image resource with custom configuration.

## Prerequisites

- User must have OpenStack credentials with the required permissions to manage image resources.
- OpenStack authentication credentials should be added as WRC secrets or provided as inputs.

## Compatibility

Tested with:

- cloudify-openstack-plugin version 26.3.0

## Node Type: cloudify.nodes.openstack.Image

This node type refers to an OpenStack image resource.

### Resource Config

- **id**: String. Optional. The OpenStack ID of an existing resource if `use_external_resource` is set to `true`.
- **name**: String. Optional. The user-readable name in OpenStack if you want to set it, or the name of an existing resource if `use_external_resource` is set to `true`.
- **kwargs**: Dictionary. Optional. Additional key-word arguments accepted by the API method, if not exposed in the resource_config by name.
- **container_format**: String. Optional. Format of the image container (e.g., `bare`).
- **disk_format**: String. Optional. Format of the image disk (e.g., `qcow2`, `raw`, `vmdk`).
- **tags**: List. Not required. List of tags for this image. Each tag is a string of at most 255 characters. The maximum number of tags allowed on an image is set by the operator.

For more information and possible keyword arguments, see: [create_image](https://docs.openstack.org/api-ref/image/v2/#create-image).

### Operations

#### cloudify.interfaces.lifecycle.create

Executes `upload_image`.

- Creates a new image from attributes.
- **Note**: Image upload from local file is not supported yet.

#### cloudify.interfaces.lifecycle.start

This operation checks the status of uploading image. However, since uploading image is not supported in this version, this operation will be disabled.

#### cloudify.interfaces.lifecycle.delete

Executes `delete_image`.

- Deletes the image resource.

#### cloudify.interfaces.operations.update

Executes `update_image`.

- **Inputs**:
  - `args`: Dictionary. Required. Key-word arguments accepted by the update Image API method.
  - **Example**: `{ "args": { "name": "new-name" } }`

#### cloudify.interfaces.operations.list

Executes `list_images`.

- **Inputs**:
  - `query`: Dictionary. Not required. Key-word arguments accepted by the List Image API method.
  - **Example**: `{ "query": { "name": "any-name" } }`

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

## Example

```yaml
example-image:
  type: cloudify.nodes.openstack.Image
  properties:
    client_config:
      auth_url: { get_input: auth_url }
      username: { get_input: username }
      password: { get_input: password }
      region_name: { get_input: region_name }
      project_name: { get_input: project_name }
      user_domain_name: { get_input: user_domain_name }
      project_domain_name: { get_input: project_domain_name }
    resource_config:
      name: "openstack-image-custom"
      container_format: "bare"
      disk_format: "qcow2"
```
