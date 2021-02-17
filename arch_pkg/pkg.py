import argparse
import json
import operator
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
    "11": "Games",
    "12": "Data",
}


PATH = os.environ["PATH"].split(":")


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
        json.dump(all_installed, f, indent=2)

    return all_installed


def load_database():
    try:
        with open("arch_pkg/database.json") as f:
            return json.load(f)
    except FileNotFoundError:
        return []


def add_to_database(installed: List, get_database: List):
    database_pkgs = [i["pkg"] for i in get_database]
    new_database = []
    scopes = ", ".join([f"{i}-{SCOPES[i]}" for i in SCOPES])
    categories = ", ".join([f"{i}-{CATEGORIES[i]}" for i in CATEGORIES])
    for i in installed:
        if i["pkg"] in database_pkgs:
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
    combined_database = get_database + new_database

    def sort_database(item):
        group_number = [i for i in CATEGORIES if item["category"] == CATEGORIES[i]][0]
        sort_key = f"{group_number.zfill(2)}-{item['pkg']}"
        return sort_key

    combined_database.sort(key=sort_database)

    for i in combined_database:
        i.update({"whatis": get_whatis(i["pkg"])})

    with open("arch_pkg/database.json", "w") as f:
        json.dump(combined_database, f, indent=2)
    return combined_database


def create_missing_list(installed, combined_database):
    installed_packages = [i["pkg"] for i in installed]
    with open(f"arch_pkg/{HOSTNAME}_install.txt", "w") as f:
        for i in CATEGORIES:
            cat_pkgs = [j for j in combined_database if j["category"] == CATEGORIES[i]]
            print(f"Category {i}: {CATEGORIES[i]}")
            for j in cat_pkgs:
                if j["pkg"] in installed_packages:
                    print(f"{j['pkg']} already installed")
                    next
                elif j["scope"] == "Global":
                    print(f"{j['pkg']} added to install.txt.")
                    f.write(f"{j['pkg']}\n")
                elif j["scope"] == "Ignore":
                    print(f"{j['pkg']} on ignore list. Consider uninstalling.")
                    next
                else:
                    print(f"{j['pkg']} out of scope for {HOSTNAME}")
                    next
            print("")
    return


def check_if_in_path(filepath):
    path_checks = [filepath for i in PATH if filepath.startswith(i)]
    if len(path_checks) >= 1:
        return True
    else:
        return False


def get_whatis(package_name):
    try:
        files = subprocess.check_output(
            ["pacman", "-Qql", package_name], encoding="utf-8"
        ).splitlines()
        files_only = [i for i in files if i[-1] != "/"]
        path_files = [i for i in files_only if check_if_in_path(i)]
        whatis = [{i: subprocess.check_output(
            ["whatis",  i], encoding="utf-8"
        ).splitlines()} for i in path_files]
        return whatis
    except subprocess.CalledProcessError:
        return ""


def main():
    installed = get_installed()
    get_database = load_database()
    combined_database = add_to_database(installed, get_database)
    create_missing_list(installed, combined_database)
    print(
        f"Missing list complete. Install using paru -S --needed - < arch_pkg/{HOSTNAME}_install.txt"
    )
    return


if __name__ == "__main__":
    main()
