import xml.etree.ElementTree as ET
import os
import json
import urllib.parse

def get_recent_files():
    xbel_path = os.path.expanduser('~/.local/share/recently-used.xbel')
    if not os.path.exists(xbel_path):
        return []
    try:
        tree = ET.parse(xbel_path)
        root = tree.getroot()
        items = []
        for bookmark in root.findall('.//{http://www.freedesktop.org/standards/desktop-bookmarks}bookmark'):
            href = bookmark.attrib.get('href', '')
            if href.startswith('file://'):
                path = urllib.parse.unquote(href[7:])
                if os.path.exists(path) and os.path.isfile(path):
                    items.append((os.path.getmtime(path), path))
        items.sort(reverse=True)
        # Keep unique files
        seen = set()
        unique_items = []
        for mtime, path in items:
            if path not in seen:
                seen.add(path)
                unique_items.append({"name": os.path.basename(path), "path": path})
            if len(unique_items) >= 6:
                break
        return unique_items
    except Exception:
        return []

def get_recent_projects():
    projects_dir = os.path.expanduser('~/Projects')
    if not os.path.exists(projects_dir):
        return []
    try:
        subdirs = [os.path.join(projects_dir, d) for d in os.listdir(projects_dir) if os.path.isdir(os.path.join(projects_dir, d))]
        subdirs.sort(key=os.path.getmtime, reverse=True)
        return [{"name": os.path.basename(d), "path": d} for d in subdirs[:6]]
    except Exception:
        return []

if __name__ == '__main__':
    data = {
        "files": get_recent_files(),
        "projects": get_recent_projects()
    }
    print(json.dumps(data))
