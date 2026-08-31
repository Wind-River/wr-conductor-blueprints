# Hardware Check Blueprint

Conductor blueprint that connects to a remote host via SSH and runs `hwcheck.sh` to validate hardware compatibility against WRCP requirements.

## Prerequisites

- Cloudify CLI (`cfy`) installed and configured with a manager profile
- `cloudify-fabric-plugin` 2.x installed on the manager

## Setup

### 1. Create Secrets

Store the target host credentials as Conductor secrets:

```bash
cfy secrets create hwcheck_ip_address -s <TARGET_IP>
cfy secrets create hwcheck_username -s <SSH_USER>
cfy secrets create hwcheck_password -s <SSH_PASSWORD>
```

### 2. Upload Blueprint

```bash
cfy blueprints upload -b hwcheck -n blueprint.yaml hwcheck.zip
```

### 3. Create Deployment and Install

1. Open the Conductor web console and navigate to **Local Blueprints**.
2. Find the **hwcheck** blueprint and click **Deploy**.
3. Fill in the deployment inputs:
   - **ip_address** – target host IP (defaults to the `hwcheck_ip_address` secret)
   - **username** – SSH user (defaults to the `hwcheck_username` secret)
   - **password** – SSH password (defaults to the `hwcheck_password` secret)
4. Click **Install** to create the deployment and run the install workflow.

### 4. View Results

1. In the Conductor web console, go to **Deployments** and select the **hwcheck** deployment.
2. Click the **Deployments Info** tab and then the **Outputs** tab.
3. The **Deployment Outputs/Capabilities** section contains output from the full hardware check report.
