#!/bin/bash
# Send the focused workspace (all its windows) to the monitor on the left or right.
#   left  = portrait monitor  -> first free workspace in P1..P9
#   right = landscape monitor -> first free workspace in 1..9
# Windows are moved into the target monitor's workspace names, and focus follows.
exec python3 - "$1" <<'PY'
import subprocess, sys
AS = "/opt/homebrew/bin/aerospace"
def run(*a):
    return subprocess.run([AS, *a], capture_output=True, text=True).stdout
side = sys.argv[1]
if side not in ("left", "right"):
    sys.exit("usage: send-workspace.sh left|right")
prefix = "P" if side == "left" else ""

ws = run("list-workspaces", "--focused").strip()
if ws.startswith("P") == (prefix == "P"):
    sys.exit(f"workspace {ws} is already on the {side} monitor")
wins = run("list-windows", "--workspace", ws, "--format", "%{window-id}").split()
if not wins:
    sys.exit(f"workspace {ws} has no windows")

occupied = {l.strip() for l in run("list-windows", "--all", "--format", "%{workspace}").splitlines()}
target = next((f"{prefix}{i}" for i in range(1, 10) if f"{prefix}{i}" not in occupied), None)
if not target:
    sys.exit(f"no free workspace on the {side} monitor")

focused = run("list-windows", "--focused", "--format", "%{window-id}").strip()
for wid in wins:
    run("move-node-to-workspace", "--window-id", wid, target)
run("focus", "--window-id", focused or wins[0])
print(f"{ws} -> {target}")
PY
