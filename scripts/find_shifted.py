import re
with open('lib/core/data/excel_data.dart', 'r') as f:
    content = f.read()

id_pattern = re.compile(r'"id":\s*\'([^\']+)\'')
title_pattern = re.compile(r'"title":\s*\'([^\']+)\'')

id_matches = id_pattern.findall(content)
title_matches = title_pattern.findall(content)

for i, pid in enumerate(id_matches):
    title = title_matches[i] if i < len(title_matches) else ''
    if 'DRONE' in title.upper() and 'FANET' in title.upper():
        print(f'{pid}: {title[:100]}')
    if 'ATTENDANCE SYSTEM' in title.upper() and 'QR' in title.upper():
        print(f'{pid}: {title[:100]}')
