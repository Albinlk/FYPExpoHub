import re
with open('lib/core/data/excel_data.dart', 'r') as f:
    content = f.read()

projects_to_feature = [
    'proj-cs230-004', 'proj-cs230-005', 'proj-cs251-096',
    'proj-cs253-161', 'proj-cs255-255', 'proj-cs266-308'
]

for pid in projects_to_feature:
    idx = content.find('"id": \'' + pid + '\'')
    if idx >= 0:
        snippet = content[idx:idx+1500]
        feat_idx = snippet.find('"featured": false')
        if feat_idx >= 0:
            line_num = content[:idx+feat_idx].count('\n') + 1
            print(f'{pid}: featured at line {line_num}')
        else:
            print(f'{pid}: featured not found in block')
    else:
        print(f'{pid}: not found in file')
