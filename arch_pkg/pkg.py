import argparse
import json
import os
import subprocess
import urllib.request
from typing import List, Set

GROUPS = ["base-devel", "dlang"]
HOSTNAME = subprocess.check_output(
    ["hostnamectl", "--static"], encoding="utf-8"
).strip()
SCOPES = {"1": HOSTNAME, "2": "Global", "3": "Ignore"}
CATEGORIES = {
    "1": "pacstrap",
    "2": "System-Core",
    "3": "System-Graphics",
    "4": "System-Utilities",
    "5": "System-Network",
    "6": "Internet",
    "7": "AudioVideo",
    "8": "Graphics",
    "9": "Development",
    "10": "Office",
}


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


def load_database():
    try:
        with open("arch_pkg/database.json") as f:
            return f
    except FileNotFoundError:
        return []


# def install_missing(installed: List, database: List):
#     # Compare installed to database
#     db_goal = [i for i in database if i["scope"] in ["global", HOSTNAME]]

#     # Iterate through goal list
#     for i in db_goal:
#         if i["pkg"] in [[i for i["pkg"] in installed]]:
#             next
#         else:
#             subprocess.run("paru", "-S", i["pkg"])
#     return


def add_to_database(installed: List, get_database: List):
    database_pkgs = [i["pkg"] for i in get_database]
    new_database = []
    scopes = ", ".join([f"{i}-{SCOPES[i]}" for i in SCOPES])
    categories = ", ".join([f"{i}-{CATEGORIES[i]}" for i in CATEGORIES])
    for i in installed:
        if i["pkg"] in database_pkgs:
            new_database.append(i)
            next
        else:
            description = subprocess.check_output(
                ["expac", "'%d'", "-Q", i["pkg"]], text=True
            ).strip()
            # Assign Scope
            scope_value = ""
            while scope_value == "":
                scope = input(
                    f'Package {i["pkg"]} from {i["loc"]} not found: {description}\n{scopes}: '
                )
                try:
                    scope_value = SCOPES[scope]
                except KeyError:
                    scope_value = ""
            # Assign Category
            cat_value = ""
            while cat_value == "":
                categ = input(
                    f'Package {i["pkg"]} needs a category: {description}\n{categories}: '
                )
                try:
                    cat_value = CATEGORIES[categ]
                except KeyError:
                    cat_value = ""
            new_package = {
                "pkg": i["pkg"],
                "loc": i["loc"],
                "scope": scope_value,
                "category": cat_value,
            }
            new_database.append(new_package)
    with open("arch_pkg.json", "w") as f:
        f.write(json.dump(new_database))
    return new_database


def main():
    installed = get_installed()
    get_database = load_database()
    new_database = add_to_database(installed, get_database)
    return


if __name__ == "__main__":
    main()
