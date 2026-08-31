import json
import urllib.request
import urllib.error
from cloudify.decorators import workflow, operation
from cloudify.workflows import ctx as workflow_ctx
from cloudify import ctx


def _call_api(host, port, path, body=None):
    url = f"http://{host}:{port}/universal-robots/robot-api{path}"
    data = json.dumps(body).encode('utf-8') if body else None
    req = urllib.request.Request(url, data=data, method='PUT')
    req.add_header('Content-Type', 'application/json')
    req.add_header('accept', 'application/json')
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return json.loads(resp.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        if e.code in (409, 412):
            return json.loads(error_body)
        raise


@operation
def start(**kwargs):
    ctx.logger.info("UR20 robot node started")


@workflow
def load_program(program_name, **kwargs):
    for node in workflow_ctx.nodes:
        props = node.properties
        if 'robot_host' in props:
            host = props['robot_host']
            port = props['api_port']
            break
    else:
        raise Exception("No robot node found")

    result = _call_api(host, port, '/program/v1/load', {'programName': program_name})
    workflow_ctx.logger.info(f"Load program result: {result}")
    return result


@workflow
def start_program(**kwargs):
    for node in workflow_ctx.nodes:
        props = node.properties
        if 'robot_host' in props:
            host = props['robot_host']
            port = props['api_port']
            break
    else:
        raise Exception("No robot node found")

    result = _call_api(host, port, '/program/v1/state', {'action': 'play'})
    workflow_ctx.logger.info(f"Start program result: {result}")
    return result


@workflow
def stop_program(**kwargs):
    for node in workflow_ctx.nodes:
        props = node.properties
        if 'robot_host' in props:
            host = props['robot_host']
            port = props['api_port']
            break
    else:
        raise Exception("No robot node found")

    result = _call_api(host, port, '/program/v1/state', {'action': 'stop'})
    workflow_ctx.logger.info(f"Stop program result: {result}")
    return result
