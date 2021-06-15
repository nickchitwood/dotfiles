import json
import subprocess


def get_child_container(node):
    child_node_count = len(node["nodes"]) + len(node["floating_nodes"])
    if child_node_count == 0:
        window = {
            "name": node.get("name"),
            "shell": node.get("shell"),
            "app_id": node.get("app_id"),
            "window_properties": node.get("window_properties"),
        }
        print(f"        {window}")
    else:
        for i in node["nodes"]:
            get_child_container(i)
        for i in node["floating_nodes"]:
            get_child_container(i)


sway_tree = subprocess.run(["swaymsg", "-t", "get_tree"], capture_output=True)
root = json.loads(sway_tree.stdout)

outputs = [{"name": i["name"], "nodes": i["nodes"]} for i in root["nodes"]]

for i in outputs:
    print(f"Output {i['name']}")
    workspaces = [
        {"name": j["name"], "nodes": j["nodes"], "floating_nodes": j["floating_nodes"]}
        for j in i["nodes"]
    ]
    for k in workspaces:
        print(f"    Workspace {k['name']}")
        get_child_container(k)
