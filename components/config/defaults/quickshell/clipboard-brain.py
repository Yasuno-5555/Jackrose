#!/usr/bin/env python3

import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

CACHE_DIR = Path("/tmp/clipboard-brain")
STORE_PATH = Path.home() / ".local/share/jackrose/clipboard-history.json"
DOWNLOADS_DIR = Path.home() / "Downloads"
MAX_ITEMS = 50

CACHE_DIR.mkdir(parents=True, exist_ok=True)
STORE_PATH.parent.mkdir(parents=True, exist_ok=True)


def has_cliphist():
    return shutil.which("cliphist") is not None


def run_capture(command, text=False):
    try:
        return subprocess.run(
            command,
            capture_output=True,
            text=text,
            check=True,
        )
    except Exception:
        return None


def load_store():
    if not STORE_PATH.exists():
        return []
    try:
        data = json.loads(STORE_PATH.read_text(encoding="utf-8"))
        if isinstance(data, list):
            return data
    except Exception:
        pass
    return []


def save_store(history):
    STORE_PATH.write_text(
        json.dumps(history[:MAX_ITEMS], ensure_ascii=False),
        encoding="utf-8",
    )


def get_cliphist_list():
    res = run_capture(["cliphist", "list"], text=True)
    if res is None:
        return []
    return [line for line in res.stdout.strip().split("\n") if line.strip()]


def decode_cliphist_item(item_id, is_binary):
    if is_binary:
        out_path = CACHE_DIR / f"{item_id}.png"
        if not out_path.exists():
            try:
                with out_path.open("wb") as handle:
                    subprocess.run(["cliphist", "decode", item_id], stdout=handle, check=True)
            except Exception:
                return None
        return str(out_path)

    res = run_capture(["cliphist", "decode", item_id])
    if res is None:
        return None
    return res.stdout.decode("utf-8", errors="ignore")


def get_plain_clipboard():
    res = run_capture(["wl-paste", "--no-newline", "--type", "text"])
    if res is None:
        return ""
    return res.stdout.decode("utf-8", errors="ignore").replace("\x00", "").strip()


def preview_text(content):
    collapsed = " ".join(content.split())
    return collapsed[:160]


def classify_content(content, is_binary):
    if is_binary:
        return "Image"

    cleaned = content.strip()
    if not cleaned:
        return "Text"

    if re.match(r"^https?://[^\s/$.?#].[^\s]*$", cleaned):
        return "URL"

    expanded = os.path.expanduser(cleaned)
    if (expanded.startswith("/") or os.path.isabs(expanded)) and os.path.exists(expanded):
        return "File path"

    lines = content.split("\n")
    code_keywords = [
        r"\bdef\s+\w+\(",
        r"\bfunction\s+\w*\(",
        r"\bclass\s+\w+",
        r"\bimport\s+[\w\s,]+",
        r"#include\s+<",
        r"\bconst\s+\w+\s*=",
        r"\blet\s+\w+\s*=",
        r"\bvar\s+\w+\s*=",
        r"\bif\s*\(.*\)\s*\{",
        r"\bpublic\s+class\s+",
        r"\bpackage\s+\w+",
        r"import\s+react",
    ]
    is_code = False
    if len(lines) > 2:
        indent_lines = sum(1 for line in lines if line.startswith("    ") or line.startswith("\t"))
        if indent_lines > 0.3 * len(lines):
            is_code = True
    if not is_code:
        for keyword in code_keywords:
            if re.search(keyword, content):
                is_code = True
                break
    if is_code:
        return "Code"

    return "Text"


def build_cliphist_history():
    history = []
    for line in get_cliphist_list()[:MAX_ITEMS]:
        parts = line.split("\t", 1)
        if len(parts) < 2:
            continue
        item_id, preview = parts
        is_binary = "[[ binary data " in preview
        content = decode_cliphist_item(item_id, is_binary)
        if content is None:
            continue
        history.append(
            {
                "id": item_id,
                "preview": preview[:160],
                "category": classify_content(content, is_binary),
                "content": content,
                "backend": "cliphist",
            }
        )
    return history


