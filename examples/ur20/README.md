# UR20 Program Load Blueprint

Conductor blueprint that controls a Universal Robots UR20 via its REST API. Supports loading, starting, and stopping programs on the robot.

## Prerequisites

- Conductor CLI (`cfy`) installed and configured with a manager profile
- Plugin wagon uploaded to the manager (see below)
- A real UR20 robot or a PolyscopeX installation accessible on the network
  - PolyscopeX simulator setup: https://docs.universal-robots.com/PolyScopeX_SDK_Documentation/build/SDK-v0.11/GettingStarted/InstallationGuide.html
- The following programs must be valid, working, and loaded on the robot or simulator:
  - `Default Program`
  - `ProgramA`
  - `ProgramB`

## Setup

### 1. Upload Plugin

```bash
cfy plugins upload ur20_program_load_plugin-1.0.0-py310-none-any.wgn -y ur20-program-load-plugin/plugin.yaml
```

### 2. Upload Blueprint

```bash
cfy blueprints upload ur20-program-load.tar.gz -b ur20-program-load -n ur20-program-load.yaml
```

### 3. Create Deployment and Install

1. Open the Conductor web console and navigate to **Local Blueprints**.
2. Find the **ur20-program-load** blueprint and click **Deploy**.
3. Fill in the deployment inputs:
   - **robot_host** – IP address of the UR20 robot (default: `127.0.0.1`)
   - **api_port** – REST API port (default: `8000`)
   - **program_name** – program to load (default: `Default program`)
4. Click **Install** to create the deployment and run the install workflow.

### 4. Run Workflows

1. In the Conductor web console, go to **Deployments** and select the **ur20-program-load** deployment.
2. Click the **Execute Workflow** button (play icon).
3. Select the desired workflow from the dropdown:
   - **program_load** – loads a program onto the robot. Enter the `program_name` parameter when prompted.
   - **program_start** – starts the currently loaded program.
   - **program_stop** – stops the running program.
4. Fill in any required parameters and click **Execute**.

Available programs: `Default Program`, `ProgramA`, `ProgramB`
