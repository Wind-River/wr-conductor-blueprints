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