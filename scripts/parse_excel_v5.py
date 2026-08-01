import openpyxl
import re
from collections import OrderedDict

EXCEL_PATH = r'D:\Downloads\StudentListName.xlsx'
OUTPUT_PATH = r'D:\MobileAppDev\FYPExpoHub\lib\core\data\excel_data.dart'

COURSE_CATEGORY = {
    'CS230': ('Computer Science', 'CS230'),
    'CS253': ('Cybersecurity', 'CS253'),
    'CS251': ('Networking & Communication', 'CS251'),
    'CS255': ('Network Security & Infrastructure', 'CS255'),
    'CS266': ('Software Engineering & Applications', 'CS266'),
}

SHEET_COURSE_MAP = OrderedDict([
    ('CS230 - List Name', 'CS230'),
    ('CS251 - List Name', 'CS251'),
    ('CS253 - List Name', 'CS253'),
    ('CS255 - List Name', 'CS255'),
    ('CS266 - List Name', 'CS266'),
])

def clean_matric(val):
    s = str(val).replace('.0', '').strip()
    return s

def sanitize(val):
    s = str(val).strip() if val else ''
    s = s.replace('\n', ' ').replace('\r', ' ').replace("'", "\\'")
    s = ' '.join(s.split())
    return s

DATE_RE = re.compile(r'(\d{1,2})\s+(?:AUG(?:UST)?|OGOS|AGUSTUS)\s+\d{4}', re.IGNORECASE)
MONTH_MAP = {
    'JANUARY': '01', 'FEBRUARY': '02', 'MARCH': '03', 'APRIL': '04',
    'MAY': '05', 'JUNE': '06', 'JULY': '07', 'AUGUST': '08', 'SEPTEMBER': '09',
    'OCTOBER': '10', 'NOVEMBER': '11', 'DECEMBER': '12',
    'OGOS': '08', 'AGUSTUS': '08',
}


def parse_list_sheet(ws, course_code):
    global current_day_label, current_date_str
    category, prog_prefix = COURSE_CATEGORY[course_code]
    projects = []
    booths = set()

    for row in ws.iter_rows(min_row=1, values_only=True):
        vals = [v for v in row] if row else []
        if not vals or len(vals) < 1:
            continue
        cell = str(vals[0]).strip() if vals[0] is not None else ''

        m = DATE_RE.search(cell)
        if m:
            day_num = int(m.group(1))
            if day_num == 6:
                current_day_label = 'Day 1'
                current_date_str = '06 Aug 2026'
            elif day_num == 7:
                current_day_label = 'Day 2'
                current_date_str = '07 Aug 2026'

        if len(vals) < 8:
            continue
        no = vals[0]
        booth_raw = vals[1]
        group = sanitize(vals[2])
        matric_raw = vals[3]
        student_name = sanitize(vals[4])
        title = sanitize(vals[5])
        supervisor = sanitize(vals[6])
        examiner = sanitize(vals[7])

        if not student_name or student_name == 'None':
            continue
        if not title or title == 'None':
            title = 'TBD (Project Title Pending)'

        try:
            no_int = int(float(no))
        except (ValueError, TypeError):
            continue

        booth_number = str(booth_raw).strip() if booth_raw else ''
        matric_id = clean_matric(matric_raw) if matric_raw else ''

        zone = booth_number.split('-')[0] if '-' in booth_number else ''

        if booth_number:
            booths.add(booth_number)

        projects.append({
            'no': no_int,
            'booth_number': booth_number,
            'zone': zone,
            'group': group,
            'matric_id': matric_id,
            'student_name': student_name,
            'title': title,
            'supervisor': supervisor,
            'examiner': examiner,
            'course_code': course_code,
            'category': category,
            'prog_prefix': prog_prefix,
            'presentation_day': f'{current_day_label} - {current_date_str}',
        })

    return projects, sorted(booths)


CALON_INDUSTRI_MATRICS = {
    # CS230
    '2023444376', '2024699546', '2024963653', '2023885286',
    '2023443658', '2023214052', '2024425838', '2023277304',
    '2023405938', '2023217236',
    # CS251
    '2023298712', '2023851666', '2023867346', '2023884362',
    '2023601134', '2023600384', '2023479866', '2024857584',
    '2023899266', '2023217904',
    # CS253
    '2024350455', '2024963455', '2024556797', '2023414808',
    '2024905321', '2023116081', '2023261412', '2023436416',
    '2024905819', '2023415054',
    # CS255
    '2023414614', '2023260244', '2023240232', '2023436724',
    '2023240168', '2023239276', '2023820446', '2023699244',
    '2023674486', '2023260928',
    # CS266
    '2023472522', '2022622854', '2023218022', '2024235476',
    '2024692246', '2023899996', '2023239802', '2023660422',
    '2023436396', '2023410826',
}

