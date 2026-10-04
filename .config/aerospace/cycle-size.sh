#!/bin/bash
# Cycle the focused window through 1/2 -> 2/3 -> 1/3 of its monitor (Raycast style).
# Only runs when the workspace has exactly 2 tiled windows.
# Resizes width in a horizontal container, height in a vertical one. Accordion is skipped.
exec python3 - <<'PY'
import json, os, subprocess, sys, time
AS = "/opt/homebrew/bin/aerospace"
OUTER, INNER = 8, 8                      # must match [gaps] in ~/.aerospace.toml
STATE = os.path.expanduser("~/.config/aerospace/.cycle-size-state.json")
STEPS = [("1/2", 1/2), ("2/3", 2/3), ("1/3", 1/3)]

def run(*a):
    return subprocess.run([AS, *a], capture_output=True, text=True).stdout.strip()

info = run("list-windows", "--focused", "--format",
           "%{window-id}|%{window-parent-container-layout}|%{monitor-appkit-nsscreen-screens-id}|%{workspace}")
if "|" not in info:
    sys.exit("no focused window")
wid, layout, screen, ws = info.split("|")
tiles = [l for l in run("list-windows", "--workspace", ws, "--format", "%{window-layout}").splitlines()
         if "floating" not in l]
if len(tiles) != 2:
    sys.exit(f"needs exactly 2 tiled windows on the workspace (found {len(tiles)})")
if "accordion" in layout:
    sys.exit("window is in accordion; switch to tiles first")
horizontal = layout.startswith("h_")

js = ('ObjC.import("AppKit"); var f=$.NSScreen.screens.js[%d].visibleFrame.size; f.width+" "+f.height' % (int(screen) - 1))
w, h = map(float, subprocess.run(["osascript", "-l", "JavaScript", "-e", js], capture_output=True, text=True).stdout.split())
extent = (w if horizontal else h) - 2 * OUTER - INNER

def focused_size():
    r = subprocess.run(["osascript", "-e",
        'tell application "System Events" to tell (first process whose frontmost is true) '
        'to get size of (value of attribute "AXFocusedWindow")'],
        capture_output=True, text=True).stdout.replace(",", " ").split()
    return float(r[0] if horizontal else r[1]) if len(r) == 2 else None

try:
    state = json.load(open(STATE))
except Exception:
    state = {}

# Current step: trust the remembered one if the window is still the size we left it at
# (apps with a minimum size can't hit exact fractions); otherwise infer it from the real size.
size = focused_size()
idx = 0
if size is not None:
    saved = state.get(wid)
    if saved and abs(size - saved[1]) <= 12:
        idx = (saved[0] + 1) % len(STEPS)
    else:
        nearest = min(range(len(STEPS)), key=lambda k: abs(size - extent * STEPS[k][1]))
        if abs(size - extent * STEPS[nearest][1]) <= 0.09 * extent:
            idx = (nearest + 1) % len(STEPS)

name, frac = STEPS[idx]
axis = "width" if horizontal else "height"
run("resize", "--window-id", wid, axis, str(round(extent * frac)))

# Some apps have a minimum window size (e.g. Safari is ~574 pt wide). If the other tile could not
# shrink to its share, it overlaps this one: shrink this window to what actually fits.
time.sleep(0.3)
other = [l.split("\t") for l in run("list-windows", "--workspace", ws, "--format",
         "%{window-id}\t%{app-name}").splitlines() if "\t" in l]
other = [o for o in other if o[0] != wid]
if other:
    pname = other[0][1].replace("\u200e", "").strip()
    js = ('var p=Application("System Events").processes.byName(%r); var out=[];'
          'p.windows().forEach(function(w){var po=w.position(),sz=w.size(); out.push(po[0]+" "+po[1]+" "+sz[0]+" "+sz[1]);});'
          'out.join(";")' % pname)
    r = subprocess.run(["osascript", "-l", "JavaScript", "-e", js], capture_output=True, text=True).stdout.strip()
    sizes = []
    for chunk in r.split(";"):
        try:
            x, y, ww, hh = map(float, chunk.split())
        except ValueError:
            continue
        if x < w - 50 and y < h - 50:                      # on-screen, not parked in a corner
            sizes.append(ww if horizontal else hh)
    if sizes:
        actual = max(sizes)
        allowed = extent * (1 - frac)
        if actual > allowed + 8:
            run("resize", "--window-id", wid, axis, str(round(extent - actual)))
            name += f" (limited: {pname} needs {round(actual)} pt)"
time.sleep(0.3)
final = focused_size()
live = set(run("list-windows", "--monitor", "all", "--format", "%{window-id}").split())
state = {k: v for k, v in state.items() if k in live}
if final is not None:
    state[wid] = [idx, final]
json.dump(state, open(STATE, "w"))
print(f"{name} of {axis}")
PY
