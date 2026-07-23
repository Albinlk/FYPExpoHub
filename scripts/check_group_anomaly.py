import openpyxl

wb = openpyxl.load_workbook(r'D:\Downloads\(LATEST) CSP650-DewanSeminar-ListName-Layout (5).xlsx', data_only=True)
ws = wb['CS230 - List Name']

print('Rows where Group column is "Group" or empty/odd:')
for row in ws.iter_rows(min_row=4, values_only=True):
    vals = [v for v in row]
    if len(vals) < 8:
        continue
    group = str(vals[2]).strip() if vals[2] else ''
    title = str(vals[5]).strip() if vals[5] else ''
    if title and title != 'None' and group in ('Group', '', 'None'):
        print(f'  Row: no={vals[0]}, group={repr(vals[2])}, student={vals[4]}, title={str(title)[:60]}')