_global_counter = 0
current_day_label = 'Day 1'
current_date_str = '06 Aug 2026'

def reset_day_state():
    global current_day_label, current_date_str
    current_day_label = 'Day 1'
    current_date_str = '06 Aug 2026'

def generate_project_id(course_code):
    global _global_counter
    _global_counter += 1
    return f"proj-{course_code.lower()}-{_global_counter:03d}"


def slugify(title):
    s = title.lower()
    s = re.sub(r'[^a-z0-9\s-]', '', s)
    s = re.sub(r'[\s-]+', '-', s).strip('-')
    return s[:80]


def build_projects_dart(all_projects):
    lines = []
    for p in all_projects:
        pid = p['id']
        slug = slugify(p['title'])
        title_esc = p['title']
        student_esc = p['student_name']
        supervisor_esc = p['supervisor']
        examiner_esc = p['examiner']
        group = p['group']
        prog_name = f"{p['course_code']} ({p['category']})"

        lines.append('    {')
        lines.append(f'      "id": \'{pid}\',')
        lines.append(f'      "event_id": \'fskm-fyp-2026\',')
        lines.append(f'      "slug": \'{slug}\',')
        lines.append(f'      "title": \'{title_esc}\',')
        lines.append(f'      "matric_id": \'{p["matric_id"]}\',')
        lines.append(f'      "programme_code": \'{group}\',')
        lines.append(f'      "programme_name": \'{prog_name}\',')
        lines.append(f'      "short_description": \'Final Year Project - {p["category"]}\',')
        lines.append(f'      "category": \'{p["category"]}\',')
        lines.append(f'      "technology_tags": ["FYP"],')
        lines.append(f'      "booth_id": \'booth-{p["booth_number"]}\',')
        lines.append(f'      "booth_number": \'{p["booth_number"]}\',')
        lines.append(f'      "booth_zone": \'{p["zone"]}\',')
        lines.append(f'      "cover_image_url": \'assets/images/project_placeholder.jpg\',')
        lines.append(f'      "poster_url": null,')
        lines.append(f'      "team_display_names": [\'{student_esc}\'],')
        lines.append(f'      "supervisor_display_name": \'{supervisor_esc}\',')
        lines.append(f'      "examiner_display_name": \'{examiner_esc}\',')
        lines.append(f'      "demo_url": null,')
        lines.append(f'      "video_url": null,')
        lines.append(f'      "repository_url": null,')
        calon = 'true' if p['matric_id'] in CALON_INDUSTRI_MATRICS else 'false'
        lines.append(f'      "featured": false,')
        lines.append(f'      "calon_industri": {calon},')
        lines.append(f'      "publication_status": \'published\',')
        lines.append(f'      "created_at": DateTime(2026, 07, 01),')
        lines.append(f'      "updated_at": DateTime(2026, 07, 01),')
        lines.append(f'      "published_at": DateTime(2026, 07, 01),')
        lines.append(f'      "presentation_day": \'{p["presentation_day"]}\',')
        lines.append('    },')
    return lines


def build_booths_dart(all_booths):
    lines = []
    for b in all_booths:
        booth_num = b['booth_number']
        zone = booth_num.split('-')[0] if '-' in booth_num else ''
        lines.append('    {')
        lines.append(f'      "id": \'booth-{booth_num}\',')
        lines.append(f'      "event_id": \'fskm-fyp-2026\',')
        lines.append(f'      "booth_number": \'{booth_num}\',')
        lines.append(f'      "zone": \'{zone}\',')
        lines.append(f'      "floor": \'Level 1\',')
        lines.append(f'      "location_note": \'Zon {zone}\',')
        lines.append(f'      "status": \'active\',')
        lines.append(f'      "publication_status": \'published\',')
        lines.append(f'      "created_at": DateTime(2026, 07, 01),')
        lines.append(f'      "updated_at": DateTime(2026, 07, 01),')
        lines.append(f'      "published_at": DateTime(2026, 07, 01),')
        lines.append(f'      "presentation_day": \'{b["presentation_day"]}\',')
        lines.append('    },')
    return lines


