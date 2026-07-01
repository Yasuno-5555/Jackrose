#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import json
import sys
import time
import select

def query_niri(subcommand):
    try:
        res = subprocess.run(["niri", "msg", "--json", subcommand], capture_output=True, text=True, check=True)
        return json.loads(res.stdout)
    except Exception:
        return []

def get_minimap_state():
    workspaces = query_niri("workspaces")
    windows = query_niri("windows")
    
    active_ws = None
    for ws in workspaces:
        if ws.get("is_focused") or ws.get("is_active"):
            active_ws = ws
            break
    if not active_ws and workspaces:
        active_ws = workspaces[0]
        
    if not active_ws:
        return {}
        
    active_ws_id = active_ws["id"]
    ws_windows = [w for w in windows if w.get("workspace_id") == active_ws_id and not w.get("is_floating")]
    
    columns_map = {}
    active_col_idx = 1
    active_app = ""
    has_urgent = False
    
    for w in ws_windows:
        layout = w.get("layout", {})
        pos = layout.get("pos_in_scrolling_layout", [1, 1])
        col = pos[0]
        
        if w.get("is_focused"):
            active_col_idx = col
            active_app = w.get("app_id") or w.get("title") or ""
            if "." in active_app:
                active_app = active_app.split(".")[-1]
                
        if w.get("is_urgent"):
            has_urgent = True
            
        if col not in columns_map:
            columns_map[col] = {
                "col_idx": col,
                "is_focused": False,
                "is_urgent": False,
                "windows": []
            }
            
        columns_map[col]["windows"].append({
            "title": w.get("title", ""),
            "app_id": w.get("app_id", ""),
            "is_focused": w.get("is_focused", False),
            "is_urgent": w.get("is_urgent", False)
        })
        
        if w.get("is_focused"):
            columns_map[col]["is_focused"] = True
        if w.get("is_urgent"):
            columns_map[col]["is_urgent"] = True

    columns_list = sorted(columns_map.values(), key=lambda c: c["col_idx"])
    
    left_count = 0
    right_count = 0
    for c in columns_list:
        col = c["col_idx"]
        if col < active_col_idx:
            left_count += 1
        elif col > active_col_idx:
            right_count += 1
            
    any_urgent = any(w.get("is_urgent") for w in windows)
    
    return {
        "workspace_idx": active_ws["idx"],
        "workspace_name": active_ws["name"] or f"Workspace {active_ws['idx']}",
        "active_column_idx": active_col_idx,
        "active_app": active_app,
        "left_count": left_count,
        "right_count": right_count,
        "has_urgent": any_urgent,
        "columns": columns_list
    }

def main():
    print(json.dumps(get_minimap_state(), ensure_ascii=False), flush=True)
    
    proc = subprocess.Popen(
        ["niri", "msg", "--json", "event-stream"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True
    )
    
    while True:
        r, _, _ = select.select([proc.stdout], [], [], 1.0)
        
        if r:
            line = proc.stdout.readline()
            if not line:
                break
            print(json.dumps(get_minimap_state(), ensure_ascii=False), flush=True)
        else:
            print(json.dumps(get_minimap_state(), ensure_ascii=False), flush=True)

if __name__ == "__main__":
    main()
