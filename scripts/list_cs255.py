import re

with open('lib/core/data/excel_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find all CS255 project IDs
ids = re.findall(r"'proj-cs255-(\d+)", content)
print(f"CS255 project IDs in data: {len(ids)}")

names_list = []
for pid in sorted(ids):
    idx = content.find(f"proj-cs255-{pid}")
    if idx > 0:
        # Find the block
        start = content.rfind('{', 0, idx)
        end = content.find('},', idx) + 1
        block = content[start:end]
        # Find team_display_names - handles escaped quotes
        nm = re.search(r"'team_display_names':\s*\[\\'([^\\]]*(?:\\\\'[^\\]]*)*)\\'\]", block)
        # Actually let me just extract raw
        nm = re.search(r"'team_display_names':\s*\[(.+?)\]", block, re.DOTALL)
        if nm:
            raw = nm.group(1).strip()
            # Replace escaped quotes, extract name
            name = raw.replace("\\'", "'").strip("' ")
            names_list.append(name)

print(f"\nCS255 student names (68 total):")
for i, name in enumerate(names_list, 1):
    print(f"{i}. {name}")