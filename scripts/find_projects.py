import re
with open('lib/core/data/excel_data.dart', 'r') as f:
    content = f.read()

id_pattern = re.compile(r'"id":\s*\'([^\']+)\'')
title_pattern = re.compile(r'"title":\s*\'([^\']+)\'')

id_matches = id_pattern.findall(content)
title_matches = title_pattern.findall(content)

print(f"Found {len(id_matches)} IDs, {len(title_matches)} titles")

targets = {'proj-cs230-004', 'proj-cs230-005', 'proj-cs251-096', 
           'proj-cs253-161', 'proj-cs255-240', 'proj-cs255-242',
           'proj-cs266-308', 'proj-cs266-310'}

for i, pid in enumerate(id_matches):
    if pid in targets and i < len(title_matches):
        print(f'{pid}: {title_matches[i][:100]}')
