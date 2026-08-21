import re, uuid, json, os

projects = []
with open(r'D:\MobileAppDev\FYPExpoHub\lib\core\data\excel_data.dart', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
current = {}
in_project = False
for line in lines:
    s = line.strip()
    if s.startswith('"id":'):
        if current and 'id' in current and current.get('slug', '').strip().strip("'") != '':
            projects.append(current)
        current = {}
        in_project = True
    if not in_project:
        continue
    m = re.match(r'"([^"]+)"\s*:\s*(.+),?\s*$', s)
    if m:
        current[m.group(1)] = m.group(2).strip().rstrip(',')
if current and 'id' in current and current.get('slug', '').strip().strip("'") != '':
    projects.append(current)

event_id = '1977e782-430c-5f3f-a6c7-359f74650691'

def sv(v):
    if v is None or v == 'null':
        return 'NULL'
    s = str(v).strip()
    if s.startswith("'") and s.endswith("'"):
        s = s[1:-1]
    s = s.replace("'", "''")
    s = s.replace("\\", "")
    return f"'{s}'"

def sl(v):
    items = re.findall(r"'([^']*)'", str(v))
    cleaned = [i.replace("\\", "") for i in items]
    return json.dumps(cleaned)

def sb(v):
    return 'true' if str(v).strip() == 'true' else 'false'

# Get already-inserted IDs
print("Getting existing IDs...")
import subprocess
# We'll use ON CONFLICT DO NOTHING so duplicates are safe

rows = []
for p in projects:
    pid = str(uuid.uuid5(uuid.NAMESPACE_URL, p.get('id', '')))
    vals = (
        f"({sv(pid)}, {sv(event_id)}, "
        f"{sv(p.get('slug', ''))}, {sv(p.get('title', ''))}, "
        f"{sv(p.get('matric_id', 'null'))}, {sv(sl(p.get('team_display_names', '[]')))}, "
        f"{sv(p.get('programme_code', ''))}, {sv(p.get('programme_name', ''))}, "
        f"{sv(p.get('short_description', ''))}, {sv(p.get('category', ''))}, "
        f"'{sl(p.get('technology_tags', '[]'))}', '{sl(p.get('team_display_names', '[]'))}', "
        f"{sv(p.get('supervisor_display_name', ''))}, {sv(p.get('examiner_display_name', 'null'))}, "
        f"{sv(p.get('booth_number', 'null'))}, {sv(p.get('booth_zone', 'null'))}, "
        f"{sv(p.get('presentation_day', 'null'))}, "
        f"{sv(p.get('demo_url', 'null'))}, {sv(p.get('video_url', 'null'))}, "
        f"{sv(p.get('repository_url', 'null'))}, "
        f"{sv(p.get('cover_image_url', ''))}, {sb(p.get('featured', 'false'))}, "
        f"{sb(p.get('calon_industri', 'false'))}, "
        f"{sv(p.get('publication_status', 'published'))}, now(), now())"
    )
    rows.append(vals)

header = (
    "INSERT INTO projects "
    "(id, event_id, slug, title, matric_id, team_display_name, programme_code, "
    "programme_name, short_description, category, tech_tags, student_team, "
    "supervisor_display_name, examiner_display_name, booth_number, booth_zone, "
    "presentation_day, demo_url, video_url, repository_url, cover_image_url, "
    "featured, industry_candidate, publication_status, created_at, updated_at) "
    "VALUES\n"
)

# Write 15-row batches with ON CONFLICT DO NOTHING
batch_size = 15
out_dir = r'D:\MobileAppDev\FYPExpoHub\scripts\clean_batches'
os.makedirs(out_dir, exist_ok=True)

batch_num = 0
for i in range(0, len(rows), batch_size):
    batch = rows[i:i + batch_size]
    batch_sql = header
    for j, v in enumerate(batch):
        v = v.rstrip(',') + ','
        batch_sql += v + '\n'
    # Replace last comma with semicolon and add ON CONFLICT
    batch_sql = batch_sql.rstrip(',\n') + ' ON CONFLICT (id) DO NOTHING;\n'
    path = os.path.join(out_dir, f'batch_{batch_num:03d}.sql')
    with open(path, 'w', encoding='utf-8') as f:
        f.write(batch_sql)
    batch_num += 1

print(f'Generated {batch_num} clean batches ({len(rows)} rows)')
