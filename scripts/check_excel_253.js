const XLSX = require('xlsx');
const path = 'D:\\Downloads\\Senarai Calon Industri OGOS 2026 FYP EXHIBITION.xlsx';
const wb = XLSX.readFile(path);
console.log('Sheets:', wb.SheetNames);
for (const sn of wb.SheetNames) {
  console.log(`\n=== ${sn} ===`);
  const rows = XLSX.utils.sheet_to_json(wb.Sheets[sn], { header: 1, defval: '' });
  for (let i = 0; i < rows.length; i++) {
    const r = rows[i];
    const matricRaw = r[3];
    if (matricRaw !== undefined && matricRaw !== null && matricRaw !== '') {
      const cleaned = String(matricRaw).replace(/\.0+$/, '').trim();
      console.log(`Row ${i}: [${r[0]}] booth=${r[1]} group=${r[2]} matric='${matricRaw}' cleaned='${cleaned}' name=${r[4]}`);
    }
  }
}
