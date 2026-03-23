# Namespace example

This blueprint creates a namespace with defined labels.

## Prerequisites

User must have created a cluster-admin token with the required permissions to manage resources properly. This token should be added as a WRC secret.

## Compatibility

Tested with:
* conductor-kubernetes-plugin version 26.3.0

## Inputs

* `kubernetes_api_server`: The IP address of the Kubernetes API server.
* `token_secret`: Secret containing cluster-admin token.
* `namespace`: Namespace to be created.
* `namespace_labels`: Labels to be added to the Namespace.
* `debug`: Kubernetes client debug level.
* `verify_ssl`: Whether to secure a connection (must provide a CA).