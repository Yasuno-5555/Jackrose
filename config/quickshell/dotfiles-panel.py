#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import json
import sys
import os

HOME = os.path.expanduser("~")

def get_git_status():
    try:
        # git status --short
        res = subprocess.run(
            ["git", "status", "--short"],
            cwd=HOME,
            capture_output=True,
            text=True,
            check=True
        )
        lines = res.stdout.strip().split("\n")
        files = []
        for line in lines:
            if not line.strip():
                continue
            parts = line.split(maxsplit=1)
            if len(parts) == 2:
                status, path = parts
                files.append({
                    "status": status.strip(),
                    "path": path.strip()
                })
        return files
    except Exception as e:
        return [{"status": "Error", "path": str(e)}]

def do_commit(message):
    try:
        # git add -A
        subprocess.run(["git", "add", "-A"], cwd=HOME, check=True)
        # git commit -m message
        subprocess.run(["git", "commit", "-m", message], cwd=HOME, check=True)
        # notify-send
        subprocess.run(["notify-send", "Dotfiles Control Center", f"Changes committed successfully:\n{message}"])
        return {"success": True, "message": "Committed successfully."}
    except Exception as e:
        subprocess.run(["notify-send", "Dotfiles Control Center Error", f"Failed to commit:\n{str(e)}"])
        return {"success": False, "message": str(e)}

def main():
    if len(sys.argv) > 1:
        if sys.argv[1] == "--status":
            print(json.dumps(get_git_status(), ensure_ascii=False))
        elif sys.argv[1] == "--commit" and len(sys.argv) > 2:
            msg = sys.argv[2]
            print(json.dumps(do_commit(msg), ensure_ascii=False))
    else:
        print(json.dumps(get_git_status(), ensure_ascii=False))

if __name__ == "__main__":
    main()
