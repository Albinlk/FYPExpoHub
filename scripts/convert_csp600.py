import openpyxl, csv, re

wb = openpyxl.load_workbook(r'C:\Users\l_alb\Downloads\JADUAL CSP600 MAC 2026 V2.xlsx', data_only=True)

rows = []
for sheet_name in wb.sheetnames:
    ws = wb[sheet_name]
    for row in ws.iter_rows(min_row=5, values_only=True):
        if row[0] is not None and isinstance(row[0], (int, float)):
            no = row[0]
            time_slot = row[1]
            student_id = row[2]
            name = row[3]
            title = row[4]
            supervisor = row[5]
            examiner = row[6]
            date_label = sheet_name

            title_str = str(title).strip() if title else ''
            if title_str.startswith('=UPPER('):
                m = re.search(r'"([^"]+)"', title_str)
                if m:
                    title_str = m.group(1)

            sup_str = str(supervisor) if supervisor else ''
            sup_str = re.sub(r'^SV\s*-\s*', '', sup_str).strip()

            ex_str = str(examiner) if examiner else ''
            ex_str = re.sub(r'^EX\s*-\s*', '', ex_str).strip()

            rows.append({
                'title': title_str.upper(),
                'technology_tags': '',
                'supervisor_display_name': sup_str,
                'programme_code': 'CS600',
                'short_description': title_str.upper(),
                'category': 'Computer Science',
                'team_display_names': str(name).strip().upper() if name else '',
                'student_id': str(int(student_id)) if student_id else '',
                'examiner': ex_str,
                'session': date_label,
                'time_slot': str(time_slot) if time_slot else '',
            })

output_path = r'D:\MobileAppDev\FYPExpoHub\assets\data\csp600-proposals.csv'
with open(output_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=[
        'title', 'technology_tags', 'supervisor_display_name',
        'programme_code', 'short_description', 'category',
        'team_display_names', 'student_id', 'examiner',
        'session', 'time_slot',
    ])
    writer.writeheader()
    writer.writerows(rows)

print(f'Written {len(rows)} rows')
for r in rows[:3]:
    print(f"  {r['title'][:70]}")
    print(f"  SV: {r['supervisor_display_name']} | Session: {r['session']}")
