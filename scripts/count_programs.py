import openpyxl
from collections import OrderedDict

wb = openpyxl.load_workbook(r'D:\Downloads\(LATEST) CSP650-DewanSeminar-ListName-Layout (5).xlsx', data_only=True)

sheet_map = OrderedDict([
    ('CS230 - List Name', 'CS230'),
    ('CS251 - List Name', 'CS251'),
    ('CS253 - List Name', 'CS253'),
    ('LATEST CS255 - List Name', 'CS255'),
    ('CS266 - List Name', 'CS266'),
])

programs = {}
for sheet_name, course in sheet_map.items():
    ws = wb[sheet_name]
    for row in ws.iter_rows(min_row=4, values_only=True):
        vals = [v for v in row]
        if len(vals) < 8:
            continue
        no = vals[0]
        group = str(vals[2]).strip() if vals[2] else ''
        title = str(vals[5]).strip() if vals[5] else ''
        if not title or title == 'None':
            continue
        try:
            no_int = int(float(str(no)))
        except (ValueError, TypeError):
            continue
        if group in ('Group', '') or not group:
            continue
        if group not in programs:
            programs[group] = {'course': course, 'count': 0}
        programs[group]['count'] += 1

print('Academic Programs (Group column):')
for prog in sorted(programs.keys()):
    info = programs[prog]
    cnt = info['count']
    crs = info['course']
    print(f'  {prog}  ({crs})  - {cnt} students')

print(f'\nTotal unique programme codes: {len(programs)}')

courses = set()
for info in programs.values():
    courses.add(info['course'])
print(f'Unique courses: {len(courses)} - {sorted(courses)}')