def main():
    wb = openpyxl.load_workbook(EXCEL_PATH, data_only=True)

    all_projects = []
    booth_map = OrderedDict()

    for sheet_name, course_code in SHEET_COURSE_MAP.items():
        ws = wb[sheet_name]
        reset_day_state()
        projs, booths = parse_list_sheet(ws, course_code)
        for b in booths:
            zone = b.split('-')[0] if '-' in b else ''
            if b not in booth_map:
                booth_map[b] = {'booth_number': b, 'zone': zone, 'presentation_day': None}

        for p in projs:
            pid = generate_project_id(course_code)
            p['id'] = pid
            if p['booth_number'] in booth_map and booth_map[p['booth_number']]['presentation_day'] is None:
                booth_map[p['booth_number']]['presentation_day'] = p['presentation_day']
            all_projects.append(p)

    for b in booth_map.values():
        if b['presentation_day'] is None:
            b['presentation_day'] = 'Day 1 - 06 Aug 2026'

    project_count = len(all_projects)
    booth_count = len(booth_map)

    proj_lines = build_projects_dart(all_projects)
    booth_lines = build_booths_dart(booth_map.values())

    # Generate schedule items
    schedule_items = [
        {
            'id': 'sch-slot-1',
            'day': 1,
            'date': 'DateTime(2026, 8, 6)',
            'start_at': '09:00',
            'end_at': '10:30',
            'title': 'Sesi Pembentangan 1',
            'type': 'session',
            'description': 'Sesi pembentangan pertama bagi semua kursus.',
            'venue': 'Blok Kuliah, FSKM',
            'audience': 'Juri & Peserta',
        },
        {
            'id': 'sch-slot-2',
            'day': 1,
            'date': 'DateTime(2026, 8, 6)',
            'start_at': '10:45',
            'end_at': '12:15',
            'title': 'Sesi Pembentangan 2',
            'type': 'session',
            'description': 'Sesi pembentangan kedua.',
            'venue': 'Blok Kuliah, FSKM',
            'audience': 'Juri & Peserta',
        },
        {
            'id': 'sch-slot-3',
            'day': 1,
            'date': 'DateTime(2026, 8, 6)',
            'start_at': '14:00',
            'end_at': '15:30',
            'title': 'Sesi Pembentangan 3',
            'type': 'session',
            'description': 'Sesi pembentangan petang.',
            'venue': 'Blok Kuliah, FSKM',
            'audience': 'Juri & Peserta',
        },
        {
            'id': 'sch-slot-4',
            'day': 2,
            'date': 'DateTime(2026, 8, 7)',
            'start_at': '09:00',
            'end_at': '10:30',
            'title': 'Sesi Pembentangan 4',
            'type': 'session',
            'description': 'Sesi pembentangan hari kedua.',
            'venue': 'Blok Kuliah, FSKM',
            'audience': 'Juri & Peserta',
        },
        {
            'id': 'sch-slot-5',
            'day': 2,
            'date': 'DateTime(2026, 8, 7)',
            'start_at': '10:45',
            'end_at': '12:15',
            'title': 'Sesi Pembentangan 5',
            'type': 'session',
            'description': 'Sesi pembentangan kedua hari kedua.',
            'venue': 'Blok Kuliah, FSKM',
            'audience': 'Juri & Peserta',
        },
        {
            'id': 'sch-slot-6',
            'day': 2,
            'date': 'DateTime(2026, 8, 7)',
            'start_at': '14:00',
            'end_at': '16:00',
            'title': 'Majlis Penutup & Penyampaian Hadiah',
            'type': 'closing',
            'description': 'Majlis penutup dan penyampaian hadiah.',
            'venue': 'Blok Kuliah, FSKM',
            'audience': 'Semua',
        },
    ]

    general_schedule = [
        {
            'id': 'sch-gen-1',
            'date': 'DateTime(2026, 8, 6)',
            'start_at': '08:30',
            'end_at': '09:00',
            'title': 'Pendaftaran Juri & Peserta',
            'venue': 'Blok Kuliah, FSKM',
            'audience': 'Juri & Peserta',
            'description': 'Sesi penyerahan kit pameran dan pendaftaran.',
        },
        {
            'id': 'sch-gen-2',
            'date': 'DateTime(2026, 8, 7)',
            'start_at': '09:00',
            'end_at': '17:00',
            'title': 'FYP Expo 2026 - Hari Terbuka',
            'venue': 'Blok Kuliah, FSKM',
            'audience': 'Awam',
            'description': 'Sesi pembukaan untuk pelawat dan industri.',
        },
    ]

    # Count per course
    course_counts = {}
    for p in all_projects:
        cc = p['course_code']
        course_counts[cc] = course_counts.get(cc, 0) + 1

    print(f"Projects: {project_count}")
    for cc, cnt in sorted(course_counts.items()):
        print(f"  {cc}: {cnt}")
    print(f"Booths: {booth_count}")

    # Write Dart file
    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        f.write('// Auto-generated from Excel parser. Do not edit manually.\n')
        f.write(f'// Generated from: StudentListName.xlsx\n')
        f.write(f'// Total projects: {project_count}, Total booths: {booth_count}\n')
        f.write('\n')
        f.write('class ExcelData {\n')
        f.write('  static const String eventId = "fskm-fyp-2026";\n')
        f.write('\n')
        f.write(f'  static const int projectCount = {project_count};\n')
        f.write('  static List<Map<String, dynamic>> get allProjects => [\n')
        f.write('\n'.join(proj_lines))
        f.write('  ];\n')
        f.write('\n')
        f.write(f'  static const int boothCount = {booth_count};\n')
        f.write('  static List<Map<String, dynamic>> get allBooths => [\n')
        f.write('\n'.join(booth_lines))
        f.write('  ];\n')
        f.write('\n')
        f.write(f'  static const int scheduleCount = {len(schedule_items) + len(general_schedule)};\n')
        f.write('  static List<Map<String, dynamic>> get allScheduleItems => [\n')
        f.write('    // Day 1 (6 Aug 2026) - Session schedule\n')
        for s in schedule_items:
            f.write('    {\n')
            f.write(f'      "id": \'{s["id"]}\',\n')
            f.write(f'      "event_id": \'fskm-fyp-2026\',\n')
            f.write(f'      "date": {s["date"]},\n')
            f.write(f'      "start_at": \'{s["start_at"]}\',\n')
            f.write(f'      "end_at": \'{s["end_at"]}\',\n')
            f.write(f'      "title": \'{s["title"]}\',\n')
            f.write(f'      "type": \'{s["type"]}\',\n')
            f.write(f'      "venue": \'{s["venue"]}\',\n')
            f.write(f'      "audience": \'{s["audience"]}\',\n')
            f.write(f'      "description": \'{s["description"]}\',\n')
            f.write(f'      "visibility": \'public\',\n')
            f.write(f'      "publication_status": \'published\',\n')
            f.write(f'      "created_at": DateTime(2026, 07, 01),\n')
            f.write(f'      "updated_at": DateTime(2026, 07, 01),\n')
            f.write(f'      "published_at": DateTime(2026, 07, 01),\n')
            f.write('    },\n')
        f.write('    // General schedule items\n')
        for s in general_schedule:
            f.write('    {\n')
            f.write(f'      "id": \'{s["id"]}\',\n')
            f.write(f'      "event_id": \'fskm-fyp-2026\',\n')
            f.write(f'      "date": {s["date"]},\n')
            f.write(f'      "start_at": \'{s["start_at"]}\',\n')
            f.write(f'      "end_at": \'{s["end_at"]}\',\n')
            f.write(f'      "title": \'{s["title"]}\',\n')
            f.write(f'      "venue": \'{s["venue"]}\',\n')
            f.write(f'      "audience": \'{s["audience"]}\',\n')
            f.write(f'      "description": \'{s["description"]}\',\n')
            f.write(f'      "visibility": \'public\',\n')
            f.write(f'      "publication_status": \'published\',\n')
            f.write(f'      "created_at": DateTime(2026, 07, 01),\n')
            f.write(f'      "updated_at": DateTime(2026, 07, 01),\n')
            f.write(f'      "published_at": DateTime(2026, 07, 01),\n')
            f.write('    },\n')
        f.write('  ];\n')
        f.write('}\n')

    print(f"\nWritten to {OUTPUT_PATH}")


if __name__ == '__main__':
    main()
