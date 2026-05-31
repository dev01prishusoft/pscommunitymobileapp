import os
import re

lib_dir = r"c:\flutter_apps\pscommunitymobileapp\lib"

# Matches: IconButton( ... icon: Icon(Icons.xyz), ... )
# We want to insert tooltip: 'xyz',
icon_regex = re.compile(r"IconButton\((.*?)(?:\s*)icon:\s*Icon\s*\(\s*Icons\.([a-zA-Z0-9_]+)[^)]*\)(.*?)\)", re.DOTALL)

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # If already contains tooltip in the file, we might skip or just be careful.
    # Actually it's easier to just do a simple replacement if tooltip is not in the match.
    
    def repl(m):
        full_match = m.group(0)
        before = m.group(1)
        icon_name = m.group(2)
        after = m.group(3)
        
        if 'tooltip:' in full_match:
            return full_match
            
        # Format the tooltip name
        tooltip_name = icon_name.replace('_', ' ').title()
        
        # reconstruct
        return f"IconButton({before}tooltip: '{tooltip_name}',\nicon: Icon(Icons.{icon_name}){after})"

    new_content = icon_regex.sub(repl, content)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Done")
