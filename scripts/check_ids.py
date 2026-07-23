import re
with open('lib/core/data/excel_data.dart', 'r') as f:
    content = f.read()
pattern = r'"id":\s*\'proj-([^\']+)\''
matches = re.findall(pattern, content)
courses = {}
for pid in matches:
    course = pid.split('-')[0]
    num = pid.split('-')[1]
    if course not in courses:
        courses[course] = {'first': num, 'last': num}
    courses[course]['last'] = num
for c in sorted(courses):
    info = courses[c]
    print(f'{c}: {info["first"]} -> {info["last"]}')
print(f'Total: {len(matches)}')
