with open(r'D:\MobileAppDev\FYPExpoHub\scripts\populate_projects.sql', encoding='utf-8') as f:
    content = f.read()

parts = content.split('VALUES\n', 1)
header = parts[0] + 'VALUES\n'
values = [l for l in parts[1].strip().split('\n') if l.strip()]

batch_size = 50
batches = []
for i in range(0, len(values), batch_size):
    batch = values[i:i+batch_size]
    # Fix last row comma to semicolon
    batch_sql = header
    for j, v in enumerate(batch):
        if i + j == len(values) - 1:
            v = v.rstrip(',') + ';'
        batch_sql += v + '\n'
    batches.append(batch_sql)

for i, batch in enumerate(batches):
    path = rf'D:\MobileAppDev\FYPExpoHub\scripts\batch_{i:02d}.sql'
    with open(path, 'w', encoding='utf-8') as f:
        f.write(batch)
    print(f'Batch {i}: {batch.count(chr(10))} rows -> {path}')

print(f'\nTotal: {len(batches)} batches, {len(values)} rows')
