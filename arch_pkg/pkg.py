import argparse
import json
import os
import subprocess
import urllib.request
from typing import List, Set

CATEGORIES = ["core", "sys_utils", ""]
GROUPS = ["base-devel", "dlang"]
HOSTNAME = (
    subprocess.run(["hostnamectl", "--static"], capture_output=True)
    .stdout.decode("utf-8")
    .strip()
)


def check_aur(packages: Set):
    pkg_str = "&arg[]=" + "&arg[]=".join([i for i in packages])
    with urllib.request.urlopen(
        f"http://aur.archlinux.org/rpc/?v=5&type=info{pkg_str}"
    ) as response:
        response_json = response.read()
    results = json.loads(response_json)
    pkg_matches = {i["Name"] for i in results["results"]}
    aur = {
        "aur_set": pkg_matches,
        "nonaur_set": packages.difference(pkg_matches),
    }
    return aur


def get_installed():
    # Get explicitly installed native packages from the sync database
    sync_pkgs = subprocess.run(["pacman", "-Qqen"], capture_output=True)
    sync_list = sync_pkgs.stdout.decode("utf-8").split("\n")
    sync_set = set(sync_list)

    # Filter out group packages
    for group in GROUPS:
        group_pkgs = subprocess.run(["pacman", "-Qqg", group], capture_output=True)
        group_list = group_pkgs.stdout.decode("utf-8").split("\n")
        sync_set = sync_set.difference(set(group_list))

    # Get explicitly install non-sync packages
    nonsync_pkgs = subprocess.run(["pacman", "-Qqem"], capture_output=True)
    nonsync_list = nonsync_pkgs.stdout.decode("utf-8").split("\n")
    nonsync_set = set(nonsync_list)

    # Split non-sync between aur and non-aur
    aur = check_aur(nonsync_set)

    # All installed
    all_installed = (
        [{"pkg": i, "loc": "sync"} for i in sync_set if i != ""]
        + [{"pkg": i, "loc": "aur"} for i in aur["aur_set"] if i != ""]
        + [{"pkg": i, "loc": "manual"} for i in aur["nonaur_set"] if i != ""]
    )
    # Return all_installed
    with open(f"arch_pkg/{HOSTNAME}_pkgs.json", "w") as f:
        json.dump(all_installed, f)

    return all_installed


def load_data():
    try:
        with open("database.json") as f:
            return f
    except FileNotFoundError:
        return []


def install_missing(installed: List, database: List):
    # Compare installed to database
    db_goal = [i for i in database if i["scope"] in ["global", HOSTNAME]]

    # Iterate through goal list
    for i in db_goal:
        if i["pkg"] in [[i for i["pkg"] in installed]]:
            next
        else:
            subprocess.run("paru", "-S", i["pkg"])
    return


def main():
    installed = get_installed()
    # database = load_data()
    # compare(installed, database)
    return


if __name__ == "__main__":
    main()
