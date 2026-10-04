#!/bin/bash
# Consolidate all occupied workspaces onto one monitor, renumbered in order.
#   split (numbers + P) -> all on landscape as 1..n
#   all landscape (1..n) -> all on portrait as P1..Pn (two monitors only; with one screen it just renumbers to 1..n)
#   all portrait (P1..Pn) -> all on landscape as 1..n
# Moves windows between workspaces; the pinning in ~/.aerospace.toml stays static.
exec python3 - <<'PY'
import subprocess, sys, re
AS = "/opt/homebrew/bin/aerospace"
def run(*a):
    return subprocess.run([AS, *a], capture_output=True, text=True).stdout

rows = [l.split("|") for l in run("list-windows", "--all", "--format", "%{window-id}|%{workspace}").splitlines() if "|" in l]
by_ws = {}
for wid, ws in rows:
    by_ws.setdefault(ws.strip(), []).append(wid.strip())

def key(w):
    m = re.fullmatch(r"(P?)(\d+)", w)
    return (1 if m and m.group(1) else 0, int(m.group(2))) if m else (2, 0)
sources = sorted((w for w in by_ws if key(w)[0] < 2), key=key)
if not sources:
    sys.exit("no windows on numbered or P workspaces")
if len(sources) > 9:
    sys.exit("more than 9 occupied workspaces")

has_num = any(not w.startswith("P") for w in sources)
has_p = any(w.startswith("P") for w in sources)
monitors = [l for l in run("list-monitors").splitlines() if l.strip()]
# all landscape -> portrait; otherwise -> landscape. With a single screen it always renumbers to 1..n
target_portrait = len(monitors) > 1 and has_num and not has_p
targets = [("P" if target_portrait else "") + str(i + 1) for i in range(len(sources))]

focused = run("list-windows", "--focused", "--format", "%{window-id}").strip()

moves = [(s, t) for s, t in zip(sources, targets) if s != t]
# Two phases through temporary workspaces so renumbering never merges two workspaces
for i, (s, t) in enumerate(moves):
    for wid in by_ws[s]:
        run("move-node-to-workspace", "--window-id", wid, f"tmp{i}")
for i, (s, t) in enumerate(moves):
    for wid in by_ws[s]:
        run("move-node-to-workspace", "--window-id", wid, t)
if focused:
    run("focus", "--window-id", focused)
print(" ".join(f"{s}->{t}" for s, t in zip(sources, targets)))
PY
