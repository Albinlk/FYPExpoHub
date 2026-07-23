import re
with open('lib/core/data/excel_data.dart', 'r') as f:
    content = f.read()

projects_to_feature = [
    'proj-cs230-004', 'proj-cs230-005', 'proj-cs251-096',
    'proj-cs253-161', 'proj-cs255-255', 'proj-cs266-308'
]

for pid in projects_to_feature:
    pattern = f'"id": \'{pid}\''
    idx = content.find(pattern)
    if idx >= 0:
        snippet = content[idx:idx+1500]
        old_feat = '"featured": false'
        new_feat = '"featured": true'
        feat_idx = snippet.find(old_feat)
        if feat_idx >= 0:
            global_idx = idx + feat_idx
            before = content[:global_idx]
            after = content[global_idx + len(old_feat):]
            content = before + new_feat + after
            line_num = content[:global_idx].count('\n') + 1
            print(f'{pid}: marked as featured (line ~{line_num})')
        else:
            print(f'{pid}: featured field not found')
    else:
        print(f'{pid}: not found')

with open('lib/core/data/excel_data.dart', 'w') as f:
    f.write(content)

print('\nDone')