def build_fallback_history():
    history = load_store()
    clean = []
    for item in history:
        if not isinstance(item, dict):
            continue
        if "id" not in item or "content" not in item:
            continue
        item.setdefault("preview", preview_text(item["content"]))
        item.setdefault("category", classify_content(item["content"], False))
        item["backend"] = "fallback"
        clean.append(item)
    if clean != history:
        save_store(clean)
    return clean


def emit_history():
    history = build_cliphist_history() if has_cliphist() else build_fallback_history()
    return json.dumps(history, ensure_ascii=False)


def append_fallback_item(content):
    cleaned = content.strip()
    if not cleaned:
        return build_fallback_history()

    history = [item for item in build_fallback_history() if item.get("content") != cleaned]
    history.insert(
        0,
        {
            "id": str(int(time.time() * 1000)),
            "preview": preview_text(cleaned),
            "category": classify_content(cleaned, False),
            "content": cleaned,
            "backend": "fallback",
        },
    )
    save_store(history)
    return history[:MAX_ITEMS]


def notify(message):
    try:
        subprocess.run(["notify-send", "Jackrose", message], check=False)
    except Exception:
        pass


def copy_item(item_id):
    if has_cliphist():
        try:
            decoded = subprocess.run(["cliphist", "decode", item_id], capture_output=True, check=True)
            subprocess.run(["wl-copy"], input=decoded.stdout, check=True)
            return True
        except Exception:
            return False

    for item in build_fallback_history():
        if item.get("id") == item_id:
            try:
                subprocess.run(["wl-copy"], input=item.get("content", ""), text=True, check=True)
                return True
            except Exception:
                return False
    return False


def save_item(item_id, category):
    if has_cliphist():
        try:
            subprocess.run(
                ["python3", str(Path(__file__).with_name("save-clip.py")), item_id, category],
                check=False,
            )
            return True
        except Exception:
            return False

    for item in build_fallback_history():
        if item.get("id") != item_id:
            continue
        DOWNLOADS_DIR.mkdir(parents=True, exist_ok=True)
        out_path = DOWNLOADS_DIR / f"clip_{time.strftime('%Y%m%d_%H%M%S')}.txt"
        out_path.write_text(item.get("content", ""), encoding="utf-8")
        notify(f"Saved to {out_path}")
        return True
    return False


def menu():
    history = build_cliphist_history() if has_cliphist() else build_fallback_history()
    if not history:
        notify("Clipboard history is empty.")
        return 1

    entries = []
    for index, item in enumerate(history, start=1):
        entries.append(f"{index:02d} [{item.get('category', 'Text')}] {item.get('preview', '')}")

    try:
        selected = subprocess.run(
            ["fuzzel", "--dmenu", "--prompt", "Clipboard ", "--width", "60"],
            input="\n".join(entries),
            text=True,
            capture_output=True,
            check=True,
        ).stdout.strip()
    except Exception:
        return 1

    if not selected:
        return 0

    try:
        picked_index = int(selected.split(" ", 1)[0]) - 1
    except Exception:
        return 1

    if picked_index < 0 or picked_index >= len(history):
        return 1

    if copy_item(history[picked_index]["id"]):
        notify("Copied to clipboard.")
        return 0
    return 1


def watch():
    if has_cliphist():
        last_payload = ""
        while True:
            payload = emit_history()
            if payload != last_payload:
                print(payload, flush=True)
                last_payload = payload
            time.sleep(1.0)
        return

    print(emit_history(), flush=True)
    last_seen = get_plain_clipboard()
    while True:
        current = get_plain_clipboard()
        if current and current != last_seen:
            last_seen = current
            print(json.dumps(append_fallback_item(current), ensure_ascii=False), flush=True)
        time.sleep(1.0)


def main():
    args = sys.argv[1:]
    if not args:
        print(emit_history())
        return

    if args[0] == "--watch":
        watch()
        return

    if args[0] == "--menu":
        raise SystemExit(menu())

    if args[0] == "copy" and len(args) >= 2:
        raise SystemExit(0 if copy_item(args[1]) else 1)

    if args[0] == "save" and len(args) >= 3:
        raise SystemExit(0 if save_item(args[1], args[2]) else 1)

    print(emit_history())


if __name__ == "__main__":
    main()
