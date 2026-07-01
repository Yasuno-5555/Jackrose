#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import subprocess
from datetime import datetime

if len(sys.argv) < 3:
    sys.exit(1)

item_id = sys.argv[1]
category = sys.argv[2]

now_str = datetime.now().strftime("%Y%m%d-%H%M%S")

if category == "Image":
    save_dir = os.path.expanduser("~/Pictures/SavedClips")
    os.makedirs(save_dir, exist_ok=True)
    out_path = os.path.join(save_dir, f"clip_{now_str}.png")
    
    try:
        with open(out_path, "wb") as f:
            subprocess.run(["cliphist", "decode", item_id], stdout=f, check=True)
        subprocess.run(["notify-send", "Clipboard Brain", f"Image saved successfully to:\n{out_path}"])
    except Exception as e:
        subprocess.run(["notify-send", "Clipboard Brain Error", f"Failed to save image:\n{str(e)}"])

else:
    save_dir = os.path.expanduser("~/Downloads/SavedClips")
    os.makedirs(save_dir, exist_ok=True)
    
    ext = ".txt"
    if category == "Code":
        ext = ".code"
    elif category == "URL":
        ext = ".url.txt"
    elif category == "File path":
        ext = ".path.txt"
        
    out_path = os.path.join(save_dir, f"clip_{now_str}{ext}")
    
    try:
        res = subprocess.run(["cliphist", "decode", item_id], capture_output=True, check=True)
        content = res.stdout
        
        with open(out_path, "wb") as f:
            f.write(content)
            
        subprocess.run(["notify-send", "Clipboard Brain", f"Content saved successfully to:\n{out_path}"])
    except Exception as e:
        subprocess.run(["notify-send", "Clipboard Brain Error", f"Failed to save content:\n{str(e)}"])
