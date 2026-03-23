# OpenStack Tenant Management

This blueprint creates an OpenStack project and assigns an existing user to that project with a selected role.

## Prerequisites

- User must have OpenStack admin-level credentials with permissions to create projects and assign roles.
- The user specified in `username` must already exist when `use_external_resource: true` is used in the `user` node.
- The role specified by `username_role_id` must already exist.

## Compatibility

Tested with:

- conductor-openstack-plugin version 26.3.0

## What This Blueprint Creates

- A new OpenStack `Project`.
- A reference to an existing OpenStack `User`.
- A reference to an existing OpenStack `Role`.
- A project update step that assigns the user to the newly created project with the selected role.

## Node Types Used

- `cloudify.nodes.openstack.Project`
- `cloudify.nodes.openstack.User`
- `cloudify.nodes.openstack.Role`

## Inputs

### Authentication and API

- **auth_url**: OpenStack authentication URL.
- **openstack_username**: Admin username used to authenticate and manage projects/users/roles.
- **openstack_password**: Password for `openstack_username`.
- **project_name**: Existing project/tenant used for authentication.
- **region_name**: OpenStack region name.
- **user_domain_name**: User domain name for authentication.
- **project_domain_name**: Project domain name for authentication.
- **insecure**: Boolean. If `true`, SSL verification is disabled.
- **ca_cert**: Path or content for CA certificate when SSL verification is enabled.

### New Project Configuration

- **new_project_name**: Name of the project to create.
- **project_domain**: Domain owning the project (name or ID).
- **project_parent_id**: Optional parent project ID for hierarchical projects.
- **project_description**: Optional project description.
- **project_tags**: Optional list of project tags.

### User and Role Assignment

- **username**: Existing OpenStack user to assign to the new project.
- **username_role_id**: Existing role ID to grant to `username` within the new project.

## Blueprint Flow

1. `project` node creates the new OpenStack project using `new_project_name` and related project metadata.
2. `user` node references an existing user (`use_external_resource: true`).
3. `role` node references an existing role by ID (`use_external_resource: true`).
4. `assign_user_to_project` node depends on all previous nodes and updates the project users mapping to assign the role to the user.

## Notes

- `project_parent_id` exists as an input for hierarchical project support, but it is not currently mapped into `resource_config` in this blueprint.
- In `user.resource_config.default_project_id`, the blueprint passes `new_project_name`. Some OpenStack deployments/APIs expect a project ID instead of name. If needed, update this mapping to use the created project ID.

## Example

```yaml
tosca_definitions_version: cloudify_dsl_1_4

imports:
  - cloudify/types/types.yaml
  - plugin:conductor-openstack-plugin?version=>=26.3.0

inputs:
  auth_url:
    type: string
    default: { get_secret: openstack_url }

  openstack_username:
    type: string
    default: { get_secret: openstack_username_admin }

  openstack_password:
    type: string
    default: { get_secret: openstack_password_admin }

  project_name:
    type: string
    default: { get_secret: openstack_tenant_name }

  user_domain_name:
    type: string

  project_domain_name:
    type: string

  insecure:
    type: boolean
    default: false

  ca_cert:
    type: string
    default: { get_secret: openstack_cacert }

  region_name:
    type: string

  new_project_name:
    type: string
    default: "team-a-project"

  project_domain:
    type: string
    default: "default"

  project_description:
    type: string
    default: "Project for Team A workloads"

  project_tags:
    type: list
    default: ["team-a", "production"]

  username:
    type: string
    default: "existing-user"

  username_role_id:
    type: string
    default: "<role-id>"

dsl_definitions:
  openstack_config: &openstack_config
    auth_url: { get_input: auth_url }
    username: { get_input: openstack_username }
    password: { get_input: openstack_password }
    project_name: { get_input: project_name }
    region_name: { get_input: region_name }
    user_domain_name: { get_input: user_domain_name }
    project_domain_name: { get_input: project_domain_name }
    insecure: { get_input: insecure }
    ca_cert: { get_input: ca_cert }

node_templates:
  project:
    type: cloudify.nodes.openstack.Project
    properties:
      client_config: *openstack_config
      resource_config:
        name: { get_input: new_project_name }
        domain_id: { get_input: project_domain }
        description: { get_input: project_description }
        tags: { get_input: project_tags }

  user:
    type: cloudify.nodes.openstack.User
    properties:
      use_external_resource: true
      client_config: *openstack_config
      resource_config:
        name: { get_input: username }

  role:
    type: cloudify.nodes.openstack.Role
    properties:
      use_external_resource: true
      client_config: *openstack_config
      resource_config:
        id: { get_input: username_role_id }
        domain_id: { get_input: project_domain }

  assign_user_to_project:
    type: cloudify.nodes.openstack.Project
    properties:
      use_external_resource: true
      client_config: *openstack_config
      resource_config:
        id: { get_attribute: [project, id] }
      users:
        - name: { get_property: [user, resource_config, name] }
          roles:
            - { get_attribute: [role, id] }
    relationships:
      - type: cloudify.relationships.depends_on
        target: project
      - type: cloudify.relationships.depends_on
        target: user
      - type: cloudify.relationships.depends_on
        target: role
```
