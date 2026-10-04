#!/bin/bash
# Pick any window from another workspace and bring it to the focused workspace.
# Uses the built-in macOS list dialog, so nothing needs installing.
# For testing, BRING_PICK="<exact list entry>" skips the dialog.
exec python3 - <<'PY'
import os, subprocess, sys
AS = "/opt/homebrew/bin/aerospace"
def run(*a):
    return subprocess.run([AS, *a], capture_output=True, text=True).stdout

LRM = "‎"
ws = run("list-workspaces", "--focused").strip()
focused = run("list-windows", "--focused", "--format", "%{window-id}").strip()
fmt = "%{window-id}%{tab}%{workspace}%{tab}%{app-name}%{tab}%{window-title}%{tab}%{app-bundle-id}"
entries = {}                                   # list entry -> window id
for line in run("list-windows", "--monitor", "all", "--format", fmt).splitlines():
    parts = line.split("\t")
    if len(parts) < 5:
        continue
    wid, w = parts[0], parts[1]
    app, title, bundle = parts[2].replace(LRM, "").strip(), parts[3].replace(LRM, "").strip(), parts[4]
    if w == ws or bundle == "com.raycast.macos":
        continue
    label = f"{app} - {title}" if title and title != app else app
    entry = f"{label}   [{w}]"
    while entry in entries:                    # identical labels stay distinct
        entry += " "
    entries[entry] = wid
if not entries:
    sys.exit("no windows on other workspaces")

choice = os.environ.get("BRING_PICK")
if choice is None:
    # Run the dialog inside System Events and activate it, so it opens in front with keyboard focus
    script = ('on run argv\n'
              'tell application "System Events"\n'
              'activate\n'
              'set r to choose from list argv with title "Bring window" with prompt "Bring to this workspace:"\n'
              'end tell\n'
              'if r is false then return ""\n'
              'return item 1 of r\nend run')
    choice = subprocess.run(["osascript", "-e", script, *sorted(entries, key=str.lower)],
                            capture_output=True, text=True).stdout.rstrip("\n")
if not choice or choice not in entries:
    sys.exit("cancelled" if not choice else f"unknown choice: {choice!r}")

wid = entries[choice]
if focused:
    run("fullscreen", "off", "--window-id", focused)
run("move-node-to-workspace", "--window-id", wid, ws)
run("focus", "--window-id", wid)
print(f"brought {choice.strip()} to {ws}")
PY
