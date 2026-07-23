import re, os

images = {f.replace('.png','') for f in os.listdir('web/project_images') if f.endswith('.png')}

with open('lib/core/data/excel_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

ids_in_data = set(re.findall(r'"id"\s*:\s*\'([^\']+)\'', content))

# Only project IDs (not booth/schedule)
proj_ids_in_data = {i for i in ids_in_data if i.startswith('proj-')}

missing_images = proj_ids_in_data - images
extra_images = images - proj_ids_in_data

print(f'Project images on disk: {len(images)}')
print(f'Project IDs in data: {len(proj_ids_in_data)}')
print(f'Missing images (in data but not on disk): {len(missing_images)}')
if missing_images:
    for m in sorted(missing_images):
        print(f'  MISSING: {m}')
print(f'Extra images (on disk but not in data): {len(extra_images)}')
if extra_images:
    for e in sorted(extra_images):
        print(f'  EXTRA: {e}')
if not missing_images and not extra_images:
    print('All 385 images match!')
